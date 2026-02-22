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
from app.shared.cache import redis_client as _redis


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

        about_text = await PersonalityService.get_personality_about_text(
            riasec_code=riasec_code_str,
            riasec_title=riasec_title,
            riasec_description=riasec_description,
            redis_client=_redis
        )

        return {
            "session_token": session_token,
            "riasec_code": riasec_code_str,
            "scores_data": scores_data,
            "about_personality": about_text
        }

    def get_fit_check_result(self, user: User, session_token: str) -> Dict[str, Any]:
        """Fetch Fit Check result."""
        session = self._get_verified_session(user, session_token)

        fit_check = self.db.query(FitCheckResult).filter(FitCheckResult.test_session_id == session.id).first()
        if not fit_check:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Fit Check result not found. Did you finish the RIASEC test?")

        # Get profession to fetch the title/code
        prof_data = None
        if session.target_profession_id:
            from app.api.v1.categories.career_profile.models.digital_profession import DigitalProfession
            p = self.db.query(DigitalProfession).filter(DigitalProfession.id == session.target_profession_id).first()
            if p:
                prof_data = {
                    "id": p.id,
                    "title": p.title,
                    "image_url": None,  # not in model yet
                    "riasec_code": p.riasec_code.riasec_code if p.riasec_code else None
                }

        explanation = build_fit_check_explanation(
            match_category=fit_check.match_category,
            rule_type=fit_check.rule_type
        )

        return {
            "session_token": session_token,
            "match_category": fit_check.match_category,
            "rule_type": fit_check.rule_type,
            "match_score": float(fit_check.match_score) if fit_check.match_score else None,
            "explanation": explanation,
            "target_profession": prof_data
        }

    def get_recommendation_result(self, user: User, session_token: str) -> Dict[str, Any]:
        """Fetch final Career Recommendations."""
        session = self._get_verified_session(user, session_token)

        rec = self.db.query(CareerRecommendation).filter(CareerRecommendation.test_session_id == session.id).first()
        if not rec:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Recommendations not generated yet.")

        # Hydrate the recommended professions with details from DigitalProfession
        rec_data = dict(rec.recommendations_data)
        prof_docs = rec_data.get("recommended_professions", [])

        # Get master data for top professions
        prof_ids = [p["profession_id"] for p in prof_docs if "profession_id" in p]

        if prof_ids:
            master_profs = self.profession_repo.get_master_professions_by_ids(prof_ids)
            prof_map = {mp.id: mp for mp in master_profs}

            for p in prof_docs:
                p_id = p.get("profession_id")
                mp = prof_map.get(p_id)
                if mp:
                    meta = mp.meta_data or {}
                    p["title"] = mp.title
                    p["image_url"] = None  # not in model yet
                    p["tasks"] = meta.get("work_activities", [])
                    p["tools"] = meta.get("tech_stack", [])
                    p["work_activities"] = meta.get("work_activities", [])
                    if mp.riasec_code:
                        p["riasec_code"] = mp.riasec_code.riasec_code

        rec_data["recommended_professions"] = prof_docs
        return {
            "session_token": session_token,
            "recommendation": rec_data
        }
