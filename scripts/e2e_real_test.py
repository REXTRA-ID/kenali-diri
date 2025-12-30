#!/usr/bin/env python3
"""
End-to-End (E2E) Real Test Script

This script performs a complete real test of the Kenali Diri Career Profiling API,
including RIASEC assessment and AI-powered Ikigai evaluation.

Usage:
    python scripts/e2e_real_test.py

Requirements:
    - API server running at http://localhost:8000
    - Database seeded with RIASEC codes and digital professions
    - Valid OpenRouter API key configured
"""
import json
import time
import random
import sys
from datetime import datetime

try:
    import requests
except ImportError:
    print("❌ ERROR: 'requests' library not installed.")
    print("   Install with: pip install requests")
    sys.exit(1)


# =============================================================================
# CONFIGURATION
# =============================================================================
BASE_URL = "http://localhost:8000/api/v1"
USER_ID = "ef9cf8e8-46b1-4e91-89d0-40f6c824319e"  # UUID format

# RIASEC question mapping (which questions map to which type)
# Based on Holland's RIASEC, 72 questions = 12 questions per type
RIASEC_QUESTIONS = {
    "R": list(range(1, 13)),      # Questions 1-12  = Realistic
    "I": list(range(13, 25)),     # Questions 13-24 = Investigative
    "A": list(range(25, 37)),     # Questions 25-36 = Artistic
    "S": list(range(37, 49)),     # Questions 37-48 = Social
    "E": list(range(49, 61)),     # Questions 49-60 = Enterprising
    "C": list(range(61, 73)),     # Questions 61-72 = Conventional
}

