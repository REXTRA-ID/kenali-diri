# Migration Alembic — Tabel Ikigai

**Tanggal:** 23 Februari 2026  
**Revises:** `c6f96ad1d8f8` (migration terakhir: add profession_id to fit_check_results)  
**Tabel yang dibuat:** `ikigai_responses`, `ikigai_dimension_scores`, `ikigai_total_scores`  
**Tabel yang dimodifikasi:** `ikigai_candidate_professions` (tambah 3 kolom)

---

## Latar Belakang

Model Python untuk keempat tabel sudah ada di kode, tapi tidak ada satu pun migration yang membuatnya di DB. Jika `alembic upgrade head` dijalankan di environment baru atau DB di-recreate, semua tabel ini tidak akan terbuat dan aplikasi crash saat pertama kali INSERT.

Selain itu, model `IkigaiCandidateProfession` dari brief RIASEC (Temuan 3 di brief RIASEC) sudah ditambahkan 3 kolom baru (`total_candidates`, `generation_strategy`, `max_candidates_limit`) tapi migration ALTER TABLE untuk kolom-kolom itu juga belum ada.

Migration ini menangani keduanya sekaligus dalam satu file.

---

## Nama File

```
alembic/versions/d7e8f9a0b1c2_create_ikigai_tables.py
```

> Revision ID `d7e8f9a0b1c2` adalah placeholder — Alembic akan generate ID acak saat `alembic revision` dijalankan. Ganti dengan ID yang di-generate oleh Alembic.

---

## Source Code Lengkap

```python
# alembic/versions/d7e8f9a0b1c2_create_ikigai_tables.py
"""Create ikigai tables and extend ikigai_candidate_professions

Revision ID: d7e8f9a0b1c2
Revises: c6f96ad1d8f8
Create Date: 2026-02-23 00:00:00.000000

Tabel baru:
  - ikigai_responses           : jawaban user 4 dimensi, satu baris per sesi
  - ikigai_dimension_scores    : skor per dimensi per profesi dari AI scoring batch
  - ikigai_total_scores        : skor total agregasi + ranking profesi

Modifikasi tabel:
  - ikigai_candidate_professions : tambah 3 kolom denormalisasi
      total_candidates       BIGINT nullable
      generation_strategy    VARCHAR(50) nullable
      max_candidates_limit   INTEGER default 30
"""
from typing import Sequence, Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "d7e8f9a0b1c2"
down_revision: Union[str, None] = "c6f96ad1d8f8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ──────────────────────────────────────────────────────────────────────────
    # 1. CREATE TABLE ikigai_responses
    # ──────────────────────────────────────────────────────────────────────────
    # Menyimpan jawaban user untuk 4 dimensi Ikigai.
    # Baris di-INSERT sebagai placeholder saat /ikigai/start dipanggil (semua
    # dimensi NULL). Diisi bertahap via UPDATE per dimensi saat user submit.
    # One-to-one dengan careerprofile_test_sessions.
    op.create_table(
        "ikigai_responses",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column(
            "test_session_id",
            sa.BigInteger(),
            sa.ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        ),
        # Setiap kolom dimensi menyimpan:
        # { "selected_profession_id": int|null, "selection_type": str,
        #   "reasoning_text": str, "answered_at": "ISO8601" }
        # NULL = dimensi belum dijawab
        sa.Column("dimension_1_love",        postgresql.JSONB(), nullable=True),
        sa.Column("dimension_2_good_at",     postgresql.JSONB(), nullable=True),
        sa.Column("dimension_3_world_needs", postgresql.JSONB(), nullable=True),
        sa.Column("dimension_4_paid_for",    postgresql.JSONB(), nullable=True),
        sa.Column("completed",    sa.Boolean(), nullable=False, server_default="false"),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("completed_at", sa.TIMESTAMP(timezone=True), nullable=True),
    )
    op.create_index(
        "ix_ikigai_responses_test_session_id",
        "ikigai_responses",
        ["test_session_id"],
    )

    # ──────────────────────────────────────────────────────────────────────────
    # 2. CREATE TABLE ikigai_dimension_scores
    # ──────────────────────────────────────────────────────────────────────────
    # Skor per dimensi untuk semua kandidat profesi.
    # INSERT sekali setelah 4 dimensi selesai + AI scoring batch selesai.
    # Immutable — tidak pernah di-UPDATE.
    # One-to-one dengan careerprofile_test_sessions.
    op.create_table(
        "ikigai_dimension_scores",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column(
            "test_session_id",
            sa.BigInteger(),
            sa.ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        ),
        # Struktur scores_data:
        # {
        #   "dimension_scores":      { dim: [{profession_id, r_raw, r_normalized,
        #                                      text_score, click_score, dimension_total}] },
        #   "normalization_params":  { dim: {r_min, r_max, professions_evaluated} },
        #   "metadata":              { total_candidates_scored, scoring_strategy,
        #                              fallback_used, failed_dimensions, calculated_at }
        # }
        sa.Column("scores_data",     postgresql.JSONB(), nullable=False),
        sa.Column(
            "calculated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("ai_model_used",   sa.String(50),  nullable=True, server_default="gemini-1.5-flash"),
        sa.Column("total_api_calls", sa.Integer(),   nullable=True, server_default="4"),
        sa.CheckConstraint(
            "total_api_calls BETWEEN 1 AND 20",
            name="chk_valid_api_calls",
        ),
    )
    op.create_index(
        "ix_ikigai_dimension_scores_test_session_id",
        "ikigai_dimension_scores",
        ["test_session_id"],
    )

    # ──────────────────────────────────────────────────────────────────────────
    # 3. CREATE TABLE ikigai_total_scores
    # ──────────────────────────────────────────────────────────────────────────
    # Skor total agregasi dari 4 dimensi untuk semua kandidat profesi.
    # INSERT sekali setelah agregasi + sorting selesai.
    # Immutable dan PERMANEN — bagian dari riwayat user, tidak pernah dihapus.
    # One-to-one dengan careerprofile_test_sessions.
    op.create_table(
        "ikigai_total_scores",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column(
            "test_session_id",
            sa.BigInteger(),
            sa.ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        ),
        # Struktur scores_data:
        # {
        #   "profession_scores": [{ rank, profession_id, profession_name, total_score,
        #                           intrinsic_score, extrinsic_score, congruence_score,
        #                           avg_r_normalized, score_what_you_love, ... }],
        #   "metadata":          { total_professions_ranked, tie_breaking_applied,
        #                          tie_breaking_details, top_2_professions, calculated_at }
        # }
        sa.Column("scores_data",         postgresql.JSONB(), nullable=False),
        sa.Column("top_profession_1_id", sa.BigInteger(), nullable=True),
        sa.Column("top_profession_2_id", sa.BigInteger(), nullable=True),
        sa.Column(
            "calculated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "top_profession_1_id IS NULL OR top_profession_2_id IS NULL OR "
            "top_profession_1_id != top_profession_2_id",
            name="chk_different_top_professions",
        ),
    )
    op.create_index(
        "ix_ikigai_total_scores_test_session_id",
        "ikigai_total_scores",
        ["test_session_id"],
    )

    # ──────────────────────────────────────────────────────────────────────────
    # 4. ALTER TABLE ikigai_candidate_professions — tambah 3 kolom denormalisasi
    # ──────────────────────────────────────────────────────────────────────────
    # Kolom ini diperlukan oleh result_service.get_recommendation_result untuk
    # menampilkan "REXTRA menemukan N profesi" tanpa parse seluruh JSONB.
    # Semua nullable agar backward compat dengan baris yang sudah ada.
    op.add_column(
        "ikigai_candidate_professions",
        sa.Column("total_candidates", sa.BigInteger(), nullable=True),
    )
    op.add_column(
        "ikigai_candidate_professions",
        sa.Column("generation_strategy", sa.String(50), nullable=True),
    )
    op.add_column(
        "ikigai_candidate_professions",
        sa.Column(
            "max_candidates_limit",
            sa.Integer(),
            nullable=True,
            server_default="30",
        ),
    )


def downgrade() -> None:
    # ──────────────────────────────────────────────────────────────────────────
    # Urutan downgrade: tabel yang punya FK ke tabel lain di-drop lebih dulu.
    # ikigai_total_scores, ikigai_dimension_scores, ikigai_responses semuanya
    # FK ke careerprofile_test_sessions — drop dalam urutan bebas.
    # ──────────────────────────────────────────────────────────────────────────

    # 4. Hapus kolom yang ditambahkan ke ikigai_candidate_professions
    op.drop_column("ikigai_candidate_professions", "max_candidates_limit")
    op.drop_column("ikigai_candidate_professions", "generation_strategy")
    op.drop_column("ikigai_candidate_professions", "total_candidates")

    # 3. Drop ikigai_total_scores
    op.drop_index(
        "ix_ikigai_total_scores_test_session_id",
        table_name="ikigai_total_scores",
    )
    op.drop_table("ikigai_total_scores")

    # 2. Drop ikigai_dimension_scores
    op.drop_index(
        "ix_ikigai_dimension_scores_test_session_id",
        table_name="ikigai_dimension_scores",
    )
    op.drop_table("ikigai_dimension_scores")

    # 1. Drop ikigai_responses
    op.drop_index(
        "ix_ikigai_responses_test_session_id",
        table_name="ikigai_responses",
    )
    op.drop_table("ikigai_responses")
```

