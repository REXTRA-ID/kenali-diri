"""
app/models/profession_study_program_rel.py
------------------------------------------
Entity: profession_study_program_rels
"""
from datetime import datetime
from typing import TYPE_CHECKING
from sqlalchemy import Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.profession import Profession

class ProfessionStudyProgramRel(Base):
    __tablename__ = "profession_study_program_rels"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(ForeignKey("professions.id", ondelete="CASCADE"), nullable=False)
    study_program_id: Mapped[int] = mapped_column(Integer, nullable=False)
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    profession: Mapped["Profession"] = relationship("Profession", back_populates="study_program_rels", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionStudyProgramRel id={self.id} profession_id={self.profession_id}>"
