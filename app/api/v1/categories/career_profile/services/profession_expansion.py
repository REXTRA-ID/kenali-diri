# app/api/v1/categories/career_profile/services/profession_expansion.py
from itertools import permutations
from typing import Dict, List, Any, Set, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.repositories.profession_repo import (
    ProfessionRepository,
    Profession
)
from app.api.v1.categories.career_profile.repositories.riasec_repo import RIASECRepository
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession


class ProfessionExpansionService:
    """
    Service for expanding profession candidates using 4-tier algorithm
    
    IMPORTANT: Congruence is calculated at RUNTIME from user's top 3 scores,
    NOT from database relationships!
    """
    
    def __init__(self, db: Session):
        self.db = db
        self.profession_repo = ProfessionRepository(db)
        self.riasec_repo = RIASECRepository(db)
    
    def expand_candidates(
        self,
        riasec_code: str,
        riasec_code_id: int,
        user_scores: Dict[str, int],
        is_inconsistent_profile: bool = False
    ) -> Dict[str, Any]:
        """
        Expand profession candidates using 4-tier algorithm with runtime congruence
        
        SPLIT-PATH STRATEGY (NEW):
        If is_inconsistent_profile=True (opposite types detected: R-S, I-E, A-C):
        - DO NOT use standard Tier 1-4 algorithm on combined code (e.g., "RS")
        - Instead, split into two separate paths:
            * Path A: First letter + hexagon-adjacent types (e.g., R → R, RI, RC)
            * Path B: Second letter + hexagon-adjacent types (e.g., S → S, SA, SE)
        - Tag each candidate with metadata: {"path": "A"} or {"path": "B"}
        - This allows frontend to display: "Your interests span two different poles..."
        
        Hexagon Adjacent Mapping (Holland's Model):
            R ← adjacent → I, C
            I ← adjacent → R, A
            A ← adjacent → I, S
            S ← adjacent → A, E
            E ← adjacent → S, C
            C ← adjacent → E, R
        
        Args:
            riasec_code: User's RIASEC code (e.g., "RIA" or "RS")
            riasec_code_id: Database ID of the RIASEC code
            user_scores: Dict with user's scores {"R": 50, "I": 48, "A": 46, ...}
            is_inconsistent_profile: Flag indicating opposite types (default: False)
            
        Returns:
            Dict containing candidates and metadata for JSONB storage:
            {
                "user_riasec_code": "RIA",
                "user_top_3_types": ["R", "I", "A"],
                "user_scores": {"R": 50, "I": 48, ...},
                "is_inconsistent_profile": False,
                "candidates": [
                    {
                        "profession_id": 10,
                        "riasec_code_id": 49,
                        "expansion_tier": 1,
                        "congruence_type": "exact_match",
                        "congruence_score": 1.0,
                        "display_order": 1,
                        "path": "A"  # Only present if is_inconsistent_profile=True
                    }
                ],
                "expansion_summary": {
                    "tier_1_count": 2,
                    "tier_2_count": 3,
                    "tier_3_count": 0,
                    "tier_4_count": 0,
                    "total_unique": 5,
                    "congruent_codes_used": ["RAI", "IRA", ...],
                    "subset_codes_used": ["RI", "RA", ...],
                    "dominant_type_used": "R"
                }
            }
        """
        # Calculate top 3 types from user scores (RUNTIME)
        sorted_scores = sorted(
            user_scores.items(),
            key=lambda x: x[1],
            reverse=True
        )
        top_3_types = [t[0] for t in sorted_scores[:3]]
        
        # ===== SPLIT-PATH STRATEGY FOR INCONSISTENT PROFILES =====
        if is_inconsistent_profile and len(riasec_code) >= 2:
            return self._expand_candidates_split_path(
                riasec_code,
                user_scores,
                top_3_types
            )
        
        # ===== STANDARD 4-TIER ALGORITHM (CONSISTENT PROFILES) =====
        # Initialize tracking
        candidates = []
        seen_profession_ids: Set[int] = set()
        display_order = 1
        
        expansion_summary = {
            "tier_1_count": 0,
            "tier_2_count": 0,
            "tier_3_count": 0,
            "tier_4_count": 0,
            "total_unique": 0
        }
        
        # TIER 1: Exact Match
        tier_1_professions = self._get_tier_1_exact_match(
            riasec_code_id,
            riasec_code,
            seen_profession_ids,
            display_order
        )
        candidates.extend(tier_1_professions)
        display_order += len(tier_1_professions)
        expansion_summary["tier_1_count"] = len(tier_1_professions)
        
        # TIER 2: Congruent Codes (if < 3 candidates)
        if len(candidates) < 3:
            congruent_codes = self._generate_congruent_codes(
                riasec_code,
                top_3_types
            )
            tier_2_professions = self._get_tier_2_congruent(
                congruent_codes,
                seen_profession_ids,
                display_order
            )
            candidates.extend(tier_2_professions)
            display_order += len(tier_2_professions)
            expansion_summary["tier_2_count"] = len(tier_2_professions)
            expansion_summary["congruent_codes_used"] = congruent_codes
        
        # TIER 3: Subset Codes (if < 3 candidates)
        if len(candidates) < 3:
            subset_codes = self._generate_subset_codes(top_3_types)
            tier_3_professions = self._get_tier_3_subset(
                subset_codes,
                seen_profession_ids,
                display_order
            )
            candidates.extend(tier_3_professions)
            display_order += len(tier_3_professions)
            expansion_summary["tier_3_count"] = len(tier_3_professions)
            expansion_summary["subset_codes_used"] = subset_codes
        
        # TIER 4: Dominant Single (if < 3 candidates)
        if len(candidates) < 3:
            dominant_type = riasec_code[0]  # First letter = highest score
            tier_4_professions = self._get_tier_4_dominant(
                dominant_type,
                seen_profession_ids,
                display_order
            )
            candidates.extend(tier_4_professions)
            display_order += len(tier_4_professions)
            expansion_summary["tier_4_count"] = len(tier_4_professions)
            expansion_summary["dominant_type_used"] = dominant_type
        
        # Update total unique count
        expansion_summary["total_unique"] = len(seen_profession_ids)
        
        # Build final JSONB structure
        return {
            "user_riasec_code": riasec_code,
            "user_top_3_types": top_3_types,
            "user_scores": user_scores,
            "is_inconsistent_profile": False,
            "candidates": candidates,
            "expansion_summary": expansion_summary
        }
    
    def _get_hexagon_adjacent(self, riasec_type: str) -> List[str]:
        """
        Get hexagon-adjacent types for a given RIASEC type (Holland's Hexagon Model)
        
        Mapping:
            R ← adjacent → I, C
            I ← adjacent → R, A
            A ← adjacent → I, S
            S ← adjacent → A, E
            E ← adjacent → S, C
            C ← adjacent → E, R
        
        Args:
            riasec_type: Single RIASEC letter (e.g., "R")
            
        Returns:
            List of adjacent types (e.g., ["I", "C"] for "R")
        """
        hexagon_map = {
            'R': ['I', 'C'],
            'I': ['R', 'A'],
            'A': ['I', 'S'],
            'S': ['A', 'E'],
            'E': ['S', 'C'],
            'C': ['E', 'R']
        }
        return hexagon_map.get(riasec_type, [])
    
    def _expand_candidates_split_path(
        self,
        riasec_code: str,
        user_scores: Dict[str, int],
        top_3_types: List[str]
    ) -> Dict[str, Any]:
        """
        Expand candidates using Split-Path strategy for inconsistent profiles
        
        Strategy:
            - Path A: Search professions based on first letter + adjacent types
            - Path B: Search professions based on second letter + adjacent types
        
        Example:
            riasec_code = "RS" (Realistic-Social, opposites)
            Path A: Search R, RI, RC
            Path B: Search S, SA, SE
        
        Args:
            riasec_code: User's inconsistent code (e.g., "RS", "IE", "AC")
            user_scores: User's RIASEC scores
            top_3_types: Top 3 types from scores
            
        Returns:
            Dict with candidates tagged by path ("A" or "B")
        """
        type_a = riasec_code[0]
        type_b = riasec_code[1] if len(riasec_code) >= 2 else None
        
        candidates = []
        seen_profession_ids: Set[int] = set()
        display_order = 1
        
        expansion_summary = {
            "path_a_count": 0,
            "path_b_count": 0,
            "total_unique": 0,
            "path_a_codes_used": [],
            "path_b_codes_used": []
        }
        
        # ===== PATH A: First Type + Adjacent =====
        path_a_codes = [type_a]  # Start with dominant type
        adjacent_a = self._get_hexagon_adjacent(type_a)
        
        # Add 2-letter combinations with adjacent types
        for adj in adjacent_a:
            path_a_codes.append(type_a + adj)
        
        # Search professions for Path A
        for code_str in path_a_codes:
            try:
                code_obj = self.riasec_repo.get_riasec_code_by_string(code_str)
                
                # TODO: Replace with actual profession query
                # professions = self.db.query(Profession).filter(
                #     Profession.riasec_code_id == code_obj.id
                # ).limit(5).all()
                
                # PLACEHOLDER
                professions = []
                
                for prof in professions:
                    if prof.id not in seen_profession_ids:
                        candidates.append({
                            "profession_id": prof.id,
                            "riasec_code_id": code_obj.id,
                            "expansion_tier": None,  # Not using standard tiers  
                            "congruence_type": "split_path",
                            "congruence_score": 0.9 if code_str == type_a else 0.7,
                            "display_order": display_order,
                            "path": "A",
                            "matched_code": code_str
                        })
                        seen_profession_ids.add(prof.id)
                        display_order += 1
                        expansion_summary["path_a_count"] += 1
                
                expansion_summary["path_a_codes_used"].append(code_str)
                
                # Limit to prevent overwhelming results
                if expansion_summary["path_a_count"] >= 10:
                    break
                    
            except HTTPException:
                # Code doesn't exist in DB, skip
                continue
        
        # ===== PATH B: Second Type + Adjacent =====
        if type_b:
            path_b_codes = [type_b]
            adjacent_b = self._get_hexagon_adjacent(type_b)
            
            # Add 2-letter combinations with adjacent types
            for adj in adjacent_b:
                path_b_codes.append(type_b + adj)
            
            # Search professions for Path B
            for code_str in path_b_codes:
                try:
                    code_obj = self.riasec_repo.get_riasec_code_by_string(code_str)
                    
                    # TODO: Replace with actual profession query
                    professions = []
                    
                    for prof in professions:
                        if prof.id not in seen_profession_ids:
                            candidates.append({
                                "profession_id": prof.id,
                                "riasec_code_id": code_obj.id,
                                "expansion_tier": None,
                                "congruence_type": "split_path",
                                "congruence_score": 0.9 if code_str == type_b else 0.7,
                                "display_order": display_order,
                                "path": "B",
                                "matched_code": code_str
                            })
                            seen_profession_ids.add(prof.id)
                            display_order += 1
                            expansion_summary["path_b_count"] += 1
                    
                    expansion_summary["path_b_codes_used"].append(code_str)
                    
                    # Limit to prevent overwhelming results
                    if expansion_summary["path_b_count"] >= 10:
                        break
                        
                except HTTPException:
                    continue
        
        expansion_summary["total_unique"] = len(seen_profession_ids)
        
        return {
            "user_riasec_code": riasec_code,
            "user_top_3_types": top_3_types,
            "user_scores": user_scores,
            "is_inconsistent_profile": True,
            "candidates": candidates,
            "expansion_summary": expansion_summary
        }
    
    def _get_tier_1_exact_match(
        self,
        riasec_code_id: int,
        riasec_code: str,
        seen_ids: Set[int],
        start_order: int
    ) -> List[Dict[str, Any]]:
        """
        Tier 1: Get professions with exact code match
        
        NOTE: This is a placeholder. Replace with actual profession table query
        once the Profession model is created.
        """
        # TODO: Replace with actual profession table query
        # Example query:
        # professions = self.db.query(Profession).filter(
        #     Profession.riasec_code_id == riasec_code_id
        # ).all()
        
        # PLACEHOLDER: Return empty list until Profession model exists
        professions = []
        
        candidates = []
        order = start_order
        
        for prof in professions:
            if prof.id not in seen_ids:
                candidates.append({
                    "profession_id": prof.id,
                    "riasec_code_id": riasec_code_id,
                    "expansion_tier": 1,
                    "congruence_type": "exact_match",
                    "congruence_score": 1.0,
                    "display_order": order
                })
                seen_ids.add(prof.id)
                order += 1
        
        return candidates
    
    def _generate_congruent_codes(
        self,
        user_code: str,
        top_3_types: List[str]
    ) -> List[str]:
        """
        Generate congruent codes from top 3 types (RUNTIME CALCULATION)
        
        IMPORTANT: Uses permutations of top 3 types, NOT from database!
        
        Example:
            user_code = "RIA"
            top_3_types = ["R", "I", "A"]
            
            All permutations: RIA, RAI, IRA, IAR, ARI, AIR (3! = 6)
            Exclude user code: RAI, IRA, IAR, ARI, AIR (5 congruent codes)
        
        Args:
            user_code: User's RIASEC code (to exclude)
            top_3_types: Top 3 types from user scores
            
        Returns:
            List of congruent code strings (excluding user's own code)
        """
        # Generate all permutations (3! = 6 combinations)
        all_permutations = [''.join(p) for p in permutations(top_3_types)]
        
        # Exclude user's own code
        congruent_codes = [
            code for code in all_permutations 
            if code != user_code
        ]
        
        return congruent_codes
    
    def _get_tier_2_congruent(
        self,
        congruent_codes: List[str],
        seen_ids: Set[int],
        start_order: int
    ) -> List[Dict[str, Any]]:
        """
        Tier 2: Get professions with congruent codes
        
        Queries professions WHERE riasec_code IN congruent_codes
        Breaks when candidates >= 5
        """
        if not congruent_codes:
            return []
        
        # Get RIASEC code IDs for congruent codes
        code_id_map = {}  # code_string -> code_id
        for code_str in congruent_codes:
            try:
                code_obj = self.riasec_repo.get_riasec_code_by_string(code_str)
                code_id_map[code_str] = code_obj.id
            except HTTPException:
                # Code doesn't exist in database, skip
                continue
        
        if not code_id_map:
            return []
        
        # TODO: Replace with actual profession table query
        # Example query:
        # code_ids = list(code_id_map.values())
        # professions = self.db.query(Profession).filter(
        #     Profession.riasec_code_id.in_(code_ids)
        # ).limit(10).all()
        
        # PLACEHOLDER: Return empty list until Profession model exists
        professions = []
        
        candidates = []
        order = start_order
        
        for prof in professions:
            if prof.id not in seen_ids:
                # Find which congruent code this profession matches
                matched_code = None
                for code_str, code_id in code_id_map.items():
                    if prof.riasec_code_id == code_id:
                        matched_code = code_str
                        break
                
                candidates.append({
                    "profession_id": prof.id,
                    "riasec_code_id": prof.riasec_code_id,
                    "expansion_tier": 2,
                    "congruence_type": "congruent",
                    "congruence_score": 0.8,  # Slightly lower than exact match
                    "display_order": order,
                    "matched_code": matched_code
                })
                seen_ids.add(prof.id)
                order += 1
                
                # Break if we have enough candidates
                if len(seen_ids) >= 5:
                    break
        
        return candidates
    
    def _generate_subset_codes(self, top_3_types: List[str]) -> List[str]:
        """
        Generate 2-letter subset codes from top 3 types (RUNTIME)
        
        IMPORTANT: Only use top 3 types, not all 6 RIASEC types!
        
        Example:
            top_3_types = ["R", "I", "A"]
            Result: ["RI", "RA", "IA", "IR", "AI", "AR"] (6 subsets)
            
            NOT: ["RE", "RC", "RS"] ❌ (E, C, S not in top 3)
        
        Args:
            top_3_types: Top 3 types (e.g., ['R', 'I', 'A'])
            
        Returns:
            List of 2-letter codes from top 3 permutations
        """
        subset_codes = []
        
        # Generate all 2-letter permutations from top 3
        for i in range(len(top_3_types)):
            for j in range(len(top_3_types)):
                if i != j:
                    code = top_3_types[i] + top_3_types[j]
                    subset_codes.append(code)
        
        return subset_codes
    
    def _get_tier_3_subset(
        self,
        subset_codes: List[str],
        seen_ids: Set[int],
        start_order: int
    ) -> List[Dict[str, Any]]:
        """
        Tier 3: Get professions with subset codes (2-letter codes from top 3)
        
        Queries each subset code and breaks when candidates >= 5
        """
        if not subset_codes:
            return []
        
        candidates = []
        order = start_order
        
        # Query each subset code
        for code_str in subset_codes:
            try:
                code_obj = self.riasec_repo.get_riasec_code_by_string(code_str)
                
                # TODO: Replace with actual profession table query
                # professions = self.db.query(Profession).filter(
                #     Profession.riasec_code_id == code_obj.id
                # ).limit(5).all()
                
                # PLACEHOLDER: Return empty list until Profession model exists
                professions = []
                
                for prof in professions:
                    if prof.id not in seen_ids:
                        candidates.append({
                            "profession_id": prof.id,
                            "riasec_code_id": code_obj.id,
                            "expansion_tier": 3,
                            "congruence_type": "subset",
                            "congruence_score": 0.6,
                            "display_order": order,
                            "matched_code": code_str
                        })
                        seen_ids.add(prof.id)
                        order += 1
                        
                        # Break if we have enough
                        if len(seen_ids) >= 5:
                            return candidates
                            
            except HTTPException:
                # Code doesn't exist, skip
                continue
        
        return candidates
    
    def _get_tier_4_dominant(
        self,
        dominant_type: str,
        seen_ids: Set[int],
        start_order: int
    ) -> List[Dict[str, Any]]:
        """
        Tier 4: Get professions with dominant single type (first letter = highest score)
        
        Example:
            user_code = "RIA" → dominant_type = "R"
            Query professions with single-letter code "R"
        """
        try:
            code_obj = self.riasec_repo.get_riasec_code_by_string(dominant_type)
            
            # TODO: Replace with actual profession table query
            # professions = self.db.query(Profession).filter(
            #     Profession.riasec_code_id == code_obj.id
            # ).limit(10).all()
            
            # PLACEHOLDER: Return empty list until Profession model exists
            professions = []
            
            candidates = []
            order = start_order
            
            for prof in professions:
                if prof.id not in seen_ids:
                    candidates.append({
                        "profession_id": prof.id,
                        "riasec_code_id": code_obj.id,
                        "expansion_tier": 4,
                        "congruence_type": "dominant_single",
                        "congruence_score": 0.4,
                        "display_order": order
                    })
                    seen_ids.add(prof.id)
                    order += 1
            
            return candidates
            
        except HTTPException:
            return []
    
    def get_candidates_with_details(
        self,
        test_session_id: int
    ) -> Dict[str, Any]:
        """
        Retrieve candidates with full details from database
        
        Args:
            test_session_id: The test session ID
            
        Returns:
            Dict with detailed candidate information including metadata
        """
        # Get candidates from database
        candidates_obj = self.profession_repo.get_candidates_by_session_id(
            test_session_id
        )
        
        if not candidates_obj:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Candidates not found for session {test_session_id}"
            )
        
        candidates_data = candidates_obj.candidates_data
        
        # TODO: Once Profession model exists, enrich with full profession details
        # profession_ids = [c['profession_id'] for c in candidates_data.get('candidates', [])]
        # professions = self.db.query(Profession).filter(
        #     Profession.id.in_(profession_ids)
        # ).all()
        # profession_map = {p.id: p for p in professions}
        
        # Enrich candidates with profession details
        # enriched_candidates = []
        # for candidate in candidates_data.get('candidates', []):
        #     prof = profession_map.get(candidate['profession_id'])
        #     if prof:
        #         enriched_candidates.append({
        #             **candidate,
        #             'profession_name': prof.name,
        #             'profession_description': prof.description,
        #             # Add other profession fields as needed
        #         })
        
        return {
            "user_riasec_code": candidates_data.get('user_riasec_code'),
            "user_top_3_types": candidates_data.get('user_top_3_types'),
            "user_scores": candidates_data.get('user_scores'),
            "expansion_summary": candidates_data.get('expansion_summary'),
            "candidates": candidates_data.get('candidates', [])
            # TODO: Replace with enriched_candidates once Profession model exists
        }
    
    def save_candidates(
        self,
        test_session_id: int,
        riasec_code: str,
        riasec_code_id: int,
        user_scores: Dict[str, int]
    ) -> IkigaiCandidateProfession:
        """
        Generate and save candidates to database
        
        Args:
            test_session_id: The test session ID
            riasec_code: User's RIASEC code
            riasec_code_id: Database ID of RIASEC code
            user_scores: User's RIASEC scores
            
        Returns:
            IkigaiCandidateProfession: Saved candidates record
        """
        # Generate candidates using 4-tier algorithm
        candidates_data = self.expand_candidates(
            riasec_code,
            riasec_code_id,
            user_scores
        )
        
        # Check if candidates already exist
        existing = self.profession_repo.get_candidates_by_session_id(test_session_id)
        
        if existing:
            # Update existing record
            return self.profession_repo.update_candidates(
                test_session_id,
                candidates_data
            )
        else:
            # Create new record
            return self.profession_repo.create_candidates(
                test_session_id,
                candidates_data
            )