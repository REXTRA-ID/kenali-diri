# app/api/v1/router.py
"""
Main API v1 Router Aggregator

This module aggregates all API v1 routers including the career profile endpoints.
"""
from fastapi import APIRouter

from app.api.v1.categories.career_profile.routers import session, riasec
from app.api.v1.general.routers import category, history

# Create main v1 router
api_v1_router = APIRouter(prefix="/api/v1")

# Include career profile routers
api_v1_router.include_router(
    session.router,
    tags=["Career Profile"]
)

api_v1_router.include_router(
    riasec.router,
    tags=["Career Profile"]
)

api_v1_router.include_router(
    category.router,
    tags=["Categories"]
)

api_v1_router.include_router(
    history.router,
    tags=["History"]
)

# Include other routers as needed
# api_v1_router.include_router(
#     other_router,
#     prefix="/other",
#     tags=["Other Category"]
# )


# API documentation endpoint
@api_v1_router.get("/", tags=["System"])
async def api_root():
    """
    API root endpoint
    
    Provides overview of available API endpoints.
    """
    return {
        "message": "Welcome to Career Profile API v1",
        "documentation": "/docs",
        "openapi_spec": "/openapi.json",
        "available_endpoints": {
            "career_profile": {
                "start_session": "POST /api/v1/career-profile/start",
                "get_session": "GET /api/v1/career-profile/session/{session_token}",
                "get_user_sessions": "GET /api/v1/career-profile/sessions/user/{user_id}",
                "abandon_session": "POST /api/v1/career-profile/session/{session_token}/abandon",
                "submit_riasec": "POST /api/v1/career-profile/riasec/submit",
                "get_result": "GET /api/v1/career-profile/riasec/result/{session_token}",
                "get_candidates": "GET /api/v1/career-profile/riasec/candidates/{session_token}",
                "get_questions": "GET /api/v1/career-profile/riasec/questions"
            }
        }
    }