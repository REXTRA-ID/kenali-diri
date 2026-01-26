# app/api/v1/categories/career_profile/schemas/ikigai.py
"""
Ikigai Assessment Schemas

This module defines Pydantic schemas for Ikigai test input and output.
The Ikigai framework evaluates 4 dimensions:
- Love (What you love)
- Good At (What you're good at)
- World Needs (What the world needs)
- Paid For (What you can be paid for)
"""
from pydantic import BaseModel, Field, validator
from typing import List, Dict, Any, Optional
from datetime import datetime


# ============== REQUEST SCHEMAS ==============

class IkigaiDimensionInput(BaseModel):
    """Input for a single Ikigai dimension"""
    text_input: str = Field(
        ...,
        min_length=10,
        max_length=2000,
        description="User's essay response for this dimension (10-2000 chars)"
    )
    
    @validator('text_input')
    def validate_not_empty(cls, v):
        if not v or v.strip() == "":
            raise ValueError("Essay cannot be empty or whitespace only")
        return v.strip()


class IkigaiSubmitRequest(BaseModel):
    """
    Request schema for submitting Ikigai test
    
    Contains 4 essay responses, one for each Ikigai dimension.
    Each essay describes the user's perspective on that dimension
    in relation to their chosen profession candidates.
    """
    session_token: str = Field(
        ...,
        min_length=10,
        description="Session token from RIASEC test"
    )
    
    love: IkigaiDimensionInput = Field(
        ...,
        description="Essay: What do you love about these professions?"
    )
    
    good_at: IkigaiDimensionInput = Field(
        ...,
        description="Essay: What skills do you have that match these professions?"
    )
    
    world_needs: IkigaiDimensionInput = Field(
        ...,
        description="Essay: How do these professions serve what the world needs?"
    )
    
    paid_for: IkigaiDimensionInput = Field(
        ...,
        description="Essay: Why can you be paid for working in these professions?"
    )


class IkigaiProfessionClickInput(BaseModel):
    """Input for profession click/selection"""
    profession_id: int = Field(..., description="ID of the clicked profession")
    is_selected: bool = Field(default=True, description="Whether profession is selected")


class IkigaiSubmitWithClicksRequest(BaseModel):
    """Extended request with profession clicks for bonus scoring"""
    session_token: str = Field(..., min_length=10)
    love: IkigaiDimensionInput
    good_at: IkigaiDimensionInput
    world_needs: IkigaiDimensionInput
    paid_for: IkigaiDimensionInput
    clicked_professions: List[IkigaiProfessionClickInput] = Field(
        default=[],
        description="List of professions user explicitly selected/clicked"
    )


# ============== RESPONSE SCHEMAS ==============

class DimensionScoreDetail(BaseModel):
    """Detailed scoring breakdown for one dimension"""
    dimension: str = Field(..., description="Dimension name (love/good_at/world_needs/paid_for)")
    topic_relevance_score: float = Field(..., ge=0.0, le=1.0, alias="K")
    sentiment_score: float = Field(..., ge=0.0, le=1.0, alias="S")
    evidence_score: float = Field(..., ge=0.0, le=1.0, alias="B")
    final_score: float = Field(..., ge=0.0, le=1.0)
    analysis: Optional[str] = Field(default=None, description="AI analysis summary")
    
    class Config:
        populate_by_name = True


class ProfessionIkigaiScore(BaseModel):
    """Complete Ikigai scores for one profession"""
    profession_id: int
    profession_name: str
    profession_description: Optional[str] = None
    riasec_code: Optional[str] = None
    
    # Dimension scores
    dimension_scores: Dict[str, DimensionScoreDetail] = Field(
        default={},
        description="Scores per dimension (love, good_at, world_needs, paid_for)"
    )
    
    # Aggregate scores
    ikigai_average_score: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Average of all dimension final_scores"
    )
    riasec_match_score: float = Field(
        default=0.0,
        ge=0.0,
        le=1.0,
        description="RIASEC personality match score from earlier test"
    )
    click_bonus: float = Field(
        default=0.0,
        ge=0.0,
        le=0.1,
        description="Confidence-adjusted click bonus (0-10%)"
    )
    
    # Final combined score
    total_score: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Final weighted score: (0.4×RIASEC) + (0.5×Ikigai) + Click"
    )
    
    # Human-readable
    match_level: str = Field(
        default="Unknown",
        description="Match level: Low/Moderate/Good/Strong/Excellent"
    )
    match_percentage: float = Field(
        default=0.0,
        ge=0.0,
        le=100.0,
        description="Total score as percentage"
    )


class IkigaiSubmitResponse(BaseModel):
    """Response schema for Ikigai test submission"""
    session_token: str
    status: str = Field(default="ikigai_completed")
    
    # Processing metadata
    total_professions_evaluated: int
    evaluation_time_seconds: float
    
    # Ranked results
    ranked_professions: List[ProfessionIkigaiScore] = Field(
        ...,
        description="Professions ranked by total_score descending"
    )
    
    # Top recommendation
    top_recommendation: Optional[ProfessionIkigaiScore] = Field(
        default=None,
        description="Highest scoring profession"
    )
    
    # Summary insights
    summary: Dict[str, Any] = Field(
        default={},
        description="Summary insights about the evaluation"
    )
    
    evaluated_at: datetime = Field(default_factory=datetime.utcnow)


class IkigaiResultResponse(BaseModel):
    """Response schema for retrieving saved Ikigai results"""
    session_token: str
    status: str
    completed_at: Optional[datetime] = None
    ranked_professions: List[ProfessionIkigaiScore]
    top_recommendation: Optional[ProfessionIkigaiScore] = None
