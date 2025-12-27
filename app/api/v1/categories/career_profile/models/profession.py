# app/api/v1/categories/career_profile/models/profession.py
from sqlalchemy import Column, BigInteger, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base


class IkigaiCandidateProfession(Base):
    __tablename__ = "ikigai_candidate_professions"

    id = Column(BigInteger, primary_key=True)

    test_session_id = Column(
        BigInteger,
        ForeignKey(
            "careerprofile_test_sessions.id",
            ondelete="CASCADE"
        ),
        nullable=False,
        unique=True
    )

    candidates_data = Column(JSONB, nullable=False)

    generated_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    # # 🔗 Relationship
    # session = relationship(
    #     "CareerProfileTestSession",
    #     back_populates="ikigai_candidates"
    # )