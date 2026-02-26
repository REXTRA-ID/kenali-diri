"""
╔══════════════════════════════════════════════════════════════════╗
║        KENALI DIRI - AI Test Runner (OpenRouter)                 ║
║  AI menjawab RIASEC + Ikigai dengan kepribadian yang konsisten   ║
╚══════════════════════════════════════════════════════════════════╝

Cara pakai:
  python test_ai_runner.py

Env yang dibutuhkan (dari .env):
  OPENROUTER_API_KEY=sk-or-v1-...
  OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
  OPENROUTER_MODEL=google/gemini-2.0-flash
  BASE_URL=http://localhost:8000
  TEST_USER_ID=<uuid>   ← user yang sudah ada di DB
"""

import os, sys, json, time, random, string, textwrap
import requests
import psycopg2
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# ─── CONFIG ───────────────────────────────────────────────────────────────────
BASE_URL         = os.getenv("BASE_URL", "http://localhost:8010")
API_V1           = f"{BASE_URL}/api/v1"
OR_API_KEY       = os.getenv("OPENROUTER_API_KEY", "")
OR_BASE_URL      = os.getenv("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1")
OR_MODEL         = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash")
DB_HOST          = os.getenv("DB_HOST", "localhost")
DB_PORT          = int(os.getenv("DB_PORT", "5433"))
DB_NAME          = os.getenv("DB_NAME", "kenali_diri")
DB_USER          = os.getenv("DB_USER", "user")
DB_PASS          = os.getenv("DB_PASS", os.getenv("DB_PASSWORD", "password"))

# Warna terminal
R = "\033[91m"; G = "\033[92m"; Y = "\033[93m"
B = "\033[94m"; M = "\033[95m"; C = "\033[96m"
W = "\033[97m"; DIM = "\033[2m"; BOLD = "\033[1m"; RESET = "\033[0m"

# ─── AI PERSONA ───────────────────────────────────────────────────────────────
# Persona diacak dari pilihan berikut - konsisten dalam 1 sesi
PERSONAS = [
    {
        "name": "Andi - Software Engineer Idealis",
        "riasec_dominan": "I",  # Investigative
        "deskripsi": "Andi adalah seorang yang sangat analitis, senang memecahkan masalah kompleks, "
                     "tertarik pada teknologi, sains, dan penelitian. Ia lebih suka bekerja mandiri "
                     "dengan data dan logika daripada banyak berinteraksi sosial. Ia tidak tertarik "
                     "dengan pekerjaan fisik atau aktivitas seni.",
    },
    {
        "name": "Budi - Kreator Konten Artistik",
        "riasec_dominan": "A",  # Artistic
        "deskripsi": "Budi adalah seseorang yang sangat kreatif, ekspresif, dan inovatif. Ia senang "
                     "menulis, mendesain, dan membuat konten. Ia lebih suka kebebasan berekspresi "
                     "daripada aturan ketat. Tidak tertarik pada pekerjaan teknis atau bisnis formal.",
    },
    {
        "name": "Citra - Pemimpin Bisnis Ambisius",
        "riasec_dominan": "E",  # Enterprising
        "deskripsi": "Citra adalah seseorang yang ambisius, persuasif, dan berorientasi pada hasil. "
                     "Ia senang memimpin, berjualan, dan mengembangkan bisnis. Ia tertarik pada "
                     "kewirausahaan dan manajemen. Tidak tertarik pada pekerjaan teknis detail.",
    },
    {
        "name": "Dian - Konselor Sosial Empatis",
        "riasec_dominan": "S",  # Social
        "deskripsi": "Dian adalah seseorang yang sangat peduli pada orang lain, senang membantu, "
                     "mengajar, dan membimbing. Ia tertarik pada psikologi, pendidikan, dan "
                     "layanan sosial. Tidak tertarik pada pekerjaan teknis atau bisnis keras.",
    },
    {
        "name": "Eko - Insinyur Praktis Realistis",
        "riasec_dominan": "R",  # Realistic
        "deskripsi": "Eko adalah seseorang yang praktis, suka kerja tangan, dan berorientasi pada "
                     "hasil nyata. Ia senang dengan mesin, konstruksi, dan teknologi fisik. "
                     "Tidak tertarik pada pekerjaan abstrak atau sosial yang banyak bicara.",
    },
    {
        "name": "Fira - Analis Data Terstruktur",
        "riasec_dominan": "C",  # Conventional
        "deskripsi": "Fira adalah seseorang yang sangat terorganisir, detail-oriented, dan suka "
                     "bekerja dengan data, angka, dan prosedur yang jelas. Ia tertarik pada "
                     "akuntansi, administrasi, dan manajemen data. Tidak suka ambiguitas.",
    },
]

