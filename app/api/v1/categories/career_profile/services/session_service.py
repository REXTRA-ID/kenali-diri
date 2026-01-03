from sqlalchemy.orm import Session
from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.riasec_repo import RIASECRepository
from app.api.v1.categories.career_profile.models.riasec import RIASECQuestionSet
from sqlalchemy.orm import Session
from app.api.v1.general.repositories.history_repo import HistoryRepository
import uuid

class SessionService:
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = SessionRepository(db)
        self.history_repo = HistoryRepository()

    def create_new_session(self, user_id: uuid.UUID):
        """
        Create new test session:
        1. Create careerprofile_test_sessions record
        2. Create kenalidiri_history record
        3. Load and generate RIASEC question set
        4. Return token + questions
        """
        # 1. Create test session
        session = self.session_repo.create(user_id)

        # 2. Create kenalidiri_history (status "ongoing")
        # Assume category_id = 1 for Career Profile
        self.history_repo.create(
            self.db,
            user_id=user_id,
            category_id=1,
            detail_session_id=session.id
        )

        # 3. Create RIASEC question set
        from app.api.v1.categories.career_profile.services.riasec_service import RIASECService
        riasec_service = RIASECService(self.db)
        question_ids = riasec_service.generate_question_set(session.session_token)
        
        # Save question set to DB
        riasec_service.riasec_repo.create_question_set(session.id, question_ids)

        # 4. Return response
        return {
            "session_token": session.session_token,
            "status": session.status,
            "started_at": session.started_at
        }
        
    def get_session_by_token(self, db: Session, token: str):
        return self.session_repo.get_by_token(db, token)

    def get_progress(self, session_id: int):
        """Get session progress info"""
        session = self.session_repo.get_by_id(session_id)

        if not session:
            return None

        return {
            "session_token": str(session.session_token),
            "current_phase": session.status,
            "riasec_completed_at": session.riasec_completed_at,
            "ikigai_completed_at": session.ikigai_completed_at,
            "can_proceed_to_ikigai": session.riasec_completed_at is not None
        }
