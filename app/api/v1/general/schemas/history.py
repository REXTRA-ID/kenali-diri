from pydantic import BaseModel
from datetime import datetime
from app.api.v1.general.schemas import CategoryResponse

class HistoryResponse(BaseModel):
    id: int
    user_id: int
    test_category: CategoryResponse
    status: str
    started_at: datetime
    completed_at: datetime | None

    class Config:
        from_attributes = True
