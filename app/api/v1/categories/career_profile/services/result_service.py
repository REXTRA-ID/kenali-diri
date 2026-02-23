from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import Optional

from app.db.models.user import User
from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from app.api.v1.categories.career_profile.models.riasec import RIASECResult, RIASECCode
from app.api.v1.categories.career_profile.models.result import CareerRecommendation, FitCheckResult
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession
from app.api.v1.categories.career_profile.services.fit_check_classifier import build_fit_check_explanation
from app.api.v1.categories.career_profile.services.personality_service import PersonalityService

# === PERBAIKAN TEMUAN 3: Gunakan get_redis_client dari core.redis (async-compatible) ===
from app.core.redis import get_redis_client

RIASEC_LETTER_NAMES = {
    "R": "Realistic", "I": "Investigative", "A": "Artistic",
    "S": "Social", "E": "Enterprising", "C": "Conventional",
}

class ResultService:

    def __init__(self, db: Session):
        self.db = db

    # === PERBAIKAN TEMUAN 13: Tambah cek session.status == "completed" ===
    def _get_validated_session(
        self, session_token: str, user: User
    ) -> CareerProfileTestSession:
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()
        if not session or str(session.user_id) != str(user.id):
            raise HTTPException(status_code=404, detail="Sesi tidak ditemukan atau bukan milik user ini")
        if session.status != "completed":
            raise HTTPException(
                status_code=400,
                detail="Sesi belum selesai. Selesaikan tes terlebih dahulu.",
            )
        return session

    # ── GET RECOMMENDATION RESULT ─────────────────────────────────────────────

    # === PERBAIKAN TEMUAN 4: Rewrite sesuai brief — response ter-flatten dan ter-enrich ===
    async def get_recommendation_result(
        self, session_token: str, user: User
    ) -> dict:
        session = self._get_validated_session(session_token, user)
        if session.test_goal != "RECOMMENDATION":
            raise HTTPException(status_code=400, detail="Sesi ini bukan tipe RECOMMENDATION")

        # Ambil career_recommendations
        rec = self.db.query(CareerRecommendation).filter(
            CareerRecommendation.test_session_id == session.id
        ).first()
        if not rec:
            raise HTTPException(status_code=404, detail="Data rekomendasi belum tersedia")

        # Ambil RIASEC result + kode
        riasec_result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()
        riasec_code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == riasec_result.riasec_code_id
        ).first()

        # Ambil kandidat profesi
        candidate_record = self.db.query(IkigaiCandidateProfession).filter(
            IkigaiCandidateProfession.test_session_id == session.id
        ).first()
        all_candidates = (
            candidate_record.candidates_data.get("candidates", [])
            if candidate_record else []
        )

        # Ambil nama profesi untuk semua kandidat via tabel relasional
        candidate_ids = [c["profession_id"] for c in all_candidates]
        from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
        prof_repo = ProfessionRepository(self.db)
        profession_names = {p.id: p.title for p in prof_repo.get_by_ids(candidate_ids)}

        MAX_DISPLAY_CANDIDATES = 30
        candidate_names = [
            {"profession_id": cid, "name": profession_names.get(cid, "Unknown")}
            for cid in candidate_ids[:MAX_DISPLAY_CANDIDATES]
        ]

        # Enrich recommended_professions dengan nama profesi
        rec_data = rec.recommendations_data
        enriched_professions = []
        for prof in rec_data.get("recommended_professions", []):
            prof["profession_name"] = profession_names.get(prof["profession_id"], "Unknown")
            enriched_professions.append(prof)

        user_first_name = user.full_name.split()[0] if user.full_name else "Pengguna"
        top_types = [RIASEC_LETTER_NAMES.get(l, l) for l in riasec_code_obj.riasec_code]

        return {
            "session_token":   session_token,
            "user_first_name": user_first_name,
            "test_completed_at": (
                session.completed_at.isoformat() if session.completed_at else None
            ),
            "riasec_summary": {
                "riasec_code":  riasec_code_obj.riasec_code,
                "riasec_title": " – ".join(top_types),
                "top_types":    top_types,
                "total_candidates_found": (
                    candidate_record.total_candidates
                    if candidate_record and candidate_record.total_candidates
                    else len(all_candidates)
                ),
            },
            "candidate_profession_names": candidate_names,
            "ikigai_profile_summary":     rec_data.get("ikigai_profile_summary", {}),
            "recommended_professions":    enriched_professions,
            "points_awarded": None,
        }

    # ── GET FIT CHECK RESULT ──────────────────────────────────────────────────

    # === PERBAIKAN TEMUAN 5: Rewrite — nested fit_check_result, user_riasec, query relasional ===
    def get_fit_check_result(self, session_token: str, user: User) -> dict:
        session = self._get_validated_session(session_token, user)
        if session.test_goal != "FIT_CHECK":
            raise HTTPException(status_code=400, detail="Sesi ini bukan tipe FIT_CHECK")

        # Ambil fit_check_results
        fit_result = self.db.query(FitCheckResult).filter(
            FitCheckResult.test_session_id == session.id
        ).first()
        if not fit_result:
            raise HTTPException(status_code=404, detail="Data fit check belum tersedia")

        # Ambil kode RIASEC user
        riasec_result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()
        user_code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == riasec_result.riasec_code_id
        ).first()

        # Ambil kode RIASEC profesi target
        prof_code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == fit_result.profession_riasec_code_id
        ).first()

        # Ambil nama profesi target via tabel relasional
        from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
        profession = ProfessionRepository(self.db).get_by_id(fit_result.profession_id)

        user_top_types = [RIASEC_LETTER_NAMES.get(l, l) for l in user_code_obj.riasec_code]
        prof_top_types = [RIASEC_LETTER_NAMES.get(l, l) for l in prof_code_obj.riasec_code]
        user_first_name = user.full_name.split()[0] if user.full_name else "Pengguna"

        # Build explanation dengan signature baru (PERBAIKAN TEMUAN 2)
        fit_result_dict = {
            "match_category":       fit_result.match_category,
            "rule_type":            fit_result.rule_type,
            "dominant_letter_same": fit_result.dominant_letter_same,
            "is_adjacent_hexagon":  fit_result.is_adjacent_hexagon,
            "match_score":          float(fit_result.match_score) if fit_result.match_score else None,
        }
        explanation = build_fit_check_explanation(
            fit_result=fit_result_dict,
            user_code=user_code_obj.riasec_code,
            profession_code=prof_code_obj.riasec_code,
        )

        MATCH_LABELS = {"HIGH": "Kecocokan Tinggi", "MEDIUM": "Kecocokan Sedang", "LOW": "Kecocokan Rendah"}
        MATCH_STARS  = {"HIGH": 3, "MEDIUM": 2, "LOW": 1}

        return {
            "session_token":    session_token,
            "user_first_name":  user_first_name,
            "test_completed_at": (
                session.completed_at.isoformat() if session.completed_at else None
            ),
            "user_riasec": {
                "riasec_code":  user_code_obj.riasec_code,
                "riasec_title": " – ".join(user_top_types),
                "top_types":    user_top_types,
            },
            "target_profession": {
                "profession_id": fit_result.profession_id,
                "name":          profession.title if profession else "Unknown",
                "riasec_code":   prof_code_obj.riasec_code,
                "riasec_title":  " – ".join(prof_top_types),
            },
            "fit_check_result": {
                **fit_result_dict,
                "match_label": MATCH_LABELS[fit_result.match_category],
                "match_stars": MATCH_STARS[fit_result.match_category],
                "explanation": explanation,
            },
            "points_awarded": None,
        }

    # ── GET PERSONALITY RESULT ────────────────────────────────────────────────

    # === PERBAIKAN TEMUAN 3, 6, 12: Fix async Redis, tambah 5 field, validasi test_goal ===
    async def get_personality_result(
        self, session_token: str, user: User
    ) -> dict:
        session = self._get_validated_session(session_token, user)

        # === PERBAIKAN TEMUAN 12: Validasi test_goal — shared endpoint tapi hanya untuk tipe dikenal ===
        VALID_GOALS = {"RECOMMENDATION", "FIT_CHECK"}
        if session.test_goal not in VALID_GOALS:
            raise HTTPException(
                status_code=400,
                detail=f"Tab Kepribadian tidak tersedia untuk tipe tes '{session.test_goal}'",
            )

        riasec_result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()
        if not riasec_result:
            raise HTTPException(status_code=404, detail="Data RIASEC tidak ditemukan")

        code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == riasec_result.riasec_code_id
        ).first()

        letters   = list(code_obj.riasec_code)
        top_types = [{"letter": l, "name": RIASEC_LETTER_NAMES.get(l, l)} for l in letters]

        # === PERBAIKAN TEMUAN 3: Gunakan get_redis_client (async-compatible), bukan redis_client sync ===
        redis_client = get_redis_client()
        about_code = await PersonalityService.get_personality_about_text(
            riasec_code=code_obj.riasec_code,
            riasec_title=code_obj.riasec_title,
            riasec_description=code_obj.riasec_description or "",
            redis_client=redis_client,
        )

        # === PERBAIKAN TEMUAN 6: Tambah 5 field dari riasec_codes ===
        # Kolom ini sudah ada di DB dan di model RIASECCode yang diperbaiki (Temuan 7)
        return {
            "session_token":      session_token,
            "riasec_code":        code_obj.riasec_code,
            "riasec_title":       " – ".join([RIASEC_LETTER_NAMES.get(l, l) for l in letters]),
            "top_types":          top_types,
            "about_code":         about_code,
            "strengths":          code_obj.strengths or [],
            "challenges":         code_obj.challenges or [],
            "strategies":         code_obj.strategies or [],
            "interaction_styles": code_obj.interaction_styles or [],
            "work_environments":  code_obj.work_environments or [],
        }
