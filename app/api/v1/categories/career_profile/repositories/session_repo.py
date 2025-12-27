# app/api/v1/categories/career_profile/repositories/session_repo.py
import uuid
from sqlalchemy.orm import Session
from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from datetime import datetime

class SessionRepository:
    def create(self, db: Session, user_id: uuid.UUID):
        """Create new test session, return (session, token)"""
        session_token = str(uuid.uuid4())

        new_session = CareerProfileTestSession(
            user_id=user_id,
            status="riasec_pending",
            session_token=session_token,
            started_at=datetime.now()
        )
        db.add(new_session)
        db.commit()
        db.refresh(new_session)

        # In real implementation, might store token separately or use session_id as token
        return new_session

    def get_by_id(self, db: Session, session_id: int):
        return db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.id == session_id
        ).first()

    def mark_riasec_completed(self, db: Session, session_id: int):
        """Mark RIASEC as completed"""
        session = self.get_by_id(db, session_id)
        if session:
            session.riasec_completed = True
            session.status = "ikigai_pending"
            db.commit()
            db.refresh(session)
        return session

    def mark_ikigai_completed(self, db: Session, session_id: int):
        """Mark Ikigai as completed"""
        session = self.get_by_id(db, session_id)
        if session:
            session.ikigai_completed = True
            session.status = "completed"
            session.completed_at = datetime.utcnow()
            db.commit()
            db.refresh(session)
        return session