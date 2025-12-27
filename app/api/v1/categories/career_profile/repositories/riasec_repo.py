# app/api/v1/categories/career_profile/repositories/riasec_repo.py
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import SQLAlchemyError, IntegrityError
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.models.riasec import (
    RIASECCode,
    RIASECQuestionSet,
    RIASECResult,
    RIASECResponse
)
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession


class RIASECRepository:
    """
    Repository for managing RIASEC test data including:
    - Question sets
    - User responses
    - Test results
    - RIASEC codes
    - Candidate professions
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    # ============ RIASEC Question Sets ============
    
    def create_question_set(
        self,
        session_id: int,
        question_ids: List[int]
    ) -> RIASECQuestionSet:
        """
        Create question set for a test session
        
        Args:
            session_id: Test session ID
            question_ids: List of question IDs to include in test
            
        Returns:
            RIASECQuestionSet: Created question set
            
        Raises:
            HTTPException: If question set already exists or database error
        """
        try:
            question_set = RIASECQuestionSet(
                test_session_id=session_id,
                question_ids=question_ids
            )
            
            self.db.add(question_set)
            self.db.commit()
            self.db.refresh(question_set)
            
            return question_set
            
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Question set already exists for session {session_id}"
            )
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create question set: {str(e)}"
            )
    
    def get_question_set(
        self,
        session_id: int
    ) -> RIASECQuestionSet:
        """
        Get question set for a test session
        
        Args:
            session_id: Test session ID
            
        Returns:
            RIASECQuestionSet: The question set
            
        Raises:
            HTTPException: If question set not found
        """
        try:
            question_set = self.db.query(RIASECQuestionSet).filter(
                RIASECQuestionSet.test_session_id == session_id
            ).first()
            
            if not question_set:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Question set not found for session {session_id}"
                )
            
            return question_set
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve question set: {str(e)}"
            )
    
    def delete_question_set(self, session_id: int) -> bool:
        """
        Delete question set for a test session
        
        Args:
            session_id: Test session ID
            
        Returns:
            bool: True if deleted successfully
        """
        try:
            question_set = self.get_question_set(session_id)
            
            self.db.delete(question_set)
            self.db.commit()
            
            return True
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to delete question set: {str(e)}"
            )
    
    # ============ RIASEC Responses ============
    
    def save_responses(
        self,
        session_id: int,
        responses_data: Dict[str, Any]
    ) -> RIASECResponse:
        """
        Save user responses for a test session
        
        Args:
            session_id: Test session ID
            responses_data: JSONB data containing user responses
                Example: {
                    "responses": [
                        {"question_id": 1, "answer": 5},
                        {"question_id": 2, "answer": 3}
                    ]
                }
            
        Returns:
            RIASECResponse: Created response record
            
        Raises:
            HTTPException: If responses already exist or database error
        """
        try:
            response = RIASECResponse(
                test_session_id=session_id,
                responses_data=responses_data
            )
            
            self.db.add(response)
            self.db.commit()
            self.db.refresh(response)
            
            return response
            
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Responses already exist for session {session_id}"
            )
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save responses: {str(e)}"
            )
    
    def get_responses(
        self,
        session_id: int
    ) -> RIASECResponse:
        """
        Get user responses for a test session
        
        Args:
            session_id: Test session ID
            
        Returns:
            RIASECResponse: The response record
            
        Raises:
            HTTPException: If responses not found
        """
        try:
            response = self.db.query(RIASECResponse).filter(
                RIASECResponse.test_session_id == session_id
            ).first()
            
            if not response:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Responses not found for session {session_id}"
                )
            
            return response
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve responses: {str(e)}"
            )
    
    def update_responses(
        self,
        session_id: int,
        responses_data: Dict[str, Any]
    ) -> RIASECResponse:
        """
        Update existing responses
        
        Args:
            session_id: Test session ID
            responses_data: Updated JSONB data
            
        Returns:
            RIASECResponse: Updated response record
        """
        try:
            response = self.get_responses(session_id)
            
            response.responses_data = responses_data
            self.db.commit()
            self.db.refresh(response)
            
            return response
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to update responses: {str(e)}"
            )
    
    # ============ RIASEC Results ============
    
    def save_result(
        self,
        session_id: int,
        scores: Dict[str, int],
        riasec_code_id: int,
        classification_type: str,
        is_inconsistent_profile: bool = False
    ) -> RIASECResult:
        """
        Save RIASEC test result
        
        Args:
            session_id: Test session ID
            scores: Dict with scores {"R": 8, "I": 7, "A": 6, "S": 5, "E": 4, "C": 3}
            riasec_code_id: Foreign key to riasec_codes table
            classification_type: Type of classification ('single', 'dual', 'triple')
            is_inconsistent_profile: Whether profile shows inconsistency
            
        Returns:
            RIASECResult: Created result record
            
        Raises:
            HTTPException: If result already exists or database error
        """
        try:
            result = RIASECResult(
                test_session_id=session_id,
                score_r=scores.get('score_r', 0),
                score_i=scores.get('score_i', 0),
                score_a=scores.get('score_a', 0),
                score_s=scores.get('score_s', 0),
                score_e=scores.get('score_e', 0),
                score_c=scores.get('score_c', 0),
                riasec_code_id=riasec_code_id,
                classification_type=classification_type,
                is_inconsistent_profile=is_inconsistent_profile
            )
            
            self.db.add(result)
            self.db.commit()
            self.db.refresh(result)
            
            return result
            
        except IntegrityError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Result already exists for session {session_id}"
            )
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save result: {str(e)}"
            )
    
    def get_result(
        self,
        session_id: int
    ) -> RIASECResult:
        """
        Get RIASEC result with joined RIASEC code info
        
        Args:
            session_id: Test session ID
            
        Returns:
            RIASECResult: Result with riasec_code relationship loaded
            
        Raises:
            HTTPException: If result not found
        """
        try:
            result = self.db.query(RIASECResult).options(
                joinedload(RIASECResult.riasec_code)
            ).filter(
                RIASECResult.test_session_id == session_id
            ).first()
            
            if not result:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Result not found for session {session_id}"
                )
            
            return result
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve result: {str(e)}"
            )
    
    def update_result(
        self,
        session_id: int,
        scores: Dict[str, int],
        riasec_code_id: int,
        classification_type: str,
        is_inconsistent_profile: bool = False
    ) -> RIASECResult:
        """
        Update existing RIASEC result
        
        Args:
            session_id: Test session ID
            scores: Updated scores
            riasec_code_id: Updated RIASEC code ID
            classification_type: Updated classification type
            is_inconsistent_profile: Updated inconsistency flag
            
        Returns:
            RIASECResult: Updated result
        """
        try:
            result = self.get_result(session_id)
            
            result.score_r = scores.get('R', result.score_r)
            result.score_i = scores.get('I', result.score_i)
            result.score_a = scores.get('A', result.score_a)
            result.score_s = scores.get('S', result.score_s)
            result.score_e = scores.get('E', result.score_e)
            result.score_c = scores.get('C', result.score_c)
            result.riasec_code_id = riasec_code_id
            result.classification_type = classification_type
            result.is_inconsistent_profile = is_inconsistent_profile
            
            self.db.commit()
            self.db.refresh(result)
            
            return result
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to update result: {str(e)}"
            )
    
    def get_result_scores_dict(self, session_id: int) -> Dict[str, int]:
        """
        Get result scores as dictionary for easy access
        
        Args:
            session_id: Test session ID
            
        Returns:
            Dict[str, int]: Scores dictionary {"R": 8, "I": 7, ...}
        """
        result = self.get_result(session_id)
        
        return {
            'R': result.score_r,
            'I': result.score_i,
            'A': result.score_a,
            'S': result.score_s,
            'E': result.score_e,
            'C': result.score_c
        }
    
    # ============ RIASEC Codes ============
    
    def get_riasec_code_by_string(
        self,
        code: str
    ) -> RIASECCode:
        """
        Get RIASEC code by code string (e.g., "RIA", "R", "SE")
        
        Args:
            code: RIASEC code string (1-3 characters)
            
        Returns:
            RIASECCode: The RIASEC code record
            
        Raises:
            HTTPException: If code not found
        """
        try:
            riasec_code = self.db.query(RIASECCode).filter(
                RIASECCode.riasec_code == code.upper()
            ).first()
            
            if not riasec_code:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"RIASEC code '{code}' not found"
                )
            
            return riasec_code
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve RIASEC code: {str(e)}"
            )
    
    def get_riasec_code_by_id(
        self,
        code_id: int
    ) -> RIASECCode:
        """
        Get RIASEC code by ID
        
        Args:
            code_id: RIASEC code ID
            
        Returns:
            RIASECCode: The RIASEC code record
            
        Raises:
            HTTPException: If code not found
        """
        try:
            riasec_code = self.db.query(RIASECCode).filter(
                RIASECCode.id == code_id
            ).first()
            
            if not riasec_code:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"RIASEC code ID {code_id} not found"
                )
            
            return riasec_code
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve RIASEC code: {str(e)}"
            )
    
    def get_all_riasec_codes(
        self,
        code_length: Optional[int] = None
    ) -> List[RIASECCode]:
        """
        Get all RIASEC codes, optionally filtered by length
        
        Args:
            code_length: Optional filter by code length (1, 2, or 3)
            
        Returns:
            List[RIASECCode]: List of RIASEC codes
        """
        try:
            query = self.db.query(RIASECCode)
            
            if code_length:
                # Filter by length using SQL length function
                query = query.filter(
                    func.length(RIASECCode.riasec_code) == code_length
                )
            
            return query.all()
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve RIASEC codes: {str(e)}"
            )
    
    def search_riasec_codes(
        self,
        search_term: str
    ) -> List[RIASECCode]:
        """
        Search RIASEC codes by code or title
        
        Args:
            search_term: Search term
            
        Returns:
            List[RIASECCode]: Matching RIASEC codes
        """
        try:
            search_pattern = f"%{search_term}%"
            
            return self.db.query(RIASECCode).filter(
                (RIASECCode.riasec_code.ilike(search_pattern)) |
                (RIASECCode.riasec_title.ilike(search_pattern))
            ).all()
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to search RIASEC codes: {str(e)}"
            )
    
    # ============ Candidate Professions (Ikigai) ============
    
    def save_candidates(
        self,
        session_id: int,
        candidates_data: Dict[str, Any]
    ) -> IkigaiCandidateProfession:
        """
        Save candidate professions for a test session
        
        Args:
            session_id: Test session ID
            candidates_data: JSONB data containing profession candidates
                Example: {
                    "user_riasec_code": "RIA",
                    "user_top_3_types": ["R", "I", "A"],
                    "candidates": [...],
                    "expansion_summary": {...}
                }
            
        Returns:
            IkigaiCandidateProfession: Created candidates record
            
        Raises:
            HTTPException: If candidates already exist or database error
        """
        try:
            candidates = IkigaiCandidateProfession(
                test_session_id=session_id,
                candidates_data=candidates_data
            )
            
            self.db.add(candidates)
            self.db.commit()
            self.db.refresh(candidates)
            
            return candidates
            
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Candidates already exist for session {session_id}"
            )
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save candidates: {str(e)}"
            )
    
    def get_candidates(
        self,
        session_id: int
    ) -> IkigaiCandidateProfession:
        """
        Get candidate professions for a test session
        
        Args:
            session_id: Test session ID
            
        Returns:
            IkigaiCandidateProfession: The candidates record
            
        Raises:
            HTTPException: If candidates not found
        """
        try:
            candidates = self.db.query(IkigaiCandidateProfession).filter(
                IkigaiCandidateProfession.test_session_id == session_id
            ).first()
            
            if not candidates:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Candidates not found for session {session_id}"
                )
            
            return candidates
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve candidates: {str(e)}"
            )
    
    def update_candidates(
        self,
        session_id: int,
        candidates_data: Dict[str, Any]
    ) -> IkigaiCandidateProfession:
        """
        Update existing candidates
        
        Args:
            session_id: Test session ID
            candidates_data: Updated JSONB data
            
        Returns:
            IkigaiCandidateProfession: Updated candidates record
        """
        try:
            candidates = self.get_candidates(session_id)
            
            candidates.candidates_data = candidates_data
            self.db.commit()
            self.db.refresh(candidates)
            
            return candidates
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to update candidates: {str(e)}"
            )
    
    def delete_candidates(self, session_id: int) -> bool:
        """
        Delete candidates for a test session
        
        Args:
            session_id: Test session ID
            
        Returns:
            bool: True if deleted successfully
        """
        try:
            candidates = self.get_candidates(session_id)
            
            self.db.delete(candidates)
            self.db.commit()
            
            return True
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to delete candidates: {str(e)}"
            )