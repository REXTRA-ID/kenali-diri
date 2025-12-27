from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.riasec_repo import RIASECRepository
from app.api.v1.general.repositories.history_repo import HistoryRepository
import uuid

class SessionService:
    def __init__(self):
        self.session_repo = SessionRepository()
        self.history_repo = HistoryRepository()

    def create_new_session(self, db, user_id: uuid.UUID):
        """
        Create new test session:
        1. Create careerprofile_test_sessions record
        2. Create kenalidiri_history record
        3. Load RIASEC questions
        4. Return token + questions
        """
        # 1. Create test session
        session = self.session_repo.create(db, user_id)

        # 2. Create kenalidiri_history (status "ongoing")
        # Assume category_id = 1 for Career Profile
        self.history_repo.create(
            db,
            user_id=user_id,
            category_id=1,
            detail_session_id=session.id
        )

        # TODO: Nanti
        # # 3. Load RIASEC questions (akan diimplementasi di 3.2)
        # riasec_repo = RIASECRepository()
        # questions = riasec_repo.get_active_question_set(db)

        # 4. Return response
        return {
            "session_token": session.session_token,
            # "questions": questions,  # 72 questions
            "status": session.status,
            "started_at": session.started_at
        }

    def get_progress(self, db, session_id: int):
        """Get session progress info"""
        session = self.session_repo.get_by_id(db, session_id)

        if not session:
            return None

        return {
            "session_token": str(session.id),  # Simplified
            "current_phase": session.status,
            "riasec_completed_at": session.riasec_completed_at,
            "ikigai_completed_at": session.ikigai_completed_at,
            "can_proceed_to_ikigai": session.riasec_completed_at is not None
        }
