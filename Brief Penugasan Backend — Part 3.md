---
title: Brief Penugasan Backend — Part 3

---

# Brief Penugasan Backend — Part 3
## Fase: Generate Narasi Rekomendasi, API Hasil RECOMMENDATION & FIT_CHECK

**Engineer:** Ariel — AI Engineer Rextra
**Scope:** Part 3 — Penutup pipeline RECOMMENDATION + API hasil kedua tipe tes
**Kelanjutan dari:** Brief RIASEC (Part 1) + Brief Ikigai Part 1 + Brief Ikigai Part 2
**Database:** PostgreSQL (shared dengan Golang CRUD system)
**Stack:** FastAPI + SQLAlchemy + Redis + Gemini via OpenRouter
**Versi Brief:** 1.0

---

## Daftar Isi

1. [Konteks & Posisi Brief Ini](#1-konteks--posisi-brief-ini)
2. [Bagian 0 — Rekap Kondisi Masuk dari Part 2](#bagian-0--rekap-kondisi-masuk-dari-part-2)
3. [Bagian 1 — FIT_CHECK: Kalkulasi Rule-Based & INSERT fit_check_results](#bagian-1--fit_check-kalkulasi-rule-based--insert-fit_check_results)
4. [Bagian 2 — RECOMMENDATION: Generate Narasi & INSERT career_recommendations](#bagian-2--recommendation-generate-narasi--insert-career_recommendations)
5. [Bagian 3 — Prompt Engineering: Narasi Ikigai & Kecocokan Profesi](#bagian-3--prompt-engineering-narasi-ikigai--kecocokan-profesi)
6. [Bagian 4 — Prompt Engineering: Format Ulang Narasi Kepribadian](#bagian-4--prompt-engineering-format-ulang-narasi-kepribadian)
7. [Bagian 5 — API Hasil RECOMMENDATION](#bagian-5--api-hasil-recommendation)
8. [Bagian 6 — API Hasil FIT_CHECK](#bagian-6--api-hasil-fit_check)
9. [Bagian 7 — API Shared: Tab Kepribadian](#bagian-7--api-shared-tab-kepribadian)
10. [Bagian 8 — Model, Schema, Router, Service](#bagian-8--model-schema-router-service)
11. [Bagian 9 — Alur Data Lengkap (Visual)](#bagian-9--alur-data-lengkap-visual)
12. [Bagian 10 — Ringkasan File yang Dibuat / Dimodifikasi](#bagian-10--ringkasan-file-yang-dibuat--dimodifikasi)
13. [Bagian 11 — Daftar Endpoint Part 3](#bagian-11--daftar-endpoint-part-3)

---

## 1. Konteks & Posisi Brief Ini

Brief ini adalah **penutup seluruh pipeline Career Profile**. Mencakup tiga hal utama:

```
[DARI BRIEF PART 2 — Selesai] ✅
    └── ikigai_total_scores sudah berisi top 2 profesi + breakdown skor
    └── Status sesi: completed
    └── career_recommendations: BELUM ADA ← Brief ini yang mengisi

[DARI BRIEF RIASEC — FIT_CHECK] ✅
    └── riasec_results sudah berisi kode RIASEC user
    └── Status sesi: completed
    └── fit_check_results: BELUM ADA ← Brief ini yang mengisi

[BRIEF PART 3 — Brief Ini] 🔵
    ├── [RECOMMENDATION] Generate narasi Gemini → INSERT career_recommendations
    ├── [FIT_CHECK] Hitung rule-based logic → INSERT fit_check_results
    ├── GET /result/recommendation/{token} → API Tab Rekomendasi + Tab Kepribadian
    ├── GET /result/fit-check/{token}      → API Tab Hasil Uji + Tab Kepribadian
    └── GET /result/personality/{token}   → API Tab Kepribadian (shared endpoint)
```

### Kapan Masing-Masing Dijalankan

| Tipe | Kapan Generate/Insert | Di Mana Kodenya |
|---|---|---|
| `fit_check_results` | Tepat saat RIASEC selesai, di dalam `_mark_fit_check_completed()` — sudah punya semua data yang dibutuhkan | `riasec_service.py` (modifikasi) |
| `career_recommendations` | Tepat saat Ikigai Part 2 selesai, setelah `ikigai_total_scores` di-INSERT | `ikigai_service.py` (modifikasi) |

Kedua tabel diisi **sebagai bagian dari pipeline yang sudah ada**, bukan endpoint terpisah. Yang baru di brief ini adalah **model, service logic, dan API endpoint untuk membaca hasilnya**.

---

## Bagian 0 — Rekap Kondisi Masuk dari Part 2

### Tabel yang Sudah Terisi Saat Brief Ini Berjalan

| Tabel | Sudah Ada | Digunakan Untuk |
|---|---|---|
| `riasec_results` | ✅ | Skor R/I/A/S/E/C, `riasec_code_id` |
| `riasec_codes` | ✅ | Detail kode: `riasec_description`, `strengths`, `challenges`, `strategies`, `work_environments`, `interaction_styles` |
| `ikigai_responses` | ✅ (RECOMMENDATION) | `reasoning_text` per 4 dimensi — sumber narasi Gemini |
| `ikigai_total_scores` | ✅ (RECOMMENDATION) | Top 2 profesi + breakdown skor per dimensi |
| `ikigai_candidate_professions` | ✅ | `congruence_type`, `congruence_score` per profesi |
| `careerprofile_test_sessions` | ✅ | `test_goal`, `target_profession_id`, `status: completed` |
| `professions` | ✅ | Nama profesi, `riasec_code_id` |
| `career_recommendations` | ✅ (tabel ada) | **BELUM DIISI** — brief ini yang mengisi |
| `fit_check_results` | ✅ (tabel ada) | **BELUM DIISI** — brief ini yang mengisi |

### Struktur Tabel `career_recommendations` (Sudah Ada di DB)

```
id                  BIGSERIAL PRIMARY KEY
test_session_id     BIGINT NOT NULL (FK ke careerprofile_test_sessions)
recommendations_data JSONB NOT NULL
top_profession1_id  BIGINT NULLABLE
top_profession2_id  BIGINT NULLABLE
generated_at        TIMESTAMPTZ DEFAULT NOW()
ai_model_used       VARCHAR(50) DEFAULT 'gemini-1.5-flash'
```

### Struktur Tabel `fit_check_results` (Sudah Ada di DB)

```
id                      BIGSERIAL PRIMARY KEY
test_session_id         BIGINT NOT NULL UNIQUE (FK ke careerprofile_test_sessions)
profession_id           BIGINT NOT NULL
user_riasec_code_id     BIGINT NOT NULL
profession_riasec_code_id BIGINT NOT NULL
match_category          ENUM (HIGH, MEDIUM, LOW)
rule_type               VARCHAR(50) NOT NULL
dominant_letter_same    BOOLEAN NOT NULL
is_adjacent_hexagon     BOOLEAN NOT NULL
match_score             DECIMAL(4,2) NULLABLE
created_at              TIMESTAMPTZ DEFAULT NOW()
```

---

## Bagian 1 — FIT_CHECK: Kalkulasi Rule-Based & INSERT fit_check_results

### 1.1 Di Mana Logic Ini Ditambahkan

Dari brief RIASEC, method `_mark_fit_check_completed()` di `riasec_service.py` sudah menangani:
- Set `session.status = "completed"`
- Isi `session.completed_at`
- Update `kenalidiri_history → completed`

**Brief ini menambahkan satu langkah lagi** di dalam method yang sama: hitung rule-based classification dan INSERT ke `fit_check_results`. Di titik ini semua data yang dibutuhkan sudah tersedia:
- `riasec_code_id` user dari `riasec_results`
- `target_profession_id` dari `session.target_profession_id`
- `riasec_code_id` profesi dari tabel `professions`

### 1.2 Rule-Based Classification: Definisi 3 Kategori

Klasifikasi menggunakan **logika heksagon Holland** — posisi relatif kode RIASEC user dan profesi target.

#### Referensi Heksagon Holland

```
        R
       / \
      C   I
      |   |
      E   A
       \ /
        S
```

Adjacent (bersebelahan, jarak 1): R-I, I-A, A-S, S-E, E-C, C-R
Alternate (jarak 2): R-A, I-S, A-E, S-C, E-R, C-I (cukup dekat, masih relevan)
Opposite (berseberangan, jarak 3): R-S, I-E, A-C

#### Matriks Jarak Antar Huruf RIASEC

```python
RIASEC_DISTANCE = {
    ("R","R"):0, ("R","I"):1, ("R","A"):2, ("R","S"):3, ("R","E"):2, ("R","C"):1,
    ("I","R"):1, ("I","I"):0, ("I","A"):1, ("I","S"):2, ("I","E"):3, ("I","C"):2,
    ("A","R"):2, ("A","I"):1, ("A","A"):0, ("A","S"):1, ("A","E"):2, ("A","C"):3,
    ("S","R"):3, ("S","I"):2, ("S","A"):1, ("S","S"):0, ("S","E"):1, ("S","C"):2,
    ("E","R"):2, ("E","I"):3, ("E","A"):2, ("E","S"):1, ("E","E"):0, ("E","C"):1,
    ("C","R"):1, ("C","I"):2, ("C","A"):3, ("C","S"):2, ("C","E"):1, ("C","C"):0,
}
```

#### Aturan Klasifikasi HIGH / MEDIUM / LOW

**HIGH — Kecocokan Tinggi:**
- Kondisi A (Identik): komposisi 3 huruf sama persis (misal user=IRC, profesi=IRC atau ICR atau RCI — semua permutasi dianggap identik)
- Kondisi B (Permutasi Huruf Dominan Sama): huruf dominan (huruf pertama) sama ATAU tertukar dengan huruf kedua tapi semua huruf sama

Lebih sederhananya: **sorted(user_code) == sorted(profession_code)** → HIGH

**rule_type untuk HIGH:**
- `"exact_match"` → user_code == profession_code (urutan identik)
- `"permutation_match"` → huruf sama tapi urutan berbeda

**MEDIUM — Kecocokan Sedang:** salah satu dari:
- Kondisi A (Dominan Sama, Subset Berbeda): huruf dominan sama, minimal 1 huruf lain beda
- Kondisi B (Adjacent Dominant): huruf dominan berbeda tapi berjarak 1 di heksagon
- Kondisi C (Semua Huruf Berdekatan): tidak ada huruf yang berlawanan (jarak ≥ 3) di antara dua kode

**rule_type untuk MEDIUM:**
- `"dominant_same"` → kondisi A
- `"adjacent_dominant"` → kondisi B
- `"close_profile"` → kondisi C (fallback)

**LOW — Kecocokan Rendah:**
- Fallback: tidak memenuhi syarat HIGH atau MEDIUM
- Biasanya: huruf dominan berbeda dan berjarak ≥ 2, atau ada huruf yang berlawanan

**rule_type untuk LOW:**
- `"mismatch"` → default

**`is_adjacent_hexagon`**: True jika huruf dominan user dan profesi berjarak ≤ 1
**`dominant_letter_same`**: True jika huruf pertama user == huruf pertama profesi

#### `match_score` — Skor Numerik Opsional

Dihitung dari rata-rata jarak semua huruf yang bisa dipasangkan:

```python
def calculate_match_score(user_code: str, profession_code: str) -> float:
    """
    Skor 0.0–1.0 berdasarkan rata-rata kedekatan huruf.
    1.0 = identik, 0.0 = semua berlawanan.
    Hanya untuk transparansi — tidak digunakan untuk klasifikasi utama.
    """
    max_distance = 3  # jarak maksimum di heksagon
    total_distance = 0
    comparisons = 0

    for i in range(min(len(user_code), len(profession_code))):
        dist = RIASEC_DISTANCE.get((user_code[i], profession_code[i]), max_distance)
        total_distance += dist
        comparisons += 1

    if comparisons == 0:
        return 0.5
    avg_distance = total_distance / comparisons
    return round(1.0 - (avg_distance / max_distance), 2)
```

### 1.3 Fungsi Klasifikasi Lengkap

```python
def classify_fit_check(
    user_riasec_code: str,       # misal "IRC"
    profession_riasec_code: str  # misal "ICR"
) -> dict:
    """
    Rule-based classification untuk FIT_CHECK.
    Return dict yang siap di-INSERT ke fit_check_results.

    Hierarki klasifikasi:
    HIGH   = dominant_same AND composition_same (semua huruf sama, urutan boleh beda)
    MEDIUM = dominant_same tapi composition berbeda  (rule: dominant_same)
             ATAU dominant adjacent (jarak 1 di heksagon)    (rule: adjacent_dominant)
    LOW    = fallback — semua kondisi di atas tidak terpenuhi (rule: mismatch)

    CATATAN PENTING — kenapa HIGH butuh dominant_same AND composition_same:
    IRC vs RIC → composition_same (set huruf sama) TAPI dominant berbeda (I vs R)
    → Ini MEDIUM (dominant_same=False, tapi adjacent_dominant=True karena I-R berjarak 1)
    → BUKAN HIGH, karena huruf yang paling mendefinisikan profil (huruf pertama) berbeda.
    HIGH hanya untuk kasus di mana huruf dominan SAMA, contoh:
    IRC vs IRC (exact_match) atau IRC vs ICR (permutation_match, dominannya sama-sama I).
    """
    user_dominant = user_riasec_code[0]
    prof_dominant = profession_riasec_code[0]

    dominant_same = (user_dominant == prof_dominant)
    composition_same = sorted(user_riasec_code) == sorted(profession_riasec_code)

    dominant_distance = RIASEC_DISTANCE.get((user_dominant, prof_dominant), 3)
    is_adjacent = dominant_distance <= 1

    match_score = calculate_match_score(user_riasec_code, profession_riasec_code)

    # === CEK HIGH: dominant_same AND composition_same ===
    # Contoh valid: IRC→IRC (exact), IRC→ICR (permutation)
    # Contoh invalid: IRC→RIC (composition_same tapi dominant I≠R → MEDIUM)
    if dominant_same and composition_same:
        rule_type = "exact_match" if user_riasec_code == profession_riasec_code else "permutation_match"
        return {
            "match_category": "HIGH",
            "rule_type": rule_type,
            "dominant_letter_same": True,
            "is_adjacent_hexagon": is_adjacent,
            "match_score": match_score
        }

    # === CEK MEDIUM: Kondisi A — dominant_same tapi composition berbeda ===
    if dominant_same:
        return {
            "match_category": "MEDIUM",
            "rule_type": "dominant_same",
            "dominant_letter_same": True,
            "is_adjacent_hexagon": is_adjacent,
            "match_score": match_score
        }

    # === CEK MEDIUM: Kondisi B — dominant adjacent (jarak 1 di heksagon) ===
    if dominant_distance == 1:
        return {
            "match_category": "MEDIUM",
            "rule_type": "adjacent_dominant",
            "dominant_letter_same": False,
            "is_adjacent_hexagon": True,
            "match_score": match_score
        }

    # === FALLBACK: LOW ===
    return {
        "match_category": "LOW",
        "rule_type": "mismatch",
        "dominant_letter_same": dominant_same,
        "is_adjacent_hexagon": is_adjacent,
        "match_score": match_score
    }
```

### 1.4 Integrasi ke `_mark_fit_check_completed()` di riasec_service.py

Modifikasi method yang sudah ada di brief RIASEC:

```python
def _mark_fit_check_completed(self, session: CareerProfileTestSession):
    """
    MODIFIKASI dari brief RIASEC:
    Tambahkan kalkulasi rule-based dan INSERT fit_check_results.
    Semua data sudah tersedia di titik ini.

    CATATAN COMMIT: Method ini tidak memanggil self.db.commit() sendiri.
    Commit dilakukan oleh caller (submit_riasec_test) setelah semua INSERT selesai,
    agar atomik — jika _insert_fit_check_result gagal, seluruh transaksi di-rollback
    termasuk perubahan status sesi dan kenalidiri_history.
    """
    session.status = "completed"
    session.completed_at = datetime.utcnow()

    # Update kenalidiri_history
    from app.db.models.kenalidiri_history import KenaliDiriHistory
    history = self.db.query(KenaliDiriHistory).filter(
        KenaliDiriHistory.detail_session_id == session.id
    ).first()
    if history:
        history.status = "completed"
        history.completed_at = datetime.utcnow()

    # === TAMBAHAN BARU: INSERT fit_check_results ===
    self._insert_fit_check_result(session)


def _insert_fit_check_result(self, session: CareerProfileTestSession):
    """
    Hitung rule-based classification dan INSERT ke fit_check_results.
    Dipanggil hanya untuk sesi FIT_CHECK setelah RIASEC selesai.
    """
    from app.api.v1.categories.career_profile.models.result import FitCheckResult
    from app.api.v1.categories.career_profile.services.fit_check_classifier import classify_fit_check

    # Ambil kode RIASEC user dari riasec_results
    riasec_result = self.db.query(RIASECResult).filter(
        RIASECResult.test_session_id == session.id
    ).first()
    if not riasec_result:
        raise HTTPException(status_code=500, detail="riasec_results tidak ditemukan saat insert fit_check_results")

    user_code_obj = self.db.query(RIASECCode).filter(
        RIASECCode.id == riasec_result.riasec_code_id
    ).first()

    # Ambil kode RIASEC profesi target
    from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
    profession = ProfessionRepository(self.db).get_by_id(session.target_profession_id)
    if not profession:
        raise HTTPException(status_code=404, detail=f"Profesi target ID {session.target_profession_id} tidak ditemukan")

    prof_code_obj = self.db.query(RIASECCode).filter(
        RIASECCode.id == profession.riasec_code_id
    ).first()

    # Klasifikasi
    classification = classify_fit_check(
        user_riasec_code=user_code_obj.riasec_code,
        profession_riasec_code=prof_code_obj.riasec_code
    )

    fit_check_record = FitCheckResult(
        test_session_id=session.id,
        profession_id=session.target_profession_id,
        user_riasec_code_id=riasec_result.riasec_code_id,
        profession_riasec_code_id=prof_code_obj.id,
        match_category=classification["match_category"],
        rule_type=classification["rule_type"],
        dominant_letter_same=classification["dominant_letter_same"],
        is_adjacent_hexagon=classification["is_adjacent_hexagon"],
        match_score=classification["match_score"]
    )
    self.db.add(fit_check_record)
    # Commit dilakukan oleh caller (submit_riasec_test) setelah method ini return
```

---

## Bagian 2 — RECOMMENDATION: Generate Narasi & INSERT career_recommendations

### 2.1 Di Mana Logic Ini Ditambahkan

Di `ikigai_service.py`, method `_run_scoring_pipeline()` dari brief Part 2 sudah melakukan:
- AI scoring batch
- INSERT `ikigai_dimension_scores`
- INSERT `ikigai_total_scores`
- UPDATE status sesi → completed

**Brief ini menambahkan satu langkah setelah `ikigai_total_scores` di-INSERT:** generate narasi Gemini dan INSERT ke `career_recommendations`.

### 2.2 Data yang Dikumpulkan untuk Generate Narasi

Gemini membutuhkan konteks dari beberapa sumber untuk menghasilkan narasi yang personal:

| Data | Sumber | Digunakan Untuk |
|---|---|---|
| `reasoning_text` per 4 dimensi | `ikigai_responses` | Input utama narasi Ikigai + match reasoning |
| Nama profesi top 1 dan top 2 | `professions` | Match reasoning per profesi |
| Deskripsi, aktivitas, skill profesi | `professions` + join tables | Konteks profesi untuk match reasoning |
| `riasec_code` user | `riasec_results` + `riasec_codes` | `riasec_alignment` per profesi |
| `congruence_type` + `congruence_score` | `ikigai_candidate_professions` | `riasec_alignment` per profesi |
| Breakdown skor per dimensi | `ikigai_total_scores` | `score_breakdown` per profesi |

### 2.3 Struktur JSONB `recommendations_data` yang Akan Di-Generate

```json
{
  "ikigai_profile_summary": {
    "what_you_love": "Kamu paling antusias saat membuat sesuatu yang bisa dilihat dan digunakan oleh orang lain, terutama ketika prosesnya melibatkan unsur kreativitas dan eksplorasi ide. Aktivitas seperti ini membuatmu merasa lebih hidup dan termotivasi untuk terus mengembangkan hasil karyamu. Ketertarikan tersebut cenderung muncul ketika kamu melihat dampak nyata dari apa yang kamu buat.",
    "what_you_are_good_at": "Kamu merasa cukup kuat dalam menganalisis informasi dan menguraikan masalah yang kompleks menjadi bagian yang lebih terstruktur. Proses berpikir yang sistematis membantumu memahami persoalan dengan lebih jernih sebelum menentukan solusi. Kemampuan ini membuatmu relatif nyaman menghadapi tantangan yang membutuhkan logika dan ketelitian.",
    "what_the_world_needs": "Kamu memandang bahwa dunia membutuhkan solusi yang mampu menjembatani hal-hal teknis yang rumit dengan bentuk yang lebih mudah dipahami. Peran seperti ini menurutmu penting agar lebih banyak orang dapat merasakan manfaat dari perkembangan teknologi. Kamu cenderung tertarik pada kontribusi yang membantu menyederhanakan kompleksitas bagi banyak pihak.",
    "what_you_can_be_paid_for": "Kamu menyadari bahwa kemampuan teknis dan kreatif yang kamu miliki memiliki nilai ekonomi yang cukup tinggi. Bidang kerja yang dinamis dan terus berkembang membuatmu melihat peluang untuk bertumbuh secara profesional sekaligus finansial. Hal ini mendorongmu mempertimbangkan karier yang tidak hanya menarik, tetapi juga berkelanjutan."
  },
  "recommended_professions": [
    {
      "rank": 1,
      "profession_id": 25,
      "match_percentage": 52.0,
      "match_reasoning": "Profesi ini cocok karena minatmu terhadap pengembangan produk digital dan aktivitas teknis kreatif selaras dengan proses pembuatan serta eksplorasi game. Ketertarikanmu pada problem solving dan eksperimen teknologi memberi ruang untuk mengembangkan pengalaman interaktif yang kompleks dan bermakna.",
      "riasec_alignment": {
        "user_code": "RIA",
        "profession_code": "RIA",
        "congruence_type": "exact_match",
        "congruence_score": 1.0
      },
      "score_breakdown": {
        "total_score": 52.0,
        "intrinsic_score": 28.5,
        "extrinsic_score": 23.5,
        "score_what_you_love": 15.0,
        "score_what_you_are_good_at": 13.5,
        "score_what_the_world_needs": 12.0,
        "score_what_you_can_be_paid_for": 11.5
      }
    },
    {
      "rank": 2,
      "profession_id": 18,
      "match_percentage": 48.0,
      "match_reasoning": "Profesi ini sesuai karena ketertarikanmu pada pembuatan produk yang dapat langsung digunakan orang lain sejalan dengan peran frontend dalam membangun antarmuka digital. Alasan dan preferensi terhadap kejelasan tampilan serta pengalaman pengguna mendukung peran ini dalam menciptakan solusi yang fungsional dan mudah dipahami.",
      "riasec_alignment": {
        "user_code": "RIA",
        "profession_code": "RI",
        "congruence_type": "subset_adjacent",
        "congruence_score": 0.80
      },
      "score_breakdown": {
        "total_score": 48.0,
        "intrinsic_score": 26.0,
        "extrinsic_score": 22.0,
        "score_what_you_love": 14.0,
        "score_what_you_are_good_at": 12.0,
        "score_what_the_world_needs": 11.5,
        "score_what_you_can_be_paid_for": 10.5
      }
    }
  ],
  "generation_context": {
    "user_riasec_code": "RIA",
    "user_riasec_code_id": 49,
    "user_riasec_classification_type": "triple",
    "total_candidates_evaluated": 15,
    "top_2_selection_method": "total_score_ranking",
    "ikigai_summary_generated_from": "user_reasoning_text_abstraction",
    "match_reasoning_generated_from": "profession_characteristics_mapping",
    "generation_timestamp": "2024-12-15T10:45:00Z"
  }
}
```

**Keterangan field `recommended_professions`:**

| Field | Sumber | Deskripsi |
|---|---|---|
| `rank` | `ikigai_total_scores` | 1 = profesi terbaik |
| `profession_id` | `ikigai_total_scores` | ID profesi |
| `match_percentage` | Computed: `total_score` as-is (sudah dalam skala 0–100) | Badge persentase di UI |
| `match_reasoning` | 🤖 Gemini | 2 kalimat kecocokan personal |
| `riasec_alignment` | `riasec_codes` + `ikigai_candidate_professions` | Transparansi RIASEC |
| `score_breakdown` | `ikigai_total_scores` | Detail skor per dimensi |

### 2.4 Strategi Generate: 1 Gemini Call untuk Semua Narasi

Semua narasi (`ikigai_profile_summary` × 4 dimensi + `match_reasoning` × 2 profesi = 6 teks) dihasilkan dalam **1 Gemini call** dengan output JSON. Ini lebih efisien dari 6 call terpisah.

```python
async def generate_recommendations_narrative(
    self,
    ikigai_responses: dict,      # reasoning_text dari 4 dimensi
    top_2_professions: list,     # data dari ikigai_total_scores
    profession_details: list,    # nama + deskripsi + aktivitas tiap profesi
    user_riasec_code: str
) -> dict:
    """
    1 Gemini call untuk generate semua 6 narasi sekaligus.
    Return: dict siap masuk ke recommendations_data JSONB.
    """
    prompt = build_recommendation_narrative_prompt(
        ikigai_responses=ikigai_responses,
        top_2_professions=top_2_professions,
        profession_details=profession_details,
        user_riasec_code=user_riasec_code
    )

    async with httpx.AsyncClient(timeout=45.0) as client:
        response = await client.post(
            url=f"{settings.OPENROUTER_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": settings.OPENROUTER_MODEL,
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": 1500,
                "temperature": 0.6   # Sedikit lebih kreatif dari scoring
            }
        )

    raw_text = response.json()["choices"][0]["message"]["content"].strip()

    # Strip markdown fences jika ada
    if raw_text.startswith("```"):
        raw_text = raw_text.split("```")[1]
        if raw_text.startswith("json"):
            raw_text = raw_text[4:]
        raw_text = raw_text.rsplit("```", 1)[0].strip()

    return json.loads(raw_text)
```

### 2.5 Integrasi ke `_run_scoring_pipeline()` di ikigai_service.py

```python
# Di dalam _run_scoring_pipeline(), SETELAH INSERT ikigai_total_scores:

# === TAMBAHAN BARU: Generate narasi + INSERT career_recommendations ===

# Ambil detail profesi top 2 untuk konteks Gemini
top_2_ids = [top_1_id, top_2_id]
profession_details = self.profession_svc.get_profession_contexts_for_recommendation(top_2_ids)

# Ambil data riasec user
riasec_result = self.db.query(RIASECResult).filter(
    RIASECResult.test_session_id == session.id
).first()
riasec_code_obj = self.db.query(RIASECCode).filter(
    RIASECCode.id == riasec_result.riasec_code_id
).first()

# Ambil congruence data per profesi dari candidates
candidate_map = {c["profession_id"]: c for c in all_candidates}

# Susun data ikigai_responses
ikigai_resp_data = {
    "what_you_love": ikigai_resp.dimension_1_love["reasoning_text"],
    "what_you_are_good_at": ikigai_resp.dimension_2_good_at["reasoning_text"],
    "what_the_world_needs": ikigai_resp.dimension_3_world_needs["reasoning_text"],
    "what_you_can_be_paid_for": ikigai_resp.dimension_4_paid_for["reasoning_text"]
}

# Susun top_2 data lengkap
top_2_data = []
for prof_score in ranked["profession_scores"][:2]:
    pid = prof_score["profession_id"]
    cand = candidate_map.get(pid, {})
    top_2_data.append({
        **prof_score,
        "congruence_type": cand.get("congruence_type", ""),
        "congruence_score": cand.get("congruence_score", 0.0)
    })

# Generate narasi
narrative_svc = RecommendationNarrativeService()
narrative_data = await narrative_svc.generate_recommendations_narrative(
    ikigai_responses=ikigai_resp_data,
    top_2_professions=top_2_data,
    profession_details=profession_details,
    user_riasec_code=riasec_code_obj.riasec_code
)

# Susun recommendations_data JSONB lengkap
# Hitung classification_type dari panjang kode (inline, bukan dari field tabel)
_code_len = len(riasec_code_obj.riasec_code)
_classification_type = {1: "single", 2: "dual", 3: "triple"}.get(_code_len, "triple")

recommendations_data = {
    "ikigai_profile_summary": narrative_data["ikigai_profile_summary"],
    "recommended_professions": [],
    "generation_context": {
        "user_riasec_code": riasec_code_obj.riasec_code,
        "user_riasec_code_id": riasec_result.riasec_code_id,
        "user_riasec_classification_type": _classification_type,  # dihitung dari len(code), bukan field tabel
        "total_candidates_evaluated": len(all_candidates),
        "top_2_selection_method": "total_score_ranking",
        "ikigai_summary_generated_from": "user_reasoning_text_abstraction",
        "match_reasoning_generated_from": "profession_characteristics_mapping",
        "generation_timestamp": datetime.utcnow().isoformat()
    }
}

# Gabungkan match_reasoning dari Gemini dengan data skor dari DB
for i, prof_score in enumerate(top_2_data):
    pid = prof_score["profession_id"]
    prof_code = next((p for p in profession_details if p["profession_id"] == pid), {})
    match_reason = narrative_data["match_reasoning"].get(str(pid), "")

    recommendations_data["recommended_professions"].append({
        "rank": prof_score["rank"],
        "profession_id": pid,
        "match_percentage": prof_score["total_score"],  # sudah skala 0-100
        "match_reasoning": match_reason,
        "riasec_alignment": {
            "user_code": riasec_code_obj.riasec_code,
            "profession_code": prof_code.get("riasec_code", ""),
            "congruence_type": prof_score.get("congruence_type", ""),
            "congruence_score": prof_score.get("congruence_score", 0.0)
        },
        "score_breakdown": {
            "total_score": prof_score["total_score"],
            "intrinsic_score": prof_score["intrinsic_score"],
            "extrinsic_score": prof_score["extrinsic_score"],
            "score_what_you_love": prof_score["score_what_you_love"],
            "score_what_you_are_good_at": prof_score["score_what_you_are_good_at"],
            "score_what_the_world_needs": prof_score["score_what_the_world_needs"],
            "score_what_you_can_be_paid_for": prof_score["score_what_you_can_be_paid_for"]
        }
    })

# INSERT career_recommendations
from app.api.v1.categories.career_profile.models.result import CareerRecommendation
rec_record = CareerRecommendation(
    test_session_id=session.id,
    recommendations_data=recommendations_data,
    top_profession1_id=top_1_id,
    top_profession2_id=top_2_id,
    ai_model_used=settings.OPENROUTER_MODEL
)
self.db.add(rec_record)
self.db.flush()
```

---

## Bagian 3 — Prompt Engineering: Narasi Ikigai & Kecocokan Profesi

### 3.1 Template Prompt Generate Narasi Rekomendasi

```python
RECOMMENDATION_NARRATIVE_PROMPT = """
Kamu adalah konselor karier berbasis data. Tugasmu adalah menulis narasi personal
berdasarkan jawaban pengguna dalam Tes Ikigai.

PROFIL RIASEC PENGGUNA: {user_riasec_code}

JAWABAN PENGGUNA PER DIMENSI IKIGAI:
---
Dimensi 1 — What You Love (Apa yang Kamu Sukai):
"{love_text}"

Dimensi 2 — What You Are Good At (Apa yang Kamu Kuasai):
"{good_at_text}"

Dimensi 3 — What The World Needs (Apa yang Dibutuhkan Dunia):
"{world_needs_text}"

Dimensi 4 — What You Can Be Paid For (Apa yang Bisa Dibayar):
"{paid_for_text}"
---

DUA PROFESI YANG DIREKOMENDASIKAN:
{professions_block}

TUGAS:
Hasilkan 6 teks narasi:
1. Ringkasan Dimensi 1 (ikigai_profile_summary.what_you_love)
2. Ringkasan Dimensi 2 (ikigai_profile_summary.what_you_are_good_at)
3. Ringkasan Dimensi 3 (ikigai_profile_summary.what_the_world_needs)
4. Ringkasan Dimensi 4 (ikigai_profile_summary.what_you_can_be_paid_for)
5. Alasan kecocokan Profesi ID {profession_1_id} (match_reasoning)
6. Alasan kecocokan Profesi ID {profession_2_id} (match_reasoning)

ATURAN PENULISAN:

UNTUK RINGKASAN DIMENSI (teks 1-4):
- 2-3 kalimat efektif per dimensi (60-90 kata)
- Bersifat GENERAL — tidak menyebut nama profesi apapun
- Tulis sebagai refleksi diri pengguna: gunakan kata "Kamu..."
- Fokus pada: apa yang membuat antusias, pola aktivitas yang disukai, orientasi kontribusi
- Abstraksi dari jawaban pengguna — bukan parafrase langsung
- Bahasa Indonesia yang natural dan empatik

UNTUK ALASAN KECOCOKAN PROFESI (teks 5-6):
- Tepat 2 kalimat (template wajib):
  Kalimat 1: "Profesi ini cocok karena [hubungan minat/kekuatan dengan aktivitas inti profesi]."
  Kalimat 2: "[Implikasi praktis — bagaimana pengalaman/pola kerja pengguna berkembang dalam profesi ini]."
- JANGAN menyebut nama profesi di dalam kalimat (nama sudah ada di label UI)
- Gunakan "Profesi ini..." atau "Peran ini..." sebagai subjek
- Spesifik terhadap profesi tersebut — bukan generik
- Diturunkan dari reasoning_text pengguna, bukan asumsi generik profesi

ATURAN OUTPUT:
- Kembalikan HANYA JSON valid, tidak ada teks tambahan
- Format tepat seperti di bawah ini

FORMAT OUTPUT:
{{
  "ikigai_profile_summary": {{
    "what_you_love": "<teks ringkasan dimensi 1>",
    "what_you_are_good_at": "<teks ringkasan dimensi 2>",
    "what_the_world_needs": "<teks ringkasan dimensi 3>",
    "what_you_can_be_paid_for": "<teks ringkasan dimensi 4>"
  }},
  "match_reasoning": {{
    "{profession_1_id}": "<2 kalimat alasan kecocokan profesi 1>",
    "{profession_2_id}": "<2 kalimat alasan kecocokan profesi 2>"
  }}
}}
"""
```

### 3.2 Fungsi Build Prompt

```python
def build_recommendation_narrative_prompt(
    ikigai_responses: dict,
    top_2_professions: list,
    profession_details: list,
    user_riasec_code: str
) -> str:

    profession_1_id = top_2_professions[0]["profession_id"]
    profession_2_id = top_2_professions[1]["profession_id"] if len(top_2_professions) > 1 else None

    professions_block = ""
    for detail in profession_details:
        pid = detail["profession_id"]
        activities = ", ".join((detail.get("activities") or [])[:3]) or "Tidak tersedia"
        skills = ", ".join((detail.get("hard_skills_required") or [])[:3]) or "Tidak tersedia"
        about = (detail.get("about_description") or "")[:250]

        # Ambil score dari top_2_professions
        score_data = next((p for p in top_2_professions if p["profession_id"] == pid), {})
        match_pct = score_data.get("total_score", 0)

        professions_block += f"""
Profesi ID {pid}: {detail['name']} (Kecocokan: {match_pct:.1f}%)
Kode RIASEC: {detail.get('riasec_code', '-')}
Deskripsi singkat: {about}
Aktivitas utama: {activities}
Skill utama: {skills}
"""

    return RECOMMENDATION_NARRATIVE_PROMPT.format(
        user_riasec_code=user_riasec_code,
        love_text=ikigai_responses["what_you_love"],
        good_at_text=ikigai_responses["what_you_are_good_at"],
        world_needs_text=ikigai_responses["what_the_world_needs"],
        paid_for_text=ikigai_responses["what_you_can_be_paid_for"],
        professions_block=professions_block.strip(),
        profession_1_id=profession_1_id,
        profession_2_id=profession_2_id or "N/A"
    )
```

---

## Bagian 4 — Prompt Engineering: Format Ulang Narasi Kepribadian

### 4.1 Konteks

Tab Kepribadian menampilkan "Tentang Kode" — narasi 3 kalimat dengan template:

```
"Kode [XXX] menunjukkan bahwa kekuatan utamamu adalah tipe [Nama Tipe Pertama].
Caramu bekerja juga dipengaruhi oleh pola pikir [Tipe Kedua] dan gaya [Tipe Ketiga].
Sinergi ketiganya membuatmu cenderung menjadi [rangkuman karakter dari riasec_description]."
```

Sumber input: `riasec_codes.riasec_description` — teks deskriptif mentah dari database.

### 4.2 Strategi: Cache per Kode RIASEC di Redis

Narasi "Tentang Kode" **sama untuk semua user dengan kode yang sama** (misal semua user dengan kode RIA mendapat narasi yang sama). Ini berbeda dari narasi Ikigai yang personal. Karena itu:

- **1 Gemini call** per kode RIASEC unik (maksimum 156 call seumur hidup — sesuai jumlah kode di DB)
- **Di-cache di Redis** dengan key `personality_about:{riasec_code}` — TTL 7 hari
- Jika cache hit → langsung return, tidak panggil Gemini
- Jika cache miss → panggil Gemini, simpan ke Redis

### 4.3 Template Prompt Format Ulang

```python
PERSONALITY_ABOUT_PROMPT = """
Kamu adalah penulis konten karier. Tugasmu adalah memformat ulang deskripsi kode RIASEC
menjadi narasi personal yang hangat dan mudah dipahami remaja/mahasiswa.

KODE RIASEC: {riasec_code}
JUDUL KODE: {riasec_title}
DESKRIPSI ASLI DARI DATABASE:
"{riasec_description}"

NAMA TIPE HURUF:
{letters_block}

TUGAS:
Tulis tepat 3 kalimat narasi dengan template wajib:

Kalimat 1: "Kode {riasec_code} menunjukkan bahwa kekuatan utamamu adalah tipe {first_letter_name}."
Kalimat 2: "{sentence_2_template}"
Kalimat 3: "Sinergi ini membuatmu cenderung menjadi [rangkuman karakter dari deskripsi — 1 kalimat singkat, padat, positif]."

ATURAN:
- Kalimat 1 dan 2 WAJIB menggunakan template persis (sudah disediakan di atas, jangan ubah)
- Kalimat 3 bebas tapi harus diturunkan dari deskripsi asli
- Maksimum 30 kata untuk kalimat 3
- Bahasa Indonesia yang hangat dan memotivasi
- Gunakan kata "kamu" (bukan "Anda")

ATURAN OUTPUT:
- Kembalikan HANYA teks 3 kalimat, tidak ada label, tidak ada JSON
- Pisahkan tiap kalimat dengan newline
"""

RIASEC_LETTER_NAMES = {
    "R": "Realistic",
    "I": "Investigative",
    "A": "Artistic",
    "S": "Social",
    "E": "Enterprising",
    "C": "Conventional"
}
```

### 4.4 Fungsi Generate Narasi Kepribadian

```python
async def get_personality_about_text(
    riasec_code: str,
    riasec_title: str,
    riasec_description: str,
    redis_client
) -> str:
    """
    Ambil narasi 'Tentang Kode' dari Redis atau generate via Gemini.
    Di-cache per kode RIASEC — tidak personal, sama untuk semua user.
    """
    cache_key = f"personality_about:{riasec_code}"

    # Cek Redis cache dulu
    if redis_client:
        try:
            cached = await redis_client.get(cache_key)
            if cached:
                return cached.decode("utf-8")
        except Exception:
            pass  # Redis down — lanjut ke Gemini

    # Build prompt
    letters = list(riasec_code)
    letter_names = [RIASEC_LETTER_NAMES.get(l, l) for l in letters]

    # Handle kode < 3 huruf (single atau dual) untuk kalimat template
    # Kode "RI" → kalimat 2 tidak boleh "pola pikir Investigative dan gaya Investigative" (duplikat)
    # Solusi: kalimat 2 diadaptasi sesuai jumlah huruf
    if len(letters) == 1:
        # Single: hanya ada 1 tipe, kalimat 2 dan 3 menyesuaikan
        second_letter_name = letter_names[0]
        third_letter_name  = None   # tidak digunakan
        sentence_2_template = f"Caramu bekerja sepenuhnya didominasi oleh orientasi {letter_names[0]}."
    elif len(letters) == 2:
        second_letter_name = letter_names[1]
        third_letter_name  = None
        sentence_2_template = f"Caramu bekerja juga dipengaruhi oleh pola pikir {letter_names[1]}."
    else:
        second_letter_name = letter_names[1]
        third_letter_name  = letter_names[2]
        sentence_2_template = (f"Caramu bekerja juga dipengaruhi oleh pola pikir {letter_names[1]} "
                               f"dan gaya {letter_names[2]}.")

    prompt = PERSONALITY_ABOUT_PROMPT.format(
        riasec_code=riasec_code,
        riasec_title=riasec_title,
        riasec_description=riasec_description or riasec_title,
        letters_block="\n".join([f"- {l}: {RIASEC_LETTER_NAMES.get(l, l)}" for l in letters]),
        first_letter_name=letter_names[0],
        sentence_2_template=sentence_2_template
    )

    async with httpx.AsyncClient(timeout=20.0) as client:
        response = await client.post(
            url=f"{settings.OPENROUTER_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": settings.OPENROUTER_MODEL,
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": 200,
                "temperature": 0.5
            }
        )

    text = response.json()["choices"][0]["message"]["content"].strip()

    # Simpan ke Redis TTL 7 hari
    if redis_client:
        try:
            await redis_client.setex(cache_key, 7 * 24 * 3600, text)
        except Exception:
            pass

    return text
```

---

## Bagian 5 — API Hasil RECOMMENDATION

### 5.1 Struktur Response: Tab Rekomendasi

Endpoint ini membaca dari `career_recommendations` + join ke `professions` + `ikigai_candidate_professions` untuk memperkaya data.

```python
GET /api/v1/career-profile/result/recommendation/{session_token}
```

**Response Structure:**

```json
{
  "session_token": "uuid-...",
  "user_first_name": "Citra",
  "test_completed_at": "2024-12-15T10:45:00Z",

  "riasec_summary": {
    "riasec_code": "RIA",
    "riasec_title": "Realistic – Investigative – Artistic",
    "top_types": ["Realistic", "Investigative", "Artistic"],
    "total_candidates_found": 15
  },

  "candidate_profession_names": [
    {"profession_id": 25, "name": "Game Developer"},
    {"profession_id": 18, "name": "Frontend Developer"},
    {"profession_id": 31, "name": "DevOps Engineer"},
    {"profession_id": 42, "name": "Data Visualization Specialist"}
  ],

  "ikigai_profile_summary": {
    "what_you_love": "Kamu paling antusias saat membuat sesuatu...",
    "what_you_are_good_at": "Kamu merasa cukup kuat dalam menganalisis...",
    "what_the_world_needs": "Kamu memandang bahwa dunia membutuhkan...",
    "what_you_can_be_paid_for": "Kamu menyadari bahwa kemampuan teknis..."
  },

  "recommended_professions": [
    {
      "rank": 1,
      "profession_id": 25,
      "profession_name": "Game Developer",
      "match_percentage": 52.0,
      "match_reasoning": "Profesi ini cocok karena...",
      "riasec_alignment": {
        "user_code": "RIA",
        "profession_code": "RIA",
        "congruence_type": "exact_match",
        "congruence_score": 1.0
      },
      "score_breakdown": {
        "total_score": 52.0,
        "intrinsic_score": 28.5,
        "extrinsic_score": 23.5,
        "score_what_you_love": 15.0,
        "score_what_you_are_good_at": 13.5,
        "score_what_the_world_needs": 12.0,
        "score_what_you_can_be_paid_for": 11.5
      }
    },
    {
      "rank": 2,
      "profession_id": 18,
      "profession_name": "Frontend Developer",
      "match_percentage": 48.0,
      "match_reasoning": "Profesi ini sesuai karena...",
      "riasec_alignment": { ... },
      "score_breakdown": { ... }
    }
  ],

  "points_awarded": null,
  "TODO_points": "Implementasi poin Rextra belum aktif. Tambahkan setelah tabel points dikonfirmasi."
}
```

**Keterangan field:**

| Field | Sumber | Keterangan |
|---|---|---|
| `user_first_name` | `users.fullname` — ambil kata pertama | Untuk heading "Hasil Tes untuk [nama]" di Flutter |
| `riasec_summary` | `riasec_results` + `riasec_codes` | Ringkasan profil RIASEC |
| `total_candidates_found` | `ikigai_candidate_professions.total_candidates` | "REXTRA menemukan N profesi" |
| `candidate_profession_names` | `ikigai_candidate_professions` + JOIN `professions` | Semua kandidat hanya nama untuk display list |
| `ikigai_profile_summary` | `career_recommendations.recommendations_data` | Narasi 4 dimensi |
| `recommended_professions` | `career_recommendations.recommendations_data` + `professions.name` | Top 2 dengan nama profesi di-enrich dari DB |
| `points_awarded` | TODO | Selalu `null` sampai tabel points dikonfirmasi |

---

## Bagian 6 — API Hasil FIT_CHECK

### 6.1 Struktur Response: Tab Hasil Uji

```python
GET /api/v1/career-profile/result/fit-check/{session_token}
```

**Response Structure:**

```json
{
  "session_token": "uuid-...",
  "user_first_name": "Citra",
  "test_completed_at": "2024-12-15T10:45:00Z",

  "user_riasec": {
    "riasec_code": "IRC",
    "riasec_title": "Investigative – Realistic – Conventional",
    "top_types": ["Investigative", "Realistic", "Conventional"]
  },

  "target_profession": {
    "profession_id": 15,
    "name": "Data Engineer",
    "riasec_code": "ICR",
    "riasec_title": "Investigative – Conventional – Realistic"
  },

  "fit_check_result": {
    "match_category": "HIGH",
    "match_label": "Kecocokan Tinggi",
    "match_stars": 3,
    "rule_type": "permutation_match",
    "dominant_letter_same": true,
    "is_adjacent_hexagon": true,
    "match_score": 0.89,

    "explanation": {
      "meaning": "Kecocokan Tinggi menunjukkan bahwa minat dominan dan minat pendukung selaras dengan karakter utama profesi.",
      "reason_points": [
        "Profil karier berkode IRC dan profesi ini berkode ICR.",
        "Huruf dominan sama (I) dan komposisi tiga huruf identik (I, R, C), sehingga menunjukkan keselarasan minat utama dan pendukung."
      ],
      "implication": "Profesi ini layak diprioritaskan sebagai tujuan pengembangan."
    },

    "next_steps": [
      "Perkuat kompetensi inti yang dibutuhkan profesi.",
      "Bangun pengalaman melalui proyek, magang, atau portofolio.",
      "Susun rencana pengembangan yang terarah."
    ],
    "cta_primary": "Buat Rencana Karier",
    "cta_secondary": null
  },

  "points_awarded": null,
  "TODO_points": "Implementasi poin Rextra belum aktif."
}
```

### 6.2 Rule-Based Explanation Generator

Teks `explanation` dan `next_steps` dihasilkan **secara programatik** (bukan Gemini) berdasarkan field di `fit_check_results`. Ini konsisten dengan prinsip "rule-based, bukan AI-generated" untuk halaman FIT_CHECK.

```python
def build_fit_check_explanation(fit_result: dict, user_code: str, profession_code: str) -> dict:
    """
    Generate teks penjelasan dinamis dari data fit_check_results.
    Tidak menggunakan AI — semua berbasis rule.
    Copywriting mengikuti template spesifikasi UI per kondisi.
    """
    category = fit_result["match_category"]
    rule_type = fit_result["rule_type"]

    user_dominant = user_code[0]
    prof_dominant = profession_code[0]
    user_set_str = ", ".join(sorted(user_code))   # misal "C, I, R"

    MATCH_LABELS = {"HIGH": "Kecocokan Tinggi", "MEDIUM": "Kecocokan Sedang", "LOW": "Kecocokan Rendah"}
    MATCH_STARS  = {"HIGH": 3, "MEDIUM": 2, "LOW": 1}

    if category == "HIGH":
        if rule_type == "exact_match":
            reason_points = [
                f"Profil karier berkode {user_code} dan profesi ini juga berkode {profession_code}.",
                f"Kode identik menunjukkan keselarasan penuh — minat utama ({user_dominant}) "
                f"dan seluruh pola aktivitas kerja berada pada spektrum yang sama."
            ]
        else:  # permutation_match
            reason_points = [
                f"Profil karier berkode {user_code} dan profesi ini berkode {profession_code}.",
                f"Huruf dominan sama ({user_dominant}) dan komposisi tiga huruf identik "
                f"({user_set_str}), sehingga menunjukkan keselarasan minat utama dan pendukung."
            ]
        meaning   = ("Kecocokan Tinggi menunjukkan bahwa minat dominan dan minat pendukung selaras "
                     "dengan karakter utama profesi. Hal ini menandakan tingkat kesesuaian yang kuat "
                     "antara profil karier dan aktivitas kerja yang dituntut profesi tersebut.")
        implication = "Profesi ini layak diprioritaskan sebagai tujuan pengembangan."
        next_steps  = [
            "Perkuat kompetensi inti yang dibutuhkan profesi.",
            "Bangun pengalaman melalui proyek, magang, atau portofolio.",
            "Susun rencana pengembangan yang terarah."
        ]
        cta_primary   = "Buat Rencana"
        cta_secondary = None

    elif category == "MEDIUM":
        if rule_type == "dominant_same":
            # Cari huruf yang berbeda antara dua kode
            user_set   = set(user_code)
            prof_set   = set(profession_code)
            diff_user  = user_set - prof_set    # huruf di user tapi tidak di profesi
            diff_prof  = prof_set - user_set    # huruf di profesi tapi tidak di user
            diff_str   = ""
            if diff_user and diff_prof:
                diff_str = (f" Huruf {', '.join(sorted(diff_user))} pada profil "
                            f"digantikan {', '.join(sorted(diff_prof))} pada profesi.")
            reason_points = [
                f"Profil berkode {user_code}, sedangkan profesi ini berkode {profession_code}.",
                f"Huruf dominan sama ({user_dominant}), namun salah satu komponen minat pendukung berbeda.{diff_str} "
                f"Hal ini menunjukkan arah minat utama sejalan, tetapi beberapa karakter tugas mungkin memerlukan adaptasi."
            ]
        else:  # adjacent_dominant
            reason_points = [
                f"Profil berkode {user_code}, sedangkan profesi ini berkode {profession_code}.",
                f"Huruf dominan berbeda ({user_dominant} pada profil, {prof_dominant} pada profesi) "
                f"namun keduanya bertetangga dalam model RIASEC. "
                f"Hal ini menunjukkan kedekatan minat meski orientasi aktivitas tidak sepenuhnya identik."
            ]
        meaning   = ("Kecocokan Sedang menunjukkan adanya keselarasan pada sebagian komponen minat, "
                     "namun terdapat perbedaan pada dominansi atau minat pendukung. "
                     "Profesi masih relevan, tetapi memerlukan penyesuaian.")
        implication = "Profesi ini tetap dapat dipertimbangkan dengan strategi penguatan yang tepat."
        next_steps  = [
            "Identifikasi komponen minat yang berbeda.",
            "Susun strategi adaptasi pada aspek tersebut.",
            "Bandingkan dengan profesi lain yang lebih selaras."
        ]
        cta_primary   = "Lihat Rekomendasi"
        cta_secondary = "Strategi Adaptasi"

    else:  # LOW
        reason_points = [
            f"Profil berkode {user_code}, sedangkan profesi ini berkode {profession_code}.",
            f"Huruf dominan berbeda ({user_dominant} pada profil, {prof_dominant} pada profesi) "
            f"dan tidak berada pada posisi bertetangga dalam model RIASEC, "
            f"sehingga arah minat utamanya tidak sejalan."
        ]
        meaning   = ("Kecocokan Rendah menunjukkan bahwa minat dominan profil karier berbeda "
                     "dan tidak berada pada spektrum yang berdekatan dengan karakter utama profesi. "
                     "Tingkat keselarasan relatif rendah.")
        implication = ("Profesi ini tetap dapat dipilih, tetapi biasanya memerlukan adaptasi "
                       "yang lebih besar dan pertimbangan yang lebih matang.")
        next_steps  = [
            "Tinjau kembali alasan memilih profesi ini.",
            "Eksplorasi profesi lain yang lebih selaras dengan profil karier.",
            "Jika tetap memilih profesi ini, siapkan strategi adaptasi yang lebih intens."
        ]
        cta_primary   = "Cari Alternatif"
        cta_secondary = "Tetap Lanjut"

    return {
        "meaning":      meaning,
        "reason_points": reason_points,
        "implication":  implication,
        "next_steps":   next_steps,
        "cta_primary":  cta_primary,
        "cta_secondary": cta_secondary,
        "match_label":  MATCH_LABELS[category],
        "match_stars":  MATCH_STARS[category]
    }
```

---

## Bagian 7 — API Shared: Tab Kepribadian

Tab Kepribadian identik antara RECOMMENDATION dan FIT_CHECK. Dibuat sebagai **1 endpoint shared** yang bisa dipanggil Flutter dari kedua halaman hasil.

```python
GET /api/v1/career-profile/result/personality/{session_token}
```

**Response Structure:**

```json
{
  "session_token": "uuid-...",
  "riasec_code": "RIA",
  "riasec_title": "Realistic – Investigative – Artistic",
  "top_types": [
    {"letter": "R", "name": "Realistic"},
    {"letter": "I", "name": "Investigative"},
    {"letter": "A", "name": "Artistic"}
  ],

  "about_code": "Kode RIA menunjukkan bahwa kekuatan utamamu adalah tipe Realistic.\nCaramu bekerja juga dipengaruhi oleh pola pikir Investigative dan gaya Artistic.\nSinergi ketiganya membuatmu cenderung menjadi problem solver teknis yang tetap kreatif dalam membangun solusi digital.",

  "strengths": [
    "Tech-savvy: cepat memahami dan menguasai tools atau software baru.",
    "Problem solver: mampu membedah masalah teknis secara logis.",
    "Creative engineer: membangun solusi fungsional sekaligus menarik.",
    "Hands-on: lebih suka langsung mengeksekusi daripada hanya berdiskusi."
  ],

  "challenges": [
    "Perfeksionisme: cenderung terlalu lama fokus pada detail kecil.",
    "Komunikasi teknis: kadang kesulitan menjelaskan konsep kompleks ke non-teknis.",
    "Over-focus: bisa terlalu larut dalam pekerjaan hingga lupa konteks tim."
  ],

  "strategies": [
    "Batasi perfeksionisme: gunakan deadline yang jelas untuk setiap tugas.",
    "Komunikasi ringkas: latih menjelaskan ide dalam 2–3 kalimat sederhana.",
    "Iterasi cepat: minta feedback sejak versi awal agar tidak revisi besar di akhir.",
    "Kelola prioritas: tentukan 1–3 tugas utama sebelum membuka pekerjaan lain."
  ],

  "interaction_styles": [
    "Pendekatan mandiri: lebih suka memikirkan solusi sendiri sebelum diskusi.",
    "Berbasis data: cenderung berpihak pada argumen yang didukung fakta.",
    "Pendengar aktif: lebih banyak mengamati sebelum memberi pendapat."
  ],

  "work_environments": [
    "Ruang eksplorasi teknis: diberi kebebasan mencoba tools dan eksperimen.",
    "Deep work friendly: menghargai waktu fokus tanpa meeting berlebihan.",
    "Budaya berbasis data: keputusan dibuat berdasarkan insight, bukan opini semata.",
    "Apresiasi hasil nyata: menilai kualitas output, bukan sekadar jam hadir."
  ]
}
```

**Sumber data:**
- `riasec_codes.strengths`, `challenges`, `strategies`, `work_environments`, `interaction_styles` → langsung dari DB, tanpa Gemini
- `about_code` → dari Gemini (cached di Redis per `riasec_code`)

---

## Bagian 8 — Model, Schema, Router, Service

### 8.1 Model SQLAlchemy

```python
# app/api/v1/categories/career_profile/models/result.py

from sqlalchemy import Column, BigInteger, String, Boolean, Numeric, TIMESTAMP, ForeignKey
from sqlalchemy import Enum as SAEnum
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.sql import func
from app.db.base import Base


class CareerRecommendation(Base):
    """
    Hasil rekomendasi akhir untuk sesi RECOMMENDATION.
    Berisi narasi Ikigai + match reasoning top 2 profesi.
    INSERT sekali setelah Ikigai Part 2 selesai. Immutable + Permanen.
    One-to-one dengan careerprofile_test_sessions.
    """
    __tablename__ = "career_recommendations"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )
    recommendations_data = Column(JSONB, nullable=False)
    top_profession1_id = Column(BigInteger, nullable=True)
    top_profession2_id = Column(BigInteger, nullable=True)
    generated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    ai_model_used = Column(String(50), default="gemini-1.5-flash")


class FitCheckResult(Base):
    """
    Hasil evaluasi kecocokan untuk sesi FIT_CHECK.
    Rule-based — tidak ada AI.
    INSERT sekali saat RIASEC selesai. Immutable.
    One-to-one dengan careerprofile_test_sessions.
    """
    __tablename__ = "fit_check_results"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )
    profession_id = Column(BigInteger, nullable=False)
    user_riasec_code_id = Column(BigInteger, nullable=False)
    profession_riasec_code_id = Column(BigInteger, nullable=False)
    match_category = Column(
        SAEnum('HIGH', 'MEDIUM', 'LOW', name='match_category_enum', create_type=False),
        nullable=False
    )
    # create_type=False karena ENUM ini sudah ada di DB — Alembic tidak perlu membuat ulang
    rule_type = Column(String(50), nullable=False)
    dominant_letter_same = Column(Boolean, nullable=False)
    is_adjacent_hexagon = Column(Boolean, nullable=False)
    match_score = Column(Numeric(4, 2), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
```

### 8.2 Schema Pydantic

```python
# app/api/v1/categories/career_profile/schemas/result.py

from pydantic import BaseModel
from typing import Optional, List, Any


class RIASECSummary(BaseModel):
    riasec_code: str
    riasec_title: str
    top_types: List[str]
    total_candidates_found: Optional[int] = None


class ScoreBreakdown(BaseModel):
    total_score: float
    intrinsic_score: float
    extrinsic_score: float
    score_what_you_love: float
    score_what_you_are_good_at: float
    score_what_the_world_needs: float
    score_what_you_can_be_paid_for: float


class RIASECAlignment(BaseModel):
    user_code: str
    profession_code: str
    congruence_type: str
    congruence_score: float


class RecommendedProfession(BaseModel):
    rank: int
    profession_id: int
    profession_name: str
    match_percentage: float
    match_reasoning: str
    riasec_alignment: RIASECAlignment
    score_breakdown: ScoreBreakdown


class CandidateProfessionName(BaseModel):
    profession_id: int
    name: str


class IkigaiProfileSummary(BaseModel):
    what_you_love: str
    what_you_are_good_at: str
    what_the_world_needs: str
    what_you_can_be_paid_for: str


class RecommendationResultResponse(BaseModel):
    session_token: str
    user_first_name: str
    test_completed_at: Optional[str]
    riasec_summary: RIASECSummary
    candidate_profession_names: List[CandidateProfessionName]
    ikigai_profile_summary: IkigaiProfileSummary
    recommended_professions: List[RecommendedProfession]
    points_awarded: None = None
    TODO_points: Optional[str] = "Implementasi poin Rextra belum aktif. Tambahkan setelah tabel points dikonfirmasi."


class FitCheckExplanation(BaseModel):
    meaning: str
    reason_points: List[str]
    implication: str
    next_steps: List[str]
    cta_primary: str
    cta_secondary: Optional[str]
    match_label: str
    match_stars: int


class TargetProfession(BaseModel):
    profession_id: int
    name: str
    riasec_code: str
    riasec_title: str


class FitCheckResultItem(BaseModel):
    match_category: str   # "HIGH" / "MEDIUM" / "LOW"
    match_label: str
    match_stars: int
    rule_type: str
    dominant_letter_same: bool
    is_adjacent_hexagon: bool
    match_score: Optional[float]
    explanation: FitCheckExplanation
    # Catatan untuk Flutter: next_steps ada di dalam explanation.next_steps, bukan di root


class FitCheckResultResponse(BaseModel):
    session_token: str
    user_first_name: str
    test_completed_at: Optional[str]
    user_riasec: RIASECSummary
    target_profession: TargetProfession
    fit_check_result: FitCheckResultItem
    points_awarded: None = None
    TODO_points: Optional[str] = "Implementasi poin Rextra belum aktif. Tambahkan setelah tabel points dikonfirmasi."


class TopTypeItem(BaseModel):
    letter: str
    name: str


class PersonalityResultResponse(BaseModel):
    session_token: str
    riasec_code: str
    riasec_title: str
    top_types: List[TopTypeItem]
    about_code: str
    strengths: List[str]
    challenges: List[str]
    strategies: List[str]
    interaction_styles: List[str]
    work_environments: List[str]
```

### 8.3 Router

```python
# app/api/v1/categories/career_profile/routers/result.py

from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.dependencies.auth import require_active_membership
from app.api.v1.categories.career_profile.services.result_service import ResultService
from app.api.v1.categories.career_profile.schemas.result import (
    RecommendationResultResponse,
    FitCheckResultResponse,
    PersonalityResultResponse
)
from app.db.models.user import User

router = APIRouter(prefix="/career-profile/result")


@router.get("/recommendation/{session_token}", response_model=RecommendationResultResponse)
@limiter.limit("30/minute")
async def get_recommendation_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil hasil lengkap tes RECOMMENDATION.
    Endpoint ini dipanggil Flutter untuk render:
    - Tab Rekomendasi (semua data kecuali Tab Kepribadian)
    
    Sumber data:
    - career_recommendations (narasi + skor)
    - riasec_results + riasec_codes (ringkasan RIASEC)
    - ikigai_candidate_professions (daftar kandidat profesi)
    - professions (nama profesi untuk enrich data)
    - users (nama depan user)
    """
    service = ResultService(db)
    return await service.get_recommendation_result(session_token, current_user)


@router.get("/fit-check/{session_token}", response_model=FitCheckResultResponse)
@limiter.limit("30/minute")
async def get_fit_check_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil hasil lengkap tes FIT_CHECK.
    Endpoint ini dipanggil Flutter untuk render:
    - Tab Hasil Uji (highlight + detail kecocokan)
    
    Penjelasan dihasilkan secara programatik (rule-based),
    tidak ada AI call saat endpoint ini dipanggil.
    """
    service = ResultService(db)
    return service.get_fit_check_result(session_token, current_user)


@router.get("/personality/{session_token}", response_model=PersonalityResultResponse)
@limiter.limit("30/minute")
async def get_personality_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil data Tab Kepribadian.
    Shared endpoint — bisa dipanggil dari halaman RECOMMENDATION maupun FIT_CHECK.
    
    'Tentang Kode' dihasilkan via Gemini dengan cache Redis per kode RIASEC.
    Semua field lain (strengths, challenges, dll) langsung dari riasec_codes tabel.
    """
    service = ResultService(db)
    return await service.get_personality_result(session_token, current_user)
```

### 8.4 Result Service

```python
# app/api/v1/categories/career_profile/services/result_service.py

from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.db.models.user import User
from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from app.api.v1.categories.career_profile.models.riasec import RIASECResult, RIASECCode
from app.api.v1.categories.career_profile.models.result import CareerRecommendation, FitCheckResult
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession
from app.api.v1.categories.career_profile.services.fit_check_classifier import build_fit_check_explanation
from app.api.v1.categories.career_profile.services.personality_service import get_personality_about_text
from app.core.redis import get_redis_client

RIASEC_LETTER_NAMES = {
    "R": "Realistic", "I": "Investigative", "A": "Artistic",
    "S": "Social", "E": "Enterprising", "C": "Conventional"
}


class ResultService:

    def __init__(self, db: Session):
        self.db = db

    def _get_validated_session(self, session_token: str, user: User) -> CareerProfileTestSession:
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()
        if not session or str(session.user_id) != str(user.id):
            raise HTTPException(status_code=404, detail="Sesi tidak ditemukan atau bukan milik user ini")
        if session.status != "completed":
            raise HTTPException(status_code=400, detail="Sesi belum selesai. Selesaikan tes terlebih dahulu.")
        return session

    async def get_recommendation_result(self, session_token: str, user: User) -> dict:
        session = self._get_validated_session(session_token, user)
        if session.test_goal != "RECOMMENDATION":
            raise HTTPException(status_code=400, detail="Sesi ini bukan tipe RECOMMENDATION")

        # Ambil career_recommendations
        rec = self.db.query(CareerRecommendation).filter(
            CareerRecommendation.test_session_id == session.id
        ).first()
        if not rec:
            raise HTTPException(status_code=404, detail="Data rekomendasi belum tersedia")

        # Ambil RIASEC result
        riasec_result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()
        riasec_code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == riasec_result.riasec_code_id
        ).first()

        # Ambil kandidat profesi
        candidate_record = self.db.query(IkigaiCandidateProfession).filter(
            IkigaiCandidateProfession.test_session_id == session.id
        ).first()
        all_candidates = candidate_record.candidates_data.get("candidates", []) if candidate_record else []

        # Ambil nama profesi untuk semua kandidat
        candidate_ids = [c["profession_id"] for c in all_candidates]
        from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
        prof_repo = ProfessionRepository(self.db)
        profession_names = {p.id: p.name for p in prof_repo.get_by_ids(candidate_ids)}

        # MAX_DISPLAY_CANDIDATES = 30, konsisten dengan batas kandidat di Part 1 (ikigai_candidate_professions)
        # Semua kandidat ditampilkan sebagai nama di list UI — bukan hanya yang display_order <= 5
        MAX_DISPLAY_CANDIDATES = 30
        candidate_names = [
            {"profession_id": cid, "name": profession_names.get(cid, "Unknown")}
            for cid in candidate_ids[:MAX_DISPLAY_CANDIDATES]
        ]

        # Enrich recommended_professions dengan nama profesi
        rec_data = rec.recommendations_data
        enriched_professions = []
        for prof in rec_data.get("recommended_professions", []):
            prof["profession_name"] = profession_names.get(prof["profession_id"], "Unknown")
            enriched_professions.append(prof)

        # Nama depan user
        user_first_name = user.fullname.split()[0] if user.fullname else "Pengguna"

        # Top types dari riasec_code
        top_types = [RIASEC_LETTER_NAMES.get(l, l) for l in riasec_code_obj.riasec_code]

        return {
            "session_token": session_token,
            "user_first_name": user_first_name,
            "test_completed_at": session.completed_at.isoformat() if session.completed_at else None,
            "riasec_summary": {
                "riasec_code": riasec_code_obj.riasec_code,
                "riasec_title": " – ".join(top_types),
                "top_types": top_types,
                "total_candidates_found": (
                    candidate_record.total_candidates
                    if candidate_record and candidate_record.total_candidates
                    else len(all_candidates)
                    # Fallback ke len() jika kolom total_candidates tidak terisi saat insert
                ),
            },
            "candidate_profession_names": candidate_names,
            "ikigai_profile_summary": rec_data.get("ikigai_profile_summary", {}),
            "recommended_professions": enriched_professions,
            "points_awarded": None
            # TODO: Implementasi poin Rextra setelah nama tabel points dikonfirmasi
        }

    def get_fit_check_result(self, session_token: str, user: User) -> dict:
        session = self._get_validated_session(session_token, user)
        if session.test_goal != "FIT_CHECK":
            raise HTTPException(status_code=400, detail="Sesi ini bukan tipe FIT_CHECK")

        # Ambil fit_check_results
        fit_result = self.db.query(FitCheckResult).filter(
            FitCheckResult.test_session_id == session.id
        ).first()
        if not fit_result:
            raise HTTPException(status_code=404, detail="Data fit check belum tersedia")

        # Ambil RIASEC user
        riasec_result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()
        user_code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == riasec_result.riasec_code_id
        ).first()

        # Ambil kode RIASEC profesi target
        prof_code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == fit_result.profession_riasec_code_id
        ).first()

        # Ambil nama profesi target
        from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
        profession = ProfessionRepository(self.db).get_by_id(fit_result.profession_id)
        prof_top_types = [RIASEC_LETTER_NAMES.get(l, l) for l in prof_code_obj.riasec_code]

        # Build explanation rule-based
        fit_result_dict = {
            "match_category": fit_result.match_category,
            "rule_type": fit_result.rule_type,
            "dominant_letter_same": fit_result.dominant_letter_same,
            "is_adjacent_hexagon": fit_result.is_adjacent_hexagon,
            "match_score": float(fit_result.match_score) if fit_result.match_score else None
        }
        explanation = build_fit_check_explanation(
            fit_result=fit_result_dict,
            user_code=user_code_obj.riasec_code,
            profession_code=prof_code_obj.riasec_code
        )

        user_top_types = [RIASEC_LETTER_NAMES.get(l, l) for l in user_code_obj.riasec_code]
        user_first_name = user.fullname.split()[0] if user.fullname else "Pengguna"

        MATCH_LABELS = {"HIGH": "Kecocokan Tinggi", "MEDIUM": "Kecocokan Sedang", "LOW": "Kecocokan Rendah"}
        MATCH_STARS = {"HIGH": 3, "MEDIUM": 2, "LOW": 1}

        return {
            "session_token": session_token,
            "user_first_name": user_first_name,
            "test_completed_at": session.completed_at.isoformat() if session.completed_at else None,
            "user_riasec": {
                "riasec_code": user_code_obj.riasec_code,
                "riasec_title": " – ".join(user_top_types),
                "top_types": user_top_types
            },
            "target_profession": {
                "profession_id": fit_result.profession_id,
                "name": profession.name if profession else "Unknown",
                "riasec_code": prof_code_obj.riasec_code,
                "riasec_title": " – ".join(prof_top_types)
            },
            "fit_check_result": {
                **fit_result_dict,
                "match_label": MATCH_LABELS[fit_result.match_category],
                "match_stars": MATCH_STARS[fit_result.match_category],
                "explanation": explanation
            },
            "points_awarded": None
        }

    async def get_personality_result(self, session_token: str, user: User) -> dict:
        session = self._get_validated_session(session_token, user)

        # Validasi test_goal — shared endpoint tapi hanya untuk tipe tes yang dikenal
        # Future-proofing: kalau ada tipe tes baru yang tidak punya riasec_results, ini mencegah runtime error
        VALID_GOALS = {"RECOMMENDATION", "FIT_CHECK"}
        if session.test_goal not in VALID_GOALS:
            raise HTTPException(
                status_code=400,
                detail=f"Tab Kepribadian tidak tersedia untuk tipe tes '{session.test_goal}'"
            )

        riasec_result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()
        if not riasec_result:
            raise HTTPException(status_code=404, detail="Data RIASEC tidak ditemukan")

        code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == riasec_result.riasec_code_id
        ).first()

        letters = list(code_obj.riasec_code)
        top_types = [{"letter": l, "name": RIASEC_LETTER_NAMES.get(l, l)} for l in letters]

        # Generate 'about_code' via Gemini (cached di Redis)
        redis_client = get_redis_client()
        about_code = await get_personality_about_text(
            riasec_code=code_obj.riasec_code,
            riasec_title=code_obj.riasec_title,
            riasec_description=code_obj.riasec_description or "",
            redis_client=redis_client
        )

        return {
            "session_token": session_token,
            "riasec_code": code_obj.riasec_code,
            "riasec_title": " – ".join([RIASEC_LETTER_NAMES.get(l, l) for l in letters]),
            "top_types": top_types,
            "about_code": about_code,
            "strengths": code_obj.strengths or [],
            "challenges": code_obj.challenges or [],
            "strategies": code_obj.strategies or [],
            "interaction_styles": code_obj.interaction_styles or [],
            "work_environments": code_obj.work_environments or []
        }
```

---

## Bagian 9 — Alur Data Lengkap (Visual)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALUR FIT_CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Dari Brief RIASEC — submit_riasec_test()]
    └── _mark_fit_check_completed() dipanggil
          ↓
    [TAMBAHAN BARU — _insert_fit_check_result()]
    Query riasec_results → ambil user_riasec_code_id
    Query professions → ambil profession_riasec_code_id
    classify_fit_check(user_code, profession_code)
      → HIGH / MEDIUM / LOW + rule_type + flags + match_score
    INSERT fit_check_results
    COMMIT (dilakukan oleh caller submit_riasec_test)
          ↓
    [Flutter panggil GET /result/fit-check/{token}]
    Load fit_check_results + riasec_codes + professions
    build_fit_check_explanation() → teks dinamis rule-based
    Return response lengkap ke Flutter

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALUR RECOMMENDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Dari Brief Part 2 — _run_scoring_pipeline()]
    └── INSERT ikigai_total_scores selesai
          ↓
    [TAMBAHAN BARU — generate + INSERT career_recommendations]
    Kumpulkan data:
      ikigai_responses (4 reasoning_text)
      ikigai_total_scores (top 2 profesi + skor)
      professions (nama + aktivitas + skill top 2 profesi)
      riasec_results + riasec_codes (kode user)
      ikigai_candidate_professions (congruence data)
          ↓
    1 Gemini call → generate 6 narasi:
      - 4 ikigai_profile_summary (per dimensi)
      - 2 match_reasoning (per profesi)
          ↓
    Susun recommendations_data JSONB lengkap
    INSERT career_recommendations
    COMMIT
          ↓
    [Flutter panggil GET /result/recommendation/{token}]
    Load career_recommendations + riasec_codes
    Load ikigai_candidate_professions → daftar nama kandidat
    Enrich profession_name dari tabel professions
    Return response lengkap ke Flutter

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALUR TAB KEPRIBADIAN (SHARED)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Flutter panggil GET /result/personality/{token}]
    Load riasec_results → riasec_code_id
    Load riasec_codes → strengths, challenges, strategies,
                        interaction_styles, work_environments
          ↓
    Cek Redis cache: personality_about:{riasec_code}
      Cache HIT  → pakai narasi dari cache, tidak panggil Gemini
      Cache MISS → panggil Gemini (format ulang riasec_description)
                   Simpan hasil ke Redis TTL 7 hari
          ↓
    Return response lengkap ke Flutter
    (identik untuk RECOMMENDATION dan FIT_CHECK)
```

---

## Bagian 10 — Ringkasan File yang Dibuat / Dimodifikasi

| File | Status | Keterangan |
|---|---|---|
| `app/api/v1/categories/career_profile/models/result.py` | **Baru** | Model `CareerRecommendation` + `FitCheckResult` |
| `app/api/v1/categories/career_profile/schemas/result.py` | **Baru** | Semua schema Pydantic untuk 3 endpoint hasil |
| `app/api/v1/categories/career_profile/routers/result.py` | **Baru** | 3 endpoint GET hasil |
| `app/api/v1/categories/career_profile/services/result_service.py` | **Baru** | Orchestrator load & enrich data untuk 3 endpoint |
| `app/api/v1/categories/career_profile/services/fit_check_classifier.py` | **Baru** | `classify_fit_check()` + `build_fit_check_explanation()` + `calculate_match_score()` |
| `app/api/v1/categories/career_profile/services/recommendation_narrative_service.py` | **Baru** | `generate_recommendations_narrative()` + `build_recommendation_narrative_prompt()` |
| `app/api/v1/categories/career_profile/services/personality_service.py` | **Baru** | `get_personality_about_text()` — Gemini + Redis cache |
| `app/api/v1/categories/career_profile/prompts/recommendation_prompts.py` | **Baru** | `RECOMMENDATION_NARRATIVE_PROMPT` + `PERSONALITY_ABOUT_PROMPT` |
| `app/api/v1/categories/career_profile/services/riasec_service.py` | **Modifikasi** | Tambah `_insert_fit_check_result()` di dalam `_mark_fit_check_completed()` |
| `app/api/v1/categories/career_profile/services/ikigai_service.py` | **Modifikasi** | Tambah generate narasi + INSERT `career_recommendations` di akhir `_run_scoring_pipeline()` |
| `app/api/v1/categories/career_profile/repositories/profession_repo.py` | **Modifikasi** | Tambah method `get_by_ids()` + `get_profession_contexts_for_recommendation()` |

---

## Bagian 11 — Daftar Endpoint Part 3

| Method | Endpoint | Auth | Rate Limit | Deskripsi |
|---|---|---|---|---|
| `GET` | `/api/v1/career-profile/result/recommendation/{session_token}` | ✅ | 30/menit | Hasil lengkap tes RECOMMENDATION — Tab Rekomendasi |
| `GET` | `/api/v1/career-profile/result/fit-check/{session_token}` | ✅ | 30/menit | Hasil lengkap tes FIT_CHECK — Tab Hasil Uji |
| `GET` | `/api/v1/career-profile/result/personality/{session_token}` | ✅ | 30/menit | Tab Kepribadian — shared untuk RECOMMENDATION & FIT_CHECK |

**Catatan integrasi:**

- `fit_check_results` diisi otomatis saat RIASEC submit (tidak ada endpoint terpisah)
- `career_recommendations` diisi otomatis saat Ikigai Part 2 selesai (tidak ada endpoint terpisah)
- Ketiga endpoint di atas hanya membaca data yang sudah ada — tidak ada AI call on-the-fly kecuali `personality` yang pakai Gemini dengan Redis cache

---

## Catatan Kelanjutan

Brief ini menyelesaikan seluruh pipeline **Career Profile untuk alur RECOMMENDATION dan FIT_CHECK**. Fitur yang belum diimplementasikan dan ditandai `TODO` di brief ini:

- **Poin Rextra** — `+200 Rextra Poin` untuk RECOMMENDATION dan `+100 Rextra Poin` untuk FIT_CHECK. Implementasi menunggu konfirmasi nama tabel points dari tim Golang. Cari `TODO_points` di response untuk menandai lokasi yang perlu diisi.
- **Halaman detail profesi** — list kandidat profesi di Tab Rekomendasi menampilkan nama profesi saja. CTA "Lihat detail profesi" masih non-aktif (TODO). Akan membutuhkan endpoint read-only untuk data profesi lengkap.
- **Share & Reward** — logika bonus poin saat user share ke media sosial, menunggu sistem poin aktif.

*Brief ini siap diimplementasikan dan konsisten dengan Brief RIASEC, Brief Ikigai Part 1, dan Brief Ikigai Part 2 yang sudah ada.*