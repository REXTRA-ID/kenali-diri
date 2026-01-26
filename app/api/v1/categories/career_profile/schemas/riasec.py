from pydantic import BaseModel, Field, validator
from typing import List, Optional

class QuestionSchema(BaseModel):
    question_id: int
    question_text: str
    riasec_type: str  # R, I, A, S, E, or C

class RIASECSubmitRequest(BaseModel):
    """Request schema for submitting RIASEC test"""
    session_token: str = Field(..., description="Session token")
    responses: List[RIASECAnswerItem] = Field(..., min_items=72, max_items=72)
    
    @validator('responses')
    def validate_responses_count(cls, v):
        if len(v) != 72:
            raise ValueError('Must provide exactly 72 responses (12 per RIASEC type)')
        
        # Score harus 1-5
        for question_id, score in v.items():
            if not (1 <= score <= 5):
                raise ValueError(f"Score for question {question_id} must be between 1-5")
        
        return v

# Response
class QuestionSetResponse(BaseModel):
    question_ids: List[int]  # 72 IDs
    questions: List[dict]     # Full question data

class RIASECScoreDetail(BaseModel):
    score_r: int
    score_i: int
    score_a: int
    score_s: int
    score_e: int
    score_c: int

class RIASECResultResponse(BaseModel):
    # session_token: str
    riasec_code: str  # e.g. "RIA"
    riasec_title: str
    riasec_scores: dict[str, int]  # {"R": 42, "I": 38, ...}
    classification_type: str  # "single", "dual", "triple"
    top_3_codes: list[str]  # ["R", "I", "A"]
    code_details: RIASECCodeSchema

class RIASECResultResponse(BaseModel):
    session_token: str
    status: str
    scores: Dict[str, int]
    code_info: Dict[str, Any]
    classification_type: str
    is_inconsistent_profile: bool
    candidates_summary: Dict[str, Any]
    
class CandidatesResponse(BaseModel):
    """Response schema for candidates list"""
    user_riasec_code: str
    user_top_3_types: List[str]
    user_scores: Dict[str, int]
    is_inconsistent_profile: bool = False  # NEW: Flag for Split-Path results
    candidates: List[Dict[str, Any]]  # Each candidate may have optional "path": "A"|"B"
    expansion_summary: Dict[str, Any]
    total_candidates: int
