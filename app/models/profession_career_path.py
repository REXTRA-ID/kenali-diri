"""
app/models/profession_career_path.py
------------------------------------
Entity: profession_career_paths
"""
from datetime import datetime
from typing import Optional
from sqlalchemy import Integer, String, DateTime, ForeignKey, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base

class ProfessionCareerPath(Base):
    __tablename__ = "profession_career_paths"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    level_name: Mapped[str] = mapped_column(String(100), nullable=False)
    estimated_salary_min: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    estimated_salary_max: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    profession: Mapped["Profession"] = relationship("Profession", back_populates="career_paths", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionCareerPath id={self.id} level={self.level_name}>"
