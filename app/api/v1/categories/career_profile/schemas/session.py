from pydantic import BaseModel
from typing import List

class StartRecommendationRequest(BaseModel):
    persona_type: str

class StartFitCheckRequest(BaseModel):
    persona_type: str
    target_profession_id: int

class StartSessionResponse(BaseModel):
    session_token: str
    test_goal: str
    status: str
    question_ids: List[int]
    total_questions: int
    message: str