---

## Cara Menjalankan

```bash
# Dari root project (direktori yang sama dengan alembic.ini)

# Pastikan di environment yang tepat
cd /path/to/kenali-diri-main

# Cek status migration saat ini
alembic current

# Jalankan upgrade ke head (akan menjalankan migration ini)
alembic upgrade head

# Verifikasi
alembic current
```

---

## Catatan Penting

**Jika DB sudah online dan tabel belum ada:**  
`alembic upgrade head` aman dijalankan — hanya membuat tabel yang belum ada, tidak menyentuh tabel yang sudah ada.

**Jika kolom `ikigai_candidate_professions` sudah ada (ditambahkan manual):**  
`op.add_column` akan gagal dengan error `column already exists`. Dalam kasus ini, wrap dengan try-except atau tambahkan `IF NOT EXISTS` lewat raw SQL:
```python
op.execute("""
    ALTER TABLE ikigai_candidate_professions
    ADD COLUMN IF NOT EXISTS total_candidates BIGINT,
    ADD COLUMN IF NOT EXISTS generation_strategy VARCHAR(50),
    ADD COLUMN IF NOT EXISTS max_candidates_limit INTEGER DEFAULT 30
""")
```

**Tentang ENUM `match_category_enum`:**  
Migration ini tidak menyentuh ENUM `match_category_enum` ('HIGH', 'MEDIUM', 'LOW') karena sudah ada di DB dan sudah dipakai oleh `fit_check_results`. Model `FitCheckResult` sudah pakai `create_type=False` — tidak perlu action apapun di migration ini.