# ─── HELPERS ──────────────────────────────────────────────────────────────────
def hr(char="─", n=62): print(DIM + char * n + RESET)
def header(text): print(f"\n{BOLD}{C}{'═'*62}{RESET}\n{BOLD}{C}  {text}{RESET}\n{BOLD}{C}{'═'*62}{RESET}")
def section(text): print(f"\n{BOLD}{Y}{'─'*62}{RESET}\n{BOLD}{Y}  {text}{RESET}\n{BOLD}{Y}{'─'*62}{RESET}")
def ok(msg): print(f"  {G}✓{RESET} {msg}")
def fail(msg): print(f"  {R}✗{RESET} {msg}")
def info(msg): print(f"  {C}ℹ{RESET} {msg}")
def ai_say(msg): print(f"  {M}🤖{RESET} {DIM}{msg}{RESET}")

def wrap(text, width=58, indent="     "):
    return "\n".join(textwrap.wrap(str(text), width=width, initial_indent=indent, subsequent_indent=indent))

# ─── OPENROUTER CALL ──────────────────────────────────────────────────────────
def call_ai(system_prompt: str, user_prompt: str, json_mode: bool = True) -> str:
    headers = {
        "Authorization": f"Bearer {OR_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://kenalidiri.dev",
    }
    body = {
        "model": OR_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user",   "content": user_prompt},
        ],
        "max_tokens": 2000,
        "temperature": 0.3,  # rendah supaya konsisten
    }
    if json_mode:
        body["response_format"] = {"type": "json_object"}

    resp = requests.post(f"{OR_BASE_URL}/chat/completions", headers=headers, json=body, timeout=60)
    resp.raise_for_status()
    return resp.json()["choices"][0]["message"]["content"]

# ─── STEP 1: BUAT USER TEST ───────────────────────────────────────────────────
def create_test_user(persona: dict) -> str:
    uid = os.getenv("TEST_USER_ID", "")
    if uid:
        ok(f"Pakai TEST_USER_ID dari env: {uid[:8]}...")
        return uid

    import uuid as _uuid
    suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
    email  = f"aitest_{suffix}@kenalidiri.dev"
    new_uuid = str(_uuid.uuid4())

    try:
        conn = psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME,
                                user=DB_USER, password=DB_PASS, connect_timeout=5)
        cur  = conn.cursor()

        # Cek existing
        cur.execute("SELECT id FROM users WHERE email=%s", (email,))
        row = cur.fetchone()
        if row:
            user_id = str(row[0])
            ok(f"User sudah ada: {email}")
        else:
            cur.execute("""
                INSERT INTO users (id, fullname, email, password, phone_number, role, is_verified, created_at)
                VALUES (%s, %s, %s, 'hashed', '08000000000', 'USER', true, now())
                RETURNING id
            """, (new_uuid, persona["name"], email))
            user_id = str(cur.fetchone()[0])

            # Token wallet
            try:
                cur.execute("""
                    INSERT INTO token_wallet (id, user_id, balance, updated_at)
                    VALUES (%s, %s, 1000, now())
                """, (str(_uuid.uuid4()), user_id))
                ok("Token wallet dibuat (balance: 1000)")
            except Exception as we:
                info(f"Wallet skip: {we}")

            conn.commit()
            ok(f"User baru: {email} (ID: {user_id[:8]}...)")

        conn.close()
        return user_id

    except Exception as e:
        fail(f"Gagal buat user DB: {e}")
        sys.exit(1)

