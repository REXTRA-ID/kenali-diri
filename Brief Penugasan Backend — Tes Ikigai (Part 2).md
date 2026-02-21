---
title: Brief Penugasan Backend — Tes Ikigai (Part 2)

---

# Brief Penugasan Backend — Tes Ikigai (Part 2)
## Fase: Submit Jawaban Dimensi, AI Scoring, Agregasi, & Penentuan Top 2 Profesi

**Engineer:** Ariel — AI Engineer Rextra
**Scope:** Ikigai Part 2 — berlaku eksklusif untuk alur `RECOMMENDATION`
**Kelanjutan dari:** Brief Ikigai Part 1 (inisiasi sesi, generate konten dimensi, cache Redis)
**Database:** PostgreSQL (shared dengan Golang CRUD system)
**Stack:** FastAPI + SQLAlchemy + Alembic + Redis + Google Gemini (via OpenRouter)
**Versi Brief:** 1.0

---

## Daftar Isi

1. [Konteks & Posisi Brief Ini](#1-konteks--posisi-brief-ini)
2. [Bagian 0 — Rekap Kondisi Awal dari Part 1](#bagian-0--rekap-kondisi-awal-dari-part-1)
3. [Bagian 1 — Alur Submit Jawaban Per Dimensi](#bagian-1--alur-submit-jawaban-per-dimensi)
4. [Bagian 2 — Trigger AI Scoring: Kapan dan Bagaimana](#bagian-2--trigger-ai-scoring-kapan-dan-bagaimana)
5. [Bagian 3 — Mekanisme AI Scoring: Formula & Skenario Lengkap](#bagian-3--mekanisme-ai-scoring-formula--skenario-lengkap)
6. [Bagian 4 — Prompt Engineering: Penilaian Relevansi Teks](#bagian-4--prompt-engineering-penilaian-relevansi-teks)
7. [Bagian 5 — Normalisasi, Kalkulasi Skor, & INSERT ikigai_dimension_scores](#bagian-5--normalisasi-kalkulasi-skor--insert-ikigai_dimension_scores)
8. [Bagian 6 — Agregasi & INSERT ikigai_total_scores](#bagian-6--agregasi--insert-ikigai_total_scores)
9. [Bagian 7 — Finalisasi Sesi & UPDATE Status](#bagian-7--finalisasi-sesi--update-status)
10. [Bagian 8 — Model, Schema, Router, Service](#bagian-8--model-schema-router-service)
11. [Bagian 9 — Alur Data Lengkap (Visual)](#bagian-9--alur-data-lengkap-visual)
12. [Bagian 10 — Ringkasan File yang Dibuat / Dimodifikasi](#bagian-10--ringkasan-file-yang-dibuat--dimodifikasi)
13. [Bagian 11 — Daftar Endpoint Ikigai Part 2](#bagian-11--daftar-endpoint-ikigai-part-2)

---

## 1. Konteks & Posisi Brief Ini

Brief ini adalah **kelanjutan langsung** dari Brief Ikigai Part 1 dan menangani seluruh proses setelah user menerima konten dimensi dari Flutter, yaitu:

1. **Submit jawaban per dimensi** — user menjawab 4 dimensi Ikigai satu per satu (atau bisa semua sekaligus jika Flutter mengirim batch). Tiap jawaban di-UPDATE ke `ikigai_responses`.
2. **Trigger AI scoring** — setelah dimensi ke-4 selesai, sistem menjalankan penilaian AI batch (4 Gemini call, 1 per dimensi) untuk menilai relevansi teks jawaban user terhadap **semua kandidat profesi** (opsi maupun pool).
3. **Kalkulasi & normalisasi** — skor relevansi mentah dinormalisasi min-max per dimensi, lalu dihitung `text_score` dan `click_score` per profesi per dimensi. Hasilnya di-INSERT ke `ikigai_dimension_scores`.
4. **Agregasi & ranking** — skor 4 dimensi dijumlahkan per profesi, diranking, top 2 ditentukan dengan tie-breaking. Hasilnya di-INSERT ke `ikigai_total_scores`.
5. **Finalisasi sesi** — UPDATE status ke `completed`, isi timestamp, update `kenalidiri_history`.

### Posisi dalam Pipeline Keseluruhan

```
[IKIGAI PART 1 — Selesai] ✅
    └── ikigai_responses row kosong sudah ter-INSERT
    └── Konten dimensi (narasi per profesi) sudah di-generate dan ada di Redis

[IKIGAI PART 2 — Brief Ini] 🔵
    ├── POST /ikigai/submit-dimension (×4) → UPDATE ikigai_responses
    ├── Setelah dimensi ke-4: AI scoring batch (4 Gemini call)
    ├── INSERT ikigai_dimension_scores
    ├── Agregasi per profesi → ranking → tie-breaking
    ├── INSERT ikigai_total_scores
    └── UPDATE status sesi + kenalidiri_history → completed

[SELESAI — Output ke Flutter] ✅
    └── 2 profesi rekomendasi utama + breakdown skor
```

> **Ruang Lingkup:** Brief ini berhenti di penentuan top 2 profesi berdasarkan skor numerik. Generate narasi rekomendasi final (teks penjelasan kecocokan per profesi berdasarkan jawaban user) akan dibahas di **Brief Ikigai Part 3**.

---

## Bagian 0 — Rekap Kondisi Awal dari Part 1

### 0.1 Tabel yang Sudah Ada

| Tabel | Status | Data Relevan |
|---|---|---|
| `careerprofile_test_sessions` | `status = ikigai_ongoing` | `session_token`, `user_id`, `uses_ikigai = true` |
| `ikigai_responses` | Row kosong ter-INSERT | Semua 4 kolom dimensi = `NULL` |
| `ikigai_candidate_professions` | Tersimpan immutable | `candidates_data` → array 1–30 profesi dengan `display_order` |
| `riasec_results` | Tersimpan | `riasec_code_id`, skor R/I/A/S/E/C |

### 0.2 Dua Kategori Kandidat Profesi (Rekap dari Part 1)

Ini penting karena scoring di Part 2 melibatkan **semua kandidat**, bukan hanya yang tampil di UI:

| Kategori | `display_order` | Tampil di UI sebagai opsi | Ikut AI Scoring |
|---|---|---|---|
| Kandidat Opsi | 1–5 | ✅ Ya | ✅ Ya |
| Kandidat Pool | 6–30 | ❌ Tidak | ✅ Ya |

**Implikasi untuk AI scoring:** Ketika Gemini menilai relevansi teks jawaban user, ia menilai teks tersebut terhadap **semua kandidat** (opsi + pool). Ini memungkinkan profesi dari pool untuk muncul sebagai top 2 meskipun tidak pernah tampil di UI.

### 0.3 Struktur JSONB `dimension_X` di `ikigai_responses` (Kondisi Awal)

```json
null
```

Setelah user submit dimensi 1, kolom `dimension_1_love` berisi:

```json
{
  "selected_profession_id": 10,
  "selection_type": "selected",
  "reasoning_text": "Saya suka coding dan problem solving karena memberikan tantangan intelektual yang menarik.",
  "answered_at": "2024-12-15T10:30:00Z"
}
```

Jika user tidak memilih opsi:

```json
{
  "selected_profession_id": null,
  "selection_type": "not_selected",
  "reasoning_text": "Tidak ada profesi yang cocok, saya lebih suka pekerjaan yang berdampak langsung ke masyarakat.",
  "answered_at": "2024-12-15T10:35:00Z"
}
```

---

## Bagian 1 — Alur Submit Jawaban Per Dimensi

### 1.0 Bagaimana Jawaban User Sampai ke Backend

Sebelum masuk ke detail teknis, penting untuk memahami **dari mana data berasal dan bagaimana perjalanannya dari Flutter ke database**.

#### Alur Input Data dari Flutter ke Backend

```
[Flutter — State Lokal]
  User melihat soal dimensi 1 (What You Love)
  Opsi tampil: 5 profesi dengan narasi (dari response /ikigai/start di Part 1)
  User bisa:
    A) Klik salah satu profesi sebagai pilihan
    B) Tidak klik profesi, langsung isi teks alasan

  Flutter menyimpan di state lokal:
    - selected_profession_id: int | null
    - selection_type: "selected" | "not_selected"
    - reasoning_text: string (user ketik bebas)

  User tekan tombol "Lanjut" / "Submit Dimensi Ini"
        ↓
  Flutter kirim POST /api/v1/career-profile/ikigai/submit-dimension
  Body: {session_token, dimension_name, selected_profession_id, selection_type, reasoning_text}
        ↓
  Backend UPDATE kolom dimensi di ikigai_responses
  Backend return: {dimensions_completed, dimensions_remaining, all_completed: false}
        ↓
  Flutter lanjut ke soal dimensi 2, 3 — proses sama
        ↓
  Flutter kirim submit untuk dimensi 4 (terakhir)
  Backend: UPDATE + trigger scoring pipeline
  Backend return: {top_2_professions, breakdown skor, status: "completed"}
```

**Penting:** Konten opsi (narasi per profesi per dimensi) sudah ada di Flutter sejak `/ikigai/start` dipanggil di Part 1 dan disimpan di state Flutter. Jadi ketika user mengisi soal, Flutter tidak perlu request tambahan ke backend — semua opsi tampil sudah siap dari awal.

#### Mengapa Submit Per Dimensi (Bukan Semua Sekaligus di Akhir)?

Desain submit per dimensi **lebih aman dan lebih efektif** dibanding kirim semua 4 jawaban sekaligus di akhir:

| Aspek | Submit Per Dimensi ✅ | Semua Sekaligus di Akhir ❌ |
|---|---|---|
| **Crash recovery** | Jawaban dimensi 1–3 tersimpan meski app crash di tengah | Semua jawaban hilang jika crash sebelum submit |
| **Koneksi putus** | User lanjut dari dimensi yang belum dijawab | User harus mengisi ulang dari awal |
| **Beban backend** | Ringan per request (1 UPDATE kecil) | 1 request besar di akhir |
| **UX** | User bisa istirahat di tengah, buka app lagi, lanjut | Harus selesaikan dalam satu sesi tanpa putus |

#### Kapan `ikigai_responses` Terisi Penuh?

```
Awal sesi (dari Part 1):
  dimension_1_love       = NULL
  dimension_2_good_at    = NULL
  dimension_3_world_needs = NULL
  dimension_4_paid_for   = NULL
  completed              = false

Setelah user submit dimensi 1:
  dimension_1_love       = {selected_profession_id, selection_type, reasoning_text, answered_at}
  dimension_2_good_at    = NULL  ← belum dijawab
  ...

Setelah user submit dimensi 4:
  dimension_1_love       = {...}
  dimension_2_good_at    = {...}
  dimension_3_world_needs = {...}
  dimension_4_paid_for   = {...}
  completed              = true   ← baru jadi true
  completed_at           = now()
```

**Scoring baru dijalankan ketika `completed = true`** — yaitu tepat setelah UPDATE dimensi ke-4 berhasil, masih dalam request yang sama. Tidak ada endpoint terpisah untuk trigger scoring; ini dilakukan otomatis di service layer.

#### Hubungan `ikigai_responses` → `ikigai_dimension_scores`

```
ikigai_responses (jawaban mentah user — diisi bertahap)
  │
  │  Setelah dimensi ke-4 selesai:
  │  Ambil reasoning_text dari 4 kolom dimensi
  │  Kirim ke Gemini (4 call paralel)
  │  Gemini return r_raw per profesi per dimensi
  │
  ▼
ikigai_dimension_scores (hasil AI scoring — INSERT sekali, immutable)
  │
  │  Setelah scoring selesai:
  │  Normalisasi + kalkulasi text_score + click_score
    text_score = 15% × r_normalized × 100   → range 0.0–15.0
    click_score = 10% × r_raw × 100          → range 0.0–10.0, hanya profesi dipilih
  │  Agregasi 4 dimensi per profesi → ranking
  │
  ▼
ikigai_total_scores (hasil final — INSERT sekali, immutable, permanen)
```

**`ikigai_responses` tidak menyimpan skor apapun** — hanya jawaban mentah (teks + pilihan profesi). Semua kalkulasi skor ada di `ikigai_dimension_scores` dan `ikigai_total_scores`. Ini memisahkan tanggung jawab dengan bersih: satu tabel untuk input user, dua tabel lain untuk hasil komputasi.

---

### 1.1 Desain: Satu Endpoint, Berlaku untuk Semua Dimensi

Alih-alih 4 endpoint terpisah (satu per dimensi), digunakan **satu endpoint** dengan parameter `dimension_name`. Ini lebih fleksibel dan mengurangi duplikasi kode.

```
POST /api/v1/career-profile/ikigai/submit-dimension
```

Body request menentukan dimensi mana yang sedang dijawab. Endpoint yang sama dipanggil hingga 4 kali (untuk dimensi 1, 2, 3, dan 4).

### 1.2 Validasi Submit Per Dimensi

Sebelum UPDATE dilakukan, backend memvalidasi:

1. **Sesi valid** — token ada, milik user ini, status `ikigai_ongoing`
2. **Dimensi valid** — `dimension_name` harus salah satu dari 4 nilai yang diizinkan
3. **Dimensi belum pernah dijawab** — jika kolom dimensi sudah terisi (tidak NULL), tolak dengan error 400. User tidak bisa overwrite jawaban yang sudah ada.
4. **Konsistensi selected_profession_id dan selection_type** — jika `selected_profession_id` tidak null, `selection_type` harus `"selected"`. Jika null, harus `"not_selected"`.
5. **Validasi profession_id** — jika `selected_profession_id` diisi, pastikan ID tersebut ada di `ikigai_candidate_professions.candidates_data` untuk sesi ini (bukan sembarang ID).
6. **Reasoning text minimal 10 karakter** — setelah di-strip whitespace.

### 1.3 Apa yang Terjadi Setelah Dimensi ke-4

Setelah UPDATE dimensi ke-4 berhasil, backend langsung mengecek apakah semua 4 dimensi sudah terisi. Jika ya:

1. Set `ikigai_responses.completed = true` dan isi `completed_at`
2. **Trigger AI scoring batch** (Bagian 2 dan 3)
3. INSERT `ikigai_dimension_scores`
4. INSERT `ikigai_total_scores`
5. UPDATE status sesi → `completed`
6. UPDATE `kenalidiri_history` → `completed`
7. Return hasil final ke Flutter (top 2 profesi + breakdown skor)

Jika bukan dimensi ke-4 (masih ada dimensi yang belum dijawab), return hanya konfirmasi bahwa dimensi ini berhasil disimpan, dengan info sisa dimensi yang harus dijawab.

---

## Bagian 2 — Trigger AI Scoring: Kapan dan Bagaimana

### 2.1 Kapan Scoring Dimulai

AI scoring **tidak dilakukan per dimensi saat user submit**. Scoring baru dimulai **setelah semua 4 dimensi selesai dijawab** (dalam satu request dimensi ke-4). Ini sesuai dengan desain di `ikigai_dimension_scores` yang bersifat INSERT sekali dan immutable.

Alasan:
- Penilaian membutuhkan semua 4 teks jawaban sekaligus untuk konsistensi normalisasi.
- 4 API call Gemini sekaligus lebih efisien daripada trigger bertahap.
- Menghindari partial data di `ikigai_dimension_scores`.

### 2.2 Struktur 4 Gemini Call

Satu call per dimensi, setiap call mengirim **satu teks jawaban user** dan meminta penilaian relevansi terhadap **semua kandidat profesi** (1–30 profesi) sekaligus.

```
Call 1: user_text = dimension_1_love.reasoning_text     → nilai semua N profesi
Call 2: user_text = dimension_2_good_at.reasoning_text  → nilai semua N profesi
Call 3: user_text = dimension_3_world_needs.reasoning_text → nilai semua N profesi
Call 4: user_text = dimension_4_paid_for.reasoning_text → nilai semua N profesi
```

Setiap call menghasilkan array `[{profession_id, r_raw}, ...]` dengan nilai `r_raw` antara 0.0–1.0 untuk setiap profesi kandidat.

### 2.3 Data Profesi yang Dikirim ke Gemini untuk Scoring

Berbeda dengan Part 1 (generate narasi panjang), untuk scoring Part 2 cukup mengirim **ringkasan singkat** per profesi agar token lebih efisien. Data yang diambil per profesi:

- `profession_id`
- `name`
- `about_description` (maks 200 karakter, di-truncate jika lebih)
- 3 aktivitas teratas dari `profession_activities`
- 3 hard skill wajib dari `profession_skill_rel`

Tidak perlu kirim salary, career path, market insights — itu hanya untuk narasi display, bukan scoring relevansi.

---

## Bagian 3 — Mekanisme AI Scoring: Formula & Skenario Lengkap

### 3.1 Definisi Variabel

Untuk setiap profesi `p` dan dimensi `d`:

| Variabel | Definisi | Range |
|---|---|---|
| `C_p,d` | Status klik: `1` jika profesi `p` dipilih user di dimensi `d`, `0` jika tidak | {0, 1} |
| `R_p,d` (raw) | Relevansi teks mentah — output dari Gemini | [0.0, 1.0] |
| `R_normalized(p,d)` | Hasil normalisasi min-max `R_p,d` per dimensi | [0.0, 1.0] |
| `T_p,d` | Skor teks = `15% × R_normalized(p,d) × 100` | [0.0, 15.0] |
| `A_p,d` | Skor klik disesuaikan = `10% × C_p,d × R_p,d × 100` (pakai R_raw, bukan normalized) | [0.0, 10.0] |
| `S_p,d` | Skor akhir dimensi = `T_p,d + A_p,d` | [0.0, 25.0] |

> **PENTING — Perbedaan penggunaan R_raw vs R_normalized:**
> - `T_p,d` (text score) menggunakan **R_normalized** karena ingin diferensiasi relatif antar profesi.
> - `A_p,d` (click score) menggunakan **R_raw** sebagai "keyakinan" — mengukur seberapa yakin model terhadap relevansi profesi yang dipilih user, sebelum dinormalisasi. Ini disebut **confidence-based click adjustment**.

### 3.2 Formula Lengkap

**R_raw dari Gemini (rubrik 3 komponen):**
```
R_p,d = 0.40 × K + 0.30 × S + 0.30 × B
```
Di mana:
- `K` = Kecocokan Topik & Kata Kunci (0.0–1.0)
- `S` = Sentimen & Intensitas Minat (0.0–1.0)
- `B` = Spesifisitas & Bukti Alasan (0.0–1.0)

**Normalisasi Min-Max per dimensi:**
```
R_normalized(p,d) = (R_raw(p,d) - R_min_d) / (R_max_d - R_min_d)
```
Kasus khusus: jika `R_max_d == R_min_d` (semua profesi dapat skor sama) → semua dapat `R_normalized = 0.5`

**Skor Teks:**
```
T_p,d = 15% × R_normalized(p,d) × 100
```
Range: 0.0–15.0

**Skor Klik (Confidence-Based):**
```
A_p,d = 10% × C_p,d × R_p,d × 100   (menggunakan R_raw sebagai keyakinan)
```
Range: 0.0–10.0

**Skor Per Dimensi:**
```
S_p,d = T_p,d + A_p,d
```

**Skor Total Profesi:**
```
Score_total(p) = S_p,love + S_p,good_at + S_p,world + S_p,paid
```
Range: 0–100%

### 3.3 Skenario Lengkap: Dampak Klik vs Tidak Klik

#### Skenario A — User PILIH Profesi X di Dimensi d

- Profesi X mendapat: `T_x,d = 15% × R_normalized(x,d)` PLUS `A_x,d = 10% × R_raw(x,d)`
- Maksimum yang bisa didapat profesi X di dimensi d: **25%** (jika R_raw = 1.0 dan R_normalized = 1.0)
- Profesi lain (tidak dipilih): hanya dapat `T_p,d = 15% × R_normalized(p,d)`, tidak ada `A`
- Maksimum profesi tidak dipilih di dimensi d: **15%**

#### Skenario B — User TIDAK PILIH Opsi (langsung isi teks bebas)

- `C_p,d = 0` untuk **semua** profesi di dimensi ini
- Semua profesi hanya dapat `T_p,d = 15% × R_normalized(p,d)` — tidak ada bonus klik siapapun
- Teks bebas user tetap dievaluasi terhadap **semua kandidat** (termasuk pool)
- Profesi dari pool yang sangat relevan dengan teks bisa tetap menang di dimensi ini
- Maksimum semua profesi di dimensi d: **15%**

#### Skenario C — User Pilih Profesi X, tapi alasan teks lemah

- R_raw(x,d) rendah, misal 0.2
- `A_x,d = 10% × 1 × 0.2 = 2%` — bonus klik kecil
- Profesi Y (tidak dipilih) tapi teks sangat relevan → R_raw(y,d) = 0.9
- `T_y,d = 15% × R_normalized(y,d)` bisa lebih besar dari S_x,d
- Artinya: profesi yang tidak dipilih bisa mengalahkan profesi yang dipilih jika teks user lebih relevan ke profesi lain

#### Skenario D — User Pilih Profesi X yang sama di semua 4 dimensi

- Profesi X mendapat bonus klik di semua 4 dimensi → potensi skor total tertinggi
- Namun jika teks user tidak relevan dengan X, bonus kliknya kecil-kecil di semua dimensi
- Profesi lain yang terus relevan secara teks bisa tetap bersaing

> **Intisari:** Skor tidak statis. Profesi yang dipilih user mendapat keuntungan struktural (bonus klik), tapi besarnya bonus bergantung pada seberapa kuat alasan teks user mendukung pilihan tersebut. Ini disebut **confidence-based** — klik tanpa alasan yang kuat menghasilkan bonus kecil.

---

## Bagian 4 — Prompt Engineering: Penilaian Relevansi Teks

### 4.1 Prinsip Desain Prompt Scoring

Berbeda dari prompt generate narasi di Part 1, prompt scoring memiliki karakteristik:

| Aspek | Perbedaan dari Part 1 |
|---|---|
| **Tujuan** | Penilaian numerik (0.0–1.0), bukan narasi deskriptif |
| **Input user** | Ada — teks jawaban user yang harus dievaluasi |
| **Konteks profesi** | Ringkas (nama + aktivitas + skill), bukan lengkap |
| **Output** | JSON array angka, bukan narasi panjang |
| **Jumlah call** | 4 call per sesi (1 per dimensi), masing-masing batch semua profesi |

### 4.2 Rubrik Penilaian untuk Gemini

Gemini diminta menilai `R_raw` per profesi menggunakan 3 komponen:

| Komponen | Bobot | Yang Dinilai | Panduan Level Skor |
|---|---|---|---|
| **K** — Kecocokan Topik & Kata Kunci | 40% | Seberapa kuat teks menyinggung aktivitas/skill/tugas inti profesi | 0.00 tidak relevan • 0.25 relevan sangat umum • 0.50 ada kata kunci/skill terkait • 0.75 menyebut skill/aktivitas inti + konteks • 1.00 menyebut beberapa skill inti + konteks spesifik |
| **S** — Sentimen & Intensitas Minat | 30% | Nada ketertarikan/penolakan terhadap aktivitas profesi | 0.00 negatif/menolak • 0.25 netral • 0.50 positif lemah • 0.75 positif jelas • 1.00 positif sangat kuat + konsisten |
| **B** — Spesifisitas & Bukti Alasan | 30% | Seberapa konkret alasan: contoh pengalaman/proyek/situasi | 0.00 sangat vague • 0.25 umum tanpa contoh • 0.50 ada contoh singkat • 0.75 contoh jelas + detail konteks • 1.00 contoh kuat + detail + menunjukkan pola/konsistensi |

Formula: `R_raw = 0.40×K + 0.30×S + 0.30×B`

### 4.3 Template Prompt Scoring (Per Dimensi)

```python
SCORING_PROMPT_TEMPLATE = """
Kamu adalah sistem evaluasi relevansi karier. Tugasmu adalah menilai
seberapa relevan teks alasan pengguna dengan setiap profesi kandidat.

DIMENSI YANG DINILAI: {dimension_label}
({dimension_description})

TEKS JAWABAN PENGGUNA:
"{user_reasoning_text}"

DAFTAR PROFESI KANDIDAT:
{professions_block}

RUBRIK PENILAIAN (untuk menghitung r_raw per profesi):
Nilai r_raw = 0.40×K + 0.30×S + 0.30×B

Komponen K (Kecocokan Topik & Kata Kunci, bobot 40%):
- 0.00 = tidak ada kesamaan topik sama sekali
- 0.25 = relevan tapi sangat umum
- 0.50 = ada kata kunci atau skill yang terkait
- 0.75 = menyebut aktivitas/skill inti dengan konteks
- 1.00 = menyebut beberapa skill inti dengan konteks spesifik

Komponen S (Sentimen & Intensitas Minat, bobot 30%):
- 0.00 = negatif/menolak profesi ini
- 0.25 = netral
- 0.50 = positif lemah
- 0.75 = positif jelas
- 1.00 = positif sangat kuat dan konsisten

Komponen B (Spesifisitas & Bukti, bobot 30%):
- 0.00 = sangat vague, tidak ada bukti
- 0.25 = umum tanpa contoh
- 0.50 = ada contoh singkat
- 0.75 = contoh jelas dengan detail konteks
- 1.00 = contoh kuat + detail + menunjukkan pola

ATURAN OUTPUT:
- Kembalikan HANYA JSON array valid, tidak ada teks tambahan
- Hitung r_raw untuk SETIAP profesi di daftar
- r_raw harus dalam range 0.00 - 1.00, 2 desimal
- Nilai r_raw harus BERBEDA antar profesi (hindari semua nilai sama)
- Urutkan array berdasarkan profession_id (ascending)

FORMAT OUTPUT:
[
  {{"profession_id": <int>, "r_raw": <float>}},
  ...
]
"""

DIMENSION_LABELS = {
    "what_you_love": {
        "label": "What You Love (Apa yang Kamu Sukai)",
        "description": "Nilai seberapa relevan teks dengan aktivitas atau aspek pekerjaan yang disukai user. Fokus pada ekspresi ketertarikan, kesenangan, atau motivasi intrinsik."
    },
    "what_you_are_good_at": {
        "label": "What You Are Good At (Apa yang Kamu Kuasai)",
        "description": "Nilai seberapa relevan teks dengan kompetensi, keahlian, atau kemampuan yang dimiliki user. Fokus pada kata-kata yang menunjukkan kemampuan, pengalaman, atau keyakinan."
    },
    "what_the_world_needs": {
        "label": "What The World Needs (Apa yang Dibutuhkan Dunia)",
        "description": "Nilai seberapa relevan teks dengan dampak sosial, nilai manfaat, atau masalah yang ingin diselesaikan user. Fokus pada orientasi kontribusi, misi, atau tujuan."
    },
    "what_you_can_be_paid_for": {
        "label": "What You Can Be Paid For (Apa yang Bisa Dibayar)",
        "description": "Nilai seberapa relevan teks dengan realitas pasar kerja, preferensi gaya kerja, atau ekspektasi kompensasi user. Fokus pada pragmatisme karier."
    }
}
```

### 4.4 Fungsi Build Prompt per Dimensi

```python
def build_scoring_prompt(
    dimension_name: str,
    user_reasoning_text: str,
    profession_contexts: list[dict]  # hasil dari ProfessionDataService (versi ringkas)
) -> str:
    """
    Membangun prompt scoring untuk satu dimensi.
    Profesi dirangkum singkat untuk efisiensi token.
    """
    dim_info = DIMENSION_LABELS[dimension_name]

    professions_block = ""
    for prof in profession_contexts:
        activities_str = ", ".join((prof.get("activities") or [])[:3]) or "Tidak tersedia"
        skills_str = ", ".join((prof.get("hard_skills_required") or [])[:3]) or "Tidak tersedia"
        about = (prof.get("about_description") or "")[:200]

        professions_block += f"""
- Profesi ID {prof['profession_id']}: {prof['name']}
  Deskripsi singkat: {about}
  Aktivitas utama: {activities_str}
  Skill utama: {skills_str}
"""

    return SCORING_PROMPT_TEMPLATE.format(
        dimension_label=dim_info["label"],
        dimension_description=dim_info["description"],
        user_reasoning_text=user_reasoning_text,
        professions_block=professions_block.strip()
    )
```

### 4.5 Contoh Prompt yang Sudah Terisi (Dimensi 1)

```
Kamu adalah sistem evaluasi relevansi karier. Tugasmu adalah menilai
seberapa relevan teks alasan pengguna dengan setiap profesi kandidat.

DIMENSI YANG DINILAI: What You Love (Apa yang Kamu Sukai)
(Nilai seberapa relevan teks dengan aktivitas atau aspek pekerjaan yang disukai user...)

TEKS JAWABAN PENGGUNA:
"Saya suka coding dan problem solving karena memberikan tantangan intelektual yang menarik.
Saya sering menghabiskan waktu luang untuk belajar bahasa pemrograman baru."

DAFTAR PROFESI KANDIDAT:
- Profesi ID 10: Software Engineer
  Deskripsi singkat: Software Engineer merancang, membangun, dan memelihara sistem perangkat lunak...
  Aktivitas utama: Merancang arsitektur sistem backend, Menulis dan mereview kode, Debugging
  Skill utama: Python atau Go, SQL dan pemodelan database, REST API design

- Profesi ID 25: Data Engineer
  Deskripsi singkat: Data Engineer membangun dan mengelola pipeline data...
  Aktivitas utama: Membangun ETL/ELT pipeline, Mengelola data warehouse, Optimasi query
  Skill utama: SQL lanjutan, Apache Spark, Python

- Profesi ID 31: DevOps Engineer
  Deskripsi singkat: DevOps Engineer memastikan infrastruktur berjalan mulus...
  Aktivitas utama: Membangun CI/CD pipeline, Monitoring sistem, Containerisasi
  Skill utama: Docker, Kubernetes, Linux

...
```

**Contoh response Gemini (sebelum di-parse):**

```json
[
  {"profession_id": 10, "r_raw": 0.88},
  {"profession_id": 25, "r_raw": 0.72},
  {"profession_id": 31, "r_raw": 0.55},
  {"profession_id": 15, "r_raw": 0.61},
  {"profession_id": 42, "r_raw": 0.43}
]
```

---

## Bagian 5 — Normalisasi, Kalkulasi Skor, & INSERT ikigai_dimension_scores

### 5.1 Proses Kalkulasi (Per Dimensi)

Setelah mendapat `r_raw` dari Gemini untuk semua N profesi di dimensi `d`:

**Langkah 1 — Normalisasi Min-Max:**
```python
r_values = [item["r_raw"] for item in ai_results]
r_min = min(r_values)
r_max = max(r_values)

for item in ai_results:
    if r_max > r_min:
        r_normalized = (item["r_raw"] - r_min) / (r_max - r_min)
    else:
        r_normalized = 0.5  # semua dapat skor sama → nilai netral
    item["r_normalized"] = round(r_normalized, 4)
```

**Langkah 2 — Hitung text_score dan click_score:**
```python
selected_id = ikigai_responses.dimension_X["selected_profession_id"]  # bisa null

for item in ai_results:
    # Text score: 15% × r_normalized
    item["text_score"] = round(0.15 * item["r_normalized"], 4)

    # Click score: 10% × C × R_raw  (C = 1 hanya jika profesi ini yang dipilih)
    is_selected = (selected_id is not None and item["profession_id"] == selected_id)
    item["click_score"] = round(0.10 * item["r_raw"], 4) if is_selected else 0.0

    # Dimension total
    item["dimension_total"] = round(item["text_score"] + item["click_score"], 4)
```

> **Catatan:** `click_score` menggunakan `r_raw` (bukan `r_normalized`) karena nilai ini merepresentasikan keyakinan model sebelum distorsi normalisasi. Ini adalah **confidence-based click adjustment** — klik hanya bernilai tinggi jika alasan teks memang relevan.

### 5.2 Struktur JSONB `scores_data` di `ikigai_dimension_scores`

Satu baris per sesi, INSERT sekali setelah 4 dimensi selesai. Format lengkap:

```json
{
  "dimension_scores": {
    "what_you_love": [
      {
        "profession_id": 10,
        "r_raw": 0.88,
        "r_normalized": 1.00,
        "text_score": 15.00,
        "click_score": 8.80,
        "dimension_total": 23.80
      },
      {
        "profession_id": 25,
        "r_raw": 0.72,
        "r_normalized": 0.64,
        "text_score": 9.60,
        "click_score": 0.0,
        "dimension_total": 9.60
      },
      {
        "profession_id": 31,
        "r_raw": 0.55,
        "r_normalized": 0.27,
        "text_score": 4.05,
        "click_score": 0.0,
        "dimension_total": 4.05
      }
    ],
    "what_you_are_good_at": [ ... ],
    "what_the_world_needs": [ ... ],
    "what_you_can_be_paid_for": [ ... ]
  },
  "normalization_params": {
    "what_you_love": {
      "r_min": 0.43,
      "r_max": 0.88,
      "professions_evaluated": 5
    },
    "what_you_are_good_at": {
      "r_min": 0.30,
      "r_max": 0.85,
      "professions_evaluated": 5
    },
    "what_the_world_needs": {
      "r_min": 0.25,
      "r_max": 0.80,
      "professions_evaluated": 5
    },
    "what_you_can_be_paid_for": {
      "r_min": 0.35,
      "r_max": 0.90,
      "professions_evaluated": 5
    }
  },
  "metadata": {
    "total_candidates_scored": 5,
    "scoring_strategy": "batch_semantic_matching",
    "fallback_used": false,
    "failed_dimensions": [],
    "calculated_at": "2024-12-15T10:40:00Z"
  }
}
```

**Keterangan field penting:**

| Field | Tipe | Deskripsi |
|---|---|---|
| `r_raw` | Float 0.0–1.0 | Output mentah dari Gemini sebelum normalisasi |
| `r_normalized` | Float 0.0–1.0 | Hasil normalisasi min-max. Profesi paling relevan per dimensi = 1.0 |
| `text_score` | Float 0.0–15.0 | `15% × r_normalized × 100` — komponen dari analisis teks. Skala 0–100 (sudah dikali 100 untuk human-readable) |
| `click_score` | Float 0.0–10.0 | `10% × r_raw × 100` jika profesi dipilih, `0` jika tidak. Skala 0–100 |
| `dimension_total` | Float 0.0–25.0 | `text_score + click_score` |
| `r_min`, `r_max` | Float | Parameter normalisasi per dimensi, untuk reproducibility |

### 5.3 Contoh Skenario Perhitungan Nyata

**Input:** User memilih profesi ID=10, reasoning_text cukup relevan.

Gemini return untuk dimensi `what_you_love`:
```
ID=10: r_raw=0.88  → r_normalized = (0.88-0.43)/(0.88-0.43) = 1.00
ID=25: r_raw=0.72  → r_normalized = (0.72-0.43)/(0.88-0.43) = 0.64
ID=31: r_raw=0.55  → r_normalized = (0.55-0.43)/(0.88-0.43) = 0.27
ID=15: r_raw=0.61  → r_normalized = (0.61-0.43)/(0.88-0.43) = 0.40
ID=42: r_raw=0.43  → r_normalized = (0.43-0.43)/(0.88-0.43) = 0.00
```

Kalkulasi skor (user pilih ID=10):
```
ID=10: text=15%×1.00×100=15.00, click=10%×0.88×100=8.80, total=23.80  ← profesi dipilih
ID=25: text=15%×0.64×100=9.60,  click=0,                  total=9.60
ID=31: text=15%×0.27×100=4.05,  click=0,                  total=4.05
ID=15: text=15%×0.40×100=6.00,  click=0,                  total=6.00
ID=42: text=15%×0.00×100=0.00,  click=0,                  total=0.00
```

---

## Bagian 6 — Agregasi & INSERT ikigai_total_scores

### 6.1 Proses Agregasi

Setelah `ikigai_dimension_scores` tersimpan, langsung lakukan agregasi:

```python
# Kumpulkan semua profession_id unik dari semua 4 dimensi
all_profession_ids = set()
for dim_scores in dimension_data.values():
    for s in dim_scores:
        all_profession_ids.add(s["profession_id"])

# Hitung total per profesi
profession_totals = {}
for pid in all_profession_ids:
    scores_per_dim = {}
    for dim_name in ["what_you_love", "what_you_are_good_at",
                     "what_the_world_needs", "what_you_can_be_paid_for"]:
        match = next((s for s in dimension_data[dim_name] if s["profession_id"] == pid), None)
        scores_per_dim[dim_name] = match["dimension_total"] if match else 0.0

    total = sum(scores_per_dim.values())
    intrinsic = scores_per_dim["what_you_love"] + scores_per_dim["what_you_are_good_at"]
    extrinsic = scores_per_dim["what_the_world_needs"] + scores_per_dim["what_you_can_be_paid_for"]

    profession_totals[pid] = {
        "profession_id": pid,
        "total_score": round(total, 2),
        "score_what_you_love": round(scores_per_dim["what_you_love"], 2),
        "score_what_you_are_good_at": round(scores_per_dim["what_you_are_good_at"], 2),
        "score_what_the_world_needs": round(scores_per_dim["what_the_world_needs"], 2),
        "score_what_you_can_be_paid_for": round(scores_per_dim["what_you_can_be_paid_for"], 2),
        "intrinsic_score": round(intrinsic, 2),
        "extrinsic_score": round(extrinsic, 2)
    }
```

### 6.2 Sorting & Tie-Breaking

**Sort utama:** `total_score DESC`

**Tie-breaking (berurutan, gunakan yang pertama resolve):**
1. `intrinsic_score DESC` — dimensi intrinsik (Love + Good At) lebih tinggi menang
2. `congruence_score DESC` — ambil dari `ikigai_candidate_professions.candidates_data`, profesi dengan kode RIASEC lebih identik (tier lebih rendah = `congruence_score` lebih tinggi) menang
3. `avg_r_normalized DESC` — rata-rata R_normalized dari 4 dimensi — profesi yang secara konsisten relevan semantik menang

```python
# Ambil congruence_score dari candidates_data untuk tie-breaking
candidate_map = {c["profession_id"]: c for c in candidates_data["candidates"]}

def sort_key(prof):
    pid = prof["profession_id"]
    congruence = candidate_map.get(pid, {}).get("congruence_score", 0.0)
    # Hitung avg_r_normalized dari dimension_scores
    r_vals = []
    for dim_scores in dimension_data.values():
        match = next((s for s in dim_scores if s["profession_id"] == pid), None)
        if match:
            r_vals.append(match["r_normalized"])
    avg_r = sum(r_vals) / len(r_vals) if r_vals else 0.0
    return (prof["total_score"], prof["intrinsic_score"], congruence, avg_r)

sorted_professions = sorted(profession_totals.values(), key=sort_key, reverse=True)
```

### 6.3 Struktur JSONB `scores_data` di `ikigai_total_scores`

```json
{
  "profession_scores": [
    {
      "rank": 1,
      "profession_id": 10,
      "total_score": 78.50,
      "score_what_you_love": 23.80,
      "score_what_you_are_good_at": 22.50,
      "score_what_the_world_needs": 18.20,
      "score_what_you_can_be_paid_for": 14.00,
      "intrinsic_score": 46.30,
      "extrinsic_score": 32.20
    },
    {
      "rank": 2,
      "profession_id": 25,
      "total_score": 52.30,
      "score_what_you_love": 9.60,
      "score_what_you_are_good_at": 18.00,
      "score_what_the_world_needs": 14.50,
      "score_what_you_can_be_paid_for": 10.20,
      "intrinsic_score": 27.60,
      "extrinsic_score": 24.70
    }
  ],
  "metadata": {
    "total_professions_ranked": 5,
    "tie_breaking_applied": false,
    "tie_breaking_details": null,
    "top_2_professions": [10, 25],
    "calculated_at": "2024-12-15T10:42:00Z"
  }
}
```

**Contoh dengan tie-breaking:**

```json
{
  "profession_scores": [ ... ],
  "metadata": {
    "total_professions_ranked": 5,
    "tie_breaking_applied": true,
    "tie_breaking_details": {
      "tied_professions": [10, 25],
      "tied_score": 75.00,
      "criteria_used": "intrinsic_score",
      "winner": 10,
      "winner_value": 46.30,
      "runner_up_value": 38.00
    },
    "top_2_professions": [10, 25],
    "calculated_at": "2024-12-15T10:42:00Z"
  }
}
```

**Keterangan field `profession_scores`:**

| Field | Range | Deskripsi |
|---|---|---|
| `rank` | 1–N | Peringkat berdasarkan total_score, tie-breaking sudah diterapkan |
| `total_score` | 0.0–100.0 | Jumlah 4 dimensi (maks teoritis 100%) |
| `score_*` | 0.0–25.0 | Skor per dimensi, diambil dari `dimension_total` |
| `intrinsic_score` | 0.0–50.0 | Love + Good At — representasi passion & kompetensi |
| `extrinsic_score` | 0.0–50.0 | World Needs + Paid For — representasi dampak & income |

---

## Bagian 7 — Finalisasi Sesi & UPDATE Status

### 7.1 Urutan Eksekusi Setelah Dimensi ke-4

Semua langkah di bawah ini dilakukan dalam **satu fungsi orchestrator** yang dipanggil setelah UPDATE dimensi ke-4 berhasil. Urutan eksekusi:

```
1. UPDATE ikigai_responses: set completed=true, completed_at=now()
2. Ambil semua data kandidat dari ikigai_candidate_professions
3. Ambil semua teks jawaban dari ikigai_responses (4 dimensi)
4. Query ringkasan profesi dari DB (untuk konteks scoring)
5. Jalankan 4 Gemini call (paralel jika memungkinkan via asyncio.gather)
6. Normalisasi + kalkulasi skor per dimensi
7. INSERT ikigai_dimension_scores (commit)
8. Agregasi + ranking + tie-breaking
9. INSERT ikigai_total_scores (commit)
10. UPDATE careerprofile_test_sessions: status→completed, completed_at=now()
11. UPDATE kenalidiri_history: status→completed, completed_at=now()
12. Final commit semua perubahan
13. Return response ke Flutter
```

### 7.2 Parallelisasi Gemini Calls

4 Gemini call dapat dijalankan secara paralel menggunakan `asyncio.gather` untuk efisiensi waktu:

```python
import asyncio

async def run_all_scoring(responses: dict, profession_contexts: list) -> dict:
    """Jalankan 4 Gemini call secara paralel."""
    tasks = [
        score_single_dimension("what_you_love", responses["what_you_love"], profession_contexts),
        score_single_dimension("what_you_are_good_at", responses["what_you_are_good_at"], profession_contexts),
        score_single_dimension("what_the_world_needs", responses["what_the_world_needs"], profession_contexts),
        score_single_dimension("what_you_can_be_paid_for", responses["what_you_can_be_paid_for"], profession_contexts),
    ]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    # Handle partial failure: jika salah satu dimensi gagal, gunakan fallback skor 0.5 rata
    dimension_names = ["what_you_love", "what_you_are_good_at", "what_the_world_needs", "what_you_can_be_paid_for"]
    final = {}
    for i, (dim_name, result) in enumerate(zip(dimension_names, results)):
        if isinstance(result, Exception):
            # Fallback: semua profesi dapat r_raw = 0.5
            final[dim_name] = [{"profession_id": p["profession_id"], "r_raw": 0.5}
                                for p in profession_contexts]
        else:
            final[dim_name] = result
    return final
```

---

## Bagian 8 — Model, Schema, Router, Service

### 8.1 Model SQLAlchemy

```python
# app/api/v1/categories/career_profile/models/ikigai.py
# (tambahkan di bawah IkigaiResponse yang sudah ada dari Part 1)

from sqlalchemy import Column, BigInteger, Integer, String, TIMESTAMP, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.sql import func
from app.db.base import Base


class IkigaiDimensionScores(Base):
    """
    Skor per dimensi untuk semua kandidat profesi.
    INSERT sekali setelah 4 dimensi selesai dan AI scoring batch selesai.
    Immutable — tidak pernah di-UPDATE.
    Data intermediate — dapat dihapus setelah 6–12 bulan untuk menghemat storage.
    One-to-one dengan careerprofile_test_sessions.
    """
    __tablename__ = "ikigai_dimension_scores"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )
    scores_data = Column(JSONB, nullable=False)
    calculated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    ai_model_used = Column(String(50), default="gemini-1.5-flash")
    total_api_calls = Column(Integer, default=4)

    __table_args__ = (
        CheckConstraint("total_api_calls BETWEEN 1 AND 20", name="chk_valid_api_calls"),
    )


class IkigaiTotalScores(Base):
    """
    Skor total agregasi dari 4 dimensi untuk semua kandidat profesi.
    INSERT sekali setelah agregasi selesai.
    Immutable dan PERMANEN — tidak pernah dihapus (bagian dari riwayat user).
    One-to-one dengan careerprofile_test_sessions.
    """
    __tablename__ = "ikigai_total_scores"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )
    scores_data = Column(JSONB, nullable=False)
    top_profession_1_id = Column(BigInteger, nullable=True)
    top_profession_2_id = Column(BigInteger, nullable=True)
    calculated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    __table_args__ = (
        CheckConstraint(
            "top_profession_1_id IS NULL OR top_profession_2_id IS NULL OR "
            "top_profession_1_id != top_profession_2_id",
            name="chk_different_top_professions"
        ),
    )
```

### 8.2 Schema Pydantic

```python
# app/api/v1/categories/career_profile/schemas/ikigai.py
# (tambahkan di bawah schema Part 1 yang sudah ada)

from pydantic import BaseModel, field_validator
from typing import Optional, List
from datetime import datetime


class SubmitDimensionRequest(BaseModel):
    session_token: str
    dimension_name: str          # "what_you_love" | "what_you_are_good_at" |
                                 # "what_the_world_needs" | "what_you_can_be_paid_for"
    selected_profession_id: Optional[int] = None
    selection_type: str          # "selected" | "not_selected"
    reasoning_text: str

    @field_validator("dimension_name")
    def validate_dimension(cls, v):
        valid = {"what_you_love", "what_you_are_good_at", "what_the_world_needs", "what_you_can_be_paid_for"}
        if v not in valid:
            raise ValueError(f"dimension_name tidak valid. Pilih dari: {valid}")
        return v

    @field_validator("selection_type")
    def validate_selection_type(cls, v):
        if v not in {"selected", "not_selected"}:
            raise ValueError("selection_type harus 'selected' atau 'not_selected'")
        return v

    @field_validator("reasoning_text")
    def validate_reasoning(cls, v):
        if len(v.strip()) < 10:
            raise ValueError("reasoning_text minimal 10 karakter")
        return v.strip()

    def validate_consistency(self):
        """Validasi konsistensi selected_profession_id dan selection_type."""
        if self.selected_profession_id is not None and self.selection_type != "selected":
            raise ValueError("Jika selected_profession_id diisi, selection_type harus 'selected'")
        if self.selected_profession_id is None and self.selection_type != "not_selected":
            raise ValueError("Jika selected_profession_id null, selection_type harus 'not_selected'")


class DimensionSubmitResponse(BaseModel):
    """Response untuk submit dimensi yang bukan dimensi ke-4 (belum selesai)."""
    session_token: str
    dimension_saved: str         # nama dimensi yang baru disimpan
    dimensions_completed: List[str]
    dimensions_remaining: List[str]
    all_completed: bool          # False jika masih ada dimensi yang belum dijawab
    message: str


class ProfessionScoreBreakdown(BaseModel):
    rank: int
    profession_id: int
    total_score: float
    score_what_you_love: float
    score_what_you_are_good_at: float
    score_what_the_world_needs: float
    score_what_you_can_be_paid_for: float
    intrinsic_score: float
    extrinsic_score: float


class IkigaiCompletionResponse(BaseModel):
    """Response setelah dimensi ke-4 selesai dan scoring selesai."""
    session_token: str
    status: str                              # "completed"
    top_2_professions: List[ProfessionScoreBreakdown]
    total_professions_evaluated: int
    tie_breaking_applied: bool
    calculated_at: str                       # ISO8601
    message: str
```

### 8.3 Router

```python
# app/api/v1/categories/career_profile/routers/ikigai.py
# (tambahkan endpoint baru di bawah endpoint Part 1)

from app.api.v1.categories.career_profile.schemas.ikigai import (
    SubmitDimensionRequest,
    DimensionSubmitResponse,
    IkigaiCompletionResponse
)


@router.post("/submit-dimension")
@limiter.limit("40/hour")
async def submit_dimension(
    request: Request,
    body: SubmitDimensionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Submit jawaban untuk satu dimensi Ikigai.
    Endpoint ini dipanggil hingga 4 kali (satu per dimensi).

    Jika ini adalah dimensi terakhir (ke-4):
      - Trigger AI scoring batch (4 Gemini call paralel)
      - INSERT ikigai_dimension_scores
      - INSERT ikigai_total_scores
      - UPDATE status sesi → completed
      - Return IkigaiCompletionResponse dengan top 2 profesi + breakdown skor

    Jika bukan dimensi terakhir:
      - Hanya UPDATE kolom dimensi di ikigai_responses
      - Return DimensionSubmitResponse dengan info progres

    Validasi yang dilakukan:
      - Sesi valid dan status ikigai_ongoing
      - Dimensi belum pernah dijawab sebelumnya
      - selected_profession_id konsisten dengan selection_type
      - Jika selected_profession_id diisi, ID harus ada di kandidat sesi ini
    """
    body.validate_consistency()
    service = IkigaiService(db)
    return await service.submit_dimension(
        user=current_user,
        session_token=body.session_token,
        dimension_name=body.dimension_name,
        selected_profession_id=body.selected_profession_id,
        selection_type=body.selection_type,
        reasoning_text=body.reasoning_text
    )


@router.get("/result/{session_token}", response_model=IkigaiCompletionResponse)
@limiter.limit("30/minute")
async def get_ikigai_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil hasil final Ikigai yang sudah tersimpan.
    Digunakan Flutter untuk reload halaman hasil tanpa re-scoring.
    Hanya bisa diakses jika sesi sudah completed.
    """
    service = IkigaiService(db)
    return service.get_ikigai_result(session_token=session_token, user=current_user)
```

### 8.4 Ikigai Service (Bagian Submit)

```python
# app/api/v1/categories/career_profile/services/ikigai_service.py
# (tambahkan method baru di class IkigaiService yang sudah ada)

DIMENSION_COLUMN_MAP = {
    "what_you_love": "dimension_1_love",
    "what_you_are_good_at": "dimension_2_good_at",
    "what_the_world_needs": "dimension_3_world_needs",
    "what_you_can_be_paid_for": "dimension_4_paid_for"
}

ALL_DIMENSIONS = list(DIMENSION_COLUMN_MAP.keys())


async def submit_dimension(
    self,
    user: User,
    session_token: str,
    dimension_name: str,
    selected_profession_id: Optional[int],
    selection_type: str,
    reasoning_text: str
) -> dict:
    """
    Submit jawaban satu dimensi. Jika ini dimensi ke-4, trigger full scoring pipeline.
    """
    # Validasi sesi
    session = self._validate_session_ikigai_ongoing(session_token, user)

    # Ambil row ikigai_responses
    ikigai_resp = self.db.query(IkigaiResponse).filter(
        IkigaiResponse.test_session_id == session.id
    ).first()

    if not ikigai_resp:
        raise HTTPException(status_code=404, detail="Row ikigai_responses tidak ditemukan.")

    # Cek dimensi belum pernah dijawab
    col_name = DIMENSION_COLUMN_MAP[dimension_name]
    if getattr(ikigai_resp, col_name) is not None:
        raise HTTPException(
            status_code=400,
            detail=f"Dimensi '{dimension_name}' sudah pernah dijawab dan tidak bisa diubah."
        )

    # Validasi profession_id jika diisi
    if selected_profession_id is not None:
        self._validate_profession_in_candidates(session.id, selected_profession_id)

    # UPDATE kolom dimensi
    dimension_data = {
        "selected_profession_id": selected_profession_id,
        "selection_type": selection_type,
        "reasoning_text": reasoning_text,
        "answered_at": datetime.utcnow().isoformat()
    }
    setattr(ikigai_resp, col_name, dimension_data)
    self.db.flush()

    # Cek apakah semua 4 dimensi sudah terisi
    dimensions_done = [
        d for d in ALL_DIMENSIONS
        if getattr(ikigai_resp, DIMENSION_COLUMN_MAP[d]) is not None
    ]
    dimensions_remaining = [d for d in ALL_DIMENSIONS if d not in dimensions_done]

    if not dimensions_remaining:
        # Semua 4 dimensi selesai — trigger full scoring pipeline
        ikigai_resp.completed = True
        ikigai_resp.completed_at = datetime.utcnow()
        self.db.flush()

        # Jalankan scoring pipeline (async)
        result = await self._run_scoring_pipeline(session, ikigai_resp)
        self.db.commit()
        return result
    else:
        # Belum semua selesai — simpan dan return progres
        self.db.commit()
        return {
            "session_token": session_token,
            "dimension_saved": dimension_name,
            "dimensions_completed": dimensions_done,
            "dimensions_remaining": dimensions_remaining,
            "all_completed": False,
            "message": f"Dimensi '{dimension_name}' berhasil disimpan. Sisa: {len(dimensions_remaining)} dimensi."
        }


async def _run_scoring_pipeline(
    self,
    session: CareerProfileTestSession,
    ikigai_resp: IkigaiResponse
) -> dict:
    """
    Orchestrator full scoring pipeline setelah semua 4 dimensi selesai.
    Alur: get candidates → get profession contexts → AI scoring (parallel) →
    normalize → calculate → INSERT dimension_scores → aggregate →
    INSERT total_scores → update session + history
    """
    from app.api.v1.categories.career_profile.services.ai_scoring_service import AIScoringService

    # 1. Ambil semua kandidat
    candidate_record = self.db.query(IkigaiCandidateProfession).filter(
        IkigaiCandidateProfession.test_session_id == session.id
    ).first()
    all_candidates = candidate_record.candidates_data["candidates"]
    profession_ids = [c["profession_id"] for c in all_candidates]

    # 2. Query ringkasan profesi untuk scoring context
    profession_contexts = self.profession_svc.get_profession_contexts_for_scoring(profession_ids)

    # 3. Susun teks jawaban per dimensi
    responses_text = {
        "what_you_love": ikigai_resp.dimension_1_love["reasoning_text"],
        "what_you_are_good_at": ikigai_resp.dimension_2_good_at["reasoning_text"],
        "what_the_world_needs": ikigai_resp.dimension_3_world_needs["reasoning_text"],
        "what_you_can_be_paid_for": ikigai_resp.dimension_4_paid_for["reasoning_text"]
    }

    # 4. AI scoring paralel
    ai_svc = AIScoringService()
    raw_scores, failed_dimensions = await ai_svc.score_all_dimensions(responses_text, profession_contexts)

    # 5. Normalisasi + kalkulasi
    selected_ids = {
        "what_you_love": (ikigai_resp.dimension_1_love or {}).get("selected_profession_id"),
        "what_you_are_good_at": (ikigai_resp.dimension_2_good_at or {}).get("selected_profession_id"),
        "what_the_world_needs": (ikigai_resp.dimension_3_world_needs or {}).get("selected_profession_id"),
        "what_you_can_be_paid_for": (ikigai_resp.dimension_4_paid_for or {}).get("selected_profession_id")
    }
    dimension_scores, norm_params = self._normalize_and_calculate(raw_scores, selected_ids)

    # 6. INSERT ikigai_dimension_scores
    scores_data = {
        "dimension_scores": dimension_scores,
        "normalization_params": norm_params,
        "metadata": {
            "total_candidates_scored": len(profession_ids),
            "scoring_strategy": "batch_semantic_matching",
            "fallback_used": len(failed_dimensions) > 0,
            "failed_dimensions": failed_dimensions,  # list dimensi yang pakai fallback r_raw=0.5
            "calculated_at": datetime.utcnow().isoformat()
        }
    }
    dim_score_record = IkigaiDimensionScores(
        test_session_id=session.id,
        scores_data=scores_data,
        ai_model_used="gemini-1.5-flash",
        total_api_calls=4
    )
    self.db.add(dim_score_record)
    self.db.flush()

    # 7. Agregasi → ranking → tie-breaking
    candidate_map = {c["profession_id"]: c for c in all_candidates}
    ranked = self._aggregate_and_rank(dimension_scores, candidate_map)

    # 8. INSERT ikigai_total_scores
    tie_applied = ranked["tie_breaking_applied"]
    top_scores_data = {
        "profession_scores": ranked["profession_scores"],
        "metadata": {
            "total_professions_ranked": len(ranked["profession_scores"]),
            "tie_breaking_applied": tie_applied,
            "tie_breaking_details": ranked.get("tie_breaking_details"),
            "top_2_professions": [
                ranked["profession_scores"][0]["profession_id"] if len(ranked["profession_scores"]) > 0 else None,
                ranked["profession_scores"][1]["profession_id"] if len(ranked["profession_scores"]) > 1 else None
            ],
            "calculated_at": datetime.utcnow().isoformat()
        }
    }
    top_1_id = ranked["profession_scores"][0]["profession_id"] if len(ranked["profession_scores"]) > 0 else None
    top_2_id = ranked["profession_scores"][1]["profession_id"] if len(ranked["profession_scores"]) > 1 else None

    total_score_record = IkigaiTotalScores(
        test_session_id=session.id,
        scores_data=top_scores_data,
        top_profession_1_id=top_1_id,
        top_profession_2_id=top_2_id
    )
    self.db.add(total_score_record)
    self.db.flush()

    # 9. Update status sesi + history
    session.status = "completed"
    session.completed_at = datetime.utcnow()

    from app.db.models.kenalidiri_history import KenaliDiriHistory
    history = self.db.query(KenaliDiriHistory).filter(
        KenaliDiriHistory.detail_session_id == session.id
    ).first()
    if history:
        history.status = "completed"
        history.completed_at = datetime.utcnow()

    # 10. Return hasil
    top_2 = ranked["profession_scores"][:2]
    return {
        "session_token": session.session_token,
        "status": "completed",
        "top_2_professions": top_2,
        "total_professions_evaluated": len(ranked["profession_scores"]),
        "tie_breaking_applied": tie_applied,
        "calculated_at": datetime.utcnow().isoformat(),
        "message": "Tes Ikigai selesai. 2 profesi rekomendasi utama telah ditentukan."
    }


def _normalize_and_calculate(
    self,
    raw_scores: dict,  # {dim_name: [{profession_id, r_raw}]}
    selected_ids: dict  # {dim_name: profession_id | None}
) -> tuple[dict, dict]:
    """
    Normalisasi min-max per dimensi + hitung text_score, click_score, dimension_total.
    Return: (dimension_scores_dict, normalization_params_dict)
    """
    dimension_scores = {}
    norm_params = {}

    for dim_name, scores in raw_scores.items():
        r_values = [s["r_raw"] for s in scores]
        r_min = min(r_values)
        r_max = max(r_values)
        selected_id = selected_ids.get(dim_name)

        normalized = []
        for s in scores:
            r_norm = (s["r_raw"] - r_min) / (r_max - r_min) if r_max > r_min else 0.5
            r_norm = round(r_norm, 4)

            text_score = round(0.15 * r_norm * 100, 4)   # range 0.0–15.0
            is_sel = (selected_id is not None and s["profession_id"] == selected_id)
            click_score = round(0.10 * s["r_raw"] * 100, 4) if is_sel else 0.0  # range 0.0–10.0
            dim_total = round(text_score + click_score, 4)  # range 0.0–25.0

            normalized.append({
                "profession_id": s["profession_id"],
                "r_raw": round(s["r_raw"], 4),
                "r_normalized": r_norm,
                "text_score": text_score,
                "click_score": click_score,
                "dimension_total": dim_total
            })

        dimension_scores[dim_name] = normalized
        norm_params[dim_name] = {
            "r_min": round(r_min, 4),
            "r_max": round(r_max, 4),
            "professions_evaluated": len(scores)
        }

    return dimension_scores, norm_params


def _aggregate_and_rank(
    self,
    dimension_scores: dict,
    candidate_map: dict
) -> dict:
    """
    Agregasi skor 4 dimensi per profesi → sort → tie-breaking → assign rank.
    """
    all_profession_ids = set()
    for dim_scores in dimension_scores.values():
        for s in dim_scores:
            all_profession_ids.add(s["profession_id"])

    totals = []
    for pid in all_profession_ids:
        sdim = {}
        for dim_name in ALL_DIMENSIONS:
            match = next((s for s in dimension_scores.get(dim_name, []) if s["profession_id"] == pid), None)
            sdim[dim_name] = match["dimension_total"] if match else 0.0

        total = sum(sdim.values())
        intrinsic = sdim["what_you_love"] + sdim["what_you_are_good_at"]
        extrinsic = sdim["what_the_world_needs"] + sdim["what_you_can_be_paid_for"]
        congruence = candidate_map.get(pid, {}).get("congruence_score", 0.0)

        r_vals = []
        for dim_scores_list in dimension_scores.values():
            m = next((s for s in dim_scores_list if s["profession_id"] == pid), None)
            if m:
                r_vals.append(m["r_normalized"])
        avg_r = round(sum(r_vals) / len(r_vals), 4) if r_vals else 0.0

        totals.append({
            "profession_id": pid,
            "total_score": round(total, 2),
            "score_what_you_love": round(sdim["what_you_love"], 2),
            "score_what_you_are_good_at": round(sdim["what_you_are_good_at"], 2),
            "score_what_the_world_needs": round(sdim["what_the_world_needs"], 2),
            "score_what_you_can_be_paid_for": round(sdim["what_you_can_be_paid_for"], 2),
            "intrinsic_score": round(intrinsic, 2),
            "extrinsic_score": round(extrinsic, 2),
            "_congruence": congruence,
            "_avg_r": avg_r
        })

    # Sort + tie-breaking
    totals.sort(key=lambda x: (x["total_score"], x["intrinsic_score"], x["_congruence"], x["_avg_r"]), reverse=True)

    # Cek tie dan catat detail
    tie_applied = False
    tie_details = None
    if len(totals) >= 2 and abs(totals[0]["total_score"] - totals[1]["total_score"]) < 0.01:
        tie_applied = True
        # Tentukan kriteria mana yang break tie
        if abs(totals[0]["intrinsic_score"] - totals[1]["intrinsic_score"]) >= 0.01:
            criteria = "intrinsic_score"
            winner_val = totals[0]["intrinsic_score"]
            runner_val = totals[1]["intrinsic_score"]
        elif abs(totals[0]["_congruence"] - totals[1]["_congruence"]) >= 0.001:
            criteria = "congruence_score"
            winner_val = totals[0]["_congruence"]
            runner_val = totals[1]["_congruence"]
        else:
            criteria = "avg_r_normalized"
            winner_val = totals[0]["_avg_r"]
            runner_val = totals[1]["_avg_r"]

        tie_details = {
            "tied_professions": [totals[0]["profession_id"], totals[1]["profession_id"]],
            "tied_score": totals[0]["total_score"],
            "criteria_used": criteria,
            "winner": totals[0]["profession_id"],
            "winner_value": winner_val,
            "runner_up_value": runner_val
        }

    # Assign rank dan bersihkan field internal
    ranked = []
    for i, t in enumerate(totals):
        t["rank"] = i + 1
        t.pop("_congruence", None)
        t.pop("_avg_r", None)
        ranked.append(t)

    return {
        "profession_scores": ranked,
        "tie_breaking_applied": tie_applied,
        "tie_breaking_details": tie_details
    }
```

### 8.5 AI Scoring Service

```python
# app/api/v1/categories/career_profile/services/ai_scoring_service.py
"""
AIScoringService — Wrapper Gemini untuk penilaian relevansi teks per dimensi.
Berbeda dari AIContentService (generate narasi), service ini menghasilkan skor numerik.
"""
import json
import asyncio
import httpx
from typing import List, Dict
from app.core.config import settings
from app.api.v1.categories.career_profile.prompts.ikigai_prompts import (
    build_scoring_prompt
)


class AIScoringService:

    async def score_single_dimension(
        self,
        dimension_name: str,
        user_reasoning_text: str,
        profession_contexts: List[dict]
    ) -> List[dict]:
        """
        Panggil Gemini untuk menilai relevansi teks user terhadap semua profesi di 1 dimensi.
        Return: [{profession_id: int, r_raw: float}, ...]
        """
        prompt = build_scoring_prompt(dimension_name, user_reasoning_text, profession_contexts)

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                url=f"{settings.OPENROUTER_BASE_URL}/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": settings.OPENROUTER_MODEL,
                    "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": 800,
                    "temperature": 0.2   # Rendah untuk konsistensi penilaian numerik
                }
            )

        raw_text = response.json()["choices"][0]["message"]["content"].strip()

        # Strip markdown fences jika ada
        if raw_text.startswith("```"):
            raw_text = raw_text.split("```")[1]
            if raw_text.startswith("json"):
                raw_text = raw_text[4:]
            raw_text = raw_text.rsplit("```", 1)[0].strip()

        results = json.loads(raw_text)

        # Validasi dan clamp nilai r_raw ke [0.0, 1.0]
        validated = []
        for item in results:
            r = max(0.0, min(1.0, float(item["r_raw"])))
            validated.append({"profession_id": item["profession_id"], "r_raw": round(r, 4)})
        return validated

    async def score_all_dimensions(
        self,
        responses_text: Dict[str, str],
        profession_contexts: List[dict]
    ) -> tuple[Dict[str, List[dict]], List[str]]:
        """
        Jalankan 4 Gemini call secara paralel.
        Return: (scores_per_dimension, failed_dimensions)
        failed_dimensions berisi nama dimensi yang gagal dan pakai fallback r_raw=0.5.
        """
        dim_names = list(responses_text.keys())
        tasks = [
            self.score_single_dimension(dim, responses_text[dim], profession_contexts)
            for dim in dim_names
        ]

        results = await asyncio.gather(*tasks, return_exceptions=True)

        final = {}
        failed_dimensions = []
        for dim_name, result in zip(dim_names, results):
            if isinstance(result, Exception):
                # Fallback: semua profesi dapat r_raw = 0.5 (skor netral)
                # Dimensi ini dicatat di failed_dimensions agar bisa diaudit
                final[dim_name] = [
                    {"profession_id": p["profession_id"], "r_raw": 0.5}
                    for p in profession_contexts
                ]
                failed_dimensions.append(dim_name)
            else:
                final[dim_name] = result

        return final, failed_dimensions
```

---

## Bagian 9 — Alur Data Lengkap (Visual)

```
[Kondisi Awal — dari Part 1]
  careerprofile_test_sessions.status = "ikigai_ongoing"
  ikigai_responses: row ada, semua 4 dimensi = NULL
  ikigai_candidate_professions: 1–30 profesi tersimpan

        ↓ Flutter panggil POST /career-profile/ikigai/submit-dimension (dimensi 1)

[Submit Dimensi 1]
  Validasi: sesi valid, dimensi 1 belum dijawab, konsistensi ID & type
  UPDATE dimension_1_love → {selected_profession_id, selection_type, reasoning_text, answered_at}
  Return: dimensions_completed=[love], dimensions_remaining=[good_at, world, paid]

        ↓ Flutter panggil lagi untuk dimensi 2, 3 (sama)
        ↓ Flutter panggil POST /ikigai/submit-dimension (dimensi 4 — TERAKHIR)

[Submit Dimensi 4 — Trigger Scoring Pipeline]
  UPDATE dimension_4_paid_for
  SET ikigai_responses.completed=true, completed_at=now()

        ↓

[AI Scoring Batch — Paralel]
  Query ringkasan profesi (nama + aktivitas + skill) untuk semua N kandidat
  asyncio.gather():
    Call 1: Gemini ← dimension_1 text + N profesi → [{profession_id, r_raw}, ...]
    Call 2: Gemini ← dimension_2 text + N profesi → [{profession_id, r_raw}, ...]
    Call 3: Gemini ← dimension_3 text + N profesi → [{profession_id, r_raw}, ...]
    Call 4: Gemini ← dimension_4 text + N profesi → [{profession_id, r_raw}, ...]
  Jika satu call gagal → fallback r_raw = 0.5 untuk semua profesi di dimensi itu

        ↓

[Normalisasi & Kalkulasi — Per Dimensi]
  Untuk tiap dimensi:
    r_min = min(r_raw), r_max = max(r_raw)
    r_normalized = (r_raw - r_min) / (r_max - r_min)  [0.5 jika r_max == r_min]
    text_score = 15% × r_normalized
    click_score = 10% × r_raw  (hanya profesi yang dipilih, 0 jika tidak dipilih)
    dimension_total = text_score + click_score

        ↓

[INSERT ikigai_dimension_scores]
  scores_data JSONB: dimension_scores per dimensi + normalization_params + metadata
  COMMIT

        ↓

[Agregasi Per Profesi]
  Untuk tiap profession_id: jumlah dimension_total dari 4 dimensi
  Hitung intrinsic = love + good_at
  Hitung extrinsic = world + paid
  Sort: total_score DESC → tie-breaking (intrinsic → congruence → avg_r)

        ↓

[INSERT ikigai_total_scores]
  scores_data JSONB: ranked profession_scores + metadata tie-breaking
  top_profession_1_id, top_profession_2_id (denormalisasi)
  COMMIT

        ↓

[Finalisasi]
  UPDATE careerprofile_test_sessions → status: completed, completed_at: now()
  UPDATE kenalidiri_history → status: completed, completed_at: now()
  COMMIT

        ↓

[Return ke Flutter]
  {
    session_token,
    status: "completed",
    top_2_professions: [rank1, rank2] dengan breakdown skor per dimensi,
    total_professions_evaluated,
    tie_breaking_applied,
    calculated_at
  }
```

---

## Bagian 10 — Ringkasan File yang Dibuat / Dimodifikasi

| File | Status | Keterangan |
|---|---|---|
| `app/api/v1/categories/career_profile/models/ikigai.py` | **Modifikasi** | Tambah model `IkigaiDimensionScores` + `IkigaiTotalScores` |
| `app/api/v1/categories/career_profile/schemas/ikigai.py` | **Modifikasi** | Tambah `SubmitDimensionRequest`, `DimensionSubmitResponse`, `IkigaiCompletionResponse` |
| `app/api/v1/categories/career_profile/routers/ikigai.py` | **Modifikasi** | Tambah endpoint `/submit-dimension` + `/result/{token}` |
| `app/api/v1/categories/career_profile/services/ikigai_service.py` | **Modifikasi** | Tambah method `submit_dimension`, `_run_scoring_pipeline`, `_normalize_and_calculate`, `_aggregate_and_rank` |
| `app/api/v1/categories/career_profile/services/ai_scoring_service.py` | **Baru** | AI scoring wrapper: `score_single_dimension` + `score_all_dimensions` |
| `app/api/v1/categories/career_profile/services/profession_data_service.py` | **Modifikasi** | Tambah method `get_profession_contexts_for_scoring()` — versi ringkas untuk scoring |
| `app/api/v1/categories/career_profile/prompts/ikigai_prompts.py` | **Modifikasi** | Tambah `SCORING_PROMPT_TEMPLATE`, `DIMENSION_LABELS`, `build_scoring_prompt()` |

---

## Bagian 11 — Daftar Endpoint Ikigai Part 2

| Method | Endpoint | Auth | Rate Limit | Deskripsi |
|---|---|---|---|---|
| `POST` | `/api/v1/career-profile/ikigai/submit-dimension` | ✅ | 40/jam | Submit jawaban satu dimensi. Dipanggil 4 kali. Jika dimensi ke-4: trigger full scoring → return top 2 profesi |
| `GET` | `/api/v1/career-profile/ikigai/result/{session_token}` | ✅ | 30/menit | Ambil hasil Ikigai yang sudah tersimpan. Hanya bisa diakses jika sesi `completed` |

---

## Catatan Kelanjutan — Brief Ikigai Part 3

Brief Ikigai Part 3 akan mencakup tahap akhir alur RECOMMENDATION:

- **Generate narasi rekomendasi final** — setelah top 2 profesi ditentukan, Gemini dipanggil sekali lagi untuk menghasilkan teks penjelasan kecocokan per profesi. Narasi ini bersifat personal: menggunakan jawaban user dari `ikigai_responses` sebagai konteks, bukan generik. Contoh output: *"Kamu cocok dengan profesi ini karena kamu secara konsisten menyebutkan ketertarikan terhadap sistem dan logika di 3 dari 4 dimensi, dengan alasan yang spesifik dan berbasis pengalaman nyata."*
- **Penyimpanan narasi** — hasil generate disimpan ke tabel `career_recommendations` (satu baris per sesi, immutable) yang akan didefinisikan di Part 3
- **Response final ke Flutter** — top 2 profesi + breakdown skor + narasi kecocokan + profil Ikigai per dimensi, siap ditampilkan di halaman hasil

Item teknis lain yang perlu diselesaikan sebelum production:
- **Alembic migration** — tabel `ikigai_dimension_scores` dan `ikigai_total_scores` harus dibuat via Alembic migration, bukan DDL manual
- **Retake protection** — prevent user memulai sesi baru jika ada sesi `ikigai_ongoing` yang belum selesai, tambahkan di `session_service.py`
- **Halaman hasil FIT_CHECK** — perbandingan kode RIASEC user vs kode RIASEC profesi target, dibahas di brief FIT_CHECK Result yang terpisah

*Brief ini siap diimplementasikan dan konsisten dengan Brief RIASEC dan Ikigai Part 1 yang sudah ada.*