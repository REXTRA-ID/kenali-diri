from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import Dict, Any

from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
from app.api.v1.categories.career_profile.models.result import CareerRecommendation, FitCheckResult
from app.api.v1.categories.career_profile.models.riasec import RIASECResult
from app.api.v1.categories.career_profile.services.personality_service import PersonalityService
from app.api.v1.categories.career_profile.services.fit_check_classifier import build_fit_check_explanation
from app.db.models.user import User
from app.core.redis import get_redis_client


class ResultService:
    """Service to handle aggregated result retrieval for Career Profile sections"""

    def __init__(self, db: Session):
        self.db = db
        self.session_repo = SessionRepository(db)
        self.profession_repo = ProfessionRepository(db)

    def _get_verified_session(self, user: User, session_token: str):
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Session not found or invalid.")
        return session

    async def get_personality_result(self, user: User, session_token: str) -> Dict[str, Any]:
        """Fetch RIASEC scores and generated personality description."""
        session = self._get_verified_session(user, session_token)

        riasec_res = self.db.query(RIASECResult).filter(RIASECResult.test_session_id == session.id).first()
        if not riasec_res:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="RIASEC result not found.")

        # Use the relationship to get title/description (one query via lazy load)
        riasec_code_obj = riasec_res.riasec_code_obj
        riasec_code_str = riasec_res.riasec_code or (riasec_code_obj.riasec_code if riasec_code_obj else "")
        riasec_title = riasec_code_obj.riasec_title if riasec_code_obj else riasec_code_str
        riasec_description = riasec_code_obj.riasec_description if riasec_code_obj else ""

        # Build scores_data from individual columns if not cached
        scores_data = riasec_res.scores_data or {
            "R": riasec_res.score_r,
            "I": riasec_res.score_i,
            "A": riasec_res.score_a,
            "S": riasec_res.score_s,
            "E": riasec_res.score_e,
            "C": riasec_res.score_c,
        }

        # Gunakan async redis client sesuai Temuan 3
        redis_client = get_redis_client()
        about_text = await PersonalityService.get_personality_about_text(
            riasec_code=riasec_code_str,
            riasec_title=riasec_title,
            riasec_description=riasec_description,
            redis_client=redis_client
        )

        return {
            "session_token": session_token,
            "riasec_code": riasec_code_str,
            "scores_data": scores_data,
            "about_personality": about_text
        }

    async def get_fit_check_result(self, user: User, session_token: str) -> Dict[str, Any]:
        """Fetch Fit Check result."""
        session = self._get_verified_session(user, session_token)

        fit_check = self.db.query(FitCheckResult).filter(FitCheckResult.test_session_id == session.id).first()
        if not fit_check:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Fit Check result not found. Did you finish the RIASEC test?")

        # Get user RIASEC
        riasec_res = self.db.query(RIASECResult).filter(RIASECResult.test_session_id == session.id).first()
        user_code_obj = riasec_res.riasec_code_obj if riasec_res else None
        if not user_code_obj:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="User RIASEC code not found.")

        # Get target profession from relational Profession
        prof_data = None
        prof_code_obj = None
        if session.target_profession_id:
            from app.models.profession import Profession
            p = self.db.query(Profession).filter(Profession.id == session.target_profession_id).first()
            if p:
                prof_code_obj = p.riasec_code
                prof_data = {
                    "id": p.id,
                    "title": p.title,
                    "image_url": p.image_url,
                    "riasec_code": prof_code_obj.riasec_code if prof_code_obj else None
                }

        if not prof_code_obj:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Profession RIASEC code not found.")

        # Build explanation dengan signature baru
        fit_result_dict = {
            "match_category":       fit_check.match_category,
            "rule_type":            fit_check.rule_type,
            "dominant_letter_same": fit_check.dominant_letter_same,
            "is_adjacent_hexagon":  fit_check.is_adjacent_hexagon,
            "match_score":          float(fit_check.match_score) if fit_check.match_score else None,
        }
        explanation = build_fit_check_explanation(
            fit_result=fit_result_dict,
            user_code=user_code_obj.riasec_code,
            profession_code=prof_code_obj.riasec_code,
        )

        return {
            "session_token": session_token,
            "fit_check_result": {
                "match_category": fit_check.match_category,
                "rule_type": fit_check.rule_type,
                "match_score": float(fit_check.match_score) if fit_check.match_score else None,
                "explanation": explanation,
                "target_profession": prof_data
            }
        }

    async def get_recommendation_result(self, user: User, session_token: str) -> Dict[str, Any]:
        """Fetch final Career Recommendations."""
        session = self._get_verified_session(user, session_token)

        rec = self.db.query(CareerRecommendation).filter(CareerRecommendation.test_session_id == session.id).first()
        if not rec:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Recommendations not generated yet.")

        riasec_res = self.db.query(RIASECResult).filter(RIASECResult.test_session_id == session.id).first()
        if not riasec_res or not riasec_res.riasec_code_obj:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="RIASEC result not found.")
        riasec_code_obj = riasec_res.riasec_code_obj
        
        # Determine Top Types from RIASEC code
        top_types = []
        if riasec_code_obj.riasec_code:
            type_map = {
                "R": "Realistic", "I": "Investigative", "A": "Artistic",
                "S": "Social", "E": "Enterprising", "C": "Conventional"
            }
            top_types = [type_map.get(letter) for letter in riasec_code_obj.riasec_code if letter in type_map]

        from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession
        candidate_record = self.db.query(IkigaiCandidateProfession).filter(IkigaiCandidateProfession.test_session_id == session.id).first()
        all_candidates = candidate_record.candidate_professions if candidate_record else []
        
        # Get Candidate Profession Names using ProfessionRepository (get_by_ids)
        candidate_names = []
        if all_candidates:
            cand_professions = self.profession_repo.get_by_ids(all_candidates)
            candidate_names = [p.title for p in cand_professions]

        rec_data = dict(rec.recommendations_data)
        ai_profs = rec_data.get("recommended_professions", [])
        
        prof_ids = [p["profession_id"] for p in ai_profs if "profession_id" in p]
        enriched_professions = []
        if prof_ids:
            # Gunakan get_by_ids dari repository relational baru
            master_profs = self.profession_repo.get_by_ids(prof_ids)
            prof_map = {mp.id: mp for mp in master_profs}

            for p in ai_profs:
                p_id = p.get("profession_id")
                mp = prof_map.get(p_id)
                if mp:
                    # Ambil data relasional
                    tasks = [act.activity_name for act in mp.activities] if mp.activities else []
                    tools = [pt_rel.tool.tool_name for pt_rel in mp.tool_rels] if mp.tool_rels else []
                    skills = [ps_rel.skill.skill_name for ps_rel in mp.skill_rels] if mp.skill_rels else []
                    
                    enriched_professions.append({
                        "profession_id": mp.id,
                        "title": mp.title,
                        "image_url": mp.image_url,
                        "riasec_code": mp.riasec_code.riasec_code if mp.riasec_code else None,
                        "tasks": tasks,
                        "tools": tools,
                        "skills": skills,
                        "match_reason": p.get("match_reason")
                    })

        user_first_name = user.full_name.split()[0] if user.full_name else "User"

        return {
            "session_token":   session_token,
            "user_first_name": user_first_name,
            "test_completed_at": (
                session.completed_at.isoformat() if session.completed_at else None
            ),
            "riasec_summary": {
                "riasec_code":  riasec_code_obj.riasec_code,
                "riasec_title": " – ".join(top_types) if top_types else riasec_code_obj.riasec_title,
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