# ─── STEP 2: AI JAWAB RIASEC ──────────────────────────────────────────────────
def ai_answer_riasec(questions: list, persona: dict) -> dict:
    section("🧠 AI Menjawab RIASEC")
    ai_say(f"Persona: {persona['name']} (dominan {persona['riasec_dominan']})")
    print()

    # Kirim semua soal sekaligus ke AI
    q_list = "\n".join([f"{q['question_id']}. [{q['riasec_type']}] {q['question_text']}" for q in questions])

    system = f"""Kamu adalah {persona['name']}.
{persona['deskripsi']}

INSTRUKSI PENTING:
- Jawab setiap soal dengan skala 1-5 (1=Sangat Tidak Setuju, 5=Sangat Setuju)
- Jawaban HARUS konsisten dengan kepribadian dan minat kamu
- Sebagai seseorang dengan tipe RIASEC dominan {persona['riasec_dominan']}, 
  kamu cenderung setuju (4-5) dengan soal bertipe {persona['riasec_dominan']} 
  dan kurang setuju (1-2) dengan tipe yang berlawanan
- Variasikan sedikit jawaban supaya natural (jangan semua 5 atau semua 1)
- Return HANYA JSON valid, tidak ada teks lain"""

    user = f"""Jawab semua soal berikut dalam format JSON:
{{"responses": [{{"question_id": 1, "score": 4}}, ...]}}

SOAL:
{q_list}"""

    print(f"  {DIM}Mengirim {len(questions)} soal ke AI...{RESET}", end="", flush=True)
    raw = call_ai(system, user, json_mode=True)
    data = json.loads(raw)
    responses = data.get("responses", [])
    print(f"\r  {G}✓{RESET} AI menjawab {len(responses)} soal RIASEC")

    # Print ringkasan per tipe RIASEC
    type_scores = {}
    for r in responses:
        qid = r["question_id"]
        match = next((q for q in questions if q["question_id"] == qid), None)
        if match:
            t = match["riasec_type"][0]
            type_scores.setdefault(t, []).append(r["score"])

    print()
    print(f"  {'Tipe':<12} {'Rata2':>6}  {'Bar'}")
    print(f"  {'─'*40}")
    for t, scores in sorted(type_scores.items()):
        avg = sum(scores)/len(scores)
        bar = "█" * int(avg * 4)
        color = G if t == persona['riasec_dominan'] else DIM
        print(f"  {color}{t:<12} {avg:>6.2f}  {bar}{RESET}")

    return responses

