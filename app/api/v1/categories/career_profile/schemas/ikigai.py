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

class StartIkigaiRequest(BaseModel):
    session_token: str

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


class SubmitDimensionRequest(BaseModel):
    session_token: str
    dimension_name: str          # "what_you_love" | "what_you_are_good_at" |
                                 # "what_the_world_needs" | "what_you_can_be_paid_for"
    selected_profession_id: Optional[int] = None
    selection_type: str          # "selected" | "not_selected"
    reasoning_text: str

    @validator("dimension_name")
    def validate_dimension(cls, v):
        valid = {"what_you_love", "what_you_are_good_at", "what_the_world_needs", "what_you_can_be_paid_for"}
        if v not in valid:
            raise ValueError(f"dimension_name tidak valid. Pilih dari: {valid}")
        return v

    @validator("selection_type")
    def validate_selection_type(cls, v):
        if v not in {"selected", "not_selected"}:
            raise ValueError("selection_type harus 'selected' atau 'not_selected'")
        return v

    @validator("reasoning_text")
    def validate_reasoning(cls, v):
        if len(v.strip()) < 10:
            raise ValueError("reasoning_text minimal 10 karakter")
        return v.strip()

    def validate_consistency(self):
        """Validasi konsistensi selected_profession_id dan selection_type."""
        if self.selected_profession_id is not None and self.selection_type != "selected":
            raise ValueError("Jika selected_profession_id diisi, selection_type harus 'selected'")
        if self.selected_profession_id is None and self.selection_type != "not_selected":
            raise ValueError("Jika selected_profession_id null, selection_type harus 'not_selected'")


class DimensionSubmitResponse(BaseModel):
    """Response untuk submit dimensi yang bukan dimensi ke-4 (belum selesai)."""
    session_token: str
    dimension_saved: str         # nama dimensi yang baru disimpan
    dimensions_completed: List[str]
    dimensions_remaining: List[str]
    all_completed: bool          # False jika masih ada dimensi yang belum dijawab
    message: str


class ProfessionScoreBreakdown(BaseModel):
    rank: int
    profession_id: int
    total_score: float
    score_what_you_love: float
    score_what_you_are_good_at: float
    score_what_the_world_needs: float
    score_what_you_can_be_paid_for: float
    intrinsic_score: float
    extrinsic_score: float


class IkigaiCompletionResponse(BaseModel):
    """Response setelah dimensi ke-4 selesai dan scoring selesai."""
    session_token: str
    status: str                              # "completed"
    top_2_professions: List[ProfessionScoreBreakdown]
    total_professions_evaluated: int
    tie_breaking_applied: bool
    calculated_at: str                       # ISO8601
    message: str


class DimensionContent(BaseModel):
    what_you_love: str
    what_you_are_good_at: str
    what_the_world_needs: str
    what_you_can_be_paid_for: str


class CandidateWithContent(BaseModel):
    profession_id: int
    profession_name: str
    display_order: int
    congruence_score: float
    dimension_content: DimensionContent


class IkigaiContentResponse(BaseModel):
    session_token: str
    status: str
    generated_at: str
    regenerated: bool
    total_display_candidates: int
    message: str
    candidates_with_content: List[CandidateWithContent]
