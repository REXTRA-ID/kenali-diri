import asyncio
import json
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional
from sqlalchemy.orm import joinedload
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
    calculate_text_score,
    calculate_click_score,
)
from app.api.v1.categories.career_profile.services.recommendation_narrative_service import RecommendationNarrativeService
from app.api.v1.categories.career_profile.models.result import CareerRecommendation
from app.api.v1.categories.career_profile.models.riasec import RIASECResult

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

        top_profession_ids = [c['profession_id'] for c in top_candidates]
        profession_contexts = self.profession_repo.get_profession_contexts_for_ikigai(top_profession_ids)

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
            "reasoning_text": reasoning_text,
            "answered_at": datetime.now(timezone.utc).isoformat()  # ISO8601 sesuai skema dokumentasi
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
        """
        Pipeline scoring Ikigai sesuai Brief Penugasan Backend Part 2.

        Langkah:
        1. Ambil semua kandidat dari DB (bukan hanya dari cache)
        2. Validasi selected_profession_id terhadap daftar kandidat
        3. 4 Gemini call paralel (1 per dimensi, menilai semua kandidat)
        4. Normalisasi min-max per dimensi, hitung text_score + click_score
        5. Simpan ke ikigai_dimension_scores dengan format JSONB per profesi per dimensi
        6. Agregasi total_score per profesi, multi-level sorting
        7. Simpan ke ikigai_total_scores dengan key 'profession_scores'
        8. Update session, kenalidiri_history, dan generate narasi rekomendasi
        """
        start_time = time.time()

        # ------------------------------------------------------------------
        # STEP 1: Ambil semua kandidat dari DB
        # ------------------------------------------------------------------
        candidate_record = self.profession_repo.get_candidates_by_session_id(session.id)
        if not candidate_record or not candidate_record.candidates_data:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                "Data kandidat profesi tidak ditemukan untuk sesi ini."
            )
        all_candidate_entries = candidate_record.candidates_data.get("candidates", [])
        all_profession_ids = [c["profession_id"] for c in all_candidate_entries]

        # Build profession_contexts ringkas untuk scoring prompt
        profession_contexts = self.profession_repo.get_profession_contexts_for_scoring(all_profession_ids)

        if not profession_contexts:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                "Tidak ada profesi valid yang bisa di-scoring."
            )

        # ------------------------------------------------------------------
        # STEP 2: Ambil jawaban & validasi selected_profession_id
        # ------------------------------------------------------------------
        answers = {
            "what_you_love":          ikigai_resp.dimension_1_love,
            "what_you_are_good_at":   ikigai_resp.dimension_2_good_at,
            "what_the_world_needs":   ikigai_resp.dimension_3_world_needs,
            "what_you_can_be_paid_for": ikigai_resp.dimension_4_paid_for
        }

        valid_profession_ids = {pc["profession_id"] for pc in profession_contexts}
        selected_ids: Dict[str, Optional[int]] = {}  # dimension -> selected_profession_id (validated)
        for dim, ans in answers.items():
            if not ans:
                selected_ids[dim] = None
                continue
            sel_id = ans.get("selected_profession_id")
            if sel_id and sel_id not in valid_profession_ids:
                logger.warning(
                    "ikigai_invalid_selected_profession",
                    dimension=dim,
                    selected_profession_id=sel_id,
                    session_id=session.id
                )
                selected_ids[dim] = None  # Abaikan pilihan tidak valid
            else:
                selected_ids[dim] = sel_id

        # ------------------------------------------------------------------
        # STEP 3: 4 Gemini call paralel (1 per dimensi, semua kandidat)
        # ------------------------------------------------------------------
        scoring_tasks = []
        dim_order = []
        for dim in IKIGAI_DIMENSIONS:
            ans = answers.get(dim)
            if not ans:
                continue
            reasoning_text = ans.get("reasoning_text", "")
            if not reasoning_text.strip():
                reasoning_text = "(tidak ada teks jawaban)"
            scoring_tasks.append(
                gemini_client.score_all_professions_for_dimension(
                    dimension_name=dim,
                    user_reasoning_text=reasoning_text,
                    profession_contexts=profession_contexts
                )
            )
            dim_order.append(dim)

        logger.info(
            "ikigai_scoring_start",
            session_id=session.id,
            dimensions=dim_order,
            total_professions=len(profession_contexts)
        )
        gemini_results = await asyncio.gather(*scoring_tasks, return_exceptions=True)

        # ------------------------------------------------------------------
        # STEP 4: Normalisasi per dimensi + hitung text_score & click_score
        # ------------------------------------------------------------------
        # dim_raw_scores[dim] = [{profession_id, r_raw}]
        dim_raw_scores: Dict[str, list] = {}
        for dim, result in zip(dim_order, gemini_results):
            if isinstance(result, Exception):
                logger.error(
                    "ikigai_scoring_dim_failed",
                    dimension=dim,
                    error=str(result),
                    session_id=session.id
                )
                # Fallback: semua profesi r_raw = 0.5
                dim_raw_scores[dim] = [
                    {"profession_id": pc["profession_id"], "r_raw": 0.5}
                    for pc in profession_contexts
                ]
            else:
                dim_raw_scores[dim] = result

        # Normalisasi min-max per dimensi -> tambah r_normalized, text_score, click_score
        dim_scored: Dict[str, list] = {}  # dim -> [{profession_id, r_raw, r_normalized, text_score, click_score, dimension_total}]
        for dim in dim_order:
            raw_list = dim_raw_scores[dim]
            r_values = [item["r_raw"] for item in raw_list]
            r_min = min(r_values) if r_values else 0.0
            r_max = max(r_values) if r_values else 1.0
            denom = r_max - r_min  # 0 jika semua r_raw identik

            sel_id_for_dim = selected_ids.get(dim)
            scored_list = []
            for item in raw_list:
                r_raw = item["r_raw"]
                # Jika semua r_raw identik (denom=0), r_norm = 0.5 (netral)
                r_norm = 0.5 if denom == 0 else (r_raw - r_min) / denom
                r_norm = max(0.0, min(1.0, round(r_norm, 4)))

                is_selected = (sel_id_for_dim is not None and item["profession_id"] == sel_id_for_dim)
                t_score = calculate_text_score(r_norm)            # 0.0 – 15.0
                c_score = calculate_click_score(r_raw, is_selected)  # 0.0 – 10.0

                scored_list.append({
                    "profession_id": item["profession_id"],
                    "r_raw": round(r_raw, 4),
                    "r_normalized": r_norm,
                    "text_score": t_score,
                    "click_score": c_score,
                    "dimension_total": round(t_score + c_score, 4)
                })
            dim_scored[dim] = scored_list

        # ------------------------------------------------------------------
        # STEP 5: Simpan ikigai_dimension_scores dengan format benar
        # ------------------------------------------------------------------
        normalization_params = {}
        for dim in dim_order:
            raw_list = dim_raw_scores[dim]
            r_values = [item["r_raw"] for item in raw_list]
            normalization_params[dim] = {
                "r_min": round(min(r_values), 4) if r_values else 0.0,
                "r_max": round(max(r_values), 4) if r_values else 1.0,
                "professions_evaluated": len(raw_list)
            }

        dimension_scores_jsonb = {
            "dimension_scores": dim_scored,
            "normalization_params": normalization_params,
            "metadata": {
                "dimensions_scored": dim_order,
                "total_professions": len(profession_contexts),
                "scoring_method": "batch_per_dimension_v2"
            }
        }

        dim_score_db = IkigaiDimensionScores(
            test_session_id=session.id,
            scores_data=dimension_scores_jsonb,
            ai_model_used="gemini-1.5-flash",
            total_api_calls=len(dim_order)
        )
        self.db.add(dim_score_db)

        # ------------------------------------------------------------------
        # STEP 6: Agregasi total_score per profesi & multi-level sorting
        # ------------------------------------------------------------------
        # Index: dim_scored[dim][profession_id] -> {}
        dim_score_by_pid: Dict[str, Dict[int, dict]] = {}
        for dim, scored_list in dim_scored.items():
            dim_score_by_pid[dim] = {item["profession_id"]: item for item in scored_list}

        # Kongruensi skor dari candidates_data
        congruence_map = {c["profession_id"]: c.get("congruence_score", 0.5) for c in all_candidate_entries}

        total_scores = []
        for pid in all_profession_ids:
            score_per_dim = {}
            sum_r_normalized = 0.0
            scored_dim_count = 0

            for dim in IKIGAI_DIMENSIONS:
                if dim in dim_score_by_pid and pid in dim_score_by_pid[dim]:
                    entry = dim_score_by_pid[dim][pid]
                    score_per_dim[dim] = entry["dimension_total"]
                    sum_r_normalized += entry["r_normalized"]
                    scored_dim_count += 1
                else:
                    score_per_dim[dim] = 0.0

            total_dim_score = sum(score_per_dim.values())  # range 0–100
            intrinsic_score = score_per_dim.get("what_you_love", 0.0) + score_per_dim.get("what_you_are_good_at", 0.0)
            extrinsic_score = score_per_dim.get("what_the_world_needs", 0.0) + score_per_dim.get("what_you_can_be_paid_for", 0.0)
            avg_r_normalized = sum_r_normalized / scored_dim_count if scored_dim_count > 0 else 0.0
            congruence_score = congruence_map.get(pid, 0.0)

            mp = prof_detail_map.get(pid)
            profession_name = mp.title if mp else "Unknown"

            total_scores.append({
                "profession_id": pid,
                "profession_name": profession_name,
                "total_score": round(total_dim_score, 4),
                "intrinsic_score": round(intrinsic_score, 4),
                "extrinsic_score": round(extrinsic_score, 4),
                "congruence_score": round(congruence_score, 4),
                "avg_r_normalized": round(avg_r_normalized, 4),
                "score_dimensions": {
                    "what_you_love": round(score_per_dim.get("what_you_love", 0.0), 4),
                    "what_you_are_good_at": round(score_per_dim.get("what_you_are_good_at", 0.0), 4),
                    "what_the_world_needs": round(score_per_dim.get("what_the_world_needs", 0.0), 4),
                    "what_you_can_be_paid_for": round(score_per_dim.get("what_you_can_be_paid_for", 0.0), 4),
                }
            })

        # Multi-level tie-breaking: total_score -> intrinsic_score -> congruence_score -> avg_r_normalized
        total_scores.sort(
            key=lambda x: (x["total_score"], x["intrinsic_score"], x["congruence_score"], x["avg_r_normalized"]),
            reverse=True
        )

        tie_breaking_applied = (
            len(total_scores) > 1
            and total_scores[0]["total_score"] == total_scores[1]["total_score"]
        )

        top_1_id = total_scores[0]["profession_id"] if total_scores else None
        top_2_id = total_scores[1]["profession_id"] if len(total_scores) > 1 else None

        # ------------------------------------------------------------------
        # STEP 7: Simpan ikigai_total_scores dengan key 'profession_scores'
        # ------------------------------------------------------------------
        total_scores_jsonb = {
            "profession_scores": total_scores,
            "metadata": {
                "total_professions_ranked": len(total_scores),
                "tie_breaking_applied": tie_breaking_applied,
                "scoring_formula": "text_score(0-15) + click_score(0-10) per dimension, total 0-100"
            }
        }

        tot_score_db = IkigaiTotalScores(
            test_session_id=session.id,
            scores_data=total_scores_jsonb,
            top_profession_1_id=top_1_id,
            top_profession_2_id=top_2_id
        )
        self.db.add(tot_score_db)

        # ------------------------------------------------------------------
        # STEP 8: Update session status & timestamps
        # ------------------------------------------------------------------
        ikigai_resp.completed = True
        ikigai_resp.completed_at = datetime.now(timezone.utc)

        session.status = "completed"
        session.ikigai_completed_at = datetime.now(timezone.utc)
        session.completed_at = datetime.now(timezone.utc)

        # Update kenalidiri_history untuk RECOMMENDATION flow (sesuai Brief Part 1)
        from app.db.models.kenalidiri_history import KenaliDiriHistory
        history = self.db.query(KenaliDiriHistory).filter(
            KenaliDiriHistory.detail_session_id == session.id
        ).first()
        if history:
            history.status = "completed"
            history.completed_at = datetime.now(timezone.utc)

        self.db.commit()

        elapsed = round(time.time() - start_time, 2)
        logger.info(
            "ikigai_finalize_success",
            session_id=session.id,
            total_professions=len(total_scores),
            top_1_id=top_1_id,
            top_2_id=top_2_id,
            elapsed_seconds=elapsed
        )

        # ──────────────────────────────────────────────────────────────────
        # PHASE 3 INTEGRATION: Generate + Save Recommendation Narrative
        # ──────────────────────────────────────────────────────────────────
        try:
            top_2_scores = total_scores[:2]
            top_2_ids = [p["profession_id"] for p in top_2_scores]

            # Fetch profesi detail Top-2 menggunakan repo baru
            profession_details = self.profession_repo.get_profession_contexts_for_recommendation(top_2_ids)
            prof_detail_map = {item['profession_id']: item for item in profession_details}

            # Build ikigai responses dict (reasoning text per dimension)
            ikigai_responses_text = {
                dim: (answers.get(dim) or {}).get("reasoning_text", "")
                for dim in IKIGAI_DIMENSIONS
            }

            # RIASEC code user
            riasec_res = self.db.query(RIASECResult).filter(
                RIASECResult.test_session_id == session.id
            ).first()
            user_riasec_code = riasec_res.riasec_code if riasec_res else "Unknown"

            # Call Gemini untuk narasi rekomendasi
            narrative_service = RecommendationNarrativeService()
            narrative_data = await narrative_service.generate_recommendations_narrative(
                ikigai_responses=ikigai_responses_text,
                top_2_professions=top_2_scores,
                profession_details=profession_details,
                user_riasec_code=user_riasec_code
            )

            # Build recommendations_data JSONB
            recommended_professions = []
            for rank, p in enumerate(top_2_scores, start=1):
                pid = p["profession_id"]
                mp_dict = prof_detail_map.get(pid, {})
                reasoning = narrative_data.get("match_reasoning", {}).get(str(pid), "")
                recommended_professions.append({
                    "rank": rank,
                    "profession_id": pid,
                    "profession_name": p.get("profession_name", ""),
                    "match_percentage": round(p["total_score"], 2),  # already 0–100 range
                    "match_reasoning": reasoning,
                    "riasec_alignment": {
                        "user_code": user_riasec_code,
                        "profession_code": mp_dict.get("riasec_code", "-"),
                        "congruence_score": p.get("congruence_score", 0)
                    },
                    "score_breakdown": {
                        "total_score": round(p["total_score"], 2),
                        "intrinsic_score": round(p["intrinsic_score"], 2),
                        "extrinsic_score": round(p["extrinsic_score"], 2),
                        "score_what_you_love": round(p["score_dimensions"]["what_you_love"], 2),
                        "score_what_you_are_good_at": round(p["score_dimensions"]["what_you_are_good_at"], 2),
                        "score_what_the_world_needs": round(p["score_dimensions"]["what_the_world_needs"], 2),
                        "score_what_you_can_be_paid_for": round(p["score_dimensions"]["what_you_can_be_paid_for"], 2)
                    }
                })

            recommendations_data = {
                "ikigai_profile_summary": narrative_data.get("ikigai_profile_summary", {}),
                "recommended_professions": recommended_professions,
                "points_awarded": None,
                "TODO_points": "Implementasi poin Rextra belum aktif."
            }

            career_rec = CareerRecommendation(
                test_session_id=session.id,
                recommendations_data=recommendations_data
            )
            self.db.add(career_rec)
            self.db.commit()
            logger.info("recommendation_narrative_saved", session_id=session.id)

        except Exception as e:
            logger.error(
                "recommendation_narrative_failed",
                error=str(e), traceback=__import__("traceback").format_exc(),
                session_id=session.id
            )
            # Non-fatal: scoring sudah selesai, narasi adalah best-effort

        # ------------------------------------------------------------------
        # FORMAT RESPONSE
        # ------------------------------------------------------------------
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

    async def get_ikigai_result(self, user: User, session_token: str) -> IkigaiCompletionResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")

        if session.status != "completed":
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Ikigai belum selesai.")

        total_scores_record = self.db.query(IkigaiTotalScores).filter(
            IkigaiTotalScores.test_session_id == session.id
        ).first()
        if not total_scores_record:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Result tidak ditemukan.")

        # Key sesuai format JSONB baru: 'profession_scores'
        prof_list = total_scores_record.scores_data.get("profession_scores", [])

        breakdown = []
        for idx, p in enumerate(prof_list):
            score_dims = p.get("score_dimensions", {})
            breakdown.append(ProfessionScoreBreakdown(
                rank=idx + 1,
                profession_id=p["profession_id"],
                total_score=round(p.get("total_score", 0.0), 4),
                score_what_you_love=round(score_dims.get("what_you_love", 0.0), 4),
                score_what_you_are_good_at=round(score_dims.get("what_you_are_good_at", 0.0), 4),
                score_what_the_world_needs=round(score_dims.get("what_the_world_needs", 0.0), 4),
                score_what_you_can_be_paid_for=round(score_dims.get("what_you_can_be_paid_for", 0.0), 4),
                intrinsic_score=round(p.get("intrinsic_score", 0.0), 4),
                extrinsic_score=round(p.get("extrinsic_score", 0.0), 4)
            ))

        return IkigaiCompletionResponse(
            session_token=session.session_token,
            status="completed",
            top_2_professions=breakdown[:2],
            total_professions_evaluated=len(prof_list),
            tie_breaking_applied=False,  # Read-only: tidak relevan
            calculated_at=total_scores_record.calculated_at.isoformat(),
            message="Berhasil mengambil hasil Ikigai."
        )
