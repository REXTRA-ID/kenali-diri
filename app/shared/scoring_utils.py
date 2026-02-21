# app/shared/scoring_utils.py
"""
Scoring Utilities for Kenali Diri Application

This module contains helper functions for calculating and normalizing scores
in the career profiling system, particularly for Ikigai evaluation.

Formula Resmi (Brief Ikigai Part 2 §3.2):
  T_p,d = 15% × R_normalized(p,d) × 100    → range 0.0–15.0
  A_p,d = 10% × C_p,d × R_raw(p,d) × 100  → range 0.0–10.0 (hanya jika dipilih)
  S_p,d = T_p,d + A_p,d                    → range 0.0–25.0
  Score_total(p) = S_p,love + S_p,good_at + S_p,world + S_p,paid  → range 0–100
"""

from typing import Optional

# =============================================================================
# FUNGSI RESMI (Brief Ikigai Part 2 §3.2)
# =============================================================================

def calculate_text_score(r_normalized: float) -> float:
    """
    Hitung text score per profesi per dimensi.

    Formula: T_p,d = 15% × R_normalized(p,d) × 100
    Range output: 0.0 – 15.0

    Args:
        r_normalized: Nilai normalisasi min-max dari r_raw Gemini (0.0–1.0)

    Returns:
        Float antara 0.0 dan 15.0
    """
    r_normalized = max(0.0, min(1.0, r_normalized))
    return round(0.15 * r_normalized * 100, 4)


def calculate_click_score(r_raw: float, is_selected: bool) -> float:
    """
    Hitung click score per profesi per dimensi (confidence-based).

    Formula: A_p,d = 10% × C_p,d × R_raw(p,d) × 100
      - Menggunakan R_raw (bukan R_normalized) sebagai ukuran keyakinan AI
        sebelum distorsi normalisasi (confidence-based adjustment)
      - C_p,d = 1 jika profesi ini yang dipilih user di dimensi ini, 0 jika tidak
    Range output: 0.0 – 10.0

    Args:
        r_raw: Nilai mentah dari Gemini sebelum normalisasi (0.0–1.0)
        is_selected: True jika profesi ini yang dipilih user di dimensi ini

    Returns:
        Float antara 0.0 dan 10.0
    """
    if not is_selected:
        return 0.0
    r_raw = max(0.0, min(1.0, r_raw))
    return round(0.10 * r_raw * 100, 4)


# =============================================================================
# FUNGSI LAMA — DEPRECATED
# Fungsi-fungsi di bawah ini tidak sesuai formula Brief Part 2.
# Dipertahankan untuk backward compatibility, jangan digunakan untuk scoring baru.
# =============================================================================

def calculate_min_max_normalization(value: float, min_val: float, max_val: float) -> float:
    """Normalize a value using min-max scaling."""
    if max_val == min_val:
        return 0.5
    return (value - min_val) / (max_val - min_val)

def calculate_ikigai_dimension_average(scores_dim: dict) -> float:
    """Calculate average of Ikigai dimensions."""
    if not scores_dim:
        return 0.0
    return sum(scores_dim.values()) / len(scores_dim)

def calculate_confidence_adjusted_click(
    is_clicked: bool,
    ai_score: float,
    click_weight: float = 0.10
) -> float:
    """
    Calculate confidence-adjusted click bonus
    
    This function normalizes the click bonus based on AI's evaluation of
    the user's essay. This prevents users from mindlessly clicking
    professions without providing relevant justifications.
    
    Formula: Bonus = click_weight × click_status × ai_score
    
    Example:
        - User clicks profession AND writes relevant essay (AI score = 0.8):
          Bonus = 0.10 × 1 × 0.8 = 0.08 (8% bonus)
        
        - User clicks profession but writes irrelevant essay (AI score = 0.1):
          Bonus = 0.10 × 1 × 0.1 = 0.01 (only 1% bonus - penalty for spam)
        
        - User doesn't click:
          Bonus = 0.10 × 0 × any = 0.0 (no bonus)
    
    Args:
        is_clicked: Whether the user clicked/selected this profession
        ai_score: AI's evaluation score (0.0 - 1.0) for the user's essay
        click_weight: Base weight for click bonus (default 10% = 0.10)
        
    Returns:
        Float between 0.0 and click_weight representing the adjusted bonus
    """
    if not is_clicked:
        return 0.0
    
    # Clamp AI score to valid range
    ai_score = max(0.0, min(1.0, ai_score))
    
    # Calculate adjusted bonus
    return click_weight * ai_score


def calculate_final_profession_score(
    riasec_match_score: float,
    dimension_scores: dict,
    click_bonus: float = 0.0,
    riasec_weight: float = 0.40,
    ikigai_weight: float = 0.50,
    click_weight: float = 0.10
) -> float:
    """
    Calculate the final weighted score for a profession candidate
    
    Combines multiple scoring factors:
    - RIASEC personality match (40%)
    - Ikigai dimension scores (50%)
    - User click/selection bonus (10% - confidence adjusted)
    
    Formula: Final = (0.4 × RIASEC) + (0.5 × Ikigai_Avg) + (0.1 × Click_Adjusted)
    
    Args:
        riasec_match_score: Score from RIASEC personality matching (0.0-1.0)
        dimension_scores: Dict of Ikigai dimension scores, e.g.:
            {
                "passion": 0.8,
                "mission": 0.7,
                "vocation": 0.6,
                "profession": 0.9
            }
        click_bonus: Pre-calculated confidence-adjusted click bonus
        riasec_weight: Weight for RIASEC score (default 0.40)
        ikigai_weight: Weight for Ikigai score (default 0.50)
        click_weight: Weight for click bonus (default 0.10)
        
    Returns:
        Final weighted score between 0.0 and 1.0
    """
    # Calculate average Ikigai dimension score
    if dimension_scores:
        ikigai_avg = sum(dimension_scores.values()) / len(dimension_scores)
    else:
        ikigai_avg = 0.0
    
    # Clamp all inputs
    riasec_match_score = max(0.0, min(1.0, riasec_match_score))
    ikigai_avg = max(0.0, min(1.0, ikigai_avg))
    click_bonus = max(0.0, min(click_weight, click_bonus))
    
    # Calculate final score
    final_score = (
        (riasec_weight * riasec_match_score) +
        (ikigai_weight * ikigai_avg) +
        click_bonus  # Already weighted by calculate_confidence_adjusted_click
    )
    
    return max(0.0, min(1.0, final_score))


def normalize_score_to_percentage(score: float, decimals: int = 1) -> float:
    """
    Convert normalized score (0.0-1.0) to percentage (0-100)
    
    Args:
        score: Normalized score between 0.0 and 1.0
        decimals: Number of decimal places (default 1)
        
    Returns:
        Percentage value between 0 and 100
    """
    percentage = max(0.0, min(1.0, score)) * 100
    return round(percentage, decimals)


def get_match_level(score: float) -> str:
    """
    Get human-readable match level based on score
    
    Thresholds:
        0.0 - 0.29: "Low Match"
        0.3 - 0.49: "Moderate Match"
        0.5 - 0.69: "Good Match"
        0.7 - 0.84: "Strong Match"
        0.85 - 1.0: "Excellent Match"
    
    Args:
        score: Normalized score between 0.0 and 1.0
        
    Returns:
        Human-readable match level string
    """
    score = max(0.0, min(1.0, score))
    
    if score >= 0.85:
        return "Excellent Match"
    elif score >= 0.70:
        return "Strong Match"
    elif score >= 0.50:
        return "Good Match"
    elif score >= 0.30:
        return "Moderate Match"
    else:
        return "Low Match"
