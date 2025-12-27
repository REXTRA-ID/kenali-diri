# app/api/v1/categories/career_profile/models/session.py
from sqlalchemy import Column, BigInteger, Boolean, String, TIMESTAMP, ForeignKey, text
from app.db.base import Base


class CareerProfileTestSession(Base):
    __tablename__ = "careerprofile_test_sessions"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    riasec_completed = Column(Boolean, default=False)
    ikigai_completed = Column(Boolean, default=False)
    status = Column(String(50), default="riasec_pending")
    started_at = Column(TIMESTAMP, server_default=text("now()"))
    completed_at = Column(TIMESTAMP, nullable=True)

    def __repr__(self):
        return f"<CareerProfileTestSession id={self.id} status={self.status}>"
