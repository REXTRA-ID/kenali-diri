# app/api/v1/categories/career_profile/repositories/profession_repo.py

from typing import List, Optional
from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import SQLAlchemyError
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession

# === Model relasional dari brief Jelajah Profesi ===
# Import dari lokasi model Jelajah Profesi yang sudah ada di project
from app.models.profession import Profession
from app.models.profession_activity import ProfessionActivity
from app.models.profession_skill_rel import ProfessionSkillRel
from app.models.profession_tool_rel import ProfessionToolRel
from app.models.profession_career_path import ProfessionCareerPath
from app.models.skill import Skill
from app.models.tool import Tool
from app.api.v1.categories.career_profile.models.riasec import RIASECCode


class ProfessionRepository:
    """
    Repository untuk query data profesi.

    Sumber data:
      - Tabel relasional `professions` + relasi (dari brief Jelajah Profesi)
        → untuk context AI scoring, generate konten Ikigai, narasi rekomendasi
      - Tabel `ikigai_candidate_professions` (JSONB)
        → untuk manajemen kandidat per sesi tes
    """

    def __init__(self, db: Session):
        self.db = db

    # ──────────────────────────────────────────────────────────────────────────
    # PROFESSION CONTEXT QUERIES (untuk pipeline Ikigai)
    # Semua method di bawah query dari tabel relasional — bukan DigitalProfession
    # ──────────────────────────────────────────────────────────────────────────

    def get_profession_contexts_for_ikigai(
        self, profession_ids: List[int]
    ) -> List[dict]:
        """
        Query konteks profesi untuk generate narasi konten display Ikigai (5 kandidat).

        Dipakai oleh: IkigaiService._generate_ikigai_content()

        Data yang diambil:
          - professions: id, name, about_description, riasec_description
          - riasec_codes (via FK riasec_code_id): riasec_code, riasec_title, riasec_description
          - profession_activities: 5 aktivitas teratas (sort_order ASC)
          - profession_skill_rels → skills: 5 hard skill wajib teratas
          - profession_skill_rels → skills: 3 soft skill teratas
          - profession_tool_rels → tools: 4 tool wajib teratas

        Returns:
            List[dict] — setiap dict adalah profession_context siap pakai di prompt AI
        """
        if not profession_ids:
            return []

        try:
            professions = (
                self.db.query(Profession)
                .options(
                    joinedload(Profession.activities),
                    joinedload(Profession.skill_rels).joinedload(ProfessionSkillRel.skill),
                    joinedload(Profession.tool_rels).joinedload(ProfessionToolRel.tool),
                )
                .filter(Profession.id.in_(profession_ids))
                .all()
            )

            # Ambil riasec_code string per profesi via join terpisah
            # (riasec_code_id ada di Profession, tapi relasinya tidak di-declare di model Jelajah Profesi)
            riasec_map = self._get_riasec_map(profession_ids)

            result = []
            for p in professions:
                activities = sorted(p.activities, key=lambda a: a.sort_order)[:5]
                hard_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "hard" and rel.priority == "wajib"
                ][:5]
                soft_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "soft"
                ][:3]
                tools = [
                    rel.tool.name
                    for rel in p.tool_rels
                    if rel.usage_type == "wajib"
                ][:4]

                rc = riasec_map.get(p.riasec_code_id, {})
                result.append({
                    "profession_id": p.id,
                    "name": p.name,
                    "riasec_code": rc.get("riasec_code", "-"),
                    "riasec_title": rc.get("riasec_title", "-"),
                    "about_description": (p.about_description or "")[:400],
                    "riasec_description": p.riasec_description or "",
                    "activities": [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                    "soft_skills_required": soft_skills,
                    "tools_required": tools,
                })

            return result

        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal query profession contexts for ikigai: {str(e)}",
            )

    def get_profession_contexts_for_scoring(
        self, profession_ids: List[int]
    ) -> List[dict]:
        """
        Query konteks profesi yang lebih ringkas untuk AI scoring prompt (semua kandidat).

        Dipakai oleh: IkigaiService._finalize_ikigai() — STEP 3 (Gemini scoring)

        Data yang diambil:
          - professions: id, name, about_description
          - profession_activities: 5 aktivitas teratas
          - profession_skill_rels → skills: 3 hard skill wajib teratas
            (lebih sedikit dari ikigai content — scoring prompt lebih singkat)

        Returns:
            List[dict] — setiap dict adalah profession_context untuk scoring prompt
        """
        if not profession_ids:
            return []

        try:
            professions = (
                self.db.query(Profession)
                .options(
                    joinedload(Profession.activities),
                    joinedload(Profession.skill_rels).joinedload(ProfessionSkillRel.skill),
                )
                .filter(Profession.id.in_(profession_ids))
                .all()
            )

            result = []
            for p in professions:
                activities = sorted(p.activities, key=lambda a: a.sort_order)[:5]
                hard_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "hard" and rel.priority == "wajib"
                ][:3]

                result.append({
                    "profession_id": p.id,
                    "name": p.name,
                    "about_description": (p.about_description or "")[:300],
                    "activities": [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                })

            return result

        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal query profession contexts for scoring: {str(e)}",
            )

    def get_profession_contexts_for_recommendation(
        self, profession_ids: List[int]
    ) -> List[dict]:
        """
        Query konteks profesi lengkap untuk generate narasi rekomendasi akhir (top-2).

        Dipakai oleh: IkigaiService._finalize_ikigai() — STEP 10 (narasi rekomendasi)

        Data yang diambil (paling lengkap dari tiga method):
          - professions: id, name, about_description, riasec_description
          - riasec_codes: riasec_code, riasec_title
          - profession_activities: 5 aktivitas teratas
          - profession_skill_rels → skills: 5 hard skill wajib teratas
          - profession_career_paths: entry_level dan senior_level (salary_min, salary_max)
            → ini yang selama ini hilang di DigitalProfession — sekarang tersedia

        Returns:
            List[dict] — setiap dict adalah profession_context untuk prompt narasi rekomendasi
        """
        if not profession_ids:
            return []

        try:
            professions = (
                self.db.query(Profession)
                .options(
                    joinedload(Profession.activities),
                    joinedload(Profession.skill_rels).joinedload(ProfessionSkillRel.skill),
                    joinedload(Profession.career_paths),
                )
                .filter(Profession.id.in_(profession_ids))
                .all()
            )

            riasec_map = self._get_riasec_map(profession_ids)

            result = []
            for p in professions:
                activities = sorted(p.activities, key=lambda a: a.sort_order)[:5]
                hard_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "hard" and rel.priority == "wajib"
                ][:5]
                career_paths = sorted(p.career_paths, key=lambda cp: cp.sort_order)

                # Entry level = career_path sort_order pertama (junior)
                # Senior level = career_path sort_order terakhir
                entry_level = career_paths[0] if career_paths else None
                senior_level = career_paths[-1] if len(career_paths) > 1 else None

                rc = riasec_map.get(p.riasec_code_id, {})
                result.append({
                    "profession_id": p.id,
                    "name": p.name,
                    "riasec_code": rc.get("riasec_code", "-"),
                    "riasec_title": rc.get("riasec_title", "-"),
                    "about_description": p.about_description or "-",
                    "riasec_description": p.riasec_description or "-",
                    "activities": [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                    # Data gaji dari profession_career_paths — tersedia karena pakai tabel relasional
                    "entry_level_path": {
                        "title": entry_level.title,
                        "experience_range": entry_level.experience_range,
                        "salary_min": entry_level.salary_min,
                        "salary_max": entry_level.salary_max,
                    } if entry_level else None,
                    "senior_level_path": {
                        "title": senior_level.title,
                        "experience_range": senior_level.experience_range,
                        "salary_min": senior_level.salary_min,
                        "salary_max": senior_level.salary_max,
                    } if senior_level else None,
                })

            return result

        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal query profession contexts for recommendation: {str(e)}",
            )

    def find_by_riasec_code(
        self, riasec_code: str, limit: int = 30
    ) -> List[Profession]:
        """
        Cari Profession berdasarkan string kode RIASEC (misal 'RIA', 'RI', 'R').
        Digunakan oleh riasec_service saat ekspansi kandidat profesi (Tier 1–4).

        Menggantikan method lama find_by_riasec_code yang query DigitalProfession.
        """
        return (
            self.db.query(Profession)
            .join(RIASECCode, Profession.riasec_code_id == RIASECCode.id)
            .filter(RIASECCode.riasec_code == riasec_code)
            .limit(limit)
            .all()
        )

    # ──────────────────────────────────────────────────────────────────────────
    # IKIGAI CANDIDATE PROFESSIONS (JSONB) — tidak berubah
    # ──────────────────────────────────────────────────────────────────────────

    def get_candidates_by_session_id(
        self, test_session_id: int
    ) -> Optional[IkigaiCandidateProfession]:
        """Ambil data kandidat profesi berdasarkan test_session_id."""
        try:
            return (
                self.db.query(IkigaiCandidateProfession)
                .filter(IkigaiCandidateProfession.test_session_id == test_session_id)
                .first()
            )
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal mengambil data kandidat: {str(e)}",
            )

    def create_candidates(
        self,
        test_session_id: int,
        candidates_data: dict,
        total_candidates: int,
        generation_strategy: str,
        max_candidates_limit: int = 30,
    ) -> IkigaiCandidateProfession:
        """
        Buat record kandidat profesi baru.
        Menyertakan kolom denormalisasi sesuai model yang sudah diperbaiki
        (total_candidates, generation_strategy, max_candidates_limit).
        """
        try:
            record = IkigaiCandidateProfession(
                test_session_id=test_session_id,
                candidates_data=candidates_data,
                total_candidates=total_candidates,
                generation_strategy=generation_strategy,
                max_candidates_limit=max_candidates_limit,
            )
            self.db.add(record)
            self.db.commit()
            self.db.refresh(record)
            return record
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal membuat data kandidat: {str(e)}",
            )

    # ──────────────────────────────────────────────────────────────────────────
    # PRIVATE HELPERS
    # ──────────────────────────────────────────────────────────────────────────

    def _get_riasec_map(self, profession_ids: List[int]) -> dict:
        """
        Ambil mapping riasec_code_id → {riasec_code, riasec_title} untuk
        daftar profesi yang diberikan. Satu query untuk semua profesi (tidak N+1).
        """
        if not profession_ids:
            return {}

        rows = (
            self.db.query(
                Profession.riasec_code_id,
                RIASECCode.riasec_code,
                RIASECCode.riasec_title,
                RIASECCode.riasec_description,
            )
            .join(RIASECCode, Profession.riasec_code_id == RIASECCode.id)
            .filter(Profession.id.in_(profession_ids))
            .filter(Profession.riasec_code_id.isnot(None))
            .all()
        )

        return {
            row.riasec_code_id: {
                "riasec_code": row.riasec_code,
                "riasec_title": row.riasec_title,
                "riasec_description": row.riasec_description,
            }
            for row in rows
        }