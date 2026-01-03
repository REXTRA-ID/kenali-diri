from pydantic import BaseModel
from datetime import datetime
import uuid
from typing import List

from app.api.v1.categories.career_profile.schemas.riasec import RIASECQuestionSchema

class SessionCreateRequest(BaseModel):
    user_id: uuid.UUID

class SessionResponse(BaseModel):
    session_token: str
    status: str
    riasec_completed_at: datetime | None = None
    ikigai_completed_at: datetime | None = None
    started_at: datetime
    questions: List[RIASECQuestionSchema]

class SessionProgressResponse(BaseModel):
    session_token: str
    current_phase: str
    riasec_completed_at: datetime | None = None
    ikigai_completed_at: datetime | None = None
    can_proceed_to_ikigai: bool
