# app/api/v1/categories/career_profile/routers/session.py
from fastapi import APIRouter, Depends, Request, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.categories.career_profile.services.session_service import SessionService
from app.api.v1.categories.career_profile.schemas.session import SessionCreateRequest, SessionResponse

router = APIRouter(prefix="/career-profile", tags=["Career Profile"])


@router.post("/start", response_model=SessionResponse)
@limiter.limit("10/hour")
async def start_test(
        request: Request,
        data: SessionCreateRequest,
        db: Session = Depends(get_db)
):
    """
    Mulai tes profil karier baru
    Return: session_token + 72 RIASEC questions
    """
    service = SessionService()
    result = service.create_new_session(db, data.user_id)

    return {
        "status": "success",
        "data": result
    }


@router.get("/session/{session_id}")
@limiter.limit("60/minute")
async def get_session_progress(
        request: Request,
        session_id: int,
        db: Session = Depends(get_db)
):
    """Get session progress info"""
    service = SessionService()
    progress = service.get_progress(db, session_id)

    if not progress:
        raise HTTPException(status_code=404, detail="Session not found")

    return progress