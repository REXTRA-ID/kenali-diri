from app.api.v1.categories.career_profile.repositories.riasec_repo import RIASECRepository
from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.utils.constants import QUESTION_TYPE_MAP
from app.api.v1.categories.career_profile.utils.classification import classify_riasec_code

class RIASECService:
    def __init__(self):
        self.riasec_repo = RIASECRepository()
        self.session_repo = SessionRepository()
        
    def submit_and_calculate(self, db, session_id: int, responses: dict):
        """
        Submit RIASEC responses dan calculate scores:
        1. Validate 72 responses
        2. Calculate raw scores (R, I, A, S, E, C)
        3. Classify RIASEC code
        4. Save responses_data ke riasec_responses
        5. Save result ke riasec_results (dengan kolom score_r, score_i, dsb)
        6. Update session: riasec_completed = TRUE
        """
        # 1. Validate
        if len(responses) != 72:
            raise ValueError("Must have exactly 72 responses")

        # 2. Calculate raw scores
        scores = {"R": 0, "I": 0, "A": 0, "S": 0, "E": 0, "C": 0}

        for question_id_str, score in responses.items():
            question_id = int(question_id_str)
            riasec_type = QUESTION_TYPE_MAP.get(question_id)
            if not riasec_type:
                raise ValueError(f"Question ID {question_id} not mapped to any RIASEC type")
            scores[riasec_type] += score

        # 3. Classify RIASEC code
        riasec_code, code_type = classify_riasec_code(scores)

        # 4. Query riasec_codes table untuk detail (deskripsi, title, dll)
        code_detail = self.riasec_repo.get_code_by_code(db, riasec_code)

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
        Calculate RIASEC scores from responses using RAW SCORE method
        
        IMPORTANT RULES:
        - Uses RAW SCORE (summation), NOT averaging!
        - Each RIASEC type has 12 questions with answers 1-5
        - Valid score range per type: 12-60 (12 × 1 = 12 min, 12 × 5 = 60 max)
        - DO NOT divide by question count - this is intentional!
        
        Example:
            - User answers all "R" questions with value 5: score_R = 60
            - User answers all "R" questions with value 1: score_R = 12
            - User answers all "R" questions with value 3: score_R = 36
        
        Args:
            responses: List of user responses (72 total: 12 per RIASEC type)
            
        Returns:
            Dict with RAW scores per type: {"R": 50, "I": 48, "A": 46, ...}
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

        # 7. Update session status
        self.session_repo.mark_riasec_completed(db, session_id)

        # Urutkan kunci untuk top 3
        sorted_codes = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        top_3_list = [item[0] for item in sorted_codes[:3]]

        return {
            "riasec_code": riasec_code,
            "responses_data": responses,
            "riasec_title": code_detail.riasec_title,
            "riasec_scores": scores,
            "classification_type": code_type,
            "top_3_codes": top_3_list,
            "code_details": {
                "code": code_detail.riasec_code,
                "title": code_detail.riasec_title,
                "description": code_detail.riasec_description,
                "strengths": code_detail.strengths,
                "challenges": code_detail.challenges
            }
        }
    
    def get_result(self, db, session_id: int):
        """Get RIASEC result yang sudah dihitung"""
        result = self.riasec_repo.get_result_by_session(db, session_id)
        
        if not result:
            return None
        
        # Load code detail
        code_detail = self.riasec_repo.get_code_by_id(db, result.riasec_code_id)
        
        Args:
            session_token: The session token
            responses: List of user responses (72 items: 12 per RIASEC type)
            
        Returns:
            Dict with complete result data
        """
        try:
            # 1. Validate session exists
            session = self.session_repo.get_session_by_token(session_token)
            print(f"DEBUG: Session status is '{session.status}'")
            
            if session.status not in ['riasec_pending', 'riasec_ongoing']:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid session status: {session.status}"
                )
            
            # Update status to ongoing if it was pending
            if session.status == 'riasec_pending':
                session.status = 'riasec_ongoing'
                self.db.commit()
            
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
                user_scores=scores,
                is_inconsistent_profile=is_inconsistent  # Pass inconsistency flag for Split-Path
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
        
        sorted_codes = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        top_3_list = [item[0] for item in sorted_codes[:3]]
        
        return {
            "riasec_code": code_detail.riasec_code,
            "riasec_title": code_detail.riasec_title,
            "riasec_scores": scores,
            "classification_type": result.riasec_code_type,
            "top_3_codes": top_3_list,
            "code_details": {
                "code": code_detail.riasec_code,
                "title": code_detail.riasec_title,
                "description": code_detail.riasec_description,
                "strengths": code_detail.strengths,
                "challenges": code_detail.challenges
            }
        }
