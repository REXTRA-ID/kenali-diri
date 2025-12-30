# app/shared/scoring_utils.py
"""
Scoring Utilities for Kenali Diri Application

This module contains helper functions for calculating and normalizing scores
in the career profiling system, particularly for Ikigai evaluation.

Key Concepts:
- Confidence-Based Click Adjustment: Prevents users from gaming the system by 
  clicking professions without providing relevant essay responses.
- The click bonus is weighted by the AI's confidence score for the essay.
"""

from typing import Optional


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
