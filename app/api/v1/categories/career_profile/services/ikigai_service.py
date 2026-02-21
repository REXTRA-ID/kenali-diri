import asyncio
import json
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional
import time

from sqlalchemy.orm import Session
from fastapi import HTTPException, status
import structlog

from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
from app.api.v1.categories.career_profile.services.profession_expansion import ProfessionExpansionService
from app.api.v1.categories.career_profile.models.ikigai import IkigaiResponse, IkigaiDimensionScores, IkigaiTotalScores
from app.api.v1.categories.career_profile.schemas.ikigai import (
    IkigaiContentResponse,
    DimensionContent,
    CandidateWithContent,
    DimensionSubmitResponse,
    IkigaiCompletionResponse,
    ProfessionScoreBreakdown
)
from app.db.models.user import User
from app.shared.ai_client import gemini_client
from app.shared.cache import redis_client
from app.shared.scoring_utils import (
    calculate_min_max_normalization,
    calculate_ikigai_dimension_average,
    calculate_confidence_adjusted_click,
    calculate_final_profession_score
)

logger = structlog.get_logger()

# Consts
IKIGAI_DIMENSIONS = [
    "what_you_love",
    "what_you_are_good_at",
    "what_the_world_needs",
    "what_you_can_be_paid_for"
]

