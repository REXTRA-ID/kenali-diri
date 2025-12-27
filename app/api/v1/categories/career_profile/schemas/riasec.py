from pydantic import BaseModel, Field, validator
from typing import List, Optional

class QuestionSchema(BaseModel):
    question_id: int
    question_text: str
    riasec_type: str  # R, I, A, S, E, or C

class RIASECSubmitRequest(BaseModel):
    session_token: str
    responses: dict[str, int] = Field(...)  # {"1": 4, "2": 5, ..., "72": 3}
    
    @validator('responses')
    def validate_responses(cls, v):
        # Harus ada 72 responses
        if len(v) != 72:
            raise ValueError("Must have exactly 72 responses")
        
        # Score harus 1-5
        for question_id, score in v.items():
            if not (1 <= score <= 5):
                raise ValueError(f"Score for question {question_id} must be between 1-5")
        
        return v

class RIASECCodeSchema(BaseModel):
    code: str
    title: str
    description: str
    strengths: list[str]
    challenges: list[str]

class RIASECResultResponse(BaseModel):
    # session_token: str
    riasec_code: str  # e.g. "RIA"
    riasec_title: str
    riasec_scores: dict[str, int]  # {"R": 42, "I": 38, ...}
    classification_type: str  # "single", "dual", "triple"
    top_3_codes: list[str]  # ["R", "I", "A"]
    code_details: RIASECCodeSchema

class RIASECQuestionSchema(BaseModel):
    code: str
    dimension: str
    question_id: int
    question_text: str  
    riasec_type: str