# app/api/v1/categories/career_profile/services/ikigai_service.py
"""
Ikigai Evaluation Service

This service orchestrates the AI-powered evaluation of user essays
against profession candidates. Uses async/parallel processing for
high performance.

Key Features:
- Parallel AI evaluation using asyncio.gather
- Weighted scoring formula: Score = 0.4K + 0.3S + 0.3B
- Confidence-adjusted click bonus
- Comprehensive error handling
"""
import asyncio
import time
from typing import Dict, List, Any, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
import structlog

from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
from app.api.v1.categories.career_profile.schemas.ikigai import (
    IkigaiSubmitRequest,
    IkigaiSubmitResponse,
    ProfessionIkigaiScore,
    DimensionScoreDetail
)
from app.shared.ai_client import gemini_client
from app.shared.scoring_utils import (
    calculate_confidence_adjusted_click,
    calculate_final_profession_score,
    normalize_score_to_percentage,
    get_match_level
)

logger = structlog.get_logger()


class IkigaiService:
    """
    Service for Ikigai test evaluation and scoring
    
    Handles:
    - Retrieving profession candidates from RIASEC results
    - Parallel AI evaluation of user essays
    - Score calculation and aggregation
    - Result ranking and storage
    """
    
    # Dimension mapping for iteration
    DIMENSIONS = ["love", "good_at", "world_needs", "paid_for"]
    
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = SessionRepository(db)
        self.profession_repo = ProfessionRepository(db)
    
    async def submit_ikigai_test(
        self,
        request: IkigaiSubmitRequest,
        clicked_profession_ids: Optional[List[int]] = None
    ) -> IkigaiSubmitResponse:
        """
        Submit and process Ikigai test with parallel AI evaluation
        
        Flow:
        1. Validate session and get candidates
        2. Extract essays from request
        3. Parallel evaluate all (profession × dimension) combinations
        4. Calculate weighted scores
        5. Rank and return results
        
        Args:
            request: IkigaiSubmitRequest with session_token and 4 essays
            clicked_profession_ids: List of profession IDs user clicked/selected
            
        Returns:
            IkigaiSubmitResponse with ranked professions and scores
        """
        start_time = time.time()
        
        try:
            # 1. Validate session
            session = self.session_repo.get_session_by_token(request.session_token)
            
            if session.status not in ['riasec_completed', 'ikigai_ongoing']:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid session status for Ikigai: {session.status}. "
                           "Must complete RIASEC first."
                )
            
            # 2. Get candidate professions from RIASEC results
            candidates = self._get_profession_candidates(session.id)
            
            if not candidates:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="No profession candidates found. Complete RIASEC test first."
                )
            
            # 3. Extract essays from request
            essays = {
                "love": request.love.text_input,
                "good_at": request.good_at.text_input,
                "world_needs": request.world_needs.text_input,
                "paid_for": request.paid_for.text_input
            }
            
            # 4. Parallel evaluate all professions
            profession_scores = await self._evaluate_all_professions_parallel(
                candidates=candidates,
                essays=essays,
                clicked_ids=clicked_profession_ids or []
            )
            
            # 5. Sort by total score descending
            ranked_professions = sorted(
                profession_scores,
                key=lambda x: x.total_score,
                reverse=True
            )
            
            # 6. Calculate evaluation time
            evaluation_time = time.time() - start_time
            
            # 7. Build response
            response = IkigaiSubmitResponse(
                session_token=request.session_token,
                status="ikigai_completed",
                total_professions_evaluated=len(ranked_professions),
                evaluation_time_seconds=round(evaluation_time, 2),
                ranked_professions=ranked_professions,
                top_recommendation=ranked_professions[0] if ranked_professions else None,
                summary=self._generate_summary(ranked_professions)
            )
            
            # 8. Update session status (placeholder - save results to DB)
            # TODO: Save ikigai results to database
            # self.session_repo.update_session_status(
            #     session_id=session.id,
            #     status='ikigai_completed',
            #     timestamp_field='ikigai_completed_at'
            # )
            
            logger.info(
                "ikigai_test_completed",
                session_token=request.session_token,
                professions_evaluated=len(ranked_professions),
                evaluation_time=evaluation_time,
                top_score=ranked_professions[0].total_score if ranked_professions else 0
            )
            
            return response
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(
                "ikigai_test_failed",
                session_token=request.session_token,
                error=str(e)
            )
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to process Ikigai test: {str(e)}"
            )
    
    def _get_profession_candidates(self, session_id: int) -> List[Dict[str, Any]]:
        """
        Get profession candidates from RIASEC results
        
        Args:
            session_id: Test session ID
            
        Returns:
            List of profession candidate dictionaries
        """
        try:
            candidates_obj = self.profession_repo.get_candidates_by_session_id(session_id)
            
            if not candidates_obj or not candidates_obj.candidates_data:
                return []
            
            # Extract candidates from JSONB data
            candidates_data = candidates_obj.candidates_data
            raw_candidates = candidates_data.get('candidates', [])
            
            # Enrich with profession details (placeholder)
            # TODO: Join with digital_professions table for full details
            enriched = []
            for i, candidate in enumerate(raw_candidates):
                enriched.append({
                    'profession_id': candidate.get('profession_id', i + 1),
                    'profession_name': candidate.get('profession_name', f'Profession {i + 1}'),
                    'profession_description': candidate.get('profession_description', ''),
                    'riasec_code': candidate.get('matched_code', ''),
                    'riasec_match_score': candidate.get('congruence_score', 0.5),
                    'path': candidate.get('path'),  # For split-path scenarios
                })
            
            return enriched
            
        except Exception as e:
            logger.warning(
                "get_candidates_failed",
                session_id=session_id,
                error=str(e)
            )
            return []
    
    async def _evaluate_all_professions_parallel(
        self,
        candidates: List[Dict[str, Any]],
        essays: Dict[str, str],
        clicked_ids: List[int]
    ) -> List[ProfessionIkigaiScore]:
        """
        Evaluate all professions across all dimensions in parallel
        
        Uses asyncio.gather for maximum concurrency. Instead of
        O(professions × dimensions) sequential calls, runs them
        all simultaneously.
        
        Args:
            candidates: List of profession candidates
            essays: Dict of dimension essays
            clicked_ids: List of clicked profession IDs
            
        Returns:
            List of ProfessionIkigaiScore objects
        """
        # Create all evaluation tasks
        tasks = []
        task_mapping = []  # Track which task belongs to which profession/dimension
        
        for candidate in candidates:
            for dimension in self.DIMENSIONS:
                task = self._evaluate_single_dimension(
                    profession_name=candidate['profession_name'],
                    profession_description=candidate.get('profession_description', ''),
                    essay=essays[dimension],
                    dimension=dimension
                )
                tasks.append(task)
                task_mapping.append({
                    'candidate': candidate,
                    'dimension': dimension
                })
        
        logger.info(
            "starting_parallel_evaluation",
            total_tasks=len(tasks),
            professions=len(candidates),
            dimensions=len(self.DIMENSIONS)
        )
        
        # Execute all tasks in parallel
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # =====================================================================
        # FAIL-FAST: Check for critical failure rates
        # =====================================================================
        total_count = len(results)
        failed_count = sum(1 for r in results if isinstance(r, Exception))
        success_count = total_count - failed_count
        
        # Calculate failure rate
        failure_rate = failed_count / total_count if total_count > 0 else 0
        
        logger.info(
            "parallel_evaluation_stats",
            total_tasks=total_count,
            successful=success_count,
            failed=failed_count,
            failure_rate=f"{failure_rate * 100:.1f}%"
        )
        
        # CRITICAL: If ALL evaluations failed, don't return misleading 0% scores
        if total_count > 0 and failed_count == total_count:
            # Get first error for context
            first_error = next((r for r in results if isinstance(r, Exception)), None)
            error_message = str(first_error) if first_error else "Unknown error"
            
            logger.critical(
                "all_ai_evaluations_failed",
                total_failed=failed_count,
                first_error=error_message,
                hint="Check AI API credentials, rate limits, or service availability"
            )
            
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=(
                    "AI evaluation service is currently unavailable. "
                    "All evaluation requests failed. Please try again later. "
                    f"Error: {error_message[:200]}"
                )
            )
        
        # WARNING: If most (>80%) evaluations failed, log critical warning
        # but allow graceful degradation with partial results
        HIGH_FAILURE_THRESHOLD = 0.8
        if failure_rate > HIGH_FAILURE_THRESHOLD:
            first_error = next((r for r in results if isinstance(r, Exception)), None)
            logger.error(
                "high_ai_evaluation_failure_rate",
                failure_rate=f"{failure_rate * 100:.1f}%",
                failed=failed_count,
                succeeded=success_count,
                first_error=str(first_error) if first_error else "Unknown",
                hint="Partial results returned. Consider investigating AI service issues."
            )
        
        # =====================================================================
        # Process results and group by profession
        # =====================================================================
        profession_results: Dict[int, Dict] = {}
        
        for i, result in enumerate(results):
            mapping = task_mapping[i]
            candidate = mapping['candidate']
            dimension = mapping['dimension']
            prof_id = candidate['profession_id']
            
            # Initialize profession entry if needed
            if prof_id not in profession_results:
                profession_results[prof_id] = {
                    'candidate': candidate,
                    'dimension_scores': {}
                }
            
            # Handle exceptions gracefully (for partial failures)
            if isinstance(result, Exception):
                logger.warning(
                    "dimension_evaluation_failed",
                    profession_id=prof_id,
                    dimension=dimension,
                    error=str(result)
                )
                # Use zero scores for failed evaluations
                result = {
                    "scores": {"K": 0.0, "S": 0.0, "B": 0.0, "final_dimension_score": 0.0},
                    "analysis": {"topic_relevance": "Evaluation failed - AI service error"}
                }
            
            # Store dimension result
            profession_results[prof_id]['dimension_scores'][dimension] = result
        
        # Build final ProfessionIkigaiScore objects
        final_scores = []
        
        for prof_id, data in profession_results.items():
            candidate = data['candidate']
            dimension_scores = data['dimension_scores']
            
            # Build dimension score details
            dimension_details = {}
            dimension_finals = []
            
            for dim in self.DIMENSIONS:
                dim_result = dimension_scores.get(dim, {})
                scores = dim_result.get('scores', {})
                analysis = dim_result.get('analysis', {})
                
                detail = DimensionScoreDetail(
                    dimension=dim,
                    K=scores.get('K', 0.0),
                    S=scores.get('S', 0.0),
                    B=scores.get('B', 0.0),
                    final_score=scores.get('final_dimension_score', 0.0),
                    analysis=analysis.get('topic_relevance', '')
                )
                dimension_details[dim] = detail
                dimension_finals.append(detail.final_score)
            
            # Calculate ikigai average
            ikigai_avg = sum(dimension_finals) / len(dimension_finals) if dimension_finals else 0.0
            
            # Calculate click bonus
            is_clicked = prof_id in clicked_ids
            ai_confidence = ikigai_avg  # Use ikigai score as confidence
            click_bonus = calculate_confidence_adjusted_click(is_clicked, ai_confidence)
            
            # Calculate final total score
            riasec_score = candidate.get('riasec_match_score', 0.5)
            total_score = calculate_final_profession_score(
                riasec_match_score=riasec_score,
                dimension_scores={dim: dimension_details[dim].final_score for dim in self.DIMENSIONS},
                click_bonus=click_bonus
            )
            
            # Build final score object
            prof_score = ProfessionIkigaiScore(
                profession_id=prof_id,
                profession_name=candidate['profession_name'],
                profession_description=candidate.get('profession_description'),
                riasec_code=candidate.get('riasec_code'),
                dimension_scores=dimension_details,
                ikigai_average_score=round(ikigai_avg, 4),
                riasec_match_score=round(riasec_score, 4),
                click_bonus=round(click_bonus, 4),
                total_score=round(total_score, 4),
                match_level=get_match_level(total_score),
                match_percentage=normalize_score_to_percentage(total_score)
            )
            
            final_scores.append(prof_score)
        
        return final_scores
    
    async def _evaluate_single_dimension(
        self,
        profession_name: str,
        profession_description: str,
        essay: str,
        dimension: str
    ) -> Dict[str, Any]:
        """
        Evaluate a single essay for one profession-dimension pair
        
        Args:
            profession_name: Name of the profession
            profession_description: Description of the profession
            essay: User's essay for this dimension
            dimension: Dimension name (love/good_at/world_needs/paid_for)
            
        Returns:
            Dict with scores and analysis from AI
        """
        try:
            result = await gemini_client.evaluate_ikigai_response(
                user_essay=essay,
                profession_name=profession_name,
                profession_description=profession_description,
                dimension=dimension
            )
            return result
        except Exception as e:
            logger.error(
                "single_dimension_eval_error",
                profession=profession_name,
                dimension=dimension,
                error=str(e)
            )
            raise
    
    def _generate_summary(self, ranked_professions: List[ProfessionIkigaiScore]) -> Dict[str, Any]:
        """
        Generate summary insights from evaluation results
        
        Args:
            ranked_professions: List of scored professions
            
        Returns:
            Dict with summary statistics and insights
        """
        if not ranked_professions:
            return {"message": "No professions evaluated"}
        
        scores = [p.total_score for p in ranked_professions]
        
        # Find strongest and weakest dimensions across top profession
        top_prof = ranked_professions[0]
        dim_scores = {
            dim: top_prof.dimension_scores.get(dim, DimensionScoreDetail(
                dimension=dim, K=0, S=0, B=0, final_score=0
            )).final_score
            for dim in self.DIMENSIONS
        }
        
        strongest_dim = max(dim_scores, key=dim_scores.get)
        weakest_dim = min(dim_scores, key=dim_scores.get)
        
        return {
            "total_evaluated": len(ranked_professions),
            "average_score": round(sum(scores) / len(scores), 3),
            "highest_score": round(max(scores), 3),
            "lowest_score": round(min(scores), 3),
            "score_spread": round(max(scores) - min(scores), 3),
            "top_profession": top_prof.profession_name,
            "top_match_level": top_prof.match_level,
            "strongest_dimension": strongest_dim,
            "weakest_dimension": weakest_dim,
            "recommendation": self._generate_recommendation_text(top_prof, strongest_dim, weakest_dim)
        }
    
    def _generate_recommendation_text(
        self,
        top_prof: ProfessionIkigaiScore,
        strongest_dim: str,
        weakest_dim: str
    ) -> str:
        """Generate human-readable recommendation text"""
        dim_labels = {
            "love": "passion",
            "good_at": "skills",
            "world_needs": "purpose",
            "paid_for": "career fit"
        }
        
        return (
            f"Based on your responses, {top_prof.profession_name} is your strongest match "
            f"with a {top_prof.match_percentage}% compatibility score. "
            f"Your {dim_labels.get(strongest_dim, strongest_dim)} alignment is particularly strong. "
            f"Consider developing your {dim_labels.get(weakest_dim, weakest_dim)} aspects "
            f"to strengthen this career path."
        )
