# Migration Alembic — Tabel Result (career_recommendations & fit_check_results)

**Tanggal:** 23 Februari 2026  
**Revises:** `d7e8f9a0b1c2` (migration sebelumnya: create ikigai tables)  
**Tabel yang dimodifikasi:**
- `career_recommendations` — tambah 3 kolom (`top_profession1_id`, `top_profession2_id`, `ai_model_used`)
- `fit_check_results` — rename kolom `generated_at` → `created_at`

---

## Latar Belakang

Dua deviasi model ditemukan saat audit Part 3 (FIT CHECK & RESULT):

**1. `career_recommendations`** — Brief §8.1 mendefinisikan 3 kolom tambahan yang tidak ada di model project:
- `top_profession1_id` — FK shortcut ke profesi rank 1 (tanpa parse JSONB)
- `top_profession2_id` — FK shortcut ke profesi rank 2
- `ai_model_used` — nama model AI yang dipakai untuk generate narasi

`ikigai_service.py` (yang sudah diperbaiki di revisi Ikigai) sudah mencoba INSERT kolom-kolom ini ke `CareerRecommendation`. Tanpa migration ini, kolom tidak ada di DB dan INSERT akan raise `AttributeError` atau kolom diabaikan SQLAlchemy.

**2. `fit_check_results`** — Brief §8.1 menggunakan nama `created_at` (konsisten dengan semua tabel lain di project). Model project menggunakan `generated_at`. `result_service.get_fit_check_result` mengakses `fit_result.created_at` untuk field `test_completed_at` di response — tanpa rename ini akan raise `AttributeError`.

---

## Nama File

```
alembic/versions/e1f2a3b4c5d6_alter_result_tables.py
```

> Revision ID `e1f2a3b4c5d6` adalah placeholder — Alembic akan generate ID acak saat `alembic revision` dijalankan. Ganti dengan ID yang di-generate oleh Alembic.

---

## Source Code Lengkap

```python
# alembic/versions/e1f2a3b4c5d6_alter_result_tables.py
"""Alter result tables: career_recommendations and fit_check_results

Revision ID: e1f2a3b4c5d6
Revises: d7e8f9a0b1c2
Create Date: 2026-02-23 00:00:00.000000

Modifikasi tabel:
  - career_recommendations:
      top_profession1_id   BIGINT nullable   ← FK shortcut rank 1 (tanpa parse JSONB)
      top_profession2_id   BIGINT nullable   ← FK shortcut rank 2
      ai_model_used        VARCHAR(50)       ← nama model AI, default "gemini-1.5-flash"

  - fit_check_results:
      RENAME COLUMN generated_at → created_at
      (konsistensi naming dengan semua tabel lain di project)
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "e1f2a3b4c5d6"
down_revision: Union[str, None] = "d7e8f9a0b1c2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ──────────────────────────────────────────────────────────────────────────
    # 1. ALTER TABLE career_recommendations — tambah 3 kolom
    # ──────────────────────────────────────────────────────────────────────────
    # top_profession1_id dan top_profession2_id adalah denormalisasi untuk
    # akses cepat tanpa parse seluruh JSONB recommendations_data.
    # Keduanya nullable agar backward compat dengan baris lama yang sudah ada.
    op.add_column(
        "career_recommendations",
        sa.Column("top_profession1_id", sa.BigInteger(), nullable=True),
    )
    op.add_column(
        "career_recommendations",
        sa.Column("top_profession2_id", sa.BigInteger(), nullable=True),
    )
    # ai_model_used: nama model AI yang dipakai generate narasi rekomendasi.
    # Default "gemini-1.5-flash" untuk baris lama yang sudah ada.
    op.add_column(
        "career_recommendations",
        sa.Column(
            "ai_model_used",
            sa.String(50),
            nullable=True,
            server_default="gemini-1.5-flash",
        ),
    )

    # ──────────────────────────────────────────────────────────────────────────
    # 2. ALTER TABLE fit_check_results — rename generated_at → created_at
    # ──────────────────────────────────────────────────────────────────────────
    # Brief §8.1 menggunakan created_at (konsisten dengan semua tabel lain).
    # result_service.get_fit_check_result mengakses fit_result.created_at
    # untuk field test_completed_at di response — tanpa rename ini AttributeError.
    op.alter_column(
        "fit_check_results",
        "generated_at",
        new_column_name="created_at",
    )


def downgrade() -> None:
    # ──────────────────────────────────────────────────────────────────────────
    # Urutan downgrade: balik semua perubahan upgrade.
    # ──────────────────────────────────────────────────────────────────────────

    # 2. Balik rename: created_at → generated_at
    op.alter_column(
        "fit_check_results",
        "created_at",
        new_column_name="generated_at",
    )

    # 1. Hapus 3 kolom yang ditambahkan ke career_recommendations
    op.drop_column("career_recommendations", "ai_model_used")
    op.drop_column("career_recommendations", "top_profession2_id")
    op.drop_column("career_recommendations", "top_profession1_id")
```

---

## Cara Menjalankan

```bash
# Dari root project (direktori yang sama dengan alembic.ini)
cd /path/to/kenali-diri-main

# Pastikan migration sebelumnya (d7e8f9a0b1c2) sudah dijalankan dulu
alembic current

# Jalankan upgrade ke head
alembic upgrade head

# Verifikasi
alembic current
```

---

## Catatan Penting

**Urutan migration wajib dijaga:**
Migration ini harus dijalankan SETELAH `d7e8f9a0b1c2_create_ikigai_tables.py`. Jika dijalankan terbalik, Alembic akan error karena chain `down_revision` putus.

Urutan lengkap seluruh migration:
```
5260bdb10656  → initial schema
97caa26d93fb  → update sessions table for ikigai
a1b2c3d4e5f6  → phase3 tables
c6f96ad1d8f8  → add profession_id to fit_check_results
d7e8f9a0b1c2  → create ikigai tables (+ alter ikigai_candidate_professions)
e1f2a3b4c5d6  → alter result tables  ← migration ini
```

**Jika kolom sudah ada (ditambahkan manual):**
`op.add_column` akan gagal dengan error `column already exists`. Ganti dengan raw SQL untuk aman:
```python
op.execute("""
    ALTER TABLE career_recommendations
    ADD COLUMN IF NOT EXISTS top_profession1_id BIGINT,
    ADD COLUMN IF NOT EXISTS top_profession2_id BIGINT,
    ADD COLUMN IF NOT EXISTS ai_model_used VARCHAR(50) DEFAULT 'gemini-1.5-flash'
""")
```

**Jika kolom `generated_at` sudah di-rename manual:**
`op.alter_column` akan gagal karena kolom `generated_at` tidak ditemukan. Cek dulu nama kolom yang ada di DB sebelum menjalankan migration ini:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'fit_check_results';
```
Jika sudah bernama `created_at`, skip atau comment bagian `alter_column` di `upgrade()` dan `downgrade()`.

**Tentang FK constraint untuk `top_profession1_id` dan `top_profession2_id`:**
Kolom ini sengaja tidak diberi FK constraint ke tabel `professions` karena:
1. Tabel `professions` berasal dari schema Jelajah Profesi (DB yang sama tapi managed terpisah)
2. Brief §8.1 mendefinisikan kolom ini sebagai shortcut denormalisasi, bukan relasi formal
3. Menambah FK akan memperumit deployment jika tabel `professions` belum ada

Jika ingin menambah FK di masa depan, buat migration terpisah setelah deployment stabil.
```
