# app/api/v1/categories/career_profile/routers/riasec.py
from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.api.v1.categories.career_profile.services.riasec_service import (
    RIASECService,
    RIASECAnswerItem
)
from app.api.v1.categories.career_profile.services.profession_expansion import (
    ProfessionExpansionService
)

from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.riasec_repo import RIASECRepository

from app.api.v1.categories.career_profile.schemas.riasec import (
    RIASECResultResponse, 
    RIASECAnswerItem, 
    RIASECSubmitRequest, 
    CandidatesResponse
)

from pprint import pprint # debug purposes

router = APIRouter(
    prefix="/career-profile/riasec",
    tags=["Career Profile - RIASEC Test"]
)   


# Endpoints
@router.post("/submit", response_model=RIASECResultResponse)
async def submit_riasec_test(
    request: RIASECSubmitRequest,
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    Submit RIASEC test responses
    
    Processes user responses, calculates scores, classifies RIASEC code,
    and generates profession candidates using 4-tier expansion algorithm.
    
    Args:
        request: Contains session_token and 12 responses
        db: Database session
        
    Returns:
        Complete test result with scores, code info, and candidates
    """
    try:
        # Convert request to service format
        responses = [
            RIASECAnswerItem(
                question_id=r.question_id,
                answer=r.answer_value
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

@router.get("/result/{session_token}")
async def get_riasec_result(
    session_token: str,
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    Get RIASEC test result for a completed session
    
    Retrieves the stored test result including scores, code information,
    and profession candidates. Useful when user refreshes the page.
    
    Args:
        session_token: The session token
        db: Database session
        
    Returns:
        Complete test result (same format as submit endpoint)
    """
    try:
        riasec_service = RIASECService(db)
        
        # Get basic result
        result = riasec_service.get_result(session_token)
        
        print('aman')
        
        # Get full result with code info
        session_repo = SessionRepository(db)
        riasec_repo = RIASECRepository(db)
        
        session = session_repo.get_session_by_token(session_token)
        full_result = riasec_repo.get_result(session.id)
        
        print('aman')
        
        # Get candidates
        profession_service = ProfessionExpansionService(db)
        candidates_data = profession_service.get_candidates_with_details(session.id)
        
        return {
            "session_token": session_token,
            "status": session.status,
            "scores": {
                "score_r": result["scores"]["R"],
                "score_i": result["scores"]["I"],
                "score_a": result["scores"]["A"],
                "score_s": result["scores"]["S"],
                "score_e": result["scores"]["E"],
                "score_c": result["scores"]["C"]
            },
            "code_info": {
                "riasec_code": full_result.riasec_code.riasec_code,
                "riasec_title": full_result.riasec_code.riasec_title,
                "riasec_description": full_result.riasec_code.riasec_description,
                "strengths": full_result.riasec_code.strengths,
                "challenges": full_result.riasec_code.challenges,
                "strategies": full_result.riasec_code.strategies,
                "work_environments": full_result.riasec_code.work_environments,
                "interaction_styles": full_result.riasec_code.interaction_styles
            },
            "classification_type": result["classification_type"],
            "is_inconsistent_profile": result["is_inconsistent_profile"],
            "candidates_summary": {
                "total_candidates": len(candidates_data.get("candidates", [])),
                "expansion_summary": candidates_data.get("expansion_summary", {}),
                "user_top_3_types": candidates_data.get("user_top_3_types", []),
                "user_scores": candidates_data.get("user_scores", {})
            },
            "calculated_at": result["calculated_at"].isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve result: {str(e)}"
        )


@router.get("/candidates/{session_token}", response_model=CandidatesResponse)
async def get_candidates(
    session_token: str,
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    Get profession candidates for a session
    
    Retrieves the list of profession candidates generated by the
    4-tier expansion algorithm, including expansion metadata.
    
    Args:
        session_token: The session token
        db: Database session
        
    Returns:
        Candidates list with expansion summary
    """
    try:
        profession_service = ProfessionExpansionService(db)
        session_repo = SessionRepository(db)
        
        session = session_repo.get_session_by_token(session_token)
        candidates_data = profession_service.get_candidates_with_details(session.id)
        
        return {
            "user_riasec_code": candidates_data.get("user_riasec_code", ""),
            "user_top_3_types": candidates_data.get("user_top_3_types", []),
            "user_scores": candidates_data.get("user_scores", {}),
            "candidates": candidates_data.get("candidates", []),
            "expansion_summary": candidates_data.get("expansion_summary", {}),
            "total_candidates": len(candidates_data.get("candidates", []))
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve candidates: {str(e)}"
        )


@router.get("/questions")
async def get_all_questions() -> Dict[str, Any]:
    """
    Get all RIASEC questions
    
    Retrieves the complete list of RIASEC questions from the JSON file.
    Useful for testing or displaying question bank.
    
    Returns:
        All questions grouped by RIASEC type
    """
    try:
        questions = RIASECService.load_questions_data()
        
        # Group by RIASEC type
        grouped = {
            'R': [],
            'I': [],
            'A': [],
            'S': [],
            'E': [],
            'C': []
        }
        
        for q_id, question in questions.items():
            riasec_type = question['riasec_type']
            grouped[riasec_type].append({
                "question_id": question["question_id"],
                "question_text": question["question_text"],
                "category": question.get("category", "general")
            })
        
        return {
            "total_questions": len(questions),
            "questions_by_type": grouped,
            "type_counts": {k: len(v) for k, v in grouped.items()}
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to load questions: {str(e)}"
        )