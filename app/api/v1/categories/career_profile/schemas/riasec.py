from pydantic import BaseModel, Field, validator
from typing import List, Dict, Any

# Request
class RIASECAnswerItem(BaseModel):
    """Schema for individual response"""
    question_id: int = Field(..., gt=0, description="Question ID")
    answer_value: int = Field(..., ge=1, le=5, description="Answer value (1-5 scale)")
    
    @validator('answer_value')
    def validate_answer(cls, v):
        if not (1 <= v <= 5):
            raise ValueError('Answer value must be between 1 and 5')
        return v

class RIASECSubmitRequest(BaseModel):
    """Request schema for submitting RIASEC test"""
    session_token: str = Field(..., description="Session token")
    responses: List[RIASECAnswerItem] = Field(..., min_items=12, max_items=12)
    
    @validator('responses')
    def validate_responses_count(cls, v):
        if len(v) != 12:
            raise ValueError('Must provide exactly 12 responses')
        
        # Check for duplicate question IDs
        question_ids = [r.question_id for r in v]
        if len(question_ids) != len(set(question_ids)):
            raise ValueError('Duplicate question IDs not allowed')
        
        return v

# Response
class QuestionSetResponse(BaseModel):
    question_ids: List[int]  # 12 IDs
    questions: List[dict]     # Full question data

class RIASECScoreDetail(BaseModel):
    score_r: int
    score_i: int
    score_a: int
    score_s: int
    score_e: int
    score_c: int

class RIASECCodeInfo(BaseModel):
    riasec_code: str
    riasec_title: str
    riasec_description: str
    strengths: List[str]
    challenges: List[str]
    strategies: List[str]
    work_environments: List[str]
    interaction_styles: List[str]

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
    candidates: List[Dict[str, Any]]
    expansion_summary: Dict[str, Any]
    total_candidates: int