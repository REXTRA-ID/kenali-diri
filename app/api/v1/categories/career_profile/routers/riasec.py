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
    Submit RIASEC test responses
    
    Processes user responses, calculates scores, classifies RIASEC code,
    and generates profession candidates using 4-tier expansion algorithm.
    
    Args:
        request: Contains session_token and 72 responses (12 per RIASEC type)
        db: Database session
        
    Returns:
        Complete test result with scores, code info, and candidates
    """
    try:
        # Convert request to service format
        responses = [
            RIASECAnswerItem(
                question_id=r.question_id,
                answer_value=r.answer_value
            )
            for r in request.responses
        ]
        
        # Submit test through service
        riasec_service = RIASECService(db)
        result = riasec_service.submit_riasec_test(
            session_token=request.session_token,
            responses=responses
        )
        
        # Format response
        return {
            "session_token": result["session_token"],
            "status": result["status"],
            "scores": {
                "score_r": result["result"]["scores"]["R"],
                "score_i": result["result"]["scores"]["I"],
                "score_a": result["result"]["scores"]["A"],
                "score_s": result["result"]["scores"]["S"],
                "score_e": result["result"]["scores"]["E"],
                "score_c": result["result"]["scores"]["C"]
            },
            "code_info": {
                "riasec_code": result["result"]["riasec_code"],
                "riasec_title": result["result"]["riasec_title"],
                "riasec_description": result["result"]["riasec_description"],
                "strengths": result["result"]["strengths"],
                "challenges": result["result"]["challenges"],
                "strategies": result["result"]["strategies"],
                "work_environments": result["result"]["work_environments"],
                "interaction_styles": result["result"]["interaction_styles"]
            },
            "classification_type": result["result"]["classification_type"],
            "is_inconsistent_profile": result["result"]["is_inconsistent_profile"],
            "candidates_summary": {
                "total_candidates": result["candidates"]["total_candidates"],
                "expansion_summary": result["candidates"]["expansion_summary"],
                "top_candidates": result["candidates"]["top_candidates"]
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to submit RIASEC test: {str(e)}"
        )

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
