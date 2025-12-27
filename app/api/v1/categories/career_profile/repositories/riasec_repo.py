from sqlalchemy.orm import Session
from app.api.v1.categories.career_profile.models.riasec import (
    RIASECCode, RIASECQuestionSet, RIASECResponse, RIASECResult
)

class RIASECRepository:
    def get_active_question_set(self, db: Session):
        """Get active question set (72 questions)"""
        question_set = db.query(RIASECQuestionSet).filter_by(is_active=True).first()
        if question_set:
            return question_set.questions_data
        return []
    
    def get_code_by_id(self, db: Session, code_id: int):
        """Get RIASEC code by ID"""
        return db.query(RIASECCode).filter_by(id=code_id).first()
    
    def get_code_by_code(self, db: Session, code: str):
        """Get RIASEC code by code string (e.g. 'RIA')"""
        return db.query(RIASECCode).filter_by(riasec_code=code).first()
    
    def save_responses(self, db: Session, session_id: int, responses: dict):
        """Save RIASEC responses"""
        response = RIASECResponse(
            test_session_id=session_id,
            responses_data=responses
        )
        db.add(response)
        db.commit()
        db.refresh(response)
        return response
    
    def save_result(
        self,
        db: Session,
        session_id: int,
        scores: dict,
        code_id: int,
        code_type: str
    ):
        """Save RIASEC result"""
        result = RIASECResult(
            test_session_id=session_id,
            score_r=scores.get("R", 0),
            score_i=scores.get("I", 0),
            score_a=scores.get("A", 0),
            score_s=scores.get("S", 0),
            score_e=scores.get("E", 0),
            score_c=scores.get("C", 0),
            riasec_code_id=code_id,
            riasec_code_type=code_type
        )
        db.add(result)
        db.commit()
        db.refresh(result)
        return result
    
    def get_result_by_session(self, db: Session, session_id: int):
        """Get RIASEC result by session ID"""
        return db.query(RIASECResult).filter_by(test_session_id=session_id).first()
