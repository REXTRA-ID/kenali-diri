from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.api.v1.dependencies.auth import get_current_user
from app.api.v1.categories.career_profile.services.result_service import ResultService
from app.api.v1.categories.career_profile.schemas.result import (
    PersonalityResultResponse,
    FitCheckResultResponse,
    RecommendationResultResponse
)
from app.db.models.user import User

router = APIRouter(
    prefix="/result",
    tags=["Career Profile - Result"]
)

@router.get(
    "/personality/{session_token}",
    response_model=PersonalityResultResponse,
    summary="Get RIASEC Personality Result"
)
async def get_personality_result(
    session_token: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get RIASEC scores and the generated personality description from AI.
    """
    service = ResultService(db)
    return await service.get_personality_result(current_user, session_token)


@router.get(
    "/fit-check/{session_token}",
    response_model=FitCheckResultResponse,
    summary="Get Fit Check Classification Result"
)
async def get_fit_check_result(
    session_token: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get rule-based classification of Fit Check based on Holland Hexagon match.
    """
    service = ResultService(db)
    return service.get_fit_check_result(current_user, session_token)


@router.get(
    "/recommendation/{session_token}",
    response_model=RecommendationResultResponse,
    summary="Get Final Career Recommendation Narrative"
)
async def get_recommendation_result(
    session_token: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get the top 2 profession recommendation narratives and Ikigai dimension summary.
    """
    service = ResultService(db)
    return service.get_recommendation_result(current_user, session_token)
