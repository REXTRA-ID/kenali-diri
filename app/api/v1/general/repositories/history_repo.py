from sqlalchemy.orm import Session
from app.db.models.kenalidiri_history import KenaliDiriHistory
from datetime import datetime


class HistoryRepository:
    def get_by_user_id(self, db: Session, user_id: int):
        """Query history by user_id, sorted by started_at DESC"""
        return db.query(KenaliDiriHistory).filter(
            KenaliDiriHistory.user_id == user_id
        ).order_by(KenaliDiriHistory.started_at.desc()).all()

    def get_by_id(self, db: Session, id: int):
        """Query single history by ID"""
        return db.query(KenaliDiriHistory).filter(
            KenaliDiriHistory.id == id
        ).first()

    def create(
            self,
            db: Session,
            user_id: int,
            category_id: int,
            detail_session_id: int
    ):
        """Create new history record"""
        history = KenaliDiriHistory(
            user_id=user_id,
            test_category_id=category_id,
            detail_session_id=detail_session_id,
            status="ongoing"
        )
        db.add(history)
        db.commit()
        db.refresh(history)
        return history

    def update_status(self, db: Session, id: int, status: str):
        """Update status"""
        history = self.get_by_id(db, id)
        if history:
            history.status = status
            db.commit()
            db.refresh(history)
        return history

    def complete(self, db: Session, id: int):
        """Mark as completed"""
        history = self.get_by_id(db, id)
        if history:
            history.status = "completed"
            history.completed_at = datetime.utcnow()
            db.commit()
            db.refresh(history)
        return history