class IkigaiService:
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = SessionRepository(db)
        self.profession_repo = ProfessionRepository(db)
        self.expansion_service = ProfessionExpansionService(db)
    
    # --------------------------------------------------------------------------
    # PHASE 1: GENERATE CONTENT
    # --------------------------------------------------------------------------
    async def start_ikigai_session(self, user: User, session_token: str) -> IkigaiContentResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")
        
        if session.status not in ["riasec_completed", "ikigai_ongoing"]:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Invalid state: {session.status}")
        
        if session.status == "riasec_completed":
            session.status = "ikigai_ongoing"
            self.db.commit()

        # check if already in redis
        cache_key = f"ikigai:content:{session_token}"
        cached_data = redis_client.get(cache_key)
        if cached_data:
            content = json.loads(cached_data)
            return IkigaiContentResponse(
                session_token=session_token,
                status="ikigai_ongoing",
                generated_at=content["generated_at"],
                regenerated=False,
                total_display_candidates=len(content["candidates"]),
                message="Konten cache ditarik",
                candidates_with_content=content["candidates"]
            )
        
        # generate content
        candidates = await self._generate_ikigai_content(session.id)
        
        # cache to Redis
        now_str = datetime.now(timezone.utc).isoformat()
        cache_payload = {
            "generated_at": now_str,
            "candidates": candidates
        }
        redis_client.setex(cache_key, 7200, json.dumps(cache_payload))
        
        return IkigaiContentResponse(
            session_token=session_token,
            status="ikigai_ongoing",
            generated_at=now_str,
            regenerated=True,
            total_display_candidates=len(candidates),
            message="Sesi dimulai dan konten berhasil di-generate",
            candidates_with_content=candidates
        )

    async def get_ikigai_content(self, user: User, session_token: str) -> IkigaiContentResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")
            
        if session.status != "ikigai_ongoing":
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Sesi Ikigai tidak dalam status ongoing")
            
        cache_key = f"ikigai:content:{session_token}"
        cached_data = redis_client.get(cache_key)
        
        if cached_data:
            content = json.loads(cached_data)
            return IkigaiContentResponse(
                session_token=session_token,
                status="ikigai_ongoing",
                generated_at=content["generated_at"],
                regenerated=False,
                total_display_candidates=len(content["candidates"]),
                message="Berhasil menarik konten Ikigai dari sesi.",
                candidates_with_content=content["candidates"]
            )
        
        # Redis miss -> regenerate since it's still ongoing
        candidates = await self._generate_ikigai_content(session.id)
        now_str = datetime.now(timezone.utc).isoformat()
        cache_payload = {
            "generated_at": now_str,
            "candidates": candidates
        }
        redis_client.setex(cache_key, 7200, json.dumps(cache_payload))
        
        return IkigaiContentResponse(
            session_token=session_token,
            status="ikigai_ongoing",
            generated_at=now_str,
            regenerated=True,
            total_display_candidates=len(candidates),
            message="Konten lama expired, regenerasi berhasil",
            candidates_with_content=candidates
        )

    async def _generate_ikigai_content(self, session_id: int) -> List[Dict]:
        candidates_data = self.expansion_service.get_candidates_with_details(session_id)
        # Ambil maksimal 5 kandidat dari display order 1..5
        top_candidates = [c for c in candidates_data['candidates'] if c.get('display_order', 99) <= 5]
        
        # Prepare context for AI batch generate
        profession_contexts = []
        for c in top_candidates:
            profession_contexts.append({
                "profession_id": c['profession_id'],
                "name": c.get('profession_name'),
                "riasec_code": c.get('riasec_code'), # Might be missed, we can fallback to candidates matched_code
                "riasec_title": c.get('riasec_code'),
                "about_description": c.get('profession_description'),
                "riasec_description": "",
                "activities": [],
                "hard_skills_required": [],
                "soft_skills_required": [],
                "tools_required": [],
                "market_insights": [],
            })
            
        ai_responses = await gemini_client.generate_ikigai_content(profession_contexts)
        
        ai_map = {item['profession_id']: item for item in ai_responses if 'profession_id' in item}
        
        result_candidates = []
        for c in top_candidates:
            pid = c['profession_id']
            ai_data = ai_map.get(pid, {})
            # fallback jika gagal content
            what_you_love = ai_data.get('what_you_love', 'Deskripsi tidak tersedia.')
            what_you_are_good_at = ai_data.get('what_you_are_good_at', 'Deskripsi tidak tersedia.')
            what_the_world_needs = ai_data.get('what_the_world_needs', 'Deskripsi tidak tersedia.')
            what_you_can_be_paid_for = ai_data.get('what_you_can_be_paid_for', 'Deskripsi tidak tersedia.')

            result_candidates.append({
                "profession_id": pid,
                "profession_name": c.get('profession_name', 'Unknown'),
                "display_order": c.get('display_order', 0),
                "congruence_score": c.get('congruence_score', 0.5),
                "dimension_content": {
                    "what_you_love": what_you_love,
                    "what_you_are_good_at": what_you_are_good_at,
                    "what_the_world_needs": what_the_world_needs,
                    "what_you_can_be_paid_for": what_you_can_be_paid_for
                }
            })
            
        return result_candidates

    # --------------------------------------------------------------------------
    # PHASE 2: SUBMIT AND SCORE
    # --------------------------------------------------------------------------
    async def submit_dimension(
        self,
        user: User,
        session_token: str,
        dimension_name: str,
        selected_profession_id: Optional[int],
        selection_type: str,
        reasoning_text: str
    ):
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")
        
        if session.status != "ikigai_ongoing":
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Sesi tidak bisa di-submit (bukan ongoing)")

        # check record in ikigai_responses, create if not exist
        ikigai_resp = self.db.query(IkigaiResponse).filter(IkigaiResponse.test_session_id == session.id).first()
        if not ikigai_resp:
            ikigai_resp = IkigaiResponse(test_session_id=session.id)
            self.db.add(ikigai_resp)
            self.db.commit()
            self.db.refresh(ikigai_resp)

        # Build insert json
        dim_data = {
            "selected_profession_id": selected_profession_id,
            "selection_type": selection_type,
            "reasoning_text": reasoning_text
        }

        # Update specific dim field
        if dimension_name == "what_you_love":
            ikigai_resp.dimension_1_love = dim_data
        elif dimension_name == "what_you_are_good_at":
            ikigai_resp.dimension_2_good_at = dim_data
        elif dimension_name == "what_the_world_needs":
            ikigai_resp.dimension_3_world_needs = dim_data
        elif dimension_name == "what_you_can_be_paid_for":
            ikigai_resp.dimension_4_paid_for = dim_data
        
        self.db.commit()
        
        # Check completion
        completed_dims = []
        if ikigai_resp.dimension_1_love: completed_dims.append("what_you_love")
        if ikigai_resp.dimension_2_good_at: completed_dims.append("what_you_are_good_at")
        if ikigai_resp.dimension_3_world_needs: completed_dims.append("what_the_world_needs")
        if ikigai_resp.dimension_4_paid_for: completed_dims.append("what_you_can_be_paid_for")

        remaining = [d for d in IKIGAI_DIMENSIONS if d not in completed_dims]
        all_completed = len(remaining) == 0

        if not all_completed:
            return DimensionSubmitResponse(
                session_token=session_token,
                dimension_saved=dimension_name,
                dimensions_completed=completed_dims,
                dimensions_remaining=remaining,
                all_completed=False,
                message=f"Dimensi {dimension_name} berhasil disimpan."
            )
            
        # ALL COMPLETED -> TRIGGER SCORING
        try:
            result = await self._finalize_ikigai(session, ikigai_resp)
            return result
        except Exception as e:
            logger.error("ikigai_finalize_failed", error=str(e))
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, f"Gagal menghitung skor final: {str(e)}")

    async def _finalize_ikigai(self, session, ikigai_resp: IkigaiResponse):
        start_time = time.time()
        
        # Lock transaksional & validasi db (already somewhat locked logically)
        # Fetch Top Candidadtes
        cache_key = f"ikigai:content:{session.session_token}"
        cached_data = redis_client.get(cache_key)
        candidates_with_content = []
        if cached_data:
            content = json.loads(cached_data)
            candidates_with_content = content.get("candidates", [])
            
        if not candidates_with_content:
            # Reconstruct fallback if cache expired before submission
            raw_cands = await self._generate_ikigai_content(session.id)
            candidates_with_content = raw_cands
            
        # Score per dimensi (4 parallel API calls)
        answers = {
            "what_you_love": ikigai_resp.dimension_1_love,
            "what_you_are_good_at": ikigai_resp.dimension_2_good_at,
            "what_the_world_needs": ikigai_resp.dimension_3_world_needs,
            "what_you_can_be_paid_for": ikigai_resp.dimension_4_paid_for
        }
        
        dimension_scores_result = {}
        
        # Define the parallel tasks
        tasks = []
        dim_order_for_tasks = []
        
        for dim in IKIGAI_DIMENSIONS:
            ans = answers[dim]
            if not ans:
                continue
                
            essay = ans.get("reasoning_text", "")
            selected_id = ans.get("selected_profession_id")
            
            # Find the profession name and description matching user selection if 'selected'
            # If 'not_selected', then what to put for profession_name? We provide a generic "other career" or just the first candidate.
            if ans.get("selection_type") == "selected" and selected_id:
                prof_data = next((c for c in candidates_with_content if c["profession_id"] == selected_id), None)
                v_prof_name = prof_data["profession_name"] if prof_data else "Unknown"
                v_prof_desc = "Deskripsi terpilih"
            else:
                v_prof_name = "Karier Eksternal"
                v_prof_desc = "Pilihan bebas pengguna di luar opsi yang ditawarkan"
                
            task = gemini_client.evaluate_ikigai_response(
                user_essay=essay,
                profession_name=v_prof_name,
                profession_description=v_prof_desc,
                dimension=dim
            )
            tasks.append(task)
            dim_order_for_tasks.append(dim)
            
        gemini_results = await asyncio.gather(*tasks, return_exceptions=True)
        
        raw_scores = {}
        for dim, res in zip(dim_order_for_tasks, gemini_results):
            if isinstance(res, Exception):
                logger.error(f"Error calling gemini for {dim}: {str(res)}")
                val = 0.5 # Fallback
            else:
                val = res.get("scores", {}).get("final_dimension_score", 0.5)
            raw_scores[dim] = val
            
        # Normalization
        min_v = min(raw_scores.values())
        max_v = max(raw_scores.values())
        norm_scores = {}
        for dim, v in raw_scores.items():
            norm_scores[dim] = calculate_min_max_normalization(v, min_v, max_v)

        dimension_scores_result["raw_scores"] = raw_scores
        dimension_scores_result["normalized_scores"] = norm_scores
        
        # Create dimension scores DB entry
        dim_score_db = IkigaiDimensionScores(
            test_session_id=session.id,
            scores_data=dimension_scores_result,
            ai_model_used="gemini-1.5-flash",
            total_api_calls=4
        )
        self.db.add(dim_score_db)

        # Phase 2 Aggregation
        total_scores = []
        for cand in candidates_with_content:
            pid = cand["profession_id"]
            c_score = cand["congruence_score"]
            # calculate score for this cand
            
            scores_dim = {}
            for dim in IKIGAI_DIMENSIONS:
                ans = answers[dim]
                sel_id = ans.get("selected_profession_id")
                # Intrinsic part
                if ans.get("selection_type") == "selected" and sel_id == pid:
                    scores_dim[dim] = norm_scores[dim]
                else:
                    scores_dim[dim] = 0.0

            # aggregation
            avg_ai = calculate_ikigai_dimension_average(scores_dim)
            
            # extrinsic
            # Cek click_bonus apakah diklik di manapun (yang mana ya? jika sel_id == pid di setidaknya 1 dim)
            was_selected_at_least_once = any((answers[d].get("selected_profession_id") == pid and answers[d].get("selection_type") == "selected") for d in IKIGAI_DIMENSIONS)
            
            click_bonus = calculate_confidence_adjusted_click(was_selected_at_least_once, avg_ai)
            
            final_total = calculate_final_profession_score(
                riasec_match_score=c_score,
                # actually function signature in scoring_utils expects dictionary of dimension variables, but avg_ai already handles dim.
                # Let's adjust based on what was existing.
                # existing: total_score = (0.5 * riasec) + (0.4 * avg_ikigai) + click_bonus
                dimension_scores=scores_dim, # We will redefine this if scoring_utils does different
                click_bonus=click_bonus
            )
            
            total_scores.append({
                "profession_id": pid,
                "profession_name": cand["profession_name"], # Required for returning breakdown, but don't save excessive data if unneeded
                "congruence_score": c_score,
                "intrinsic_score": avg_ai,
                "extrinsic_score": c_score * 0.5 + click_bonus, # Concept split for tie breaking
                "total_score": final_total,
                "score_dimensions": scores_dim
            })
            
        # Sort and Rank
        # Multilevel Tie-Breaking
        def tie_break_key(x):
            return (
                x["total_score"],
                x["intrinsic_score"],
                x["congruence_score"],
                sum(x["score_dimensions"].values()) / 4 # average normalized score
            )
            
        total_scores.sort(key=tie_break_key, reverse=True)
        
        # Keep track if tie breaking logic was strictly necessary (multiple similar totals)
        tie_breaking_applied = False
        if len(total_scores) > 1 and total_scores[0]["total_score"] == total_scores[1]["total_score"]:
            tie_breaking_applied = True
            
        top_1 = total_scores[0]["profession_id"] if total_scores else None
        top_2 = total_scores[1]["profession_id"] if len(total_scores) > 1 else None

        tot_score_db = IkigaiTotalScores(
            test_session_id=session.id,
            scores_data={"professions": total_scores},
            top_profession_1_id=top_1,
            top_profession_2_id=top_2
        )
        self.db.add(tot_score_db)
        
        # update states
        ikigai_resp.completed = True
        ikigai_resp.completed_at = datetime.now(timezone.utc)
        
        session.status = "completed"
        session.completed_at = datetime.now(timezone.utc)
        self.db.commit()
        
        # Format response
        breakdown = []
        for idx, p in enumerate(total_scores):
            breakdown.append(ProfessionScoreBreakdown(
                rank=idx + 1,
                profession_id=p["profession_id"],
                total_score=round(p["total_score"], 4),
                score_what_you_love=round(p["score_dimensions"]["what_you_love"], 4),
                score_what_you_are_good_at=round(p["score_dimensions"]["what_you_are_good_at"], 4),
                score_what_the_world_needs=round(p["score_dimensions"]["what_the_world_needs"], 4),
                score_what_you_can_be_paid_for=round(p["score_dimensions"]["what_you_can_be_paid_for"], 4),
                intrinsic_score=round(p["intrinsic_score"], 4),
                extrinsic_score=round(p["extrinsic_score"], 4)
            ))
            
        return IkigaiCompletionResponse(
            session_token=session.session_token,
            status="completed",
            top_2_professions=breakdown[:2],
            total_professions_evaluated=len(total_scores),
            tie_breaking_applied=tie_breaking_applied,
            calculated_at=datetime.now(timezone.utc).isoformat(),
            message="Ikigai berhasil di-submit dan diskor."
        )

    def get_ikigai_result(self, user: User, session_token: str) -> IkigaiCompletionResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")
            
        if session.status != "completed":
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Ikigai belum selesai.")
            
        total_scores = self.db.query(IkigaiTotalScores).filter(IkigaiTotalScores.test_session_id == session.id).first()
        if not total_scores:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Result tidak ditemukan.")
            
        prof_list = total_scores.scores_data.get("professions", [])
        
        breakdown = []
        for idx, p in enumerate(prof_list):
            breakdown.append(ProfessionScoreBreakdown(
                rank=idx + 1,
                profession_id=p["profession_id"],
                total_score=round(p["total_score"], 4),
                score_what_you_love=round(p["score_dimensions"]["what_you_love"], 4),
                score_what_you_are_good_at=round(p["score_dimensions"]["what_you_are_good_at"], 4),
                score_what_the_world_needs=round(p["score_dimensions"]["what_the_world_needs"], 4),
                score_what_you_can_be_paid_for=round(p["score_dimensions"]["what_you_can_be_paid_for"], 4),
                intrinsic_score=round(p.get("intrinsic_score", 0), 4),
                extrinsic_score=round(p.get("extrinsic_score", 0), 4)
            ))
            
        return IkigaiCompletionResponse(
            session_token=session.session_token,
            status="completed",
            top_2_professions=breakdown[:2],
            total_professions_evaluated=len(prof_list),
            tie_breaking_applied=False, # Optional since this is just a read
            calculated_at=total_scores.calculated_at.isoformat(),
            message="Berhasil mengambil hasil Ikigai."
        )
