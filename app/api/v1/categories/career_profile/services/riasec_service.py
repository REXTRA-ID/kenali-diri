# app/api/v1/categories/career_profile/services/riasec_service.py
import json
import random
from pathlib import Path
from typing import List, Dict, Tuple, Any, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from pydantic import BaseModel

from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.riasec_repo import RIASECRepository
from app.api.v1.categories.career_profile.services.profession_expansion import ProfessionExpansionService
from app.api.v1.categories.career_profile.schemas.riasec import RIASECAnswerItem

from pprint import pprint # debug purpose

# Helper
def load_riasec_questions(questions_path):
    with open(questions_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    required_keys = {
        'version', 'total_questions', 'questions_per_type', 
        'types', 'scale', 'questions', 'questions_by_type'
    }

    if not required_keys.issubset(data.keys()):
        missing = required_keys - data.keys()
        raise ValueError(f"Invalid JSON format. Missing keys: {missing}")

    return data['questions']


class RIASECService:
    """Service for RIASEC test logic and calculations"""
    
    # Singleton pattern for questions cache
    _questions_cache: Optional[Dict[int, Any]] = None
    
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = SessionRepository(db)
        self.riasec_repo = RIASECRepository(db)
        self.profession_service = ProfessionExpansionService(db)
    
    @classmethod
    def load_questions_data(cls) -> Dict[int, Any]:
        """
        Load RIASEC questions from JSON file (cached)
        
        Returns:
            Dict mapping question_id to question data
        """
        if cls._questions_cache is None:
            questions_path = Path("data/riasec_questions.json")
            
            if not questions_path.exists():
                raise FileNotFoundError(
                    f"RIASEC questions file not found at {questions_path}"
                )
            
            questions_list = load_riasec_questions(questions_path)
            
            cls._questions_cache = {
                q['question_id']: q for q in questions_list
            } 
        
        return cls._questions_cache
    
    def generate_question_set(self, session_token: str) -> List[int]:
        """
        Generate all 72 questions (12 per RIASEC type)
        
        Args:
            session_token: Session token for random seed (used for shuffling order)
            
        Returns:
            List of 72 question IDs (all questions, shuffled)
        """
        # Seed random with session token
        random.seed(session_token)
        
        # Question ID ranges per type (72 total: 12 per type)
        question_ranges = {
            'R': list(range(1, 13)),
            'I': list(range(13, 25)),
            'A': list(range(25, 37)),
            'S': list(range(37, 49)),
            'E': list(range(49, 61)),
            'C': list(range(61, 73))
        }
        
        all_questions = []
        
        # Include all questions from each type
        for riasec_type, question_pool in question_ranges.items():
            all_questions.extend(question_pool)
        
        # Shuffle the final order
        random.shuffle(all_questions)
        
        return all_questions
    
    def calculate_scores(self, responses: List[RIASECAnswerItem]) -> Dict[str, int]:
        """
        Calculate RIASEC scores from responses
        
        Args:
            responses: List of user responses
            
        Returns:
            Dict with scores per type: {"R": 8, "I": 9, ...}
        """
        # Initialize scores
        scores = {'R': 0, 'I': 0, 'A': 0, 'S': 0, 'E': 0, 'C': 0}
        
        # Load questions to determine type
        questions = self.load_questions_data()
        
        # Aggregate scores
        for response in responses:
            question = questions.get(response.question_id)
            if not question:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid question_id: {response.question_id}"
                )
            
            riasec_type = question['riasec_type'][0] # first letter, example: 'Realistic' -> 'R'
            scores[riasec_type] += response.answer_value
        
        return scores
    
    def classify_riasec_code(
        self, 
        scores: Dict[str, int]
    ) -> Tuple[str, str, bool]:
        """
        Classify RIASEC code based on scores
        
        Args:
            scores: Dict with RIASEC scores
            
        Returns:
            Tuple of (riasec_code, classification_type, is_inconsistent)
        """
        # Define RIASEC order for tie-breaker (R-I-A-S-E-C)
        riasec_order = {"R": 0, "I": 1, "A": 2, "S": 3, "E": 4, "C": 5}
        
        # Sort scores descending by score, then ascending by RIASEC order (tie-breaker)
        # Key: (-score, riasec_index) - negative score for descending, positive index for ascending
        sorted_scores = sorted(
            scores.items(), 
            key=lambda x: (-x[1], riasec_order.get(x[0], 999)), 
            reverse=False
        )
        
        rank1_type, rank1_score = sorted_scores[0]
        rank2_type, rank2_score = sorted_scores[1]
        rank3_type, rank3_score = sorted_scores[2]
        
        # Check for single letter classification
        gap_1_2 = rank1_score - rank2_score
        relative_gap = gap_1_2 / rank1_score if rank1_score > 0 else 0
        
        if (gap_1_2 >= 9 and 
            relative_gap >= 0.15 and 
            rank1_score >= 40):
            riasec_code = rank1_type
            classification_type = 'single'
        
        # Check for dual letter classification
        elif (rank1_score >= 40 and
              gap_1_2 < 9 and
              (rank2_score - rank3_score) >= 9 and
              rank2_score >= 30):
            riasec_code = rank1_type + rank2_type
            classification_type = 'dual'
        
        # Fallback to triple letter
        else:
            riasec_code = rank1_type + rank2_type + rank3_type
            classification_type = 'triple'
        
        # Check for inconsistent profile (opposite codes)
        is_inconsistent = self._check_inconsistent_profile(riasec_code)
        
        return riasec_code, classification_type, is_inconsistent
    
    def _check_inconsistent_profile(self, riasec_code: str) -> bool:
        """
        Check if profile contains opposite/conflicting codes
        
        Opposite pairs: R-S, I-E, A-C
        """
        opposites = [
            ('R', 'S'),
            ('S', 'R'),
            ('I', 'E'),
            ('E', 'I'),
            ('A', 'C'),
            ('C', 'A')
        ]
        
        for pair in opposites:
            if pair[0] in riasec_code and pair[1] in riasec_code:
                return True
        
        return False
    
    def submit_riasec_test(
        self,
        session_token: str,
        responses: List[RIASECAnswerItem]
    ) -> Dict[str, Any]:
        """
        Submit RIASEC test and process complete flow
        
        Args:
            session_token: The session token
            responses: List of user responses (72 items: 12 per RIASEC type)
            
        Returns:
            Dict with complete result data
        """
        try:
            # 1. Validate session exists
            session = self.session_repo.get_session_by_token(session_token)
            
            if session.status not in ['riasec_ongoing']:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid session status: {session.status}"
                )
            
            # 2. Validate responses
            if len(responses) != 72:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Expected 72 responses (12 per RIASEC type), got {len(responses)}"
                )
            
            # Get question set and validate question IDs
            question_set = self.riasec_repo.get_question_set(session.id)
            expected_ids = set(question_set.question_ids)
            provided_ids = set(r.question_id for r in responses)
            
            if expected_ids != provided_ids:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Response question_ids don't match assigned questions"
                )
            
            # Validate answer values (1-5)
            for response in responses:
                if not (1 <= response.answer_value <= 5):
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Answer must be between 1-5, got {response.answer_value}"
                    )
            
            # 3. Calculate scores
            scores = self.calculate_scores(responses)
            
            # 4. Classify RIASEC code
            riasec_code, classification_type, is_inconsistent = \
                self.classify_riasec_code(scores)
            
            # Get RIASEC code from database
            riasec_code_obj = self.riasec_repo.get_riasec_code_by_string(riasec_code)
            
            # 5. Save responses to DB
            responses_data = {
                "answers": [
                    {
                        "question_id": r.question_id,
                        "answer": r.answer_value
                    }
                    for r in responses
                ]
            }
            
            self.riasec_repo.save_responses(session.id, responses_data)
            
            # 6. Save result to DB
            score_dict = {
                'score_r': scores['R'],
                'score_i': scores['I'],
                'score_a': scores['A'],
                'score_s': scores['S'],
                'score_e': scores['E'],
                'score_c': scores['C']
            }
            
            result = self.riasec_repo.save_result(
                session_id=session.id,
                scores=score_dict,
                riasec_code_id=riasec_code_obj.id,
                classification_type=classification_type,
                is_inconsistent_profile=is_inconsistent
            )
            
            # 7. Generate candidate professions
            candidates_data = self.profession_service.expand_candidates(
                riasec_code=riasec_code,
                riasec_code_id=riasec_code_obj.id,
                user_scores=scores
            )
            
            # 8. Save candidates to DB
            self.riasec_repo.save_candidates(session.id, candidates_data)
            
            # 9. Update session status
            self.session_repo.update_session_status(
                session_id=session.id,
                status='riasec_completed',
                timestamp_field='riasec_completed_at'
            )
            
            # 10. Build and return result response
            return {
                "session_token": session_token,
                "status": "riasec_completed",
                "result": {
                    "riasec_code": riasec_code,
                    "riasec_code_id": riasec_code_obj.id,
                    "riasec_title": riasec_code_obj.riasec_title,
                    "riasec_description": riasec_code_obj.riasec_description,
                    "classification_type": classification_type,
                    "is_inconsistent_profile": is_inconsistent,
                    "scores": scores,
                    "strengths": riasec_code_obj.strengths,
                    "challenges": riasec_code_obj.challenges,
                    "strategies": riasec_code_obj.strategies,
                    "work_environments": riasec_code_obj.work_environments,
                    "interaction_styles": riasec_code_obj.interaction_styles
                },
                "candidates": {
                    "total_candidates": len(candidates_data.get('candidates', [])),
                    "expansion_summary": candidates_data.get('expansion_summary', {}),
                    "top_candidates": candidates_data.get('candidates', [])[:10]
                }
            }
            
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to submit RIASEC test: {str(e)}"
            )

    def get_result(self, session_token: str) -> Dict[str, Any]:
        """
        Retrieve RIASEC test result
        
        Args:
            session_token: The session token
            
        Returns:
            Dict with result data
        """
        session = self.session_repo.get_session_by_token(session_token)
        result = self.riasec_repo.get_result(session.id)
        
        return {
            "riasec_code": result.riasec_code.riasec_code,
            "riasec_title": result.riasec_code.riasec_title,
            "classification_type": result.classification_type,
            "scores": {
                "R": result.score_r,
                "I": result.score_i,
                "A": result.score_a,
                "S": result.score_s,
                "E": result.score_e,
                "C": result.score_c
            },
            "is_inconsistent_profile": result.is_inconsistent_profile,
            "calculated_at": result.calculated_at
        }