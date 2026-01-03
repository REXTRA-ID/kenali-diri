# app/api/v1/categories/career_profile/models/riasec.py
from sqlalchemy import Column, BigInteger, String, JSON, TIMESTAMP, ForeignKey, text, CheckConstraint, Boolean, Integer
from app.db.base import Base

class RIASECCode(Base):
    __tablename__ = "riasec_codes"
    
    id = Column(BigInteger, primary_key=True)
    riasec_code = Column(String(10), unique=True, nullable=False)
    riasec_title = Column(String(200))
    riasec_description = Column(String(1000))
    # Kolom JSONB
    strengths = Column(JSON, server_default=text("'[]'::jsonb"))
    challenges = Column(JSON, server_default=text("'[]'::jsonb"))
    strategies = Column(JSON, server_default=text("'[]'::jsonb"))
    work_environments = Column(JSON, server_default=text("'[]'::jsonb"))
    interaction_styles = Column(JSON, server_default=text("'[]'::jsonb"))
    congruent_code_ids = Column(JSON, server_default=text("'[]'::jsonb"))
    
    created_at = Column(TIMESTAMP, server_default=text("now()"))
    updated_at = Column(TIMESTAMP, server_default=text("now()"), onupdate=text("now()"))

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

    # session = relationship(
    #     "CareerProfileTestSession",
    #     back_populates="result"
    # )

    riasec_code = relationship(
        "RIASECCode",
        back_populates="results"
    )

    __table_args__ = (
        CheckConstraint(
            "score_r BETWEEN 0 AND 100 AND "
            "score_i BETWEEN 0 AND 100 AND "
            "score_a BETWEEN 0 AND 100 AND "
            "score_s BETWEEN 0 AND 100 AND "
            "score_e BETWEEN 0 AND 100 AND "
            "score_c BETWEEN 0 AND 100",
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
    test_session_id = Column(BigInteger, ForeignKey("careerprofile_test_sessions.id"))
    question_set_id = Column(BigInteger, ForeignKey("riasec_question_sets.id"))
    responses_data = Column(JSON)  # {"1": 4, "2": 5, ...}
    created_at = Column(TIMESTAMP, server_default=text("now()"))

class RIASECResult(Base):
    __tablename__ = "riasec_results"
    
    id = Column(BigInteger, primary_key=True)
    test_session_id = Column(BigInteger, ForeignKey("careerprofile_test_sessions.id"), unique=True)
    
    score_r = Column(Integer, default=0)
    score_i = Column(Integer, default=0)
    score_a = Column(Integer, default=0)
    score_s = Column(Integer, default=0)
    score_e = Column(Integer, default=0)
    score_c = Column(Integer, default=0)
    
    riasec_code_id = Column(BigInteger, ForeignKey("riasec_codes.id"))
    riasec_code_type = Column(String(20))  # "single", "dual", "triple"
    calculated_at = Column(TIMESTAMP, server_default=text("now()"))
