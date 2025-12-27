from pydantic import BaseModel
from datetime import datetime

class SessionCreateRequest(BaseModel):
    user_id: int

class SessionResponse(BaseModel):
    session_token: str
    status: str
    riasec_completed: bool
    ikigai_completed: bool
    started_at: datetime
    questions: list | None = None  # Optional, untuk initial response

class SessionProgressResponse(BaseModel):
    session_token: str
    current_phase: str
    riasec_completed: bool
    ikigai_completed: bool
    can_proceed_to_ikigai: bool
