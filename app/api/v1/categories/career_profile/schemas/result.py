from pydantic import BaseModel, ConfigDict
from typing import List, Optional, Dict, Any


class PersonalityResultResponse(BaseModel):
    session_token: str
    riasec_code: str
    scores_data: Dict[str, int]
    about_personality: str

    model_config = ConfigDict(from_attributes=True)


class TargetProfessionData(BaseModel):
    id: int
    title: str
    image_url: Optional[str] = None
    riasec_code: Optional[str] = None


class FitCheckExplanation(BaseModel):
    meaning: str
    reason_points: List[str]
    implication: str


class FitCheckResultResponse(BaseModel):
    session_token: str
    match_category: str
    rule_type: str
    match_score: Optional[float] = None
    explanation: FitCheckExplanation
    target_profession: Optional[TargetProfessionData] = None

    model_config = ConfigDict(from_attributes=True)


class RecommendationResultResponse(BaseModel):
    session_token: str
    recommendation: Dict[str, Any]

    model_config = ConfigDict(from_attributes=True)
