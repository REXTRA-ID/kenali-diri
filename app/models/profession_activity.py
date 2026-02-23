"""
app/models/profession_activity.py
---------------------------------
Entity: profession_activities
"""
from datetime import datetime
from sqlalchemy import Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base

class ProfessionActivity(Base):
    __tablename__ = "profession_activities"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    description: Mapped[str] = mapped_column(Text, nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    profession: Mapped["Profession"] = relationship("Profession", back_populates="activities", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionActivity id={self.id} profession_id={self.profession_id}>"
