"""
app/models/profession_skill_rel.py
----------------------------------
Entity: profession_skill_rels
"""
from datetime import datetime
from sqlalchemy import Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base

class ProfessionSkillRel(Base):
    __tablename__ = "profession_skill_rels"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    skill_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("skills.id", ondelete="CASCADE"), nullable=False, index=True
    )
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    profession: Mapped["Profession"] = relationship("Profession", back_populates="skill_rels", lazy="select")
    skill: Mapped["Skill"] = relationship("Skill", lazy="joined")

    def __repr__(self) -> str:
        return f"<ProfessionSkillRel id={self.id} profession_id={self.profession_id} skill_id={self.skill_id}>"