# ─── STEP 3: AI JAWAB IKIGAI ─────────────────────────────────────────────────
def ai_answer_ikigai(session_token: str, headers: dict, persona: dict,
                     candidates: list, riasec_code: str) -> dict:
    section("💡 AI Menjawab Ikigai")
    ai_say(f"RIASEC: {riasec_code} | Kandidat: {[c['name'] for c in candidates]}")

    dims = [
        ("what_you_love",           "Apa yang kamu CINTAI (passion)"),
        ("what_you_are_good_at",    "Apa yang kamu KUASAI (skill)"),
        ("what_the_world_needs",    "Apa yang DUNIA BUTUHKAN darimu"),
        ("what_you_can_be_paid_for","Apa yang bisa MENGHASILKAN uang untukmu"),
    ]

    system = f"""Kamu adalah {persona['name']}.
{persona['deskripsi']}
Tipe RIASEC kamu: {riasec_code}

Kamu sedang mengisi tes Ikigai untuk menentukan profesi yang paling cocok.
Kandidat profesi yang tersedia: {json.dumps([c['name'] for c in candidates], ensure_ascii=False)}

INSTRUKSI:
- Pilih profesi yang paling sesuai dengan kepribadianmu ATAU tidak pilih jika tidak ada yang cocok
- Berikan alasan yang jujur dan konsisten dengan kepribadianmu (min 15 kata)
- Return HANYA JSON valid"""

    results = {}
    print()
    for dim_name, dim_label in dims:
        cands_str = "\n".join([f"- ID {c['id']}: {c['name']}" for c in candidates])
        user = f"""Dimensi: {dim_label}

Pilihan profesi:
{cands_str}

Jawab dalam format JSON:
{{
  "selected_profession_id": <id atau null jika tidak ada yang cocok>,
  "selection_type": "selected" atau "not_selected",
  "reasoning_text": "<alasan min 15 kata>"
}}"""

        raw = call_ai(system, user, json_mode=True)
        answer = json.loads(raw)

        # Validasi
        if answer.get("selected_profession_id") is not None:
            answer["selection_type"] = "selected"
        else:
            answer["selection_type"] = "not_selected"
            answer["selected_profession_id"] = None

        # Kirim ke API
        payload = {
            "session_token": session_token,
            "dimension_name": dim_name,
            "selected_profession_id": answer["selected_profession_id"],
            "selection_type": answer["selection_type"],
            "reasoning_text": answer["reasoning_text"],
        }
        is_final = dim_name == "what_you_can_be_paid_for"
        if is_final:
            print(f"\n  {Y}⏳ Dimensi 4 (FINAL) - AI scoring berjalan...{RESET}")

        resp = requests.post(f"{API_V1}/career-profile/ikigai/submit-dimension",
                             json=payload, headers=headers, timeout=60)

        chosen_name = next((c['name'] for c in candidates
                            if c['id'] == answer.get('selected_profession_id')), "Tidak dipilih")
        status_icon = G + "✓" + RESET if resp.status_code == 200 else R + "✗" + RESET

        print(f"\n  {status_icon} {dim_label}")
        print(f"  {DIM}Pilihan : {chosen_name}{RESET}")
        print(wrap(f"Alasan  : {answer['reasoning_text']}"))

        if resp.status_code != 200:
            fail(f"Gagal submit dimensi: {resp.text[:200]}")

        results[dim_name] = {
            "label": dim_label,
            "chosen": chosen_name,
            "reasoning": answer["reasoning_text"],
            "api_status": resp.status_code,
            "api_response": resp.json() if resp.status_code == 200 else resp.text,
        }

        if not is_final:
            time.sleep(0.5)

    return results

