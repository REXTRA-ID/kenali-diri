def classify_riasec_code(scores: dict) -> tuple[str, str]:
    """
    Classify RIASEC code based on scores
    
    Args:
        scores: {"R": 42, "I": 38, "A": 35, "S": 28, "E": 25, "C": 22}
    
    Returns:
        (code, type): ("RIA", "triple")
    """
    # Sort by score descending
    sorted_types = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    
    top_3 = sorted_types[:3]
    top_1_score = top_3[0][1]
    top_2_score = top_3[1][1]
    top_3_score = top_3[2][1]
    
    # Determine classification type
    if top_1_score >= 40 and top_2_score < 30:
        # Single dominant
        code = top_3[0][0]
        return (code, "single")
    
    elif top_2_score >= 30 and top_3_score < 28:
        # Dual
        code = top_3[0][0] + top_3[1][0]
        return (code, "dual")
    
    else:
        # Triple
        code = top_3[0][0] + top_3[1][0] + top_3[2][0]
        return (code, "triple")
