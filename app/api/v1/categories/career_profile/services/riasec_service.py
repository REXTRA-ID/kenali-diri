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

        if not code_detail:
            raise ValueError(f"RIASEC code {riasec_code} not found in database")

        # 5. Save responses
        self.riasec_repo.save_responses(db, session_id, responses)

        # 6. Save result ke riasec_results
        self.riasec_repo.save_result(
            db,
            session_id=session_id,
            scores=scores,
            code_id=code_detail.id,
            code_type=code_type
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
        
        scores = {k.split('_')[-1].upper().upper(): v for k, v in result.__dict__.items() if k.startswith("score_")}
        
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
