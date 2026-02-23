from pydantic import BaseModel
from typing import Optional, List


# ── Shared building blocks ────────────────────────────────────────────────────

class TopTypeItem(BaseModel):
    """Satu huruf RIASEC beserta nama tipenya. Digunakan di PersonalityResultResponse."""
    letter: str   # "R", "I", "A", "S", "E", atau "C"
    name: str     # "Realistic", "Investigative", dst.


class RIASECSummary(BaseModel):
    """Ringkasan profil RIASEC. Digunakan di FitCheckResultResponse dan RecommendationResultResponse."""
    riasec_code:           str
    riasec_title:          str
    top_types:             List[str]
    total_candidates_found: Optional[int] = None  # hanya untuk RECOMMENDATION


# ── Personality Tab (shared endpoint) ────────────────────────────────────────

class PersonalityResultResponse(BaseModel):
    """
    Response GET /result/personality/{session_token}
    Shared endpoint — bisa dipanggil dari halaman RECOMMENDATION maupun FIT_CHECK.
    """
    session_token:      str
    riasec_code:        str
    riasec_title:       str
    top_types:          List[TopTypeItem]
    about_code:         str
    strengths:          List[str]
    challenges:         List[str]
    strategies:         List[str]
    interaction_styles: List[str]
    work_environments:  List[str]


# ── FIT CHECK ─────────────────────────────────────────────────────────────────

class FitCheckExplanation(BaseModel):
    """Penjelasan dinamis rule-based hasil Fit Check."""
    meaning:       str
    reason_points: List[str]
    implication:   str
    next_steps:    List[str]
    cta_primary:   str
    cta_secondary: Optional[str]
    match_label:   str
    match_stars:   int


class TargetProfession(BaseModel):
    """Profesi yang dicek dalam sesi FIT_CHECK."""
    profession_id: int
    name:          str
    riasec_code:   str
    riasec_title:  str


class FitCheckResultItem(BaseModel):
    """Wrapper item hasil Fit Check."""
    match_category:      str    # "HIGH" / "MEDIUM" / "LOW"
    match_label:         str    # "Kecocokan Tinggi" / "Kecocokan Sedang" / "Kecocokan Rendah"
    match_stars:         int    # 3 / 2 / 1
    rule_type:           str
    dominant_letter_same: bool
    is_adjacent_hexagon: bool
    match_score:         Optional[float]
    explanation:         FitCheckExplanation


class FitCheckResultResponse(BaseModel):
    """Response GET /result/fit-check/{session_token}"""
    session_token:    str
    user_first_name:  str
    test_completed_at: Optional[str]
    user_riasec:      RIASECSummary
    target_profession: TargetProfession
    fit_check_result: FitCheckResultItem
    points_awarded:   Optional[str] = None
    TODO_points: Optional[str] = (
        "Implementasi poin Rextra belum aktif. Tambahkan setelah tabel points dikonfirmasi."
    )


# ── RECOMMENDATION ────────────────────────────────────────────────────────────

class ScoreBreakdown(BaseModel):
    """Breakdown skor Ikigai per dimensi untuk satu profesi."""
    total_score:              float
    intrinsic_score:          float
    extrinsic_score:          float
    score_what_you_love:      float
    score_what_you_are_good_at: float
    score_what_the_world_needs: float
    score_what_you_can_be_paid_for: float


class RIASECAlignment(BaseModel):
    """Informasi keselarasan RIASEC antara user dan profesi yang direkomendasikan."""
    user_code:        str
    profession_code:  str
    congruence_type:  str
    congruence_score: float


class RecommendedProfession(BaseModel):
    """Satu profesi yang direkomendasikan beserta narasi dan skor."""
    rank:             int
    profession_id:    int
    profession_name:  str
    match_percentage: float
    match_reasoning:  str
    riasec_alignment: RIASECAlignment
    score_breakdown:  ScoreBreakdown


class CandidateProfessionName(BaseModel):
    """Pasangan ID+nama untuk satu profesi kandidat — hanya untuk list display."""
    profession_id: int
    name:          str


class IkigaiProfileSummary(BaseModel):
    """Narasi ringkasan 4 dimensi Ikigai dari Gemini."""
    what_you_love:          str
    what_you_are_good_at:   str
    what_the_world_needs:   str
    what_you_can_be_paid_for: str


class RecommendationResultResponse(BaseModel):
    """Response GET /result/recommendation/{session_token}"""
    session_token:             str
    user_first_name:           str
    test_completed_at:         Optional[str]
    riasec_summary:            RIASECSummary
    candidate_profession_names: List[CandidateProfessionName]
    ikigai_profile_summary:    IkigaiProfileSummary
    recommended_professions:   List[RecommendedProfession]
    points_awarded:            Optional[str] = None
    TODO_points: Optional[str] = (
        "Implementasi poin Rextra belum aktif. Tambahkan setelah tabel points dikonfirmasi."
    )
