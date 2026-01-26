# app/api/v1/categories/career_profile/routers/ikigai.py
"""
Ikigai Assessment API Router

This router handles endpoints for the Ikigai career assessment feature.
The Ikigai framework evaluates career fit across 4 dimensions:
- Love: What you love doing
- Good At: What you're good at
- World Needs: What the world needs
- Paid For: What you can be paid for

API Endpoints:
- POST /submit: Submit Ikigai essays for AI evaluation
- GET /result/{session_token}: Retrieve saved Ikigai results
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.db.session import get_db
from app.api.v1.categories.career_profile.services.ikigai_service import IkigaiService
from app.api.v1.categories.career_profile.schemas.ikigai import (
    IkigaiSubmitRequest,
    IkigaiSubmitWithClicksRequest,
    IkigaiSubmitResponse,
    IkigaiResultResponse
)

router = APIRouter(
    prefix="/career-profile/ikigai",
    tags=["Career Profile - Ikigai"]
)


@router.post(
    "/submit",
    response_model=IkigaiSubmitResponse,
    status_code=status.HTTP_200_OK,
    summary="Submit Ikigai Test",
    description="""
    Submit Ikigai test essays for AI-powered career evaluation.
    
    **Prerequisites:**
    - Must have completed RIASEC test first
    - Session must be in 'riasec_completed' or 'ikigai_ongoing' status
    
    **Processing:**
    - All essays are evaluated in parallel using AI (async)
    - Each profession candidate is scored across all 4 dimensions
    - Final score = (0.4 × RIASEC) + (0.5 × Ikigai Average) + Click Bonus
    
    **Response:**
    - Ranked list of professions by total score
    - Detailed breakdown of scores per dimension
    - Top recommendation with match percentage
    """
)
async def submit_ikigai_test(
    request: IkigaiSubmitRequest,
    db: Session = Depends(get_db)
) -> IkigaiSubmitResponse:
    """
    Submit Ikigai test with 4 dimension essays
    
    The AI evaluates each essay for:
    - K (Topic Relevance): 40% weight
    - S (Sentiment/Intensity): 30% weight
    - B (Evidence/Specificity): 30% weight
    
    Dimension Score = 0.4K + 0.3S + 0.3B
    
    Args:
        request: IkigaiSubmitRequest with session_token and 4 essays
        db: Database session (injected)
        
    Returns:
        IkigaiSubmitResponse with ranked professions and scores
        
    Raises:
        400: Invalid session status
        404: Session or candidates not found
        500: AI evaluation or processing error
    """
    service = IkigaiService(db)
    return await service.submit_ikigai_test(request)


@router.post(
    "/submit-with-clicks",
    response_model=IkigaiSubmitResponse,
    status_code=status.HTTP_200_OK,
    summary="Submit Ikigai Test with Click Selections",
    description="""
    Submit Ikigai test with essays AND explicit profession selections.
    
    **Click Bonus System:**
    - Clicking a profession adds up to 10% bonus
    - BUT bonus is confidence-adjusted based on essay quality
    - Bonus = 0.10 × AI Score (prevents spam clicking)
    
    Example:
    - Click + good essay (AI=0.8) → 8% bonus
    - Click + bad essay (AI=0.1) → 1% bonus (penalty for spam)
    """
)
async def submit_ikigai_with_clicks(
    request: IkigaiSubmitWithClicksRequest,
    db: Session = Depends(get_db)
) -> IkigaiSubmitResponse:
    """
    Submit Ikigai test with click selections for bonus scoring
    
    Args:
        request: Extended request with clicked profession IDs
        db: Database session
        
    Returns:
        IkigaiSubmitResponse with click-adjusted scores
    """
    service = IkigaiService(db)
    
    # Extract clicked profession IDs
    clicked_ids = [
        click.profession_id 
        for click in request.clicked_professions 
        if click.is_selected
    ]
    
    # Convert to base request
    base_request = IkigaiSubmitRequest(
        session_token=request.session_token,
        love=request.love,
        good_at=request.good_at,
        world_needs=request.world_needs,
        paid_for=request.paid_for
    )
    
    return await service.submit_ikigai_test(base_request, clicked_ids)


@router.get(
    "/result/{session_token}",
    response_model=IkigaiResultResponse,
    status_code=status.HTTP_200_OK,
    summary="Get Ikigai Results",
    description="""
    Retrieve saved Ikigai test results for a session.
    
    **Returns:**
    - Ranked profession list from previous submission
    - Score breakdowns and match levels
    - Top recommendation
    
    **Note:** Results are only available after completing the Ikigai test.
    """
)
async def get_ikigai_result(
    session_token: str,
    db: Session = Depends(get_db)
) -> IkigaiResultResponse:
    """
    Get saved Ikigai results by session token
    
    Args:
        session_token: The session token from test
        db: Database session
        
    Returns:
        IkigaiResultResponse with saved results
        
    Raises:
        404: Session or results not found
    """
    # TODO: Implement result retrieval from database
    # For now, return placeholder response
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Result retrieval not yet implemented. "
               "Submit a new test to get immediate results."
    )


@router.get(
    "/dimensions",
    status_code=status.HTTP_200_OK,
    summary="Get Ikigai Dimensions Info",
    description="Get information about the 4 Ikigai dimensions and scoring criteria"
)
async def get_ikigai_dimensions():
    """
    Get Ikigai dimension descriptions
    
    Returns information about each dimension to help users
    understand what to write in their essays.
    """
    return {
        "dimensions": [
            {
                "id": "love",
                "name": "What You Love",
                "japanese": "好きなこと (Suki na koto)",
                "prompt": "What activities, topics, or aspects of these professions do you genuinely enjoy? Describe what makes you excited or happy about them.",
                "scoring_focus": [
                    "Passion indicators",
                    "Enthusiasm in language",
                    "Specific activities mentioned"
                ]
            },
            {
                "id": "good_at",
                "name": "What You're Good At",
                "japanese": "得意なこと (Tokui na koto)",
                "prompt": "What skills, abilities, or talents do you have that align with these professions? Include any relevant experience or achievements.",
                "scoring_focus": [
                    "Skill relevance",
                    "Concrete achievements",
                    "Experience evidence"
                ]
            },
            {
                "id": "world_needs",
                "name": "What The World Needs",
                "japanese": "世界が必要としていること",
                "prompt": "How do these professions contribute to society? What problems do they solve or what value do they create for others?",
                "scoring_focus": [
                    "Social impact awareness",
                    "Problem-solution thinking",
                    "Purpose alignment"
                ]
            },
            {
                "id": "paid_for",
                "name": "What You Can Be Paid For",
                "japanese": "お金になること (Okane ni naru koto)",
                "prompt": "Why is this profession financially viable? What market demand exists and why would employers value your contribution?",
                "scoring_focus": [
                    "Market awareness",
                    "Career viability",
                    "Professional value proposition"
                ]
            }
        ],
        "scoring_formula": {
            "dimension_score": "0.4×K + 0.3×S + 0.3×B",
            "components": {
                "K": "Topic Relevance (40%)",
                "S": "Sentiment & Intensity (30%)",
                "B": "Evidence & Specificity (30%)"
            },
            "final_score": "0.4×RIASEC + 0.5×IkigaiAvg + ClickBonus"
        }
    }
