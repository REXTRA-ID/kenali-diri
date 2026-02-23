# Revisi Project FastAPI Kenali Diri — RIASEC TEST

**Tanggal:** 23 Februari 2026  
**Scope:** Fase RIASEC — Session setup, model kandidat profesi, schema validasi, konfigurasi DB  
**Acuan:** Brief Pengerjaan FastAPI — Tes Profil Karier (RIASEC)  
**Status:** Siap implementasi

---

## Daftar Isi

1. [Latar Belakang](#1-latar-belakang)
2. [Daftar Temuan & Masalah](#2-daftar-temuan--masalah)
3. [File yang Harus Diubah](#3-file-yang-harus-diubah)
4. [Source Code Lengkap Per File](#4-source-code-lengkap-per-file)

---

## 1. Latar Belakang

Audit statis terhadap codebase kenali-diri menemukan sejumlah deviasi antara implementasi aktual dengan spesifikasi di Brief RIASEC. Deviasi ini terbagi menjadi tiga kategori:

- **Bug logika** yang langsung berdampak ke data salah di production (salah category_id di history)
- **Model tidak lengkap** yang akan menyebabkan migration tidak sinkron dengan DB
- **Kode mati (dead code)** yang meningkatkan risiko engineer baru menggunakan fungsi yang sudah tidak berlaku
- **Konfigurasi tidak optimal** yang berdampak ke stabilitas koneksi DB online

Semua temuan di bawah ini bersifat **murni static code review** — tidak memerlukan akses DB untuk dikonfirmasi.

---

## 2. Daftar Temuan & Masalah

### Temuan 1 — KRITIS: `CAREER_PROFILE_CATEGORY_ID = 1` seharusnya `3`

**File:** `app/api/v1/categories/career_profile/services/session_service.py`

**Masalah:**  
Konstanta `CAREER_PROFILE_CATEGORY_ID` di-set ke `1`, padahal Brief halaman 764 secara eksplisit menetapkan nilai `3` sesuai seed data tabel `kenalidiri_categories` dengan `category_code = CAREER_PROFILE`.

```python
# Kondisi sekarang — SALAH
CAREER_PROFILE_CATEGORY_ID = 1
```

**Dampak:**  
Setiap kali user memulai tes (RECOMMENDATION maupun FIT_CHECK), record di tabel `kenalidiri_history` akan tercatat dengan `test_category_id = 1` — kategori yang salah. Ini merusak data history seluruh user secara silent tanpa error apapun.

---

### Temuan 2 — KRITIS: `StartRecommendationRequest` dan `StartFitCheckRequest` tidak ada `field_validator`

**File:** `app/api/v1/categories/career_profile/schemas/session.py`

**Masalah:**  
Brief halaman 635–656 mewajibkan validasi nilai `persona_type` di level schema Pydantic:
- `RECOMMENDATION` → hanya boleh menerima `PATHFINDER`, `BUILDER`, atau `ACHIEVER`
- `FIT_CHECK` → hanya boleh menerima `BUILDER` atau `ACHIEVER`

Implementasi sekarang tidak punya validator apapun — field `persona_type` di kedua schema hanya bertipe `str` polos tanpa pembatasan nilai.

```python
# Kondisi sekarang — TIDAK ADA VALIDATOR
class StartRecommendationRequest(BaseModel):
    persona_type: str  # tidak ada pengecekan nilai

class StartFitCheckRequest(BaseModel):
    persona_type: str  # tidak ada pengecekan nilai
    target_profession_id: int
```

**Dampak:**  
Request dengan `persona_type` sembarang (misal `"ADMIN"`, `"RANDOM"`, string kosong) akan diterima dan diproses tanpa ditolak, menyebabkan data `persona_type` tidak valid tersimpan ke DB.

---

### Temuan 3 — KRITIS: Model `IkigaiCandidateProfession` tidak lengkap

**File:** `app/api/v1/categories/career_profile/models/profession.py`

**Masalah:**  
Brief halaman 594–626 mendefinisikan model `IkigaiCandidateProfession` dengan kolom lengkap:

| Kolom | Tipe | Keterangan |
|---|---|---|
| `total_candidates` | `Integer, nullable=False` | Jumlah kandidat profesi yang digenerate |
| `generation_strategy` | `String(50)` | Strategi generate: `"4_tier_expansion"` atau `"split_path"` |
| `max_candidates_limit` | `Integer, default=30` | Batas maksimum kandidat |
| `CheckConstraint` | `total_candidates BETWEEN 1 AND 30` | Validasi di level DB |
| `Index` | `idx_ikigai_candidates_session` | Index untuk query cepat per session |

Model yang ada di project hanya punya 4 kolom: `id`, `test_session_id`, `candidates_data`, `generated_at`. Ketiga kolom di atas tidak ada.

```python
# Kondisi sekarang — TIDAK LENGKAP
class IkigaiCandidateProfession(Base):
    __tablename__ = "ikigai_candidate_professions"
    id = Column(BigInteger, primary_key=True)
    test_session_id = Column(BigInteger, ForeignKey(...), nullable=False, unique=True)
    candidates_data = Column(JSONB, nullable=False)
    generated_at = Column(DateTime(timezone=True), server_default=func.now())
    # total_candidates  ← TIDAK ADA
    # generation_strategy ← TIDAK ADA
    # max_candidates_limit ← TIDAK ADA
    # CheckConstraint ← TIDAK ADA
    # Index ← TIDAK ADA
```

**Dampak:**  
- Skema model Python tidak sinkron dengan spesifikasi brief
- `result_service.py` sudah mencoba akses `candidate_record.total_candidates` (untuk `total_candidates_found` di response API hasil) — ini akan raise `AttributeError` saat runtime karena kolom tidak ada di model
- Migration Alembic yang sudah ada tidak membuat kolom-kolom ini, sehingga tabel di DB juga tidak akan punya kolom tersebut jika DB di-recreate

---

### Temuan 4 — MEDIUM: `pool_recycle=3600` seharusnya `1800`, dan `DB_POOL_RECYCLE` tidak ada di `config.py`

**File:** `app/db/session.py` dan `app/core/config.py`

**Masalah (dua bagian):**

**Bagian A** — `app/db/session.py` hardcode `pool_recycle=3600` (60 menit):
```python
# Kondisi sekarang — HARDCODE SALAH
engine = create_engine(
    DATABASE_URL,
    pool_recycle=3600   # ← seharusnya 1800 (30 menit)
)
```

**Bagian B** — Brief halaman 65 dan 102 menetapkan nilai ini seharusnya diambil dari `settings.DB_POOL_RECYCLE`, tapi field `DB_POOL_RECYCLE` sama sekali tidak ada di `config.py`. Cara yang benar adalah mendefinisikan field ini di config, lalu `session.py` menggunakannya dari settings — bukan hardcode langsung.

**Dampak:**  
Koneksi DB ke server PostgreSQL online di-recycle setiap 60 menit, padahal standar untuk DB remote adalah 30 menit. Ini meningkatkan risiko koneksi stale yang menyebabkan intermittent error pada request yang pakai koneksi lama.

---

### Temuan 5 — RENDAH: Blok DEPRECATED di `scoring_utils.py` masih ada

**File:** `app/shared/scoring_utils.py`

**Masalah:**  
File masih mengandung 4 fungsi berlabel `DEPRECATED` (baris 62–174):
- `calculate_min_max_normalization`
- `calculate_ikigai_dimension_average`
- `calculate_confidence_adjusted_click`
- `calculate_final_profession_score` (formula lama: RIASEC 40% + Ikigai 50% + click 10%)

Fungsi-fungsi ini menggunakan formula yang sudah tidak sesuai dengan Brief Ikigai Part 2 §3.2. Tidak ada satu file pun yang mengimportnya saat ini, tapi keberadaannya berisiko: engineer baru bisa salah menggunakannya dan mengira masih valid.

**Catatan tambahan:** `ikigai_service.py` masih mengimport `calculate_min_max_normalization` dari file ini padahal tidak dipakai di mana pun — dead import yang menyambung ke masalah ini.

---

## 3. File yang Harus Diubah

| File | Aksi | Temuan |
|---|---|---|
| `app/api/v1/categories/career_profile/models/profession.py` | **Modifikasi** | Tambah 3 kolom + CheckConstraint + Index |
| `app/api/v1/categories/career_profile/schemas/session.py` | **Modifikasi** | Tambah `field_validator` di kedua schema |
| `app/api/v1/categories/career_profile/services/session_service.py` | **Modifikasi** | Ubah `CAREER_PROFILE_CATEGORY_ID = 1` → `3` |
| `app/core/config.py` | **Modifikasi** | Tambah `DB_POOL_RECYCLE: int = 1800` |
| `app/db/session.py` | **Modifikasi** | Ganti hardcode `pool_recycle=3600` → `pool_recycle=settings.DB_POOL_RECYCLE` |
| `app/shared/scoring_utils.py` | **Modifikasi** | Hapus blok DEPRECATED (baris 62–174) |

---

## 4. Source Code Lengkap Per File

---

### File 1: `app/api/v1/categories/career_profile/models/profession.py`

**Perubahan:** Tambah kolom `total_candidates`, `generation_strategy`, `max_candidates_limit`, `CheckConstraint`, dan `Index` sesuai Brief halaman 594–626.

```python
# app/api/v1/categories/career_profile/models/profession.py

from sqlalchemy import Column, BigInteger, Integer, String, ForeignKey, CheckConstraint, Index
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import TIMESTAMP
from sqlalchemy.sql import func
from app.db.base import Base


class IkigaiCandidateProfession(Base):
    """
    Menyimpan daftar kandidat profesi yang digenerate saat RIASEC selesai.
    One-to-one dengan careerprofile_test_sessions.
    INSERT sekali, immutable — tidak pernah di-UPDATE setelah dibuat.

    Kandidat terbagi dua kategori:
      - display_order 1–5  : Kandidat Opsi   → tampil di UI Ikigai sebagai pilihan user
      - display_order 6–30 : Kandidat Pool   → ikut AI scoring tapi tidak tampil di UI

    candidates_data JSONB format:
    {
      "candidates": [
        {
          "profession_id": int,
          "display_order": int,       # 1–5 opsi, 6–30 pool
          "congruence_type": str,     # "exact_match" | "permutation_match" | ...
          "congruence_score": float,  # 0.0–1.0
          "tier": int                 # 1–4 (tier ekspansi RIASEC)
        },
        ...
      ]
    }
    """
    __tablename__ = "ikigai_candidate_professions"

    id = Column(BigInteger, primary_key=True, autoincrement=True)

    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True  # One-to-one dengan session
    )

    # JSONB utama — berisi array kandidat lengkap
    candidates_data = Column(JSONB, nullable=False)

    # Denormalisasi untuk analytics cepat (tanpa parse JSON setiap query)
    # Minimum 1 (bukan 5) — constraint 5 terlalu ketat saat data profesi masih sedikit.
    # Validasi "idealnya >= 5" dilakukan di service layer sebagai warning log, bukan hard fail.
    total_candidates = Column(Integer, nullable=False)

    # Strategi yang digunakan saat generate kandidat:
    # "4_tier_expansion" → ekspansi 4 tier dari kode RIASEC user
    # "split_path"       → profil split (kode ambigu / tidak dominan)
    generation_strategy = Column(String(50), nullable=True)

    # Batas maksimum kandidat yang boleh digenerate (default 30)
    max_candidates_limit = Column(Integer, default=30)

    generated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    __table_args__ = (
        Index("idx_ikigai_candidates_session", "test_session_id"),
        # Minimum 1 bukan 5: mencegah hard fail saat DB profesi belum lengkap.
        # Naikkan minimum ke 5 setelah data produksi sudah cukup terisi.
        CheckConstraint(
            "total_candidates BETWEEN 1 AND 30",
            name="chk_total_candidates_range"
        ),
    )

    def __repr__(self):
        return (
            f"<IkigaiCandidateProfession "
            f"session={self.test_session_id} "
            f"total={self.total_candidates} "
            f"strategy={self.generation_strategy}>"
        )
```

---

### File 2: `app/api/v1/categories/career_profile/schemas/session.py`

**Perubahan:** Tambah `field_validator` di `StartRecommendationRequest` (hanya PATHFINDER/BUILDER/ACHIEVER) dan `StartFitCheckRequest` (hanya BUILDER/ACHIEVER), sesuai Brief halaman 635–656.

```python
# app/api/v1/categories/career_profile/schemas/session.py

from pydantic import BaseModel, field_validator
from typing import List


class StartRecommendationRequest(BaseModel):
    """
    Request body untuk endpoint POST /career-profile/recommendation/start.

    Validasi persona_type:
      - Hanya menerima: PATHFINDER, BUILDER, ACHIEVER
      - FIT_CHECK tidak ada di sini karena endpoint berbeda
    """
    persona_type: str  # PATHFINDER / BUILDER / ACHIEVER

    @field_validator("persona_type")
    @classmethod
    def validate_persona(cls, v: str) -> str:
        valid = {"PATHFINDER", "BUILDER", "ACHIEVER"}
        if v not in valid:
            raise ValueError(
                f"persona_type '{v}' tidak valid untuk RECOMMENDATION. "
                f"Pilih dari: {sorted(valid)}"
            )
        return v


class StartFitCheckRequest(BaseModel):
    """
    Request body untuk endpoint POST /career-profile/fit-check/start.

    Validasi persona_type:
      - Hanya menerima: BUILDER, ACHIEVER
      - PATHFINDER tidak bisa FIT_CHECK karena belum punya profesi target
    """
    persona_type: str
    target_profession_id: int  # Wajib: ID profesi yang mau dicek kecocokannya

    @field_validator("persona_type")
    @classmethod
    def validate_persona(cls, v: str) -> str:
        valid = {"BUILDER", "ACHIEVER"}
        if v not in valid:
            raise ValueError(
                f"persona_type '{v}' tidak valid untuk FIT_CHECK. "
                f"FIT_CHECK hanya tersedia untuk: {sorted(valid)}"
            )
        return v


class StartSessionResponse(BaseModel):
    """
    Response setelah sesi tes berhasil dibuat.
    Dikirim ke Flutter sebagai konfirmasi + data soal.
    """
    session_token: str
    test_goal: str           # RECOMMENDATION / FIT_CHECK
    status: str              # riasec_ongoing
    question_ids: List[int]  # Urutan 72 ID soal — Flutter harus tampilkan sesuai urutan ini
    total_questions: int     # Selalu 72
    message: str
```

---

### File 3: `app/api/v1/categories/career_profile/services/session_service.py`

**Perubahan:** Ubah `CAREER_PROFILE_CATEGORY_ID = 1` menjadi `3` sesuai Brief halaman 764. Tidak ada perubahan lain pada logika service.

```python
# app/api/v1/categories/career_profile/services/session_service.py

import uuid
import random
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.db.models.user import User
from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from app.api.v1.categories.career_profile.models.riasec import RIASECQuestionSet
from app.db.models.kenalidiri_history import KenaliDiriHistory
from app.api.v1.dependencies.token import check_and_deduct_token

# ID kategori "Tes Profil Karier" di tabel kenalidiri_categories
# category_code = CAREER_PROFILE, id = 3 (sesuai seed data)
# PERBAIKAN: nilai sebelumnya salah (1), seharusnya 3
CAREER_PROFILE_CATEGORY_ID = 3


class SessionService:
    def __init__(self, db: Session):
        self.db = db

    def start_session(
        self,
        user: User,
        persona_type: str,
        test_goal: str,
        uses_ikigai: bool,
        target_profession_id: int | None
    ) -> dict:
        """
        Setup lengkap sesi tes baru dalam satu transaksi:
        1. Potong token (hanya RECOMMENDATION)
        2. INSERT careerprofile_test_sessions
        3. INSERT kenalidiri_history (dengan category_id = 3)
        4. Generate & INSERT riasec_question_sets
        5. Return session_token + question_ids ke Flutter

        Seluruh langkah di atas atomik — jika salah satu gagal,
        semua di-rollback termasuk potongan token.
        """
        try:
            # === STEP 1: Token check (hanya RECOMMENDATION) ===
            if test_goal == "RECOMMENDATION":
                check_and_deduct_token(
                    user=user,
                    db=self.db,
                    amount=3,
                    description="Pemakaian Tes Profil Karier — Rekomendasi Profesi"
                )

            # === STEP 2: INSERT careerprofile_test_sessions ===
            session_token = str(uuid.uuid4())

            new_session = CareerProfileTestSession(
                user_id=user.id,
                session_token=session_token,
                persona_type=persona_type,
                test_goal=test_goal,
                target_profession_id=target_profession_id,
                uses_ikigai=uses_ikigai,
                status="riasec_ongoing",
                algorithm_version="1.0",
                question_set_version="1.0"
            )
            self.db.add(new_session)
            self.db.flush()  # Dapatkan ID tanpa commit dulu

            # === STEP 3: INSERT kenalidiri_history ===
            # Menggunakan CAREER_PROFILE_CATEGORY_ID = 3 (bukan 1)
            history_entry = KenaliDiriHistory(
                user_id=user.id,
                test_category_id=CAREER_PROFILE_CATEGORY_ID,
                detail_session_id=new_session.id,
                status="ongoing"
            )
            self.db.add(history_entry)

            # === STEP 4: Generate urutan soal & INSERT riasec_question_sets ===
            question_ids = self._generate_question_ids(session_token)

            question_set = RIASECQuestionSet(
                test_session_id=new_session.id,
                question_ids=question_ids,
            )
            self.db.add(question_set)

            # === STEP 5: Commit semua sekaligus (atomik) ===
            self.db.commit()

            return {
                "session_token": session_token,
                "test_goal": test_goal,
                "status": "riasec_ongoing",
                "question_ids": question_ids,
                "total_questions": len(question_ids),
                "message": (
                    "Sesi tes berhasil dibuat. "
                    "Tampilkan 72 soal ke user sesuai urutan question_ids yang diterima. "
                    "Flutter yang handle pembagian per halaman."
                )
            }

        except HTTPException:
            self.db.rollback()
            raise
        except Exception as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal membuat sesi tes: {str(e)}"
            )

    def _generate_question_ids(self, session_token: str) -> list[int]:
        """
        Generate urutan 72 ID soal (12 soal per tipe RIASEC), diacak urutannya.

        Seed dari session_token agar urutan tetap konsisten kalau user refresh.
        Dengan seed yang sama, urutan selalu identik.

        Struktur riasec_questions (72 soal total):
        - ID 1-12   → tipe R (Realistic)
        - ID 13-24  → tipe I (Investigative)
        - ID 25-36  → tipe A (Artistic)
        - ID 37-48  → tipe S (Social)
        - ID 49-60  → tipe E (Enterprising)
        - ID 61-72  → tipe C (Conventional)

        Semua 72 soal diambil, lalu diacak urutannya (tidak dikelompokkan per tipe).
        Flutter yang handle pembagian per halaman dari 72 soal ini.
        """
        random.seed(session_token)

        type_ranges = {
            "R": list(range(1, 13)),
            "I": list(range(13, 25)),
            "A": list(range(25, 37)),
            "S": list(range(37, 49)),
            "E": list(range(49, 61)),
            "C": list(range(61, 73)),
        }

        # Ambil SEMUA 72 soal (12 per tipe)
        all_questions = []
        for riasec_type, pool in type_ranges.items():
            all_questions.extend(pool)

        # Acak urutan tampil (bukan dikelompokkan per tipe)
        random.shuffle(all_questions)
        return all_questions

    def get_session_by_token(self, session_token: str) -> CareerProfileTestSession:
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session token tidak valid atau tidak ditemukan"
            )
        return session
```

---

### File 4: `app/core/config.py`

**Perubahan:** Tambah field `DB_POOL_RECYCLE: int = 1800` sesuai Brief halaman 65. Field ini kemudian digunakan oleh `session.py` sehingga nilai tidak lagi hardcode.

```python
# app/core/config.py

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str
    APP_VERSION: str
    ENV: str = "development"

    DATABASE_URL: str
    SQLALCHEMY_POOL_SIZE: int = 20
    SQLALCHEMY_MAX_OVERFLOW: int = 40

    # Pool recycle — recycle koneksi DB tiap 30 menit
    # Penting untuk DB remote/online agar koneksi stale tidak menyebabkan error
    # Brief RIASEC halaman 65 & 102: nilai 1800 (30 menit)
    DB_POOL_RECYCLE: int = 1800

    # Redis
    REDIS_URL: str

    # Celery
    CELERY_BROKER_URL: str

    # OpenRouter AI
    OPENROUTER_API_KEY: str
    OPENROUTER_BASE_URL: str = "https://openrouter.ai/api/v1"
    OPENROUTER_MODEL: str = "google/gemini-3-flash-preview"

    # AI Settings
    AI_MAX_TOKENS: int = 2000
    AI_TEMPERATURE: float = 0.7

    # Security
    SECRET_KEY: str

    # Monitoring
    SENTRY_DSN: str | None = None
    LOG_LEVEL: str = "INFO"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()
```

---

### File 5: `app/db/session.py`

**Perubahan:** Ganti hardcode `pool_recycle=3600` menjadi `pool_recycle=settings.DB_POOL_RECYCLE` sesuai Brief halaman 102.

```python
# app/db/session.py

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from app.core.config import settings
from typing import Generator

DATABASE_URL = settings.DATABASE_URL

# pool_recycle diambil dari settings (default 1800 = 30 menit)
# Brief RIASEC halaman 102: pool_recycle=settings.DB_POOL_RECYCLE
# Penting untuk DB remote: koneksi stale di-recycle sebelum timeout dari sisi server
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,                          # Verify connections before using
    pool_size=settings.SQLALCHEMY_POOL_SIZE,
    max_overflow=settings.SQLALCHEMY_MAX_OVERFLOW,
    echo=False,                                  # Set to True untuk debug SQL (dev only)
    pool_timeout=30,
    pool_recycle=settings.DB_POOL_RECYCLE        # 1800 detik = 30 menit
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    expire_on_commit=False
)


def get_db() -> Generator[Session, None, None]:
    """
    Dependency function untuk FastAPI endpoints.

    Menyediakan database session dan memastikan session ditutup
    setelah request selesai.

    Usage:
        @app.get("/example")
        def example(db: Session = Depends(get_db)):
            pass
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_db_context():
    """
    Context manager untuk database session di luar FastAPI
    (scripts, background tasks).

    Usage:
        with get_db_context() as db:
            pass
    """
    db = SessionLocal()
    try:
        return db
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
```

---

### File 6: `app/shared/scoring_utils.py`

**Perubahan:** Hapus seluruh blok DEPRECATED (4 fungsi lama yang menggunakan formula tidak sesuai Brief Ikigai Part 2). Fungsi yang valid (`calculate_text_score`, `calculate_click_score`, `normalize_score_to_percentage`, `get_match_level`) dipertahankan.

**Catatan tambahan:** Setelah file ini diubah, hapus juga import `calculate_min_max_normalization` yang sudah tidak dipakai di `ikigai_service.py` baris 30.

```python
# app/shared/scoring_utils.py
"""
Scoring Utilities — Kenali Diri

Berisi fungsi helper untuk kalkulasi skor dalam pipeline Career Profile.

Formula Resmi (Brief Ikigai Part 2 §3.2):
  T_p,d = 15% × R_normalized(p,d) × 100    → range 0.0–15.0
  A_p,d = 10% × C_p,d × R_raw(p,d) × 100  → range 0.0–10.0 (hanya jika dipilih)
  S_p,d = T_p,d + A_p,d                    → range 0.0–25.0
  Score_total(p) = S_p,love + S_p,good_at + S_p,world + S_p,paid  → range 0–100
"""


def calculate_text_score(r_normalized: float) -> float:
    """
    Hitung text score per profesi per dimensi.

    Formula: T_p,d = 15% × R_normalized(p,d) × 100
    Range output: 0.0 – 15.0

    Args:
        r_normalized: Nilai normalisasi min-max dari r_raw Gemini (0.0–1.0)

    Returns:
        Float antara 0.0 dan 15.0
    """
    r_normalized = max(0.0, min(1.0, r_normalized))
    return round(0.15 * r_normalized * 100, 4)


def calculate_click_score(r_raw: float, is_selected: bool) -> float:
    """
    Hitung click score per profesi per dimensi (confidence-based).

    Formula: A_p,d = 10% × C_p,d × R_raw(p,d) × 100
      - Menggunakan R_raw (bukan R_normalized) sebagai ukuran keyakinan AI
        sebelum distorsi normalisasi (confidence-based adjustment)
      - C_p,d = 1 jika profesi ini yang dipilih user di dimensi ini, 0 jika tidak
    Range output: 0.0 – 10.0

    Args:
        r_raw: Nilai mentah dari Gemini sebelum normalisasi (0.0–1.0)
        is_selected: True jika profesi ini yang dipilih user di dimensi ini

    Returns:
        Float antara 0.0 dan 10.0
    """
    if not is_selected:
        return 0.0
    r_raw = max(0.0, min(1.0, r_raw))
    return round(0.10 * r_raw * 100, 4)


def normalize_score_to_percentage(score: float, decimals: int = 1) -> float:
    """
    Konversi normalized score (0.0–1.0) ke persentase (0–100).

    Args:
        score: Normalized score antara 0.0 dan 1.0
        decimals: Jumlah desimal (default 1)

    Returns:
        Persentase antara 0 dan 100
    """
    percentage = max(0.0, min(1.0, score)) * 100
    return round(percentage, decimals)


def get_match_level(score: float) -> str:
    """
    Konversi skor numerik ke label kecocokan yang dapat dibaca manusia.

    Threshold:
        0.0 – 0.29 : "Low Match"
        0.3 – 0.49 : "Moderate Match"
        0.5 – 0.69 : "Good Match"
        0.7 – 0.84 : "Strong Match"
        0.85 – 1.0 : "Excellent Match"

    Args:
        score: Normalized score antara 0.0 dan 1.0

    Returns:
        String label kecocokan
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
```

---

## Catatan Penutup

**Urutan pengerjaan yang disarankan:**

1. `config.py` → tambah `DB_POOL_RECYCLE` dulu agar tidak breaking saat `session.py` diubah
2. `session.py` → ganti hardcode setelah config siap
3. `session_service.py` → ubah konstanta (perubahan terkecil, dampak terbesar — prioritaskan)
4. `schemas/session.py` → tambah validator
5. `models/profession.py` → tambah kolom + constraint
6. `scoring_utils.py` → hapus blok deprecated + hapus dead import di `ikigai_service.py`

**Setelah selesai, perlu dibuat migration Alembic baru** untuk kolom `total_candidates`, `generation_strategy`, `max_candidates_limit` di tabel `ikigai_candidate_professions` agar skema DB di-update ke kondisi yang sesuai model.
