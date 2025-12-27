# app/api/v1/categories/career_profile/routers/riasec.py
from fastapi import APIRouter, Depends, Request, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.categories.career_profile.services.riasec_service import RIASECService
from app.api.v1.categories.career_profile.services.session_service import SessionService
from app.api.v1.categories.career_profile.schemas.riasec import (
    RIASECSubmitRequest,
    RIASECResultResponse
)

router = APIRouter(prefix="/career-profile/riasec", tags=["RIASEC"])

@router.post("/submit", response_model=RIASECResultResponse)
@limiter.limit("5/hour")
async def submit_riasec(
    request: Request,
    data: RIASECSubmitRequest,
    db: Session = Depends(get_db)
):
    """
    Submit 72 RIASEC responses
    Return: riasec_code, scores, classification
    """
    session_service = SessionService()
    riasec_service = RIASECService()

    # Cari session berdasarkan token
    session = session_service.get_session_by_token(db, data.session_token)
    if not session:
        raise HTTPException(status_code=404, detail="Session token tidak valid")

    # Cek apakah sudah pernah submit
    if session.riasec_completed_at is not None:
        raise HTTPException(status_code=400, detail="RIASEC sudah diselesaikan untuk sesi ini")

    # Logika perhitungan berat
    result = riasec_service.submit_and_calculate(db, session.id, data.responses)
    
    return result

@router.get("/result/{session_token}", response_model=RIASECResultResponse)
@limiter.limit("60/minute")
async def get_riasec_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db)
):
    """Get RIASEC result"""
    service = RIASECService()
    session_service = SessionService()
    
    session = session_service.get_session_by_token(db, session_token)
    result = service.get_result(db, session.id)
    
    if not result:
        raise HTTPException(status_code=404, detail="RIASEC result not found")
    
    return result
