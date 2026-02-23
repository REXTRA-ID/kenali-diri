import os
import requests
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import sys

# Replace with the actual database URL, or read from .env if needed
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@localhost:5432/kenali_diri")

try:
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    # Get a random or the first user from the database
    result = session.execute(text('SELECT id FROM users LIMIT 1')).fetchone()
    if not result:
        print("No users found in database.")
        sys.exit(1)
        
    user_id = str(result[0])
    print(f"Using test User ID: {user_id}")
    session.close()

except Exception as e:
    print(f"Database connection error: {e}")
    sys.exit(1)

BASE_URL = "http://localhost:8010/api/v1"
headers = {
    "x-user-id": user_id,
    "Content-Type": "application/json"
}

def print_response(stage, response):
    print(f"\n--- {stage} ---")
    print(f"Status Code: {response.status_code}")
    if response.status_code >= 400:
        try:
            print("Error Details:", response.json())
        except:
            print("Error Text:", response.text)
    else:
        print("Success")

from datetime import datetime
print("\n==================================================")
print("ALUR 1: REKOMENDASI PROFESI (RECOMMENDATION)")
print("==================================================")

# 1A. Start Session
payload_1a = {"persona_type": "PATHFINDER"}
r1a = requests.post(f"{BASE_URL}/career-profile/recommendation/start", json=payload_1a, headers=headers)
print_response("1A. Memulai Sesi RECOMMENDATION", r1a)
if r1a.status_code != 200 and r1a.status_code != 201:
    sys.exit(1)
rec_session_token = r1a.json().get("session_token")
print(f"Session Token: {rec_session_token}")

# 1B. Submit RIASEC (72 items mock)
types_riasec = ["R", "I", "A", "S", "E", "C"]
base_scores = {"R": 5, "I": 4, "A": 3, "S": 2, "E": 1, "C": 3}
responses_riasec = []
for type_idx, q_type in enumerate(types_riasec):
    for i in range(1, 13): # 12 per type
        question_id = (type_idx * 12) + i
        val = base_scores[q_type]
        # just add a little variance
        if i % 3 == 0 and val < 5: val += 1
        responses_riasec.append({
            "question_id": question_id,
            "question_type": q_type,
            "answer_value": val,
            "answered_at": datetime.utcnow().isoformat() + "Z"
        })

payload_1b = {
    "session_token": rec_session_token,
    "responses": responses_riasec
}
r1b = requests.post(f"{BASE_URL}/career-profile/riasec/submit", json=payload_1b, headers=headers)
print_response("1B. Submit Jawaban RIASEC", r1b)
if r1b.status_code != 200:
    sys.exit(1)

# 1C. Start Ikigai
payload_1c = {"session_token": rec_session_token}
r1c = requests.post(f"{BASE_URL}/career-profile/ikigai/start", json=payload_1c, headers=headers)
print_response("1C. Memulai Sesi Tes IKIGAI", r1c)
if r1c.status_code != 200:
    sys.exit(1)

# Wait... what if Ikigai content generation fails from OpenRouter? Let's check the result.
try:
    data_1c = r1c.json()
    professions = data_1c.get('professions', [])
    first_prof_id = professions[0]['profession_id'] if professions else None
except Exception as e:
    first_prof_id = None
    print(f"Failed to parse professions: {e}")

# 1D. Submit Dimension 1
payload_1d = {
    "session_token": rec_session_token,
    "dimension_name": "what_you_love",
    "selected_profession_id": first_prof_id,
    "selection_type": "selected" if first_prof_id else "not_selected",
    "reasoning_text": "Saya suka ini."
}
r1d = requests.post(f"{BASE_URL}/career-profile/ikigai/submit-dimension", json=payload_1d, headers=headers)
print_response("1D. Submit Dimensi 1 - What You Love", r1d)

# 1E. Submit Dimension 2
payload_1e = payload_1d.copy()
payload_1e["dimension_name"] = "what_you_are_good_at"
r1e = requests.post(f"{BASE_URL}/career-profile/ikigai/submit-dimension", json=payload_1e, headers=headers)
print_response("1E. Submit Dimensi 2 - What You Are Good At", r1e)

# 1F. Submit Dimension 3
payload_1f = payload_1d.copy()
payload_1f["dimension_name"] = "what_the_world_needs"
r1f = requests.post(f"{BASE_URL}/career-profile/ikigai/submit-dimension", json=payload_1f, headers=headers)
print_response("1F. Submit Dimensi 3 - What The World Needs", r1f)

# 1G. Submit Dimension 4 (Triggers Final AI)
payload_1g = payload_1d.copy()
payload_1g["dimension_name"] = "what_you_can_be_paid_for"
print("\n--> Submitting 4th Dimension. This triggers background AI scoring... please wait <--")
r1g = requests.post(f"{BASE_URL}/career-profile/ikigai/submit-dimension", json=payload_1g, headers=headers)
print_response("1G. Submit Dimensi 4 - What You Can Be Paid For (Final)", r1g)

# 1H. Check Recommendation Result
r1h = requests.get(f"{BASE_URL}/career-profile/result/recommendation/{rec_session_token}", headers=headers)
print_response("1H. Cek Hasil Rekomendasi", r1h)


print("\n==================================================")
print("ALUR 2: FIT CHECK")
print("==================================================")

# 2A. Start Fit Check
payload_2a = {
    "persona_type": "BUILDER",
    "target_profession_id": 1  # use 1 or anything
}
r2a = requests.post(f"{BASE_URL}/career-profile/fit-check/start", json=payload_2a, headers=headers)
print_response("2A. Memulai Sesi FIT CHECK", r2a)
if r2a.status_code == 200 or r2a.status_code == 201:
    fit_session_token = r2a.json().get("session_token")
    
    # 2B. Submit RIASEC
    payload_2b = {
        "session_token": fit_session_token,
        "responses": responses_riasec
    }
    r2b = requests.post(f"{BASE_URL}/career-profile/riasec/submit", json=payload_2b, headers=headers)
    print_response("2B. Submit Jawaban RIASEC untuk FIT CHECK", r2b)
    
    # 2C. Fit Check Result
    r2c = requests.get(f"{BASE_URL}/career-profile/result/fit-check/{fit_session_token}", headers=headers)
    print_response("2C. Hasil Pencocokan Fit Check", r2c)
    
else:
    print("Failed to start FIT CHECK")

print("\nDone!")
