# app/api/v1/categories/career_profile/models/riasec.py
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import JSONB, ARRAY
from sqlalchemy.sql import func
from app.db.base import Base

from sqlalchemy import (
    Column, BigInteger, Integer, String, Text,
    Boolean, ForeignKey, DateTime,
    CheckConstraint, JSON
)

class RIASECCode(Base):
    __tablename__ = "riasec_codes"

    id = Column(BigInteger, primary_key=True)
    riasec_code = Column(String(3), nullable=False, unique=True)
    riasec_title = Column(String(255), nullable=False)
    riasec_description = Column(Text)

    strengths = Column(JSONB, default=list)
    challenges = Column(JSONB, default=list)
    strategies = Column(JSONB, default=list)
    work_environments = Column(JSONB, default=list)
    interaction_styles = Column(JSONB, default=list)

    congruent_code_ids = Column(JSONB, default=list)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )

    results = relationship("RIASECResult", back_populates="riasec_code")

    __table_args__ = (
        CheckConstraint(
            "riasec_code ~ '^[RIASEC]{1,3}$'",
            name="chk_riasec_code_format"
        ),
    )
    
class RIASECQuestionSet(Base):
    __tablename__ = "riasec_question_sets"

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

    question_ids = Column(JSONB, nullable=False)
    generated_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship(
        "CareerProfileTestSession",
        back_populates="question_set"
    )

class RIASECResult(Base):
    __tablename__ = "riasec_results"

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

    score_r = Column(Integer, nullable=False)
    score_i = Column(Integer, nullable=False)
    score_a = Column(Integer, nullable=False)
    score_s = Column(Integer, nullable=False)
    score_e = Column(Integer, nullable=False)
    score_c = Column(Integer, nullable=False)

    riasec_code_id = Column(
        BigInteger,
        ForeignKey("riasec_codes.id", ondelete="RESTRICT"),
        nullable=False
    )

    classification_type = Column(String(20), nullable=False)
    is_inconsistent_profile = Column(Boolean, default=False)

    calculated_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship(
        "CareerProfileTestSession",
        back_populates="result"
    )

    riasec_code = relationship(
        "RIASECCode",
        back_populates="results"
    )

    __table_args__ = (
        CheckConstraint(
            "score_r BETWEEN 2 AND 10 AND "
            "score_i BETWEEN 2 AND 10 AND "
            "score_a BETWEEN 2 AND 10 AND "
            "score_s BETWEEN 2 AND 10 AND "
            "score_e BETWEEN 2 AND 10 AND "
            "score_c BETWEEN 2 AND 10",
            name="chk_riasec_results_scores"
        ),
        CheckConstraint(
            "classification_type IN ('single', 'dual', 'triple')",
            name="chk_riasec_results_classification"
        ),
    )

class RIASECResponse(Base):
    __tablename__ = "riasec_responses"

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

    responses_data = Column(JSONB, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship(
        "CareerProfileTestSession",
        back_populates="response"
    )