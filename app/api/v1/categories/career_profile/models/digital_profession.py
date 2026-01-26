# app/api/v1/categories/career_profile/models/digital_profession.py
from sqlalchemy import Column, BigInteger, String, Text, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base


class DigitalProfession(Base):
    """
    Master table for Digital Professions with flexible metadata
    
    Schema Design Philosophy:
    - Strict columns for core data (title, description, RIASEC mapping)
    - JSONB for flexible, evolving metadata (tech_stack, frameworks, seniority)
    - This allows adding new technologies without schema migration
    
    Example meta_data structure:
    {
        "tech_stack": ["Python", "React", "PostgreSQL"],
        "frameworks": ["FastAPI", "Next.js"],
        "seniority_level": ["Junior", "Mid-Level"],
        "work_mode": ["Remote", "Hybrid"],
        "industry_focus": ["FinTech", "HealthTech"]
    }
    """
    __tablename__ = "digital_professions"
    
    # Core Columns
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    
    # Standardized profession title following format: [Specialization] [Platform] [Role]
    # Examples: "Web Frontend Developer", "Mobile iOS Engineer", "Data Science Analyst"
    title = Column(String(255), nullable=False, unique=True, index=True)
    
    # Detailed description of the profession
    description = Column(Text, nullable=True)
    
    # RIASEC Personality Type Mapping (REQUIRED)
    riasec_code_id = Column(
        BigInteger,
        ForeignKey("riasec_codes.id", ondelete="RESTRICT"),
        nullable=False,
        index=True
    )
    
    # Flexible Metadata (JSONB for schema flexibility)
    # Contains: tech_stack, frameworks, seniority_level, work_mode, industry_focus, etc.
    meta_data = Column(JSONB, nullable=False, default=dict, server_default='{}')
    
    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    
    # Relationships
    riasec_code = relationship(
        "RIASECCode",
        foreign_keys=[riasec_code_id],
        backref="digital_professions"
    )
    
    def __repr__(self):
        return f"<DigitalProfession(id={self.id}, title='{self.title}', riasec_code_id={self.riasec_code_id})>"
