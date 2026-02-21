# app/api/v1/categories/career_profile/repositories/profession_repo.py
from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession
from app.api.v1.categories.career_profile.models.digital_profession import DigitalProfession


class Profession:
    """
    Data class representing a profession from JSONB candidates_data
    """
    def __init__(self, data: dict):
        self.id = data.get('profession_id')
        self.profession_id = data.get('profession_id')
        self.riasec_code_id = data.get('riasec_code_id')
        self.expansion_tier = data.get('expansion_tier')
        self.congruence_type = data.get('congruence_type')
        self.congruence_score = data.get('congruence_score')
        self.display_order = data.get('display_order')
        self.matched_code = data.get('matched_code')
    
    def to_dict(self) -> dict:
        """Convert to dictionary"""
        return {
            'profession_id': self.profession_id,
            'riasec_code_id': self.riasec_code_id,
            'expansion_tier': self.expansion_tier,
            'congruence_type': self.congruence_type,
            'congruence_score': self.congruence_score,
            'display_order': self.display_order,
            'matched_code': self.matched_code
        }


class ProfessionRepository:
    """
    Repository for querying profession data from IkigaiCandidateProfession JSONB
    
    This repository extracts profession candidates from the candidates_data JSONB column
    based on various filtering criteria like riasec_code_id, profession_id, etc.
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_master_professions_by_riasec_code_id(
        self,
        riasec_code_id: int,
        limit: int = 10
    ) -> List[DigitalProfession]:
        """Query actual digital professions from the master table"""
        return self.db.query(DigitalProfession).filter(
            DigitalProfession.riasec_code_id == riasec_code_id
        ).limit(limit).all()

    def get_master_professions_by_ids(
        self,
        profession_ids: List[int]
    ) -> List[DigitalProfession]:
        """Query actual digital professions by multiple IDs"""
        return self.db.query(DigitalProfession).filter(
            DigitalProfession.id.in_(profession_ids)
        ).all()

    def get_master_professions_by_riasec_code_ids(
        self,
        riasec_code_ids: List[int],
        limit: int = 20
    ) -> List[DigitalProfession]:
        """Query actual digital professions by multiple RIASEC code IDs"""
        return self.db.query(DigitalProfession).filter(
            DigitalProfession.riasec_code_id.in_(riasec_code_ids)
        ).limit(limit).all()
    
    def get_professions_by_code_id(
        self,
        riasec_code_id: int,
        test_session_id: Optional[int] = None
    ) -> List[Profession]:
        """
        Query professions by RIASEC code ID from JSONB candidates_data
        
        Args:
            riasec_code_id: The RIASEC code ID to filter by
            test_session_id: Optional test session ID to narrow search
            
        Returns:
            List[Profession]: List of matching professions
            
        Example JSONB structure:
            {
                "candidates": [
                    {
                        "profession_id": 10,
                        "riasec_code_id": 49,
                        "expansion_tier": 1,
                        "congruence_type": "exact_match",
                        "congruence_score": 1.0,
                        "display_order": 1
                    }
                ]
            }
        """
        try:
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            professions = []
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        if candidate.get('riasec_code_id') == riasec_code_id:
                            professions.append(Profession(candidate))
            
            return professions
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve professions by code ID: {str(e)}"
            )
    
    def get_professions_by_code_ids(
        self,
        code_ids: List[int],
        test_session_id: Optional[int] = None,
        limit: Optional[int] = None
    ) -> List[Profession]:
        """
        Query professions by multiple RIASEC code IDs from JSONB
        Useful for tier 2 expansion (congruent codes)
        
        Args:
            code_ids: List of RIASEC code IDs
            test_session_id: Optional test session ID to narrow search
            limit: Optional limit on number of results
            
        Returns:
            List[Profession]: List of matching professions
        """
        try:
            if not code_ids:
                return []
            
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            professions = []
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        if candidate.get('riasec_code_id') in code_ids:
                            professions.append(Profession(candidate))
                            
                            # Apply limit if specified
                            if limit and len(professions) >= limit:
                                return professions
            
            return professions
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve professions by code IDs: {str(e)}"
            )
    
    def get_profession_by_id(
        self,
        profession_id: int,
        test_session_id: Optional[int] = None
    ) -> Profession:
        """
        Query single profession by ID from JSONB candidates_data
        
        Args:
            profession_id: The profession ID
            test_session_id: Optional test session ID to narrow search
            
        Returns:
            Profession: The profession object
            
        Raises:
            HTTPException: If profession not found
        """
        try:
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        if candidate.get('profession_id') == profession_id:
                            return Profession(candidate)
            
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Profession {profession_id} not found in candidates data"
            )
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve profession: {str(e)}"
            )
    
    def get_professions_by_ids(
        self,
        profession_ids: List[int],
        test_session_id: Optional[int] = None
    ) -> List[Profession]:
        """
        Query multiple professions by their IDs from JSONB
        
        Args:
            profession_ids: List of profession IDs
            test_session_id: Optional test session ID to narrow search
            
        Returns:
            List[Profession]: List of matching professions
        """
        try:
            if not profession_ids:
                return []
            
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            professions = []
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        if candidate.get('profession_id') in profession_ids:
                            professions.append(Profession(candidate))
            
            return professions
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve professions by IDs: {str(e)}"
            )
    
    def get_professions_by_tier(
        self,
        tier: int,
        test_session_id: Optional[int] = None
    ) -> List[Profession]:
        """
        Query professions by expansion tier from JSONB
        
        Args:
            tier: Expansion tier (1-4)
            test_session_id: Optional test session ID to narrow search
            
        Returns:
            List[Profession]: List of professions from specified tier
        """
        try:
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            professions = []
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        if candidate.get('expansion_tier') == tier:
                            professions.append(Profession(candidate))
            
            return professions
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve professions by tier: {str(e)}"
            )
    
    def search_professions(
        self,
        congruence_type: Optional[str] = None,
        min_score: Optional[float] = None,
        test_session_id: Optional[int] = None,
        limit: int = 20
    ) -> List[Profession]:
        """
        Search professions with filters from JSONB
        
        Args:
            congruence_type: Filter by congruence type (exact_match, congruent, subset, etc.)
            min_score: Minimum congruence score
            test_session_id: Optional test session ID to narrow search
            limit: Maximum number of results
            
        Returns:
            List[Profession]: List of matching professions
        """
        try:
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            professions = []
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        # Apply filters
                        if congruence_type and candidate.get('congruence_type') != congruence_type:
                            continue
                        
                        if min_score and candidate.get('congruence_score', 0) < min_score:
                            continue
                        
                        professions.append(Profession(candidate))
                        
                        if len(professions) >= limit:
                            return professions
            
            return professions
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to search professions: {str(e)}"
            )
    
    def count_professions_by_code_id(
        self,
        riasec_code_id: int,
        test_session_id: Optional[int] = None
    ) -> int:
        """
        Count professions for a given RIASEC code from JSONB
        
        Args:
            riasec_code_id: The RIASEC code ID
            test_session_id: Optional test session ID to narrow search
            
        Returns:
            int: Number of professions
        """
        try:
            query = self.db.query(IkigaiCandidateProfession)
            
            if test_session_id:
                query = query.filter(
                    IkigaiCandidateProfession.test_session_id == test_session_id
                )
            
            records = query.all()
            
            count = 0
            for record in records:
                candidates_data = record.candidates_data
                if candidates_data and 'candidates' in candidates_data:
                    for candidate in candidates_data['candidates']:
                        if candidate.get('riasec_code_id') == riasec_code_id:
                            count += 1
            
            return count
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to count professions: {str(e)}"
            )
    
    # ============ CRUD Operations for IkigaiCandidateProfession ============
    
    def create_candidates(
        self,
        test_session_id: int,
        candidates_data: dict
    ) -> IkigaiCandidateProfession:
        """
        Create new candidate professions record
        
        Args:
            test_session_id: Foreign key to test session
            candidates_data: JSONB data containing candidates and metadata
            
        Returns:
            IkigaiCandidateProfession: Created record
        """
        try:
            candidate_prof = IkigaiCandidateProfession(
                test_session_id=test_session_id,
                candidates_data=candidates_data
            )
            self.db.add(candidate_prof)
            self.db.commit()
            self.db.refresh(candidate_prof)
            return candidate_prof
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create candidates: {str(e)}"
            )
    
    def get_candidates_by_session_id(
        self,
        test_session_id: int
    ) -> Optional[IkigaiCandidateProfession]:
        """
        Get candidate professions by test session ID
        
        Args:
            test_session_id: The test session ID
            
        Returns:
            IkigaiCandidateProfession or None if not found
        """
        try:
            return self.db.query(IkigaiCandidateProfession).filter(
                IkigaiCandidateProfession.test_session_id == test_session_id
            ).first()
            
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve candidates: {str(e)}"
            )
    
    def update_candidates(
        self,
        test_session_id: int,
        candidates_data: dict
    ) -> IkigaiCandidateProfession:
        """
        Update existing candidate professions record
        
        Args:
            test_session_id: The test session ID
            candidates_data: Updated JSONB data
            
        Returns:
            IkigaiCandidateProfession: Updated record
        """
        try:
            candidate_prof = self.get_candidates_by_session_id(test_session_id)
            
            if not candidate_prof:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Candidates not found for session {test_session_id}"
                )
            
            candidate_prof.candidates_data = candidates_data
            self.db.commit()
            self.db.refresh(candidate_prof)
            return candidate_prof
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to update candidates: {str(e)}"
            )
    
    def delete_candidates(self, test_session_id: int) -> bool:
        """
        Delete candidate professions record
        
        Args:
            test_session_id: The test session ID
            
        Returns:
            bool: True if deleted successfully
        """
        try:
            candidate_prof = self.get_candidates_by_session_id(test_session_id)
            
            if not candidate_prof:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Candidates not found for session {test_session_id}"
                )
            
            self.db.delete(candidate_prof)
            self.db.commit()
            return True
            
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to delete candidates: {str(e)}"
            )