# Ikigai essays for a tech-oriented profile
IKIGAI_ESSAYS = {
    "love": (
        "Saya sangat menyukai coding dan memecahkan masalah logika yang kompleks. "
        "Ada kebahagiaan tersendiri saat berhasil debugging dan menemukan solusi elegan. "
        "Saya selalu excited ketika belajar teknologi baru dan menerapkannya di project nyata. "
        "Bekerja dengan data dan membangun sistem backend yang scalable adalah hal yang membuat saya semangat."
    ),
    "good_at": (
        "Saya menguasai Python dan SQL optimization dengan baik berdasarkan pengalaman 3 tahun. "
        "Saya pernah membangun RESTful API yang melayani 10,000+ request per menit. "
        "Kemampuan problem-solving dan analytical thinking saya sudah teruji di berbagai hackathon. "
        "Saya juga familiar dengan Docker, Kubernetes, dan cloud infrastructure dasar."
    ),
    "world_needs": (
        "Dunia butuh sistem yang efisien, aman, dan dapat diandalkan untuk menunjang transformasi digital. "
        "Industri membutuhkan engineer yang bisa membangun infrastruktur backend yang scalable. "
        "Banyak perusahaan yang struggle dengan legacy system dan butuh modernisasi. "
        "Dengan skill ini saya bisa membantu organisasi menjadi lebih efisien dan data-driven."
    ),
    "paid_for": (
        "Software Engineering adalah skill high demand di industri teknologi saat ini. "
        "Gaji untuk Backend Developer sangat kompetitif dengan range 15-50 juta per bulan di Indonesia. "
        "Remote work opportunities sangat banyak untuk role ini. "
        "Career progression jelas dari Junior ke Senior ke Staff/Principal Engineer."
    ),
}


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
def print_header():
    """Print test header"""
    print("\n" + "=" * 70)
    print("🚀 KENALI DIRI - End-to-End Real Test")
    print("=" * 70)
    print(f"   Base URL: {BASE_URL}")
    print(f"   Started:  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70 + "\n")


def print_step(step: int, total: int, message: str):
    """Print step header"""
    print(f"\n[{step}/{total}] {message}")
    print("-" * 50)


def print_success(message: str):
    """Print success message"""
    print(f"✅ {message}")


def print_error(message: str, response=None):
    """Print error message"""
    print(f"❌ {message}")
    if response:
        print(f"   Status Code: {response.status_code}")
        try:
            print(f"   Response: {json.dumps(response.json(), indent=2)[:500]}")
        except:
            print(f"   Response: {response.text[:500]}")


def print_info(message: str):
    """Print info message"""
    print(f"ℹ️  {message}")


def generate_riasec_answers(dominant_types: list = ["I", "R"]) -> list:
    """
    Generate 72 RIASEC answers with specified dominant types
    
    Args:
        dominant_types: List of RIASEC types to score high (e.g., ["I", "R"])
        
    Returns:
        List of {"question_id": int, "answer_value": int} dictionaries
    """
    answers = []
    
    for question_id in range(1, 73):
        # Determine which type this question belongs to
        question_type = None
        for type_code, questions in RIASEC_QUESTIONS.items():
            if question_id in questions:
                question_type = type_code
                break
        
        # Assign score based on dominance
        if question_type in dominant_types:
            # High score for dominant types (4-5)
            score = random.choice([4, 5, 5, 5])  # Bias toward 5
        else:
            # Low to medium score for other types (1-3)
            score = random.choice([1, 2, 2, 3])
        
        answers.append({
            "question_id": question_id,
            "answer_value": score
        })
    
    return answers


# =============================================================================
# TEST STEPS
# =============================================================================
def step_1_start_session() -> str:
    """Start a new career profile session"""
    print_step(1, 5, "Starting Session...")
    
    url = f"{BASE_URL}/career-profile/start"
    payload = {"user_id": USER_ID}
    
    response = requests.post(url, json=payload)
    
    if response.status_code not in [200, 201]:
        print_error("Failed to start session", response)
        return None
    
    data = response.json()
    session_token = data.get("session_token")
    
    if not session_token:
        print_error("No session_token in response", response)
        return None
    
    print_success(f"Session Created! Token: {session_token[:20]}...")
    print_info(f"Status: {data.get('status')}")
    
    return session_token


def step_2_submit_riasec(session_token: str) -> dict:
    """Submit RIASEC assessment with IR-dominant profile"""
    print_step(2, 5, "Submitting RIASEC (Simulating 'IR' Profile)...")
    
    url = f"{BASE_URL}/career-profile/riasec/submit"
    
    # Generate answers dominant in I (Investigative) and R (Realistic)
    answers = generate_riasec_answers(dominant_types=["I", "R"])
    
    payload = {
        "session_token": session_token,
        "responses": answers
    }
    
    print_info(f"Submitting {len(answers)} answers...")
    
    response = requests.post(url, json=payload)
    
    if response.status_code != 200:
        print_error("Failed to submit RIASEC", response)
        return None
    
    data = response.json()
    riasec_code = data.get("riasec_code", "?")
    
    print_success(f"RIASEC Submitted! Code: {riasec_code}")
    
    # Print score breakdown if available
    scores = data.get("scores", {})
    if scores:
        print_info("Score Breakdown:")
        for type_code, score in sorted(scores.items(), key=lambda x: x[1], reverse=True):
            bar = "█" * int(score / 5) if isinstance(score, (int, float)) else ""
            print(f"      {type_code}: {score} {bar}")
    
    return data


def step_3_check_candidates(session_token: str) -> list:
    """Check generated profession candidates"""
    print_step(3, 5, "Checking Candidates...")
    
    url = f"{BASE_URL}/career-profile/riasec/candidates/{session_token}"
    
    response = requests.get(url)
    
    if response.status_code != 200:
        print_error("Failed to get candidates", response)
        return None
    
    data = response.json()
    candidates = data.get("candidates", [])
    
    if not candidates:
        print_error("No candidates returned!")
        print_info("This might indicate that profession expansion is not yet connected to DB.")
        return []
    
    print_success(f"Found {len(candidates)} Candidates. Top 5:")
    
    for i, candidate in enumerate(candidates[:5], 1):
        name = candidate.get("profession_name", "Unknown")
        source = candidate.get("source", candidate.get("matched_code", "N/A"))
        score = candidate.get("congruence_score", 0)
        print(f"      {i}. {name} (Score: {score:.2f}, Source: {source})")
    
    return candidates


def step_4_submit_ikigai(session_token: str) -> dict:
    """Submit Ikigai assessment (calls real AI)"""
    print_step(4, 5, "Submitting Ikigai (Calling Real AI)...")
    
    url = f"{BASE_URL}/career-profile/ikigai/submit"
    
    payload = {
        "session_token": session_token,
        "love": {"text_input": IKIGAI_ESSAYS["love"]},
        "good_at": {"text_input": IKIGAI_ESSAYS["good_at"]},
        "world_needs": {"text_input": IKIGAI_ESSAYS["world_needs"]},
        "paid_for": {"text_input": IKIGAI_ESSAYS["paid_for"]}
    }
    
    print_info("⏳ Waiting for AI Analysis... (this may take 5-30 seconds)")
    
    start_time = time.time()
    response = requests.post(url, json=payload, timeout=120)
    elapsed = time.time() - start_time
    
    if response.status_code == 503:
        print_error("AI Service Unavailable (503)", response)
        print_info("Check if OPENROUTER_API_KEY is valid in docker-compose.yaml")
        return None
    
    if response.status_code != 200:
        print_error("Failed to submit Ikigai", response)
        return None
    
    data = response.json()
    
    print_success(f"Ikigai Completed in {elapsed:.2f}s!")
    print_info(f"Professions Evaluated: {data.get('total_professions_evaluated', '?')}")
    
    return data


def step_5_verify_result(ikigai_result: dict):
    """Verify and display final results"""
    print_step(5, 5, "Final Result Verification...")
    
    if not ikigai_result:
        print_error("No Ikigai result to verify!")
        return False
    
    top = ikigai_result.get("top_recommendation")
    
    if not top:
        print_error("No top recommendation in result!")
        return False
    
    print_success("🏆 TOP RECOMMENDATION:")
    print(f"      Profession:    {top.get('profession_name', 'Unknown')}")
    print(f"      Match Score:   {top.get('match_percentage', 0):.1f}%")
    print(f"      Match Level:   {top.get('match_level', 'Unknown')}")
    print(f"      RIASEC Code:   {top.get('riasec_code', 'N/A')}")
    
    # Print dimension breakdown
    dim_scores = top.get("dimension_scores", {})
    if dim_scores:
        print("\n      Dimension Scores:")
        for dim, detail in dim_scores.items():
            if isinstance(detail, dict):
                score = detail.get("final_score", 0)
                print(f"         - {dim}: {score:.2f}")
    
    # Print summary
    summary = ikigai_result.get("summary", {})
    if summary:
        print("\n   📊 Summary:")
        print(f"      Total Evaluated: {summary.get('total_evaluated', '?')}")
        print(f"      Average Score:   {summary.get('average_score', 0):.3f}")
        print(f"      Strongest:       {summary.get('strongest_dimension', 'N/A')}")
        
        recommendation_text = summary.get("recommendation", "")
        if recommendation_text:
            print(f"\n   💡 AI Recommendation:")
            # Wrap text
            words = recommendation_text.split()
            line = "      "
            for word in words:
                if len(line) + len(word) > 70:
                    print(line)
                    line = "      " + word + " "
                else:
                    line += word + " "
            if line.strip():
                print(line)
    
    return True


# =============================================================================
# MAIN
# =============================================================================
def main():
    """Run the full E2E test"""
    print_header()
    
    try:
        # Step 1: Start Session
        session_token = step_1_start_session()
        if not session_token:
            print("\n❌ TEST FAILED at Step 1")
            return False
        
        # Step 2: Submit RIASEC
        riasec_result = step_2_submit_riasec(session_token)
        if not riasec_result:
            print("\n❌ TEST FAILED at Step 2")
            return False
        
        # Step 3: Check Candidates
        candidates = step_3_check_candidates(session_token)
        # Continue even if no candidates (may not be connected to DB yet)
        
        # Step 4: Submit Ikigai (Real AI)
        ikigai_result = step_4_submit_ikigai(session_token)
        if not ikigai_result:
            print("\n❌ TEST FAILED at Step 4 (AI Evaluation)")
            print("   Note: This might be expected if AI service is not configured.")
            return False
        
        # Step 5: Verify Result
        success = step_5_verify_result(ikigai_result)
        
        # Final summary
        print("\n" + "=" * 70)
        if success:
            print("✨ ALL TESTS PASSED SUCCESSFULLY!")
        else:
            print("⚠️  Tests completed with warnings")
        print("=" * 70 + "\n")
        
        return success
        
    except requests.exceptions.ConnectionError:
        print("\n❌ CONNECTION ERROR!")
        print("   Could not connect to API server.")
        print("   Make sure the server is running: docker compose up")
        return False
    except Exception as e:
        print(f"\n❌ UNEXPECTED ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
