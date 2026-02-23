"""
app/models/profession_tool_rel.py
----------------------------------
Entity: profession_tool_rels
"""
from typing import TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.profession import Profession
    from app.models.tool import Tool
from sqlalchemy import Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.db.base import Base

class ProfessionToolRel(Base):
    __tablename__ = "profession_tool_rels"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    tool_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("tools.id", ondelete="CASCADE"), nullable=False, index=True
    )
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    profession: Mapped["Profession"] = relationship("Profession", back_populates="tool_rels", lazy="select")
    tool: Mapped["Tool"] = relationship("Tool", lazy="joined")

    def __repr__(self) -> str:
        return f"<ProfessionToolRel id={self.id} profession_id={self.profession_id} tool_id={self.tool_id}>"
