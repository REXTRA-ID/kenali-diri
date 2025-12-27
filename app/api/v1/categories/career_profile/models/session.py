# app/api/v1/categories/career_profile/models/session.py
from sqlalchemy import Column, BigInteger, Boolean, String, TIMESTAMP, ForeignKey, text
from app.db.base import Base
from sqlalchemy.dialects.postgresql import UUID

class CareerProfileTestSession(Base):
    __tablename__ = "careerprofile_test_sessions"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    session_token = Column(String(100), nullable=False, unique=True)
    riasec_completed_at = Column(TIMESTAMP, server_default=text("now()"))
    ikigai_completed_at = Column(TIMESTAMP, server_default=text("now()"))
    status = Column(String(50), default="riasec_pending")
    started_at = Column(TIMESTAMP, server_default=text("now()"))
    completed_at = Column(TIMESTAMP, nullable=True)

    def __repr__(self):
        return f"<CareerProfileTestSession id={self.id} status={self.status}>"
