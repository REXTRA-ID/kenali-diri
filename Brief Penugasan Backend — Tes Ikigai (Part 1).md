---
title: Brief Penugasan Backend — Tes Ikigai (Part 1)

---

# Brief Penugasan Backend — Tes Ikigai (Part 1)
## Fase: Penentuan Kandidat Profesi & Penyiapan Konten Dimensi

**Engineer:** Ariel — AI Engineer Rextra
**Scope:** Ikigai Part 1 — berlaku eksklusif untuk alur `RECOMMENDATION`
**Kelanjutan dari:** Brief RIASEC (Part 1 sebelumnya)
**Database:** PostgreSQL (shared dengan Golang CRUD system)
**Stack:** FastAPI + SQLAlchemy + Alembic + Redis + Prometheus + Google Gemini (via OpenRouter)
**Versi Brief:** 1.0

---

## Daftar Isi

1. [Konteks & Posisi Brief Ini dalam Alur Keseluruhan](#1-konteks--posisi-brief-ini-dalam-alur-keseluruhan)
2. [Bagian 0 — Rekap Proses Akhir RIASEC & Titik Handoff](#bagian-0--rekap-proses-akhir-riasec--titik-handoff)
3. [Bagian 1 — Kandidat Profesi: Definisi, Dua Tipe, dan Mekanisme Ekspansi](#bagian-1--kandidat-profesi-definisi-dua-tipe-dan-mekanisme-ekspansi)
4. [Bagian 2 — Sumber Data Profesi untuk Konteks AI](#bagian-2--sumber-data-profesi-untuk-konteks-ai)
5. [Bagian 3 — Inisiasi Sesi Ikigai (Endpoint & INSERT Awal)](#bagian-3--inisiasi-sesi-ikigai-endpoint--insert-awal)
6. [Bagian 4 — Penyiapan Konten Dimensi: Arsitektur & Mekanisme](#bagian-4--penyiapan-konten-dimensi-arsitektur--mekanisme)
7. [Bagian 5 — Prompt Engineering: Template Generate Narasi 4 Dimensi](#bagian-5--prompt-engineering-template-generate-narasi-4-dimensi)
8. [Bagian 6 — Model, Schema, Router, Service](#bagian-6--model-schema-router-service)
9. [Bagian 7 — Alur Data Lengkap (Visual)](#bagian-7--alur-data-lengkap-visual)
10. [Bagian 8 — Ringkasan File yang Dibuat / Dimodifikasi](#bagian-8--ringkasan-file-yang-dibuat--dimodifikasi)
11. [Bagian 9 — Daftar Endpoint Ikigai Part 1](#bagian-9--daftar-endpoint-ikigai-part-1)

---

## 1. Konteks & Posisi Brief Ini dalam Alur Keseluruhan

Brief ini adalah **kelanjutan langsung** dari Brief RIASEC (Part 1) dan menangani dua tanggung jawab utama:

1. **Konfirmasi bahwa `ikigai_candidate_professions` telah selesai di-INSERT** pada akhir fase RIASEC (sudah dikerjakan di Brief sebelumnya), serta penjelasan bagaimana data tersebut dikonsumsi pada fase Ikigai.
2. **Penyiapan konten dimensi** — yaitu proses mengambil data profesi dari database, menggunakannya sebagai konteks untuk AI (Gemini), dan men-generate narasi deskriptif yang akan ditampilkan sebagai **teks opsi pilihan user** di setiap dimensi Ikigai sebelum user mulai menjawab.

### Posisi dalam Pipeline Keseluruhan

```
[RIASEC Selesai] ✅
    └── ikigai_candidate_professions sudah ter-INSERT (Brief RIASEC)
    └── Kode RIASEC user tersimpan di riasec_results

[IKIGAI PART 1 — Brief Ini] 🔵
    ├── Inisiasi sesi Ikigai (INSERT ikigai_responses row kosong)
    ├── Query data lengkap profesi kandidat dari DB
    ├── Generate narasi 4 dimensi via Gemini API (konten opsi UI)
    └── Return konten opsi ke Flutter untuk ditampilkan

[IKIGAI PART 2 — Brief Berikutnya] ⬜
    ├── User submit jawaban per dimensi (UPDATE ikigai_responses)
    ├── AI scoring (INSERT ikigai_dimension_scores)
    ├── Agregasi skor (INSERT ikigai_total_scores)
    └── Generate rekomendasi naratif (INSERT career_recommendations)
```

> **Catatan Ruang Lingkup:** Brief ini **TIDAK** mencakup proses submit jawaban user, AI scoring, agregasi, maupun `career_recommendations`. Semua hal tersebut dibahas di Brief Ikigai Part 2.

---

## Bagian 0 — Rekap Proses Akhir RIASEC & Titik Handoff

### 0.1 Apa yang Terjadi saat User Submit Soal Terakhir RIASEC

Ketika user menekan tombol **Submit** pada halaman terakhir soal RIASEC, backend FastAPI menjalankan serangkaian proses dalam satu transaksi atomik. Proses ini mencakup **scoring**, **klasifikasi**, dan **persiapan kandidat profesi untuk Ikigai**. Berikut urutan lengkapnya:

**Langkah 1 — Validasi & Simpan Jawaban**
Semua 12 jawaban user diterima sekaligus (bukan per halaman). Jawaban divalidasi terhadap `question_ids` yang tersimpan di `riasec_question_sets`, lalu di-INSERT ke tabel `riasec_responses`.

**Langkah 2 — Hitung Skor per Tipe**
Sistem menghitung skor mentah untuk setiap 6 tipe RIASEC (R, I, A, S, E, C) berdasarkan jawaban user. Setiap tipe memiliki 2 pertanyaan dengan skala 1–5, sehingga rentang skor per tipe adalah 2–10.

**Langkah 3 — Klasifikasi Kode RIASEC**
Berdasarkan skor, sistem menentukan kode RIASEC user (1, 2, atau 3 huruf) menggunakan algoritma klasifikasi yang sudah didefinisikan di Brief RIASEC. Klasifikasi ini menghasilkan:
- `riasec_code` — kode string, contoh: `"RIA"`
- `riasec_code_id` — FK ke tabel master `riasec_codes`
- `riasec_code_type` — `single`, `dual`, atau `triple`
- `is_inconsistent_profile` — flag untuk profil yang tidak terdefinisi jelas

**Langkah 4 — INSERT `riasec_results`**
Seluruh hasil scoring dan klasifikasi disimpan ke tabel `riasec_results`. Kolom `riasec_code_id` di tabel ini adalah FK ke `riasec_codes.id` dan menjadi referensi utama untuk tahap selanjutnya.

**Langkah 5 — Ekspansi & INSERT `ikigai_candidate_professions`**
Langsung setelah `riasec_results` tersimpan, sistem menjalankan algoritma ekspansi 4-tier untuk menghasilkan daftar kandidat profesi. Hasilnya di-INSERT ke `ikigai_candidate_professions` sebagai JSONB immutable. Penjelasan lengkap algoritma ekspansi ada di Bagian 1.

**Langkah 6 — UPDATE Status Sesi**
`careerprofile_test_sessions.status` diubah dari `riasec_ongoing` → `riasec_completed` dan kolom `riasec_completed_at` diisi dengan timestamp saat ini.

### 0.2 Kondisi Database setelah RIASEC Selesai

Tabel-tabel berikut sudah tersimpan dan siap dikonsumsi oleh fase Ikigai:

| Tabel | Status | Data Relevan untuk Ikigai |
|---|---|---|
| `careerprofile_test_sessions` | `status = riasec_completed` | `session_token`, `user_id`, `uses_ikigai = true` |
| `riasec_question_sets` | Tersimpan | Tidak digunakan di Ikigai |
| `riasec_responses` | Tersimpan | Tidak digunakan di Ikigai |
| `riasec_results` | **Tersimpan** | `riasec_code_id`, `riasec_code_type`, skor R/I/A/S/E/C |
| `ikigai_candidate_professions` | **Tersimpan** | `candidates_data` (JSONB, 5–30 profesi) |
| `kenalidiri_history` | `status = ongoing` | Tidak diubah sampai Ikigai selesai |

Data yang dikonsumsi oleh fase Ikigai dari hasil RIASEC:

```
riasec_results.riasec_code_id               → konteks kepribadian user untuk AI
ikigai_candidate_professions.candidates_data → daftar profession_id kandidat
```

**Contoh baris `riasec_results` yang sudah tersimpan:**

```json
{
  "id": 301,
  "test_session_id": 1042,
  "score_r": 9,
  "score_i": 8,
  "score_a": 7,
  "score_s": 4,
  "score_e": 3,
  "score_c": 2,
  "riasec_code_id": 10,
  "riasec_code_type": "triple",
  "is_inconsistent_profile": false,
  "created_at": "2025-06-01T08:22:14Z"
}
```

**Contoh baris `ikigai_candidate_professions` yang sudah tersimpan (kolom `candidates_data`):**

```json
{
  "candidates": [
    {
      "profession_id": 10,
      "riasec_code_id": 10,
      "expansion_tier": 1,
      "congruence_type": "exact_match",
      "congruence_score": 1.0,
      "display_order": 1
    },
    {
      "profession_id": 25,
      "riasec_code_id": 49,
      "expansion_tier": 2,
      "congruence_type": "congruent_permutation",
      "congruence_score": 0.93,
      "display_order": 2
    },
    {
      "profession_id": 31,
      "riasec_code_id": 7,
      "expansion_tier": 2,
      "congruence_type": "congruent_adjacent",
      "congruence_score": 0.87,
      "display_order": 3
    },
    {
      "profession_id": 15,
      "riasec_code_id": 55,
      "expansion_tier": 3,
      "congruence_type": "subset_adjacent",
      "congruence_score": 0.76,
      "display_order": 4
    },
    {
      "profession_id": 42,
      "riasec_code_id": 33,
      "expansion_tier": 3,
      "congruence_type": "subset_alternate",
      "congruence_score": 0.68,
      "display_order": 5
    },
    {
      "profession_id": 8,
      "riasec_code_id": 2,
      "expansion_tier": 4,
      "congruence_type": "dominant_single",
      "congruence_score": 0.55,
      "display_order": 6
    }
  ],
  "metadata": {
    "total_candidates": 6,
    "user_riasec_code_id": 10,
    "user_riasec_code": "RIA",
    "user_riasec_classification_type": "triple",
    "user_riasec_scores": {
      "R": 9, "I": 8, "A": 7, "S": 4, "E": 3, "C": 2
    },
    "is_inconsistent_profile": false,
    "expansion_strategy": "4_tier_expansion",
    "split_path_strategy": false,
    "expansion_summary": {
      "tier_1_exact": 1,
      "tier_2_congruent": 2,
      "tier_3_subset": 2,
      "tier_4_dominant": 1
    },
    "congruent_code_ids": [10, 49, 7, 55, 33, 2],
    "display_count": 5,
    "generated_at": "2025-06-01T08:22:15Z"
  }
}
```

> Dari contoh di atas, profesi dengan `display_order` 1–5 (profession_id: 10, 25, 31, 15, 42) akan menjadi **Kandidat Opsi** yang tampil di UI dan di-generate narasi dimensinya. Profesi dengan `display_order` 6 (profession_id: 8) masuk ke **Kandidat Pool** — ikut AI scoring batch di Part 2, tidak tampil di UI.

---

## Bagian 1 — Kandidat Profesi: Definisi, Dua Tipe, dan Mekanisme Ekspansi

### 1.1 Apa itu Kandidat Profesi?

Kandidat profesi adalah **daftar profesi yang dipilih secara algoritmis** berdasarkan kode RIASEC user, yang akan menjadi subjek evaluasi sepanjang Tes Ikigai. Daftar ini dihasilkan satu kali di akhir proses RIASEC dan disimpan secara permanen di tabel `ikigai_candidate_professions` sebagai data immutable — tidak ada perubahan pada daftar ini selama sesi Ikigai berlangsung.

Jumlah kandidat berkisar antara **1 hingga 30 profesi**, bergantung pada ketersediaan data profesi di database dan hasil ekspansi bertingkat. Constraint database menggunakan `CHECK (total_candidates BETWEEN 1 AND 30)` untuk mengakomodasi kondisi data yang masih berkembang di fase development. Validasi minimum ideal (5 profesi) dilakukan di level service sebagai warning log, bukan hard error.

### 1.2 Dua Tipe Kandidat: Opsi UI dan Pool Skor

Seluruh kandidat dalam daftar terbagi menjadi dua tipe berdasarkan fungsinya dalam alur Ikigai:

**Tipe 1 — Kandidat Opsi (Displayed Candidates)**

Kandidat opsi adalah profesi yang **ditampilkan sebagai pilihan klik** kepada user di setiap soal dimensi Ikigai. User dapat memilih satu dari opsi ini atau memilih untuk tidak memilih dan langsung mengisi teks alasan. Jumlah kandidat opsi adalah **5 profesi teratas** berdasarkan urutan `display_order` (nilai 1 sampai 5). Kandidat-kandidat ini berasal dari tier ekspansi dengan kongruensi tertinggi terhadap profil RIASEC user, sehingga merupakan yang paling relevan secara kepribadian.

Untuk kandidat opsi inilah backend men-generate narasi konten dimensi via Gemini — teks deskriptif per dimensi yang menjelaskan relevansi profesi tersebut dari sudut pandang "Love", "Good At", "World Needs", dan "Paid For". Proses generate ini adalah inti dari brief ini.

**Tipe 2 — Kandidat Pool (Background Scoring Candidates)**

Kandidat pool adalah profesi-profesi di luar 5 opsi tampil, dengan `display_order > 5`. Profesi-profesi ini **tidak muncul sebagai tombol pilihan** di UI, namun tetap diikutsertakan dalam proses AI scoring batch yang terjadi setelah user menyelesaikan semua 4 dimensi (dibahas di Brief Part 2).

Fungsi utama kandidat pool adalah menjadi **referensi komparasi dalam scoring**: ketika user tidak memilih salah satu dari 5 opsi dan hanya mengisi teks alasan bebas, AI scoring mengevaluasi teks tersebut terhadap **seluruh kandidat** — baik 5 opsi maupun semua kandidat pool — untuk menemukan profesi yang paling sesuai secara semantik dengan alasan yang diberikan user. Dengan demikian, kandidat pool mencegah sistem melewatkan profesi yang mungkin sangat sesuai meskipun tidak sempat ditampilkan sebagai opsi.

| | Kandidat Opsi | Kandidat Pool |
|---|---|---|
| **`display_order`** | 1 – 5 | 6 – 30 |
| **Tampil di UI** | ✅ Ya — sebagai tombol pilihan | ❌ Tidak |
| **Narasi dimensi di-generate** | ✅ Ya — via Gemini sebelum soal dimulai | ❌ Tidak |
| **Ikut AI scoring batch** | ✅ Ya | ✅ Ya |
| **Sumber ekspansi** | Tier 1 & 2 (kongruensi tertinggi) | Tier 2, 3, & 4 (sisa ekspansi) |

### 1.3 Mekanisme Ekspansi Kandidat: 4-Tier Expansion

Daftar kandidat dihasilkan oleh algoritma ekspansi bertahap dari Tier 1 hingga Tier 4. Ekspansi berhenti ketika jumlah kandidat sudah mencapai batas optimal (15 profesi) atau batas maksimum (30 profesi). Proses ini dijalankan di akhir fase RIASEC, bukan saat Ikigai dimulai.

Setiap tier berikutnya hanya dieksekusi jika jumlah kandidat yang terkumpul masih di bawah 3 profesi.

**Tabel Urutan Ekspansi Kandidat**

| Tier | Sumber Kode | Aturan Pengambilan | Contoh (Kode User: RIA) | Rentang `congruence_score` |
|---|---|---|---|---|
| **1** | Exact match | Ambil profesi dengan kode RIASEC identik persis dengan kode user | `RIA` | 1.0 |
| **2** | Congruent codes | Jika kandidat < 3, tambahkan profesi dari permutasi 3 huruf yang sama dan kode bersebelahan di heksagon Holland. **Hanya berlaku jika kode user bertipe `triple`.** | `RAI`, `IRA`, `IAR`, `ARI`, `AIR` (permutasi); kode bersebelahan | 0.85 – 0.95 |
| **3** | Subset codes | Jika kandidat < 3, tambahkan profesi dari kombinasi huruf yang dibentuk dari kode utama user | `RI`, `RA`, `IA` (jika triple) / `R`, `I` (jika dual) | 0.65 – 0.80 |
| **4** | Dominant single | Jika kandidat < 3, tambahkan profesi berbasis huruf dominan tunggal (huruf pertama kode user) | `R` | 0.50 – 0.65 |

**Perilaku per Tipe Kode User**

Cara kerja ekspansi berbeda tergantung tipe kode RIASEC user (`riasec_code_type`):

| Tipe Kode | Contoh | Tier 2 | Tier 3 menghasilkan | Tier 4 |
|---|---|---|---|---|
| `triple` | `RIA` | Dieksekusi — permutasi + adjacent | Kombinasi 2 huruf: `RI`, `RA`, `IA` | `R` |
| `dual` | `RI` | Dilewati | Huruf tunggal: `R`, `I` | Sama dengan Tier 3 — tidak ada efek tambahan |
| `single` | `R` | Dilewati | Tidak ada subset yang bisa dibentuk | Sama dengan Tier 1 — tidak ada efek tambahan |

Untuk kode `single`, jika Tier 1 sudah menemukan cukup profesi (≥ 3), ekspansi selesai. Jika tidak cukup, sistem tetap mencoba Tier 4 (dominant single) yang hasilnya identik dengan Tier 1, sehingga tidak menambah kandidat baru. Kondisi ini dicatat di `expansion_summary` tanpa menyebabkan error.

**Penentuan `display_order`**

Setelah seluruh kandidat terkumpul, diurutkan dengan tiga level prioritas:
1. `expansion_tier ASC` — tier lebih rendah = kongruensi lebih tinggi
2. `congruence_score DESC` — jika tier sama, skor kongruensi lebih tinggi tampil duluan
3. Urutan Holland ASC (`R=1, I=2, A=3, S=4, E=5, C=6`) — tie-breaker ketiga jika skor identik, berdasarkan urutan default psikometrik

Nilai `display_order` diisi dari 1 hingga n. Lima profesi dengan `display_order` 1–5 menjadi **Kandidat Opsi** yang tampil di UI.

**Penanganan Profil Inkonsisten (`is_inconsistent_profile = true`)**

Profil inkonsisten terjadi ketika dua huruf dominan saling berlawanan secara psikologis di heksagon Holland (misalnya R–S, I–E, A–C). Untuk kondisi ini, sistem menerapkan *Split-Path Strategy*:

- Alih-alih mencari profesi berkode gabungan (misal `RS`), sistem membangun **dua cluster kandidat terpisah**.
- Cluster A: ekspansi berbasis huruf pertama dan adjacent-nya (misal `R` → cari `R`, `RI`, `RC`).
- Cluster B: ekspansi berbasis huruf kedua dan adjacent-nya (misal `S` → cari `S`, `SA`, `SE`).
- Kedua cluster digabung, dideduplikasi, lalu diurutkan `display_order` seperti biasa.

Untuk konten dimensi di Brief Part 1 ini, tidak ada perlakuan khusus — narasi Gemini bersifat general per profesi, bukan spesifik ke profil user. Yang memerlukan penanganan berbeda adalah narasi rekomendasi akhir di Part 2.

Satu field perlu ditambahkan di `candidates_data.metadata`:

```json
"split_path_strategy": true
```

Field ini digunakan oleh Part 2 untuk tahu bahwa pendekatan narasi rekomendasi perlu mengakomodasi dua arah eksplorasi berbeda.

**Skenario Jumlah Kandidat**

*Skenario A — Total Kandidat < 5*

Terjadi ketika data profesi di database belum lengkap (umum di fase development). Semua kandidat menjadi Kandidat Opsi dan seluruhnya di-generate narasi dimensinya. Tidak ada Kandidat Pool. Sistem mencatat warning log tapi tidak menggagalkan proses — sesi tetap berjalan normal.

*Skenario B — Total Kandidat 5 sampai 30*

Skenario normal production. Lima profesi teratas (`display_order` 1–5) menjadi Kandidat Opsi. Sisanya menjadi Kandidat Pool yang ikut AI scoring batch di Part 2.

### 1.4 Struktur JSONB `candidates_data`

Setiap baris di `ikigai_candidate_professions` menyimpan satu kolom JSONB `candidates_data` dengan struktur berikut. Data ini bersifat **immutable** setelah di-INSERT — tidak ada field dinamis seperti status pemilihan atau jumlah klik yang disimpan di sini.

```json
{
  "candidates": [
    {
      "profession_id": 10,
      "riasec_code_id": 10,
      "expansion_tier": 1,
      "congruence_type": "exact_match",
      "congruence_score": 1.0,
      "display_order": 1
    },
    {
      "profession_id": 25,
      "riasec_code_id": 49,
      "expansion_tier": 2,
      "congruence_type": "congruent_permutation",
      "congruence_score": 0.95,
      "display_order": 2
    },
    {
      "profession_id": 15,
      "riasec_code_id": 7,
      "expansion_tier": 3,
      "congruence_type": "subset_adjacent",
      "congruence_score": 0.75,
      "display_order": 6
    }
  ],
  "metadata": {
    "total_candidates": 12,
    "user_riasec_code_id": 10,
    "user_riasec_code": "RIA",
    "user_riasec_classification_type": "triple",
    "user_riasec_scores": {"R": 45, "I": 42, "A": 38, "S": 25, "E": 22, "C": 20},
    "is_inconsistent_profile": false,
    "expansion_strategy": "4_tier_expansion",
    "split_path_strategy": false,
    "expansion_summary": {
      "tier_1_exact": 2,
      "tier_2_congruent": 4,
      "tier_3_subset": 4,
      "tier_4_dominant": 2
    },
    "congruent_code_ids": [10, 15, 7, 49, 69, 60],
    "display_count": 5,
    "generated_at": "2025-01-15T10:00:00Z"
  }
}
```

**Penjelasan field `congruence_type`:**

| Nilai | Asal Tier | Keterangan |
|---|---|---|
| `exact_match` | Tier 1 | Kode identik persis dengan kode user |
| `congruent_permutation` | Tier 2 | Permutasi 3 huruf yang sama (misalnya RAI dari RIA) |
| `congruent_adjacent` | Tier 2 | Kode bersebelahan di heksagon Holland |
| `subset_adjacent` | Tier 3 | 2 huruf bersebelahan dari kode user (misalnya RI dari RIA) |
| `subset_alternate` | Tier 3 | 2 huruf tidak bersebelahan dari kode user (misalnya RA dari RIA — melewati I) |
| `dominant_single` | Tier 4 | Hanya huruf dominan/pertama dari kode user |

---

## Bagian 2 — Sumber Data Profesi untuk Konteks AI

Ini adalah inti dari brief ini. AI membutuhkan **konteks deskriptif yang kaya** tentang setiap profesi kandidat agar dapat men-generate narasi opsi yang relevan per dimensi. Seluruh konteks ini diambil dari tabel-tabel berelasi di bawah tabel `professions`.

### 2.1 Peta Relasi Tabel yang Digunakan

```
professions (tabel inti)
    ├── profession_activities       (aktivitas kerja harian)
    ├── profession_market_insights  (kondisi pasar kerja)
    ├── profession_career_paths     (jenjang karier + rentang gaji)
    ├── profession_skill_rel ──► skills (hard skill + soft skill)
    ├── profession_tool_rel  ──► tools  (alat dan teknologi)
    └── riasec_codes                (profil kepribadian RIASEC profesi)
```

### 2.2 Field yang Di-query per Tabel

```sql
-- Query utama untuk mengambil konteks profesi
-- Dijalankan untuk SETIAP profession_id di daftar kandidat (display_order <= 5)

SELECT
  p.id,
  p.name,
  p.about_description,
  p.riasec_description,

  -- Kode RIASEC profesi (dari riasec_codes master)
  rc.riasec_code,
  rc.riasec_title,
  rc.strengths,        -- JSONB array: kekuatan kepribadian yang cocok
  rc.work_environments, -- JSONB array: lingkungan kerja yang sesuai

  -- Aktivitas kerja (urut sort_order)
  (
    SELECT json_agg(pa.description ORDER BY pa.sort_order)
    FROM profession_activities pa
    WHERE pa.profession_id = p.id
  ) AS activities,

  -- Hard skills wajib (prioritas "wajib", tipe "hard")
  (
    SELECT json_agg(s.name)
    FROM profession_skill_rel psr
    JOIN skills s ON s.id = psr.skill_id
    WHERE psr.profession_id = p.id
      AND psr.skill_type = 'hard'
      AND psr.priority = 'wajib'
  ) AS hard_skills_required,

  -- Soft skills wajib
  (
    SELECT json_agg(s.name)
    FROM profession_skill_rel psr
    JOIN skills s ON s.id = psr.skill_id
    WHERE psr.profession_id = p.id
      AND psr.skill_type = 'soft'
      AND psr.priority = 'wajib'
  ) AS soft_skills_required,

  -- Tools utama (wajib)
  (
    SELECT json_agg(t.name)
    FROM profession_tool_rel ptr
    JOIN tools t ON t.id = ptr.tool_id
    WHERE ptr.profession_id = p.id
      AND ptr.usage_type = 'wajib'
  ) AS tools_required,

  -- Market insight (3 poin pertama saja, urut sort_order)
  (
    SELECT json_agg(pmi.description ORDER BY pmi.sort_order)
    FROM (
      SELECT description, sort_order
      FROM profession_market_insights
      WHERE profession_id = p.id
      ORDER BY sort_order
      LIMIT 3
    ) pmi
  ) AS market_insights,

  -- Rentang gaji entry-level (career path dengan sort_order terendah)
  (
    SELECT json_build_object(
      'title', pcp.title,
      'experience_range', pcp.experience_range,
      'salary_min', pcp.salary_min,
      'salary_max', pcp.salary_max
    )
    FROM profession_career_paths pcp
    WHERE pcp.profession_id = p.id
    ORDER BY pcp.sort_order ASC
    LIMIT 1
  ) AS entry_level_path,

  -- Level senior (career path dengan sort_order tertinggi)
  (
    SELECT json_build_object(
      'title', pcp.title,
      'experience_range', pcp.experience_range,
      'salary_min', pcp.salary_min,
      'salary_max', pcp.salary_max
    )
    FROM profession_career_paths pcp
    WHERE pcp.profession_id = p.id
    ORDER BY pcp.sort_order DESC
    LIMIT 1
  ) AS senior_level_path

FROM professions p
LEFT JOIN riasec_codes rc ON rc.id = p.riasec_code_id
WHERE p.id = ANY(:profession_ids)  -- bind parameter: array of int
```

### 2.3 Struktur Data Profesi yang Dikirim ke AI

Setelah query di atas, data setiap profesi dikemas menjadi objek Python berikut sebelum diinjeksikan ke prompt. Di bawah ini skema tipenya diikuti contoh data nyata untuk satu profesi:

**Skema tipe:**

```python
ProfessionContext = {
    "profession_id": int,
    "name": str,                        # "Software Engineer"
    "about_description": str | None,    # Deskripsi umum profesi
    "riasec_description": str | None,   # Penjelasan kecocokan kepribadian
    "riasec_code": str,                 # "RIA"
    "riasec_title": str,                # "Realistic–Investigative–Artistic"
    "work_environments": list[str],     # ["Tech-Forward", "Problem-Solving Culture"]
    "activities": list[str],            # ["Merancang arsitektur sistem", ...]
    "hard_skills_required": list[str],  # ["Python", "SQL", "System Design"]
    "soft_skills_required": list[str],  # ["Analytical Thinking", "Communication"]
    "tools_required": list[str],        # ["VSCode", "Git", "Docker"]
    "market_insights": list[str],       # ["Permintaan tinggi di industri fintech", ...]
    "entry_level_path": {
        "title": str,                   # "Junior Software Engineer"
        "experience_range": str,        # "0–2 tahun"
        "salary_min": int | None,       # 8000000
        "salary_max": int | None        # 12000000
    },
    "senior_level_path": {
        "title": str,                   # "Staff Engineer"
        "experience_range": str,        # "7+ tahun"
        "salary_min": int | None,
        "salary_max": int | None
    }
}
```

**Contoh data nyata untuk profession_id 10 (Software Engineer):**

```json
{
  "profession_id": 10,
  "name": "Software Engineer",
  "about_description": "Software Engineer merancang, membangun, dan memelihara sistem perangkat lunak yang mendukung berbagai layanan digital. Peran ini mencakup pengembangan backend, frontend, maupun full-stack tergantung spesialisasi.",
  "riasec_description": "Profesi ini sangat cocok untuk individu dengan kode RIA — mereka yang senang membangun sistem konkret (R), berpikir analitis dalam memecahkan masalah teknis kompleks (I), dan menuangkan kreativitas dalam desain solusi (A).",
  "riasec_code": "RIA",
  "riasec_title": "Realistic–Investigative–Artistic",
  "work_environments": [
    "Tech-Forward Culture",
    "Problem-Solving Environment",
    "Agile & Iterative Workflow",
    "Deep Work Friendly"
  ],
  "activities": [
    "Merancang arsitektur sistem backend dan mendefinisikan struktur database",
    "Menulis dan mereview kode dalam sprint dua mingguan",
    "Melakukan debugging dan profiling performa aplikasi",
    "Berkolaborasi dengan product manager untuk menerjemahkan kebutuhan bisnis ke spesifikasi teknis",
    "Menulis dokumentasi teknis dan unit test"
  ],
  "hard_skills_required": [
    "Python atau Go",
    "SQL dan pemodelan database relasional",
    "REST API design",
    "Git & version control",
    "Dasar-dasar sistem terdistribusi"
  ],
  "soft_skills_required": [
    "Analytical thinking",
    "Komunikasi teknis yang jelas",
    "Kemampuan belajar mandiri"
  ],
  "tools_required": [
    "VSCode atau JetBrains IDE",
    "Git / GitHub",
    "Docker",
    "PostgreSQL",
    "Postman"
  ],
  "market_insights": [
    "Permintaan Software Engineer di Indonesia tumbuh 23% YoY berdasarkan data LinkedIn 2024",
    "Fintech, e-commerce, dan healthtech adalah sektor dengan penyerapan tertinggi",
    "Remote work opportunity sangat tinggi — lebih dari 60% posisi menawarkan opsi hybrid atau full remote"
  ],
  "entry_level_path": {
    "title": "Junior Software Engineer",
    "experience_range": "0–2 tahun",
    "salary_min": 8000000,
    "salary_max": 12000000
  },
  "senior_level_path": {
    "title": "Senior Software Engineer",
    "experience_range": "5+ tahun",
    "salary_min": 25000000,
    "salary_max": 45000000
  }
}
```

---

## Bagian 3 — Inisiasi Sesi Ikigai (Endpoint & INSERT Awal)

### 3.1 Trigger Inisiasi

Inisiasi Ikigai dipicu oleh Flutter segera setelah halaman hasil RIASEC ditampilkan dan user menekan tombol **"Mulai Tes Ikigai"**. Ini adalah endpoint yang mempersiapkan segala sesuatunya sebelum soal dimensi pertama ditampilkan.

### 3.2 Apa yang Terjadi di Endpoint Ini

Dalam **satu transaksi atomik**:

1. Validasi sesi: token valid, status `riasec_completed`, `uses_ikigai = true`
2. UPDATE `careerprofile_test_sessions.status` → `ikigai_ongoing`
3. INSERT `ikigai_responses` (satu baris kosong — diisi bertahap per dimensi)
4. Query data lengkap profesi kandidat (Bagian 2)
5. Generate narasi konten dimensi via Gemini API (Bagian 5)
6. Cache hasil generate di Redis (Bagian 4)
7. Return konten opsi ke Flutter

### 3.3 Model `ikigai_responses`

```python
# app/api/v1/categories/career_profile/models/ikigai.py

from sqlalchemy import Column, BigInteger, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import TIMESTAMP
from sqlalchemy.sql import func
from app.db.base import Base

class IkigaiResponse(Base):
    """
    Menyimpan jawaban user untuk 4 dimensi Ikigai.
    Row di-INSERT saat user mulai Ikigai (kosong/placeholder).
    Diisi bertahap per dimensi via UPDATE.
    One-to-one dengan careerprofile_test_sessions.
    """
    __tablename__ = "ikigai_responses"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )

    # Format per kolom dimensi (identik):
    # {
    #   "selected_profession_id": int | null,
    #   "selection_type": "selected" | "not_selected",
    #   "reasoning_text": str,
    #   "answered_at": "ISO8601"
    # }
    # NULL saat baru di-INSERT, diisi via UPDATE per dimensi
    dimension_1_love        = Column(JSONB, nullable=True)
    dimension_2_good_at     = Column(JSONB, nullable=True)
    dimension_3_world_needs = Column(JSONB, nullable=True)
    dimension_4_paid_for    = Column(JSONB, nullable=True)

    completed    = Column(Boolean, nullable=False, default=False)
    created_at   = Column(TIMESTAMP(timezone=True), server_default=func.now())
    completed_at = Column(TIMESTAMP(timezone=True), nullable=True)
```

**Contoh isi baris `ikigai_responses` saat baru di-INSERT (semua dimensi NULL):**

```json
{
  "id": 88,
  "test_session_id": 1042,
  "dimension_1_love": null,
  "dimension_2_good_at": null,
  "dimension_3_world_needs": null,
  "dimension_4_paid_for": null,
  "completed": false,
  "created_at": "2025-06-01T08:25:00Z",
  "completed_at": null
}
```

**Contoh isi baris `ikigai_responses` setelah user selesai mengisi semua dimensi (diisi di Brief Part 2):**

```json
{
  "id": 88,
  "test_session_id": 1042,
  "dimension_1_love": {
    "selected_profession_id": 10,
    "selection_type": "selected",
    "reasoning_text": "Saya suka membangun sistem dari nol dan melihat hasilnya dipakai banyak orang.",
    "answered_at": "2025-06-01T08:27:11Z"
  },
  "dimension_2_good_at": {
    "selected_profession_id": 10,
    "selection_type": "selected",
    "reasoning_text": "Saya cukup kuat di logika pemrograman dan problem solving struktural.",
    "answered_at": "2025-06-01T08:29:03Z"
  },
  "dimension_3_world_needs": {
    "selected_profession_id": null,
    "selection_type": "not_selected",
    "reasoning_text": "Dunia butuh orang yang bisa membuat teknologi lebih mudah diakses semua kalangan, bukan hanya yang melek teknologi.",
    "answered_at": "2025-06-01T08:31:44Z"
  },
  "dimension_4_paid_for": {
    "selected_profession_id": 25,
    "selection_type": "selected",
    "reasoning_text": "Data engineer sepertinya menawarkan kompensasi lebih baik untuk skill yang saya punya sekarang.",
    "answered_at": "2025-06-01T08:33:20Z"
  },
  "completed": true,
  "created_at": "2025-06-01T08:25:00Z",
  "completed_at": "2025-06-01T08:33:20Z"
}
```

> `selection_type: "not_selected"` berarti user tidak memilih profesi dari opsi yang tampil dan langsung mengisi teks alasan bebas. Dalam kondisi ini `selected_profession_id` bernilai `null`. Teks di `reasoning_text` tetap ada dan dipakai oleh AI scoring batch di Part 2 untuk mencocokkan ke seluruh kandidat pool.

---

## Bagian 4 — Penyiapan Konten Dimensi: Arsitektur & Mekanisme

### 4.1 Apa itu "Konten Opsi Dimensi"?

Setiap soal Ikigai menampilkan daftar profesi kandidat sebagai pilihan klik. Selain nama profesi, Flutter membutuhkan **teks deskriptif singkat per profesi per dimensi** — yaitu narasi yang menjelaskan *mengapa profesi tersebut relevan untuk dimensi tersebut*.

**Contoh tampilan di UI:**

```
Dimensi 1 — "Apa yang Kamu Sukai?"

[ ✓ Software Engineer ]
  "Pekerjaan ini memungkinkan kamu mengeksplorasi ide teknis secara mendalam,
   membangun sistem dari nol, dan terus bereksperimen dengan teknologi baru."

[ ○ Data Analyst ]
  "Profesi ini cocok jika kamu menikmati menemukan pola tersembunyi dalam data
   dan mengubahnya menjadi insight yang bermakna."
```

Teks di dalam kotak itulah yang dimaksud **konten opsi dimensi** — dan inilah yang di-generate AI di brief ini.

**Profesi mana yang masuk ke proses generate ini?**

Penentu utamanya adalah field `display_order` di dalam JSONB `candidates_data` pada tabel `ikigai_candidate_professions`. Sistem membaca array `candidates` dari JSONB tersebut, memfilter hanya entri dengan `display_order <= 5`, mengambil `profession_id` dari entri-entri itu, lalu `profession_id` itulah yang di-query ke database untuk mengambil data lengkap profesi dan dikirimkan ke Gemini sebagai input generate narasi dimensi. Tidak ada profesi lain yang masuk ke proses generate — hanya profesi dengan `display_order` 1 sampai 5 (atau semua profesi jika total kandidat kurang dari 5).

### 4.2 Mekanisme Penyimpanan Konten

Konten opsi di-generate **sekali** saat endpoint `POST /ikigai/start` dipanggil. Setelah berhasil di-generate:

- Disimpan di **Redis** dengan key `ikigai_content:{session_token}` dan TTL 2 jam
- Sekaligus di-return langsung ke Flutter dalam response `/start`
- Flutter menyimpan konten ini di state lokal selama sesi berlangsung
- Jika Flutter perlu reload konten (misalnya app di-kill lalu dibuka lagi), endpoint `GET /ikigai/content/{session_token}` mengambil ulang dari Redis; jika cache sudah expired tapi sesi masih aktif, konten di-generate ulang otomatis

---

**A. File `app/core/redis.py`**

Buat file ini jika belum ada. Jika sudah ada, cukup tambahkan fungsi `get_redis_client()` dan `close_redis_client()` di bawah.

```python
# app/core/redis.py

import logging
import redis
from redis.exceptions import ConnectionError, TimeoutError, RedisError
from app.core.config import settings

logger = logging.getLogger(__name__)

_redis_client: redis.Redis | None = None


def get_redis_client() -> redis.Redis | None:
    """
    Mengembalikan Redis client singleton.
    Mengembalikan None jika koneksi gagal — caller harus handle None.

    Digunakan di IkigaiService untuk cache konten dimensi.
    """
    global _redis_client

    if _redis_client is not None:
        return _redis_client

    try:
        client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            password=settings.REDIS_PASSWORD if settings.REDIS_PASSWORD else None,
            db=0,
            decode_responses=True,
            socket_connect_timeout=3,   # timeout koneksi awal: 3 detik
            socket_timeout=3,           # timeout operasi read/write: 3 detik
            retry_on_timeout=False      # jangan retry otomatis — kita handle manual
        )
        # Ping untuk verifikasi koneksi sebelum disimpan ke singleton
        client.ping()
        _redis_client = client
        logger.info("Redis client berhasil terhubung ke %s:%s", settings.REDIS_HOST, settings.REDIS_PORT)
    except (ConnectionError, TimeoutError) as e:
        logger.warning(
            "Tidak dapat terhubung ke Redis (%s:%s): %s. "
            "Fitur caching Ikigai akan berjalan dalam degraded mode.",
            settings.REDIS_HOST, settings.REDIS_PORT, str(e)
        )
        _redis_client = None
    except RedisError as e:
        logger.warning("Redis error saat inisialisasi: %s. Caching dinonaktifkan.", str(e))
        _redis_client = None

    return _redis_client


def close_redis_client() -> None:
    """Tutup koneksi Redis. Dipanggil saat aplikasi shutdown."""
    global _redis_client
    if _redis_client is not None:
        try:
            _redis_client.close()
        except RedisError:
            pass
        finally:
            _redis_client = None
            logger.info("Redis client ditutup.")
```

Daftarkan `close_redis_client` di lifecycle FastAPI di `main.py`:

```python
# app/main.py (tambahkan bagian lifespan atau on_event shutdown)

from app.core.redis import close_redis_client

@app.on_event("shutdown")
async def shutdown_event():
    close_redis_client()
```

---

**B. Variabel di `.env`**

Tambahkan tiga variabel berikut ke file `.env`. Isi sesuai konfigurasi Redis yang dipakai:

```
REDIS_HOST=# isi dengan host Redis kamu
REDIS_PORT=# isi dengan port Redis (default 6379)
REDIS_PASSWORD=# isi dengan password Redis kamu (kosongkan jika tidak ada password)
```

---

**C. Tambahan di `app/core/config.py`**

Tambahkan field Redis ke class `Settings` yang sudah ada. Sesuaikan nama class dan import dengan yang sudah ada di proyek:

```python
# app/core/config.py  (bagian yang perlu ditambahkan ke class Settings)

from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # ... field yang sudah ada ...

    # Redis
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: Optional[str] = None  # None jika Redis tanpa password

    class Config:
        env_file = ".env"
        extra = "ignore"   # abaikan variabel .env yang tidak terdaftar di Settings
```

`REDIS_HOST` dan `REDIS_PORT` memiliki default value aman (`localhost:6379`) sehingga aplikasi tetap bisa start meskipun variabel `.env` belum diisi — Redis hanya akan gagal saat pertama kali `get_redis_client()` dipanggil, dan kegagalan tersebut sudah ditangani dengan graceful degradation.

---

**D. Cara Setup Redis di VPS (Ubuntu/Debian)**

Jalankan perintah berikut di VPS secara berurutan:

```bash
# 1. Install Redis
sudo apt update
sudo apt install -y redis-server

# 2. Verifikasi Redis sudah jalan
sudo systemctl status redis-server
# Harusnya tampil: Active: active (running)

# Tes koneksi manual
redis-cli ping
# Output: PONG

# 3. Set password Redis
# Buka file konfigurasi
sudo nano /etc/redis/redis.conf

# Cari baris: # requirepass foobared
# Uncomment dan ganti dengan password kamu, contoh:
#   requirepass namapasswordkamu
# Simpan file (Ctrl+X → Y → Enter)

# 4. Restart Redis agar password aktif
sudo systemctl restart redis-server

# 5. Verifikasi password sudah aktif
redis-cli
# Di dalam redis-cli:
AUTH namapasswordkamu
# Output: OK

# Keluar dari redis-cli
exit

# 6. Pastikan Redis auto-start saat VPS reboot
sudo systemctl enable redis-server

# 7. (Opsional) Cek port Redis sedang listen
sudo ss -tlnp | grep 6379
# Harusnya tampil: LISTEN ... 127.0.0.1:6379
```

Setelah setup selesai, isi `.env` dengan nilai yang sesuai:

```
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=namapasswordkamu
```

> Jika Redis diakses dari host yang sama dengan aplikasi FastAPI (VPS yang sama), gunakan `127.0.0.1` sebagai host, bukan IP publik. Ini lebih aman karena Redis tidak perlu terekspos ke jaringan luar.

---

**E. Operasi Redis yang Dipakai di Service**

Hanya dua operasi yang digunakan di `IkigaiService`:

```python
from redis.exceptions import RedisError

redis_client = get_redis_client()

# Simpan konten dengan TTL 2 jam (saat /start berhasil)
if redis_client:
    try:
        redis_client.setex(
            name=f"ikigai_content:{session_token}",
            time=7200,  # detik
            value=json.dumps(content_dict)
        )
    except RedisError as e:
        logger.warning("Gagal cache konten Ikigai ke Redis: %s", str(e))
        # Tidak raise — konten sudah di-return ke Flutter, caching optional

# Ambil konten (saat /content/{token} dipanggil)
cached = None
if redis_client:
    try:
        cached = redis_client.get(f"ikigai_content:{session_token}")
    except RedisError as e:
        logger.warning("Gagal ambil konten Ikigai dari Redis: %s", str(e))
        # cached tetap None — fallback ke regenerate

# cached = None jika key tidak ada, sudah expired, atau Redis error
```

**Penanganan jika Redis Down**

Jika `get_redis_client()` mengembalikan `None` (koneksi gagal saat startup), semua operasi Redis di-skip secara otomatis karena ada pengecekan `if redis_client`. Sesi Ikigai tetap berjalan normal — konten di-generate dan di-return ke Flutter. Hanya endpoint `/content/{token}` yang tidak bisa digunakan untuk reload karena tidak ada cache. Kondisi ini tercatat di warning log.

**Penanganan jika Redis Expired (Cache Miss di `/content`)**

Jika user memanggil `GET /content/{session_token}` dan cache sudah expired (lebih dari 2 jam tidak aktif), sistem **menge-generate ulang konten** selama sesi masih `ikigai_ongoing` dan row `ikigai_responses` masih ada. Alur generate ulang identik dengan `/start`, namun tanpa mengubah status sesi atau membuat row `ikigai_responses` baru. Response menyertakan `"regenerated": true` untuk keperluan monitoring.

### 4.3 Struktur Data Konten yang Di-generate

```python
IkigaiDimensionContent = {
    "session_token": str,
    "generated_at": str,         # ISO8601
    "regenerated": bool,         # false saat pertama, true saat regenerate
    "candidates_with_content": [
        {
            "profession_id": int,
            "profession_name": str,
            "display_order": int,
            "congruence_score": float,
            "dimension_content": {
                "what_you_love": str,        # Narasi 2 kalimat
                "what_you_are_good_at": str, # Narasi 2 kalimat
                "what_the_world_needs": str, # Narasi 2 kalimat
                "what_you_can_be_paid_for": str  # Narasi 2 kalimat
            }
        }
        # ... semua kandidat opsi (display_order 1–5 atau semua jika < 5)
    ]
}
```

**Contoh data nyata yang di-return endpoint `/start` dan disimpan ke Redis:**

```json
{
  "session_token": "sess_abc123xyz",
  "status": "ikigai_ongoing",
  "generated_at": "2025-06-01T08:25:03Z",
  "regenerated": false,
  "total_display_candidates": 5,
  "message": "Sesi Ikigai berhasil dimulai. Tampilkan profesi kandidat beserta narasi dimensinya kepada user.",
  "candidates_with_content": [
    {
      "profession_id": 10,
      "profession_name": "Software Engineer",
      "display_order": 1,
      "congruence_score": 1.0,
      "dimension_content": {
        "what_you_love": "Kamu bisa menghabiskan waktu membangun sistem dari nol dan melihat langsung bagaimana hasil kerjamu berdampak pada pengalaman jutaan pengguna. Setiap tantangan teknis adalah teka-teki baru yang memberi kepuasan tersendiri ketika berhasil dipecahkan.",
        "what_you_are_good_at": "Kemampuan berpikir logis dan sistematis terus diasah di sini, mulai dari merancang arsitektur backend hingga mengoptimalkan performa sistem secara menyeluruh. Python, SQL, dan pemahaman mendalam tentang struktur data adalah fondasi yang kamu kuasai dan terus kembangkan.",
        "what_the_world_needs": "Di era digital, setiap layanan dan platform bergantung pada sistem yang stabil dan skalabel — itulah yang kamu bangun setiap harinya. Kontribusimu langsung berdampak pada keandalan layanan yang digunakan jutaan orang.",
        "what_you_can_be_paid_for": "Bidang ini menawarkan jalur karier yang jelas, mulai dari tahap awal dengan gaji Rp 8–12 juta per bulan hingga level senior yang bisa menembus Rp 25–45 juta seiring pengalaman yang berkembang. Permintaan pasar yang konsisten tinggi menjadikan ini salah satu bidang dengan stabilitas karier terbaik."
      }
    },
    {
      "profession_id": 25,
      "profession_name": "Data Engineer",
      "display_order": 2,
      "congruence_score": 0.93,
      "dimension_content": {
        "what_you_love": "Membangun pipeline data yang andal dan melihat data mentah berubah menjadi aset yang bisa dipakai tim lain untuk mengambil keputusan adalah kepuasan tersendiri di bidang ini. Tantangan skala dan keandalan sistem membuatnya tidak pernah membosankan.",
        "what_you_are_good_at": "Keahlian dalam SQL, pemrosesan data skala besar, dan orkestrasi pipeline menjadi nilai utama yang terus berkembang dalam peran ini. Pemikiran sistematis dan kemampuan debugging data flow adalah fondasi yang paling diasah setiap harinya.",
        "what_the_world_needs": "Keputusan bisnis yang baik hanya bisa dibuat jika datanya bersih, terpercaya, dan tersedia tepat waktu — itulah masalah yang kamu selesaikan. Peran ini menjadi tulang punggung tim data di hampir semua industri yang berbasis data.",
        "what_you_can_be_paid_for": "Spesialisasi ini termasuk yang paling dicari di pasar saat ini, dengan kompensasi mulai dari Rp 10–15 juta di level awal dan bisa tumbuh ke Rp 30–50 juta di level senior. Ekosistem cloud yang berkembang pesat terus membuka peluang baru."
      }
    },
    {
      "profession_id": 31,
      "profession_name": "DevOps Engineer",
      "display_order": 3,
      "congruence_score": 0.87,
      "dimension_content": {
        "what_you_love": "Memastikan sistem berjalan mulus 24/7 dan membangun infrastruktur yang bisa dipercaya tim engineering adalah tantangan yang menarik bagi mereka yang menyukai kontrol penuh atas ekosistem teknologi. Otomasi proses manual memberikan kepuasan tersendiri setiap kali pipeline berhasil dijalankan.",
        "what_you_are_good_at": "Kemampuan dalam containerisasi, CI/CD pipeline, dan monitoring sistem menjadi keahlian inti yang terus dibutuhkan. Kombinasi pemahaman infrastructure dan mindset engineering membuat peran ini cocok untuk mereka yang kuat di sisi teknis operasional.",
        "what_the_world_needs": "Setiap produk digital membutuhkan infrastruktur yang andal agar bisa melayani penggunanya tanpa gangguan — itulah yang kamu jaga setiap hari. Semakin banyak perusahaan beralih ke cloud dan microservices, semakin krusial keberadaan peran ini.",
        "what_you_can_be_paid_for": "Permintaan DevOps Engineer terus tumbuh seiring adopsi cloud di industri, dengan gaji awal Rp 10–14 juta yang bisa berkembang ke Rp 28–45 juta di level senior. Sertifikasi cloud (AWS, GCP, Azure) dapat mempercepat pertumbuhan karier secara signifikan."
      }
    },
    {
      "profession_id": 15,
      "profession_name": "Backend Developer",
      "display_order": 4,
      "congruence_score": 0.76,
      "dimension_content": {
        "what_you_love": "Membangun logika bisnis yang kompleks dan memastikan semua bagian sistem berkomunikasi dengan efisien adalah inti dari peran ini. Tantangan performa, keamanan, dan skalabilitas memberikan variasi masalah menarik untuk diselesaikan setiap harinya.",
        "what_you_are_good_at": "Kemampuan dalam pemrograman server-side, pengelolaan database, dan desain API menjadi keahlian utama yang terus diasah. Pola pikir yang berorientasi pada efisiensi dan keandalan sistem adalah karakter kuat yang dibutuhkan di sini.",
        "what_the_world_needs": "Hampir semua aplikasi digital membutuhkan backend yang handal untuk memproses data dan melayani jutaan permintaan setiap detiknya. Peran ini adalah fondasi tak terlihat yang menentukan apakah sebuah produk bisa berfungsi atau tidak.",
        "what_you_can_be_paid_for": "Peran ini menawarkan kompensasi yang kompetitif, mulai dari Rp 8–12 juta di awal karier hingga Rp 22–40 juta di level senior dengan spesialisasi yang kuat. Keahlian di bidang ini sangat portabel ke berbagai industri dan ukuran perusahaan."
      }
    },
    {
      "profession_id": 42,
      "profession_name": "Mobile Developer",
      "display_order": 5,
      "congruence_score": 0.68,
      "dimension_content": {
        "what_you_love": "Membangun pengalaman yang langsung dirasakan pengguna di genggaman mereka — dari animasi halus hingga performa yang responsif — adalah tantangan kreatif-teknis yang unik di bidang ini. Melihat aplikasi yang kamu bangun diunduh dan digunakan ribuan orang memberikan kepuasan nyata.",
        "what_you_are_good_at": "Kemampuan dalam Flutter, Swift, atau Kotlin dipadukan dengan pemahaman UX dan performa mobile menjadi kombinasi keahlian yang sangat dicari. Kepekaan terhadap detail visual dan kemampuan debugging di environment yang terbatas adalah kekuatan utama yang diasah di sini.",
        "what_the_world_needs": "Lebih dari 70% akses internet di Asia Tenggara terjadi melalui perangkat mobile — artinya setiap layanan digital pada akhirnya membutuhkan pengalaman mobile yang baik. Peran ini berada di garis depan yang paling langsung menyentuh kehidupan pengguna.",
        "what_you_can_be_paid_for": "Spesialisasi mobile menawarkan gaji mulai dari Rp 8–13 juta di level junior hingga Rp 25–40 juta di level senior, dengan peluang freelance dan remote yang sangat terbuka lebar. Keahlian cross-platform seperti Flutter semakin meningkatkan nilai tawar di pasar."
      }
    }
  ]
}
```

### 4.4 Jumlah API Call ke Gemini

Seluruh profesi kandidat opsi diproses dalam **1 API call** ke Gemini per sesi. Gemini diminta return JSON array terstruktur dengan satu objek per profesi. Ini berlaku baik untuk generate pertama maupun regenerate.

> Ini berbeda dari AI scoring di Brief Part 2 yang menggunakan **4 API call** (1 per dimensi, batch semua kandidat).

---

## Bagian 5 — Prompt Engineering: Template Generate Narasi 4 Dimensi

### 5.1 Prinsip Desain Prompt

| Prinsip | Implementasi |
|---|---|
| **General, bukan spesifik ke user** | Prompt tidak menyertakan identitas atau jawaban user (belum ada di tahap ini) |
| **Kontekstual per dimensi** | Setiap dimensi memiliki framing pertanyaan yang berbeda dalam prompt |
| **Konsisten per profesi** | Semua 4 dimensi untuk satu profesi di-generate dalam satu blok |
| **Terstruktur (JSON output)** | Gemini diminta return JSON ketat agar mudah di-parse backend |
| **Berbahasa Indonesia** | Narasi dalam Bahasa Indonesia, gaya informal-profesional (sesuai tone produk) |
| **Singkat dan padat** | 2 kalimat per dimensi per profesi (sekitar 25–40 kata) |

### 5.2 Input Prompt: Variabel yang Diinjeksikan dari Database

Sebelum prompt dikirim ke Gemini, backend mengambil dan mengisi variabel berikut dari hasil query Bagian 2:

```python
PROMPT_VARIABLES = {
    # Dari riasec_codes (profesi, bukan user)
    "profession_name": str,
    "profession_riasec_code": str,
    "profession_riasec_title": str,
    "profession_about": str,
    "profession_riasec_description": str,
    "profession_work_environments": list[str],
    "profession_activities": list[str],
    "profession_hard_skills": list[str],
    "profession_soft_skills": list[str],
    "profession_tools": list[str],
    "profession_market_insights": list[str],
    "entry_level_salary_range": str,  # "Rp 8–12 juta/bulan"
    "senior_level_title": str,        # "Staff Engineer"
    "senior_level_salary_range": str, # "Rp 25–40 juta/bulan"
}
```

### 5.3 Template Prompt Lengkap

```python
IKIGAI_DIMENSION_CONTENT_PROMPT = """
Kamu adalah sistem backend yang membantu menghasilkan teks deskriptif singkat
untuk fitur tes Ikigai dalam aplikasi pengembangan karier.

KONTEKS PROFESI:
Nama Profesi: {profession_name}
Kode RIASEC: {profession_riasec_code} ({profession_riasec_title})
Deskripsi Umum: {profession_about}
Kecocokan Kepribadian: {profession_riasec_description}
Lingkungan Kerja: {profession_work_environments}
Aktivitas Kerja Utama: {profession_activities}
Hard Skill Wajib: {profession_hard_skills}
Soft Skill Wajib: {profession_soft_skills}
Tools Utama: {profession_tools}
Kondisi Pasar: {profession_market_insights}
Karier Awal: {entry_level_salary_range}
Karier Senior: {senior_level_title} — {senior_level_salary_range}

TUGAS:
Hasilkan narasi singkat (tepat 2 kalimat per dimensi) untuk profesi di atas,
dari sudut pandang 4 dimensi Ikigai berikut:

1. **what_you_love** (Apa yang Kamu Sukai):
   Jelaskan aspek pekerjaan ini yang membuat seseorang bisa jatuh cinta atau
   terus termotivasi — aktivitas, eksplorasi, atau tantangan yang menyenangkan.
   JANGAN menyebut nama profesi di kalimat. Fokus pada esensi aktivitasnya.

2. **what_you_are_good_at** (Apa yang Kamu Kuasai):
   Jelaskan kemampuan dan keahlian apa yang dibutuhkan dan diasah dalam profesi ini,
   sehingga seseorang yang memilikinya akan merasa kompeten dan terus berkembang.
   Cantumkan 1–2 hard skill atau soft skill yang paling relevan.

3. **what_the_world_needs** (Apa yang Dibutuhkan Dunia):
   Jelaskan nilai dan dampak pekerjaan ini bagi masyarakat, industri, atau
   pengguna yang dilayani. Tekankan relevansi sosial dan ekonomi profesi ini.

4. **what_you_can_be_paid_for** (Apa yang Bisa Dibayar):
   Jelaskan prospek ekonomi dan peluang finansial profesi ini secara realistis.
   Sebutkan rentang gaji entry atau growth trajectory jika relevan.

ATURAN OUTPUT:
- Kembalikan HANYA JSON valid, tidak ada teks tambahan sebelum atau sesudah JSON
- Setiap dimensi: tepat 2 kalimat, 25–40 kata
- Bahasa Indonesia, gaya profesional tapi personal (gunakan "kamu")
- JANGAN menyebut nama profesi, nama jabatan (termasuk jabatan senior seperti "Staff Engineer", "Senior Analyst"), maupun istilah yang secara langsung mengidentifikasi profesi tersebut. Fokus pada aktivitas, dampak, dan pengalaman kerja secara generik.
- JANGAN menggunakan kata "profesi ini" berulang — variasikan kalimat
- Format output yang diharapkan:

{{
  "what_you_love": "...",
  "what_you_are_good_at": "...",
  "what_the_world_needs": "...",
  "what_you_can_be_paid_for": "..."
}}
"""
```

### 5.4 Contoh Output yang Diharapkan untuk "Software Engineer"

```json
{
  "what_you_love": "Kamu bisa menghabiskan waktu membangun sistem dari nol dan melihat langsung bagaimana kode yang kamu tulis berjalan di tangan jutaan pengguna. Setiap tantangan teknis adalah teka-teki baru yang memberi kepuasan tersendiri ketika berhasil dipecahkan.",

  "what_you_are_good_at": "Kemampuan berpikir logis dan sistematis akan terus diasah di sini, mulai dari merancang arsitektur backend hingga mengoptimalkan performa sistem. Python, SQL, dan pemahaman mendalam tentang data structure adalah fondasi yang kamu kuasai dan terus kembangkan.",

  "what_the_world_needs": "Di era digital, setiap layanan dan platform bergantung pada sistem yang stabil dan skalabel — itulah apa yang kamu bangun. Kontribusimu langsung berdampak pada keandalan layanan yang digunakan jutaan orang setiap harinya.",

  "what_you_can_be_paid_for": "Bidang ini menawarkan jalur karier yang jelas, mulai dari tahap awal dengan gaji Rp 8–12 juta per bulan hingga level senior yang bisa menembus Rp 25–40 juta seiring pengalaman yang berkembang. Permintaan pasar yang konsisten tinggi menjadikan ini salah satu bidang dengan stabilitas karier terbaik."
}
```

### 5.5 Proses Batch: Semua Profesi dalam Satu Request

Untuk efisiensi, semua profesi kandidat (`display_order <= 5`) diproses dalam **satu request ke Gemini**:

```python
def build_batch_prompt(profession_contexts: list[ProfessionContext]) -> str:
    """
    Membuat satu prompt yang berisi semua profesi kandidat.
    Gemini diminta return array JSON dengan satu objek per profesi.
    """
    professions_block = ""
    for i, prof in enumerate(profession_contexts):
        professions_block += f"""
---
PROFESI {i+1}: {prof['name']} (ID: {prof['profession_id']})
Kode RIASEC: {prof['riasec_code']} ({prof['riasec_title']})
Deskripsi: {prof['about_description'] or 'Tidak tersedia'}
Kecocokan Kepribadian: {prof['riasec_description'] or 'Tidak tersedia'}
Aktivitas: {', '.join(prof['activities'][:5]) if prof['activities'] else 'Tidak tersedia'}
Hard Skill: {', '.join(prof['hard_skills_required'][:5]) if prof['hard_skills_required'] else 'Tidak tersedia'}
Soft Skill: {', '.join(prof['soft_skills_required'][:3]) if prof['soft_skills_required'] else 'Tidak tersedia'}
Tools: {', '.join(prof['tools_required'][:4]) if prof['tools_required'] else 'Tidak tersedia'}
Pasar Kerja: {', '.join(prof['market_insights'][:2]) if prof['market_insights'] else 'Tidak tersedia'}
Gaji Entry: {_format_salary_range(prof.get('entry_level_path'))}
Potensi Senior: {prof.get('senior_level_path', {}).get('title', '-')} — {_format_salary_range(prof.get('senior_level_path'))}
"""

    return BATCH_PROMPT_TEMPLATE.format(
        professions_block=professions_block,
        count=len(profession_contexts)
    )

BATCH_PROMPT_TEMPLATE = """
Kamu adalah sistem backend penghasil konten tes karier.

Di bawah ini terdapat {count} profesi. Untuk setiap profesi,
hasilkan narasi 4 dimensi Ikigai (masing-masing tepat 2 kalimat).

[DAFTAR PROFESI]
{professions_block}

[ATURAN OUTPUT]
- Kembalikan HANYA JSON array valid
- Setiap item memiliki: profession_id, what_you_love, what_you_are_good_at,
  what_the_world_needs, what_you_can_be_paid_for
- Tiap narasi: 2 kalimat, 25–40 kata, Bahasa Indonesia
- Gunakan "kamu", jangan sebut nama profesi atau nama jabatan eksplisit
- Tidak ada teks tambahan sebelum/sesudah JSON

[FORMAT OUTPUT]
[
  {{
    "profession_id": <int>,
    "what_you_love": "...",
    "what_you_are_good_at": "...",
    "what_the_world_needs": "...",
    "what_you_can_be_paid_for": "..."
  }},
  ...
]
"""
```

**Contoh prompt batch yang sudah terisi variabel nyata (inilah string yang dikirim ke Gemini API):**

```
Kamu adalah sistem backend penghasil konten tes karier.

Di bawah ini terdapat 2 profesi. Untuk setiap profesi,
hasilkan narasi 4 dimensi Ikigai (masing-masing tepat 2 kalimat).

[DAFTAR PROFESI]
---
PROFESI 1: Software Engineer (ID: 10)
Kode RIASEC: RIA (Realistic–Investigative–Artistic)
Deskripsi: Software Engineer merancang, membangun, dan memelihara sistem perangkat lunak yang mendukung berbagai layanan digital.
Kecocokan Kepribadian: Profesi ini sangat cocok untuk individu dengan kode RIA — mereka yang senang membangun sistem konkret, berpikir analitis, dan menuangkan kreativitas dalam desain solusi.
Aktivitas: Merancang arsitektur sistem backend, Menulis dan mereview kode dalam sprint, Debugging dan profiling performa, Berkolaborasi dengan product manager, Menulis dokumentasi teknis
Hard Skill: Python atau Go, SQL dan pemodelan database, REST API design, Git & version control, Dasar sistem terdistribusi
Soft Skill: Analytical thinking, Komunikasi teknis, Kemampuan belajar mandiri
Tools: VSCode, Git/GitHub, Docker, PostgreSQL
Pasar Kerja: Permintaan tumbuh 23% YoY berdasarkan data LinkedIn 2024, Fintech dan e-commerce adalah sektor penyerapan tertinggi
Gaji Entry: Rp 8–12 juta/bulan
Potensi Senior: Rp 25–45 juta/bulan

---
PROFESI 2: Data Engineer (ID: 25)
Kode RIASEC: RAI (Realistic–Artistic–Investigative)
Deskripsi: Data Engineer membangun dan mengelola pipeline data yang memungkinkan tim analytics dan machine learning bekerja dengan data yang bersih dan andal.
Kecocokan Kepribadian: Cocok untuk individu yang menyukai tantangan infrastruktur data, berpikir sistematis, dan senang memecahkan masalah skala besar dengan pendekatan rekayasa.
Aktivitas: Membangun dan memaintain ETL/ELT pipeline, Mengelola data warehouse dan data lake, Optimasi query dan schema database, Berkolaborasi dengan data scientist dan analyst
Hard Skill: SQL lanjutan, Apache Spark atau dbt, Airflow atau pipeline orchestration, Python, Cloud data platform (BigQuery/Redshift)
Soft Skill: Problem solving sistematis, Komunikasi lintas tim, Perhatian terhadap kualitas data
Tools: dbt, Apache Airflow, BigQuery, Git
Pasar Kerja: Salah satu spesialisasi dengan pertumbuhan permintaan tertinggi di Asia Tenggara, Adopsi cloud data stack membuka banyak posisi baru di startup dan enterprise
Gaji Entry: Rp 10–15 juta/bulan
Potensi Senior: Rp 30–50 juta/bulan

[ATURAN OUTPUT]
- Kembalikan HANYA JSON array valid
- Setiap item memiliki: profession_id, what_you_love, what_you_are_good_at,
  what_the_world_needs, what_you_can_be_paid_for
- Tiap narasi: 2 kalimat, 25–40 kata, Bahasa Indonesia
- Gunakan "kamu", jangan sebut nama profesi atau nama jabatan eksplisit
- Tidak ada teks tambahan sebelum/sesudah JSON

[FORMAT OUTPUT]
[
  {
    "profession_id": <int>,
    "what_you_love": "...",
    "what_you_are_good_at": "...",
    "what_the_world_needs": "...",
    "what_you_can_be_paid_for": "..."
  },
  ...
]
```

**Contoh raw response dari Gemini (sebelum di-parse `AIContentService`):**

```json
[
  {
    "profession_id": 10,
    "what_you_love": "Kamu bisa menghabiskan waktu membangun sistem dari nol dan melihat langsung bagaimana hasil kerjamu berdampak pada pengalaman jutaan pengguna. Setiap tantangan teknis adalah teka-teki baru yang memberi kepuasan tersendiri ketika berhasil dipecahkan.",
    "what_you_are_good_at": "Kemampuan berpikir logis dan sistematis terus diasah di sini, mulai dari merancang arsitektur backend hingga mengoptimalkan performa sistem secara menyeluruh. Python, SQL, dan pemahaman mendalam tentang struktur data adalah fondasi yang kamu kuasai dan terus kembangkan.",
    "what_the_world_needs": "Di era digital, setiap layanan dan platform bergantung pada sistem yang stabil dan skalabel — itulah yang kamu bangun setiap harinya. Kontribusimu langsung berdampak pada keandalan layanan yang digunakan jutaan orang.",
    "what_you_can_be_paid_for": "Bidang ini menawarkan jalur karier yang jelas, mulai dari tahap awal dengan gaji Rp 8–12 juta per bulan hingga level senior yang bisa menembus Rp 25–45 juta seiring pengalaman yang berkembang. Permintaan pasar yang konsisten tinggi menjadikan ini salah satu bidang dengan stabilitas karier terbaik."
  },
  {
    "profession_id": 25,
    "what_you_love": "Membangun pipeline data yang andal dan melihat data mentah berubah menjadi aset yang bisa dipakai tim lain untuk mengambil keputusan adalah kepuasan tersendiri di bidang ini. Tantangan skala dan keandalan sistem membuatnya tidak pernah membosankan.",
    "what_you_are_good_at": "Keahlian dalam SQL, pemrosesan data skala besar, dan orkestrasi pipeline menjadi nilai utama yang terus berkembang dalam peran ini. Pemikiran sistematis dan kemampuan debugging data flow adalah fondasi yang paling diasah setiap harinya.",
    "what_the_world_needs": "Keputusan bisnis yang baik hanya bisa dibuat jika datanya bersih, terpercaya, dan tersedia tepat waktu — itulah masalah yang kamu selesaikan. Peran ini menjadi tulang punggung tim data di hampir semua industri yang berbasis data.",
    "what_you_can_be_paid_for": "Spesialisasi ini termasuk yang paling dicari di pasar saat ini, dengan kompensasi mulai dari Rp 10–15 juta di level awal dan bisa tumbuh ke Rp 30–50 juta di level senior. Ekosistem cloud yang berkembang pesat terus membuka peluang baru."
  }
]
```

> Response di atas sudah dalam format JSON bersih. Jika Gemini mengembalikan response yang dibungkus markdown fences (`` ```json ... ``` ``), `AIContentService` akan men-strip fences tersebut sebelum `json.loads()` dipanggil — lihat Bagian 6.5.

### 5.6 Penanganan Error & Fallback

| Skenario | Penanganan |
|---|---|
| Gemini return JSON tidak valid | Parse dengan `json.loads(clean_response)`, strip markdown fences |
| Profesi tidak ada data di DB (`about_description` null) | Isi dengan placeholder minimal sebelum inject ke prompt |
| API timeout | Retry 1 kali dengan exponential backoff (2 detik) |
| Semua retry gagal | Return konten fallback statis per profesi (nama + deskripsi singkat dari `profession.name`) |
| `profession_id` tidak ditemukan di response AI | Log warning, skip profesi tersebut, lanjutkan dengan yang lain |

---

## Bagian 6 — Model, Schema, Router, Service

### 6.1 Schema Request & Response

```python
# app/api/v1/categories/career_profile/schemas/ikigai.py

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class DimensionContent(BaseModel):
    what_you_love: str
    what_you_are_good_at: str
    what_the_world_needs: str
    what_you_can_be_paid_for: str


class CandidateWithContent(BaseModel):
    profession_id: int
    profession_name: str
    display_order: int
    congruence_score: float
    dimension_content: DimensionContent


class StartIkigaiRequest(BaseModel):
    session_token: str


class StartIkigaiResponse(BaseModel):
    session_token: str
    status: str                                  # "ikigai_ongoing"
    candidates_with_content: List[CandidateWithContent]
    total_display_candidates: int
    content_generated_at: str                    # ISO8601
    message: str


class GetIkigaiContentResponse(BaseModel):
    """Endpoint reload konten (dari Redis atau regenerate) jika Flutter perlu refresh."""
    session_token: str
    status: str
    candidates_with_content: List[CandidateWithContent]
    total_display_candidates: int
    content_generated_at: str
    from_cache: bool
    regenerated: bool   # True jika Redis expired dan konten di-generate ulang
```

### 6.2 Router Ikigai

```python
# app/api/v1/categories/career_profile/routers/ikigai.py

from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.dependencies.auth import require_active_membership
from app.api.v1.categories.career_profile.services.ikigai_service import IkigaiService
from app.api.v1.categories.career_profile.schemas.ikigai import (
    StartIkigaiRequest,
    StartIkigaiResponse,
    GetIkigaiContentResponse
)
from app.db.models.user import User

router = APIRouter(prefix="/career-profile/ikigai")


@router.post("/start", response_model=StartIkigaiResponse)
@limiter.limit("10/hour")
async def start_ikigai(
    request: Request,
    body: StartIkigaiRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Inisiasi sesi Ikigai setelah RIASEC selesai.

    Yang terjadi di endpoint ini:
    1. Validasi sesi (token valid, status riasec_completed, uses_ikigai=true)
    2. UPDATE status sesi → ikigai_ongoing
    3. INSERT ikigai_responses (row kosong)
    4. Query data profesi kandidat dari DB (display_order <= 5)
    5. Generate narasi 4 dimensi via Gemini (1 API call batch)
    6. Cache konten di Redis (TTL 2 jam)
    7. Return konten ke Flutter
    """
    service = IkigaiService(db)
    return service.start_ikigai_session(
        user=current_user,
        session_token=body.session_token
    )


@router.get("/content/{session_token}", response_model=GetIkigaiContentResponse)
@limiter.limit("30/minute")
async def get_ikigai_content(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil kembali konten opsi dimensi.
    Prioritas: ambil dari Redis cache.
    Jika cache expired tapi sesi masih aktif, generate ulang otomatis.
    Digunakan Flutter jika perlu reload (app di-kill, dll).
    """
    service = IkigaiService(db)
    return service.get_cached_content(
        user=current_user,
        session_token=session_token
    )
```

### 6.3 Ikigai Service (Inisiasi)

```python
# app/api/v1/categories/career_profile/services/ikigai_service.py
"""
IkigaiService — Bagian Inisiasi (Part 1)

Mencakup:
1. Validasi sesi sebelum Ikigai dimulai
2. Transisi status sesi → ikigai_ongoing
3. INSERT ikigai_responses (placeholder kosong)
4. Pengambilan data profesi dari DB (multi-table query)
5. Generate konten dimensi via Gemini
6. Caching konten di Redis
"""
import json
from datetime import datetime
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from app.api.v1.categories.career_profile.models.ikigai import IkigaiResponse
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession
from app.api.v1.categories.career_profile.services.profession_data_service import ProfessionDataService
from app.api.v1.categories.career_profile.services.ai_content_service import AIContentService
from app.core.redis import get_redis_client
from app.db.models.user import User

REDIS_TTL_SECONDS = 7200  # 2 jam


class IkigaiService:

    def __init__(self, db: Session):
        self.db = db
        self.profession_svc = ProfessionDataService(db)
        self.ai_svc = AIContentService()
        self.redis = get_redis_client()

    def start_ikigai_session(self, user: User, session_token: str) -> dict:
        """
        Orchestrator utama untuk inisiasi sesi Ikigai.
        Seluruh langkah DB dalam satu transaksi.
        Generate AI dilakukan setelah transaksi commit.
        """
        # 1. Validasi sesi
        session = self._validate_session_for_ikigai(session_token, user)

        # 2. Ambil daftar kandidat profesi
        candidate_record = self.db.query(IkigaiCandidateProfession).filter(
            IkigaiCandidateProfession.test_session_id == session.id
        ).first()

        if not candidate_record:
            raise HTTPException(
                status_code=404,
                detail="Data kandidat profesi tidak ditemukan. Pastikan RIASEC sudah selesai."
            )

        # Ambil hanya profesi dengan display_order <= 5
        all_candidates = candidate_record.candidates_data.get("candidates", [])
        display_candidates = [c for c in all_candidates if c.get("display_order", 99) <= 5]

        if not display_candidates:
            raise HTTPException(
                status_code=500,
                detail="Tidak ada profesi kandidat yang siap ditampilkan."
            )

        profession_ids = [c["profession_id"] for c in display_candidates]

        try:
            # 3. Transisi status + INSERT ikigai_responses (dalam transaksi)
            session.status = "ikigai_ongoing"
            ikigai_response = IkigaiResponse(test_session_id=session.id)
            self.db.add(ikigai_response)
            self.db.commit()

        except Exception as e:
            self.db.rollback()
            raise HTTPException(
                status_code=500,
                detail=f"Gagal menginisiasi sesi Ikigai: {str(e)}"
            )

        # 4. Query data lengkap profesi dari DB (di luar transaksi utama)
        profession_contexts = self.profession_svc.get_profession_contexts(profession_ids)

        # 5. Generate konten narasi via Gemini
        try:
            generated_contents = self.ai_svc.generate_dimension_content(profession_contexts)
        except Exception as e:
            # Gagal generate tidak membatalkan sesi — gunakan fallback
            generated_contents = self.ai_svc.get_fallback_content(profession_contexts)

        # 6. Susun response + cache di Redis
        candidates_with_content = self._merge_candidates_with_content(
            display_candidates, profession_contexts, generated_contents
        )

        result = {
            "session_token": session_token,
            "status": "ikigai_ongoing",
            "candidates_with_content": candidates_with_content,
            "total_display_candidates": len(candidates_with_content),
            "content_generated_at": datetime.utcnow().isoformat(),
            "message": (
                "Sesi Ikigai berhasil dimulai. "
                "Tampilkan profesi kandidat beserta narasi dimensinya kepada user."
            )
        }

        # Cache di Redis
        cache_key = f"ikigai_content:{session_token}"
        self.redis.setex(cache_key, REDIS_TTL_SECONDS, json.dumps(result))

        return result

    def get_cached_content(self, user: User, session_token: str) -> dict:
        """
        Ambil konten dari Redis.
        Jika cache expired tapi sesi masih ikigai_ongoing, generate ulang konten.
        """
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()

        if not session or str(session.user_id) != str(user.id):
            raise HTTPException(status_code=404, detail="Sesi tidak ditemukan")

        if session.status not in ("ikigai_ongoing",):
            raise HTTPException(
                status_code=400,
                detail=f"Sesi tidak dalam status ikigai_ongoing: '{session.status}'"
            )

        cache_key = f"ikigai_content:{session_token}"
        cached = self.redis.get(cache_key)

        if cached:
            result = json.loads(cached)
            result["from_cache"] = True
            result["regenerated"] = False
            return result

        # Cache expired — regenerate selama sesi masih aktif
        # Ambil kandidat yang sudah tersimpan (tidak berubah, immutable)
        candidate_record = self.db.query(IkigaiCandidateProfession).filter(
            IkigaiCandidateProfession.test_session_id == session.id
        ).first()

        if not candidate_record:
            raise HTTPException(
                status_code=404,
                detail="Data kandidat profesi tidak ditemukan."
            )

        all_candidates = candidate_record.candidates_data.get("candidates", [])
        display_candidates = [c for c in all_candidates if c.get("display_order", 99) <= 5]
        profession_ids = [c["profession_id"] for c in display_candidates]

        profession_contexts = self.profession_svc.get_profession_contexts(profession_ids)

        try:
            generated_contents = self.ai_svc.generate_dimension_content(profession_contexts)
        except Exception:
            generated_contents = self.ai_svc.get_fallback_content(profession_contexts)

        candidates_with_content = self._merge_candidates_with_content(
            display_candidates, profession_contexts, generated_contents
        )

        result = {
            "session_token": session_token,
            "status": "ikigai_ongoing",
            "candidates_with_content": candidates_with_content,
            "total_display_candidates": len(candidates_with_content),
            "content_generated_at": datetime.utcnow().isoformat(),
            "from_cache": False,
            "regenerated": True,
            "message": "Konten berhasil di-generate ulang."
        }

        # Re-cache dengan TTL baru
        self.redis.setex(cache_key, REDIS_TTL_SECONDS, json.dumps(result))

        return result

    # ============================================================
    # PRIVATE HELPERS
    # ============================================================

    def _validate_session_for_ikigai(
        self,
        session_token: str,
        user: User
    ) -> CareerProfileTestSession:
        """
        Validasi lengkap sesi sebelum Ikigai dimulai:
        - Token valid dan milik user ini
        - Status = riasec_completed (bukan ikigai_ongoing atau completed)
        - uses_ikigai = true
        - test_goal = RECOMMENDATION
        """
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()

        if not session:
            raise HTTPException(status_code=404, detail="Session token tidak ditemukan")

        if str(session.user_id) != str(user.id):
            raise HTTPException(status_code=403, detail="Sesi bukan milik user yang sedang login")

        if not session.uses_ikigai:
            raise HTTPException(
                status_code=400,
                detail="Sesi ini adalah FIT_CHECK — tidak memiliki alur Ikigai"
            )

        if session.status == "ikigai_ongoing":
            raise HTTPException(
                status_code=400,
                detail=(
                    "Sesi Ikigai sudah dimulai sebelumnya. "
                    "Gunakan GET /ikigai/content/{session_token} untuk memuat ulang konten."
                )
            )

        if session.status == "completed":
            raise HTTPException(
                status_code=400,
                detail="Sesi ini sudah selesai sepenuhnya."
            )

        if session.status != "riasec_completed":
            raise HTTPException(
                status_code=400,
                detail=f"Status sesi tidak valid untuk memulai Ikigai: '{session.status}'"
            )

        return session

    def _merge_candidates_with_content(
        self,
        display_candidates: list,
        profession_contexts: list,
        generated_contents: dict
    ) -> list:
        """
        Gabungkan data kandidat, data profesi dari DB, dan konten yang di-generate AI.
        Return list kandidat lengkap dengan konten siap pakai Flutter.
        """
        context_map = {pc["profession_id"]: pc for pc in profession_contexts}
        content_map = {gc["profession_id"]: gc for gc in generated_contents}

        result = []
        for candidate in display_candidates:
            prof_id = candidate["profession_id"]
            context = context_map.get(prof_id, {})
            content = content_map.get(prof_id, {})

            result.append({
                "profession_id": prof_id,
                "profession_name": context.get("name", f"Profesi #{prof_id}"),
                "display_order": candidate["display_order"],
                "congruence_score": candidate["congruence_score"],
                "dimension_content": {
                    "what_you_love": content.get("what_you_love", ""),
                    "what_you_are_good_at": content.get("what_you_are_good_at", ""),
                    "what_the_world_needs": content.get("what_the_world_needs", ""),
                    "what_you_can_be_paid_for": content.get("what_you_can_be_paid_for", "")
                }
            })

        return sorted(result, key=lambda x: x["display_order"])
```

### 6.4 ProfessionDataService

```python
# app/api/v1/categories/career_profile/services/profession_data_service.py
"""
ProfessionDataService — Query konteks profesi dari database.
Menggabungkan data dari tabel profession dan semua tabel relasinya.
"""
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List


class ProfessionDataService:

    def __init__(self, db: Session):
        self.db = db

    def get_profession_contexts(self, profession_ids: List[int]) -> List[dict]:
        """
        Query data lengkap untuk daftar profession_id.
        Mengambil data dari: professions, riasec_codes,
        profession_activities, profession_skill_rel, skills,
        profession_tool_rel, tools, profession_market_insights,
        profession_career_paths.
        """
        # Gunakan raw SQL untuk efisiensi dan keterbacaan
        sql = text("""
            SELECT
                p.id AS profession_id,
                p.name,
                p.about_description,
                p.riasec_description,
                rc.riasec_code,
                rc.riasec_title,
                rc.strengths,
                rc.work_environments,

                (SELECT json_agg(pa.description ORDER BY pa.sort_order)
                 FROM profession_activities pa
                 WHERE pa.profession_id = p.id) AS activities,

                (SELECT json_agg(s.name)
                 FROM profession_skill_rel psr
                 JOIN skills s ON s.id = psr.skill_id
                 WHERE psr.profession_id = p.id
                   AND psr.skill_type = 'hard' AND psr.priority = 'wajib'
                ) AS hard_skills_required,

                (SELECT json_agg(s.name)
                 FROM profession_skill_rel psr
                 JOIN skills s ON s.id = psr.skill_id
                 WHERE psr.profession_id = p.id
                   AND psr.skill_type = 'soft' AND psr.priority = 'wajib'
                ) AS soft_skills_required,

                (SELECT json_agg(t.name)
                 FROM profession_tool_rel ptr
                 JOIN tools t ON t.id = ptr.tool_id
                 WHERE ptr.profession_id = p.id
                   AND ptr.usage_type = 'wajib'
                ) AS tools_required,

                (SELECT json_agg(pmi.description ORDER BY pmi.sort_order)
                 FROM (SELECT description, sort_order
                       FROM profession_market_insights
                       WHERE profession_id = p.id
                       ORDER BY sort_order LIMIT 3) pmi
                ) AS market_insights,

                (SELECT row_to_json(ep)
                 FROM (SELECT title, experience_range, salary_min, salary_max
                       FROM profession_career_paths
                       WHERE profession_id = p.id
                       ORDER BY sort_order ASC LIMIT 1) ep
                ) AS entry_level_path,

                (SELECT row_to_json(sp)
                 FROM (SELECT title, experience_range, salary_min, salary_max
                       FROM profession_career_paths
                       WHERE profession_id = p.id
                       ORDER BY sort_order DESC LIMIT 1) sp
                ) AS senior_level_path

            FROM professions p
            LEFT JOIN riasec_codes rc ON rc.id = p.riasec_code_id
            WHERE p.id = ANY(:ids)
        """)

        rows = self.db.execute(sql, {"ids": profession_ids}).mappings().all()
        return [dict(row) for row in rows]
```

### 6.5 AIContentService

```python
# app/api/v1/categories/career_profile/services/ai_content_service.py
"""
AIContentService — Wrapper untuk Gemini API call (konten dimensi).
"""
import json
import httpx
from typing import List
from app.core.config import settings
from app.api.v1.categories.career_profile.prompts.ikigai_prompts import (
    build_batch_prompt,
    FALLBACK_CONTENT_TEMPLATE
)


class AIContentService:

    def generate_dimension_content(self, profession_contexts: List[dict]) -> List[dict]:
        """
        Kirim satu batch prompt ke Gemini.
        Return list dict dengan profession_id dan 4 dimensi konten.
        """
        if not profession_contexts:
            return []

        prompt = build_batch_prompt(profession_contexts)

        response = httpx.post(
            url=f"{settings.OPENROUTER_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": settings.OPENROUTER_MODEL,
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": 2000,
                "temperature": 0.7
            },
            timeout=30.0
        )

        raw_text = response.json()["choices"][0]["message"]["content"]

        # Strip markdown code fences jika ada
        clean_text = raw_text.strip()
        if clean_text.startswith("```"):
            clean_text = clean_text.split("```")[1]
            if clean_text.startswith("json"):
                clean_text = clean_text[4:]
            clean_text = clean_text.rsplit("```", 1)[0].strip()

        return json.loads(clean_text)

    def get_fallback_content(self, profession_contexts: List[dict]) -> List[dict]:
        """
        Konten fallback statis jika Gemini gagal.
        Menggunakan template generik berisi nama profesi.
        """
        return [
            {
                "profession_id": prof["profession_id"],
                "what_you_love": FALLBACK_CONTENT_TEMPLATE["what_you_love"].format(
                    name=prof["name"]
                ),
                "what_you_are_good_at": FALLBACK_CONTENT_TEMPLATE["what_you_are_good_at"].format(
                    name=prof["name"],
                    skills=", ".join((prof.get("hard_skills_required") or [])[:3]) or "skill teknis relevan"
                ),
                "what_the_world_needs": FALLBACK_CONTENT_TEMPLATE["what_the_world_needs"].format(
                    name=prof["name"]
                ),
                "what_you_can_be_paid_for": FALLBACK_CONTENT_TEMPLATE["what_you_can_be_paid_for"].format(
                    name=prof["name"]
                )
            }
            for prof in profession_contexts
        ]


# app/api/v1/categories/career_profile/prompts/ikigai_prompts.py

FALLBACK_CONTENT_TEMPLATE = {
    "what_you_love": (
        "Bekerja di bidang ini membuka ruang eksplorasi dan kreativitas yang luas "
        "bagi mereka yang menyukai tantangan dan pembelajaran berkelanjutan. "
        "Setiap harinya menghadirkan permasalahan baru yang menarik untuk diselesaikan."
    ),
    "what_you_are_good_at": (
        "Bidang ini menuntut kemampuan analitis dan ketelitian tinggi, "
        "serta penguasaan {skills} yang menjadi fondasi pekerjaan sehari-hari. "
        "Keahlian yang diasah di sini sangat transferable ke banyak industri."
    ),
    "what_the_world_needs": (
        "Peran ini memberikan kontribusi nyata terhadap ekosistem digital "
        "yang semakin menjadi tulang punggung kehidupan modern. "
        "Setiap output pekerjaanmu berdampak langsung pada pengalaman pengguna dan efisiensi bisnis."
    ),
    "what_you_can_be_paid_for": (
        "Bidang ini menawarkan kompensasi yang kompetitif dengan prospek pertumbuhan karier yang jelas. "
        "Permintaan tenaga ahli di bidang ini konsisten tinggi, "
        "memberikan stabilitas dan peluang berkembang secara finansial."
    )
}
```

---

## Bagian 7 — Alur Data Lengkap (Visual)

```
[Kondisi Awal]
  careerprofile_test_sessions.status = "riasec_completed"
  ikigai_candidate_professions.candidates_data → sudah tersimpan

        ↓ Flutter panggil POST /career-profile/ikigai/start

[Validasi Sesi]
  Cek: token valid, status riasec_completed, uses_ikigai=true

        ↓

[Transisi DB — Satu Transaksi]
  UPDATE careerprofile_test_sessions.status → "ikigai_ongoing"
  INSERT ikigai_responses (semua dimensi = NULL)
  COMMIT

        ↓

[Query Data Profesi — Di Luar Transaksi]
  Ambil candidates dengan display_order <= 5 dari candidates_data
  Warning log jika total kandidat < 5 (tidak gagalkan proses)
  Untuk setiap profession_id:
    Query professions JOIN riasec_codes
    Query profession_activities (sort_order ASC)
    Query profession_skill_rel JOIN skills (wajib saja)
    Query profession_tool_rel JOIN tools (wajib saja)
    Query profession_market_insights (top 3)
    Query profession_career_paths (entry + senior)

        ↓

[Generate Konten — 1 Gemini API Call]
  Input: Konteks semua profesi kandidat opsi (batch)
  Output: JSON array dengan 4 narasi dimensi per profesi
  Error handling: retry 1x → fallback statis
  Narasi tidak menyebut nama profesi/jabatan — generik aktivitas & dampak

        ↓

[Cache + Response]
  Simpan ke Redis: key = "ikigai_content:{session_token}", TTL = 2 jam
  Jika Redis down: konten tetap di-return ke Flutter, cache skip, warning log
  Return ke Flutter: candidates_with_content (profesi + narasi 4 dimensi)

        ↓ Flutter tampilkan soal dimensi 1

-------- ALUR RELOAD (jika app di-kill / perlu refresh) --------

        Flutter panggil GET /career-profile/ikigai/content/{session_token}

        ↓

[Cek Redis]
  Cache HIT  → return langsung (from_cache: true, regenerated: false)
  Cache MISS → cek status sesi masih ikigai_ongoing?
                  Ya  → generate ulang (1 Gemini call) → re-cache → return (regenerated: true)
                  Tidak → return 400 status sesi tidak valid

-------- SELANJUTNYA — BRIEF PART 2 --------

  User pilih/tidak pilih profesi + isi reasoning text per dimensi
  POST /career-profile/ikigai/submit-dimension (×4)
  Setelah dimensi 4: AI scoring batch → agregasi → rekomendasi
```

---

## Bagian 8 — Ringkasan File yang Dibuat / Dimodifikasi

| File | Status | Keterangan |
|---|---|---|
| `app/api/v1/categories/career_profile/models/ikigai.py` | **Baru** | Model `IkigaiResponse` (+ model Ikigai lain di Part 2) |
| `app/api/v1/categories/career_profile/schemas/ikigai.py` | **Baru** | Schema request/response untuk endpoint Ikigai Part 1 |
| `app/api/v1/categories/career_profile/routers/ikigai.py` | **Baru** | Router: `/start` + `/content/{token}` |
| `app/api/v1/categories/career_profile/services/ikigai_service.py` | **Baru** | Orchestrator: validasi + transisi + query + AI + cache |
| `app/api/v1/categories/career_profile/services/profession_data_service.py` | **Baru** | Query multi-table data profesi (raw SQL) |
| `app/api/v1/categories/career_profile/services/ai_content_service.py` | **Baru** | Wrapper Gemini API: batch generate + fallback |
| `app/api/v1/categories/career_profile/prompts/ikigai_prompts.py` | **Baru** | Template prompt + fallback content |
| `app/core/redis.py` | **Modifikasi** | Tambah fungsi `get_redis_client()` jika belum ada |
| `app/api/v1/main_router.py` | **Modifikasi** | Register `ikigai.router` |

---

## Bagian 9 — Daftar Endpoint Ikigai Part 1

| Method | Endpoint | Auth | Rate Limit | Deskripsi |
|---|---|---|---|---|
| `POST` | `/api/v1/career-profile/ikigai/start` | ✅ | 10/jam | Inisiasi sesi Ikigai, generate konten dimensi, return ke Flutter |
| `GET` | `/api/v1/career-profile/ikigai/content/{session_token}` | ✅ | 30/menit | Reload konten dari Redis; jika expired dan sesi masih aktif, generate ulang otomatis |

---

## Catatan Kelanjutan (Brief Part 2)

Brief Ikigai Part 2 akan mencakup:

- `POST /ikigai/submit-dimension` — user submit jawaban per dimensi (UPDATE `ikigai_responses`)
- Validasi dan partial update per dimensi
- Trigger AI scoring setelah dimensi ke-4 selesai (`ikigai_dimension_scores`)
- Algoritma normalisasi min-max dan kalkulasi `click_score`
- Agregasi ke `ikigai_total_scores`
- Generate narasi rekomendasi final (`career_recommendations`)
- UPDATE `kenalidiri_history` → completed
- UPDATE `careerprofile_test_sessions` → completed

---

*Brief ini siap diimplementasikan. Seluruh keputusan desain telah dikunci berdasarkan spesifikasi PDF dan entity brief Jelajah Profesi yang tersedia.*