# ─── MAIN ─────────────────────────────────────────────────────────────────────
def main():
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"\n{BOLD}{C}╔{'═'*62}╗{RESET}")
    print(f"{BOLD}{C}║{'KENALI DIRI - AI Test Runner (OpenRouter)':^62}║{RESET}")
    print(f"{BOLD}{C}║{now:^62}║{RESET}")
    print(f"{BOLD}{C}╚{'═'*62}╝{RESET}\n")

    if not OR_API_KEY or OR_API_KEY == "sk-or-v1-xxxxx":
        fail("OPENROUTER_API_KEY belum diset di .env!")
        sys.exit(1)

    # Pilih RIASEC target
    print(f"  {BOLD}Pilih target RIASEC code:{RESET}")
    riasec_options = {"R": "Realistic", "I": "Investigative", "A": "Artistic",
                      "S": "Social", "E": "Enterprising", "C": "Conventional"}
    for k, v in riasec_options.items():
        persona_match = next((p for p in PERSONAS if p["riasec_dominan"] == k), None)
        print(f"    {BOLD}{k}{RESET} - {v} ({persona_match['name'] if persona_match else '?'})")
    print(f"    {BOLD}R{RESET}andom")
    print()

    choice = input(f"  Masukkan pilihan (R/I/A/S/E/C atau Enter=Random): ").strip().upper()
    if choice in riasec_options:
        persona = next((p for p in PERSONAS if p["riasec_dominan"] == choice), random.choice(PERSONAS))
        print(f"  {G}✓{RESET} Target RIASEC: {BOLD}{choice}{RESET} - {riasec_options[choice]}")
    else:
        persona = random.choice(PERSONAS)
        print(f"  {G}✓{RESET} Random persona dipilih")

    print(f"  {BOLD}Persona AI:{RESET} {M}{persona['name']}{RESET}")
    print(f"  {BOLD}Dominan   :{RESET} RIASEC {persona['riasec_dominan']}")
    print(wrap(f"Karakter  : {persona['deskripsi']}"))
    print()

    # Load questions
    q_path = os.path.join(os.path.dirname(__file__), "data", "riasec_questions.json")
    if not os.path.exists(q_path):
        q_path = os.path.join(os.path.dirname(__file__), "riasec_questions.json")
    with open(q_path, encoding="utf-8") as f:
        raw_q = json.load(f)
    questions = raw_q if isinstance(raw_q, list) else raw_q.get("questions", [])
    ok(f"{len(questions)} soal RIASEC dimuat")

    # Buat user
    user_id = create_test_user(persona)
    HEADERS = {"x-user-id": user_id, "Content-Type": "application/json"}

    # ── ALUR RECOMMENDATION ──────────────────────────────────────────────────
    header("ALUR: RECOMMENDATION (RIASEC + IKIGAI)")

    # Start session
    r = requests.post(f"{API_V1}/career-profile/recommendation/start",
                      json={"persona_type": "PATHFINDER"}, headers=HEADERS)
    if r.status_code not in [200, 201]:
        fail(f"Start session gagal: {r.text[:200]}"); sys.exit(1)
    rec_data = r.json()
    rec_token = rec_data.get("session_token") or rec_data.get("token")
    q_ids = [q["question_id"] for q in rec_data.get("questions", questions)]
    ok(f"Session dimulai | token: {rec_token[:16]}... | {len(q_ids)} soal")

    # AI jawab RIASEC
    ai_responses = ai_answer_riasec(questions, persona)

    # Submit RIASEC
    section("📤 Submit Jawaban RIASEC")
    payload_riasec = {
        "session_token": rec_token,
        "responses": [
            {
                "question_id": r["question_id"],
                "question_type": next((q["riasec_type"][0] for q in questions if q["question_id"] == r["question_id"]), "R"),
                "answer_value": r["score"],
                "answered_at": datetime.now().isoformat(),
            }
            for r in ai_responses
        ],
    }
    r = requests.post(f"{API_V1}/career-profile/riasec/submit",
                      json=payload_riasec, headers=HEADERS, timeout=30)
    if r.status_code != 200:
        fail(f"Submit RIASEC gagal: {r.text[:300]}"); sys.exit(1)

    riasec_result = r.json()
    riasec_code   = riasec_result.get("riasec_code", "?")
    scores        = riasec_result.get("scores", {})

    ok(f"RIASEC Code: {BOLD}{riasec_code}{RESET}")
    print()
    print(f"  {'Tipe':<15} {'Skor':>6}  {'Bar'}")
    print(f"  {'─'*40}")
    for t, s in sorted(scores.items(), key=lambda x: -x[1]):
        bar   = "█" * int(s / 5)
        color = G if t.startswith(riasec_code) else DIM
        print(f"  {color}{t:<15} {s:>6.1f}  {bar}{RESET}")

    # Get RIASEC result detail
    r = requests.get(f"{API_V1}/career-profile/riasec/result/{rec_token}", headers=HEADERS)
    riasec_detail = r.json() if r.status_code == 200 else {}

    # Start Ikigai
    section("🎯 Memulai Fase Ikigai")
    r = requests.post(f"{API_V1}/career-profile/ikigai/start",
                      json={"session_token": rec_token}, headers=HEADERS, timeout=30)
    if r.status_code != 200:
        fail(f"Ikigai start gagal: {r.text[:300]}"); sys.exit(1)

    ikigai_data = r.json()
    professions = ikigai_data.get("professions", [])
    candidates  = [{"id": p["profession_id"], "name": p.get("name", p.get("profession_name", "?"))}
                   for p in professions]
    ok(f"{len(candidates)} kandidat profesi:")
    for c in candidates:
        print(f"    {DIM}• [{c['id']}] {c['name']}{RESET}")

    # AI jawab Ikigai
    ikigai_results = ai_answer_ikigai(rec_token, HEADERS, persona, candidates, riasec_code)

    # Get result recommendation
    section("📊 Hasil Rekomendasi Akhir")
    time.sleep(2)
    r = requests.get(f"{API_V1}/career-profile/result/recommendation/{rec_token}", headers=HEADERS)
    rec_result = {}
    if r.status_code == 200:
        rec_result = r.json()
        top = rec_result.get("top_professions", rec_result.get("recommendations", []))
        ok(f"Hasil rekomendasi diterima!")
        if top:
            print()
            for i, p in enumerate(top[:3], 1):
                name  = p.get("profession_name", p.get("name", "?"))
                score = p.get("total_score", p.get("score", 0))
                print(f"  {BOLD}#{i}{RESET} {G}{name}{RESET}  {DIM}(score: {score:.2f}){RESET}")
    else:
        fail(f"Get result gagal: {r.text[:200]}")

    # Get personality
    r = requests.get(f"{API_V1}/career-profile/result/personality/{rec_token}", headers=HEADERS)
    personality_result = r.json() if r.status_code == 200 else {}
    if r.status_code == 200:
        ok(f"Personality result: {personality_result.get('riasec_code', '?')} - "
           f"{personality_result.get('personality_title', personality_result.get('title', '?'))}")

    # ── SUMMARY JSON ──────────────────────────────────────────────────────────
    header("📋 RINGKASAN LENGKAP (JSON)")

    summary = {
        "test_run_at": now,
        "ai_persona": {
            "name":      persona["name"],
            "dominan":   persona["riasec_dominan"],
            "karakter":  persona["deskripsi"],
        },
        "riasec": {
            "code":       riasec_code,
            "scores":     scores,
            "detail":     riasec_detail,
            "ai_answers": [
                {
                    "question_id": a["question_id"],
                    "score":       a["score"],
                    "question":    next((q["question_text"] for q in questions
                                        if q["question_id"] == a["question_id"]), "?"),
                    "type":        next((q["riasec_type"] for q in questions
                                        if q["question_id"] == a["question_id"]), "?"),
                }
                for a in ai_responses
            ],
        },
        "ikigai": {
            "candidates": candidates,
            "dimensions": {
                dim: {
                    "label":      v["label"],
                    "chosen":     v["chosen"],
                    "reasoning":  v["reasoning"],
                }
                for dim, v in ikigai_results.items()
            },
            "final_result": rec_result,
        },
        "personality": personality_result,
    }

    # Tampilkan ringkasan key points di terminal
    print(f"\n  {BOLD}PERSONA    :{RESET} {persona['name']}")
    print(f"  {BOLD}RIASEC     :{RESET} {G}{riasec_code}{RESET}")
    print(f"  {BOLD}KANDIDAT   :{RESET} {', '.join(c['name'] for c in candidates)}")
    print()
    print(f"  {BOLD}JAWABAN IKIGAI:{RESET}")
    for dim, v in ikigai_results.items():
        print(f"\n  {C}{v['label']}{RESET}")
        print(f"  → Dipilih : {G}{v['chosen']}{RESET}")
        print(wrap(f"  Alasan   : {v['reasoning']}"))

    # Simpan ke file JSON
    out_file = f"ai_test_result_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    out_path = os.path.join(os.path.dirname(__file__), out_file)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)

    print(f"\n  {G}✓{RESET} Hasil disimpan ke: {BOLD}{out_file}{RESET}")
    print(f"\n{BOLD}{G}{'═'*62}{RESET}")
    print(f"{BOLD}{G}  TEST SELESAI! Semua hasil tersimpan di JSON di atas.{RESET}")
    print(f"{BOLD}{G}{'═'*62}{RESET}\n")


if __name__ == "__main__":
    main()