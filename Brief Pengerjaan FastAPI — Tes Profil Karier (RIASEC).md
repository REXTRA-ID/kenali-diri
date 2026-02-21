---
title: Brief Pengerjaan FastAPI — Tes Profil Karier (RIASEC)

---

# Brief Pengerjaan FastAPI — Tes Profil Karier (RIASEC)
**Engineer:** Ariel — AI Engineer Rextra  
**Scope:** RIASEC — berlaku untuk alur RECOMMENDATION dan FIT_CHECK  
**Database:** PostgreSQL (shared dengan Golang CRUD system)  
**Stack:** FastAPI + SQLAlchemy + Alembic + Redis + Prometheus  
**Versi Brief:** 2.0 — Lengkap dengan semua koreksi dari bedah project

---

## Konteks Arsitektur

FastAPI yang kamu kerjakan adalah **layanan AI terpisah** yang berbagi database PostgreSQL yang sama dengan Golang (CRUD system). Ini sepenuhnya valid dan umum dilakukan — keduanya connect ke instance PostgreSQL yang sama, selama konfigurasi koneksi benar dan tidak ada konflik schema ownership.

**Pembagian tanggung jawab:**
- **Golang**: CRUD umum — manajemen user, membership, token wallet, dll.
- **FastAPI**: Logic AI, scoring RIASEC, ekspansi kandidat, kalkulasi Ikigai, rekomendasi profesi.

FastAPI tidak perlu membuat ulang tabel milik Golang. Cukup baca/tulis sesuai FK yang sudah ada.

---

## Temuan dari Bedah Project (Harus Diperbaiki)

Sebelum melanjutkan coding, ada beberapa hal kritis di project yang sudah ada yang **wajib diperbaiki**:

**1. Duplikasi class `RIASECService`** di `riasec_service.py` — ada dua class dengan nama sama dalam satu file. Class kedua override class pertama. Ini fatal, harus di-merge jadi satu.

**2. Logika klasifikasi di `classification.py` tidak lengkap** — hanya cek `top_1 >= 40` dan `top_2 < 30`, tidak ada pengecekan gap absolut, gap relatif, dan semua kondisi bridge table yang benar. Wajib ditulis ulang sesuai spek.

**3. Model `RIASECQuestionSet` di `riasec.py` salah** — kolom di model itu seharusnya milik `riasec_results`, bukan `riasec_question_sets`. Model ini harus dikoreksi.

**4. Formula scoring di `scoring_utils.py` berbeda dari spek** — file ini pakai RIASEC weight 40% + Ikigai 50% + click 10%, padahal spek Ikigai mendefinisikan 4 dimensi masing-masing 25% (15% teks + 10% klik). Formula ini perlu direvisi saat masuk ke brief Ikigai.

**5. Kolom timestamp session salah default** — `riasec_completed_at` dan `ikigai_completed_at` di model session menggunakan `server_default=now()`, seharusnya `nullable=True` dan hanya diisi saat tahap itu selesai.

---

## Bagian 0 — Konfigurasi Database (Shared PostgreSQL)

### File: `app/core/config.py` — **MODIFIKASI**

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "Kenali Diri Career Profile API"
    APP_VERSION: str = "1.0.0"

    # === DATABASE — PostgreSQL online, shared dengan Golang ===
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "rextra_db"
    DB_USER: str = "postgres"
    DB_PASSWORD: str = ""

    # Connection pool (penting untuk layanan yang share DB)
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 20
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 1800  # Recycle koneksi tiap 30 menit

    @property
    def DATABASE_URL(self) -> str:
        return (
            f"postgresql://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    # === AI — OpenRouter (Gemini Flash) ===
    OPENROUTER_API_KEY: str = ""
    OPENROUTER_BASE_URL: str = "https://openrouter.ai/api/v1"
    OPENROUTER_MODEL: str = "google/gemini-flash-1.5"

    # === Redis ===
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
```

### File: `app/db/session.py` — **MODIFIKASI**

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_engine(
    settings.DATABASE_URL,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_timeout=settings.DB_POOL_TIMEOUT,
    pool_recycle=settings.DB_POOL_RECYCLE,
    pool_pre_ping=True,  # Auto-reconnect jika koneksi terputus
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### File: `.env` (untuk deploy ke server online)

```env
# PostgreSQL online — ganti sesuai environment
DB_HOST=db.youronlinehost.com
DB_PORT=5432
DB_NAME=rextra_db
DB_USER=postgres
DB_PASSWORD=your_secure_password

OPENROUTER_API_KEY=sk-or-...
REDIS_HOST=localhost
REDIS_PORT=6379
```

> **Catatan:** Pastikan IP server FastAPI sudah masuk whitelist/security group di PostgreSQL online-nya (Railway, Supabase, RDS, dsb). Jika pakai Supabase, gunakan connection string dari dashboard "Project Settings → Database → Connection string (URI)".

---

## Bagian 1 — Gerbang Akses (Access Control)

Sebelum user bisa memulai tes apapun, ada pengecekan bertahap. Pengecekan ini diimplementasikan menggunakan **FastAPI Dependency Injection (`Depends`)** — cara yang benar dan idiomatis untuk FastAPI.

### 1.1 Pengecekan Role User

Hanya role `USER` dan `EXPERT` yang boleh mengakses endpoint tes profil karier. Data ini ada di tabel `public.users` milik Golang.

### File: `app/api/v1/dependencies/auth.py` — **FILE BARU**

```python
# app/api/v1/dependencies/auth.py
from fastapi import Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.db.models.user import User
import uuid

ALLOWED_ROLES = {"USER", "EXPERT"}

async def get_current_user(
    x_user_id: str = Header(..., description="UUID user dari JWT yang sudah divalidasi Golang"),
    db: Session = Depends(get_db)
) -> User:
    """
    Ambil user dari DB berdasarkan x-user-id di header.
    
    Catatan implementasi:
    Header x-user-id dikirim Flutter setelah JWT divalidasi di Golang service.
    Untuk production yang lebih ketat, FastAPI bisa memvalidasi JWT secara mandiri
    menggunakan shared secret atau public key dari Golang auth service.
    Untuk sekarang, user_id di-lookup langsung ke database.
    """
    try:
        user_uuid = uuid.UUID(x_user_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Format user ID tidak valid"
        )

    user = db.query(User).filter(User.id == user_uuid).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User tidak ditemukan"
        )
    return user


async def require_career_test_role(
    current_user: User = Depends(get_current_user)
) -> User:
    """
    Pastikan user punya role yang diizinkan untuk tes profil karier.
    Role yang diizinkan: USER, EXPERT.
    """
    if current_user.role not in ALLOWED_ROLES:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Role '{current_user.role}' tidak memiliki akses ke tes profil karier"
        )
    return current_user


async def require_active_membership(
    current_user: User = Depends(require_career_test_role),
    db: Session = Depends(get_db)
) -> User:
    """
    Cek status membership user.
    
    === TODO: IMPLEMENTASI MEMBERSHIP (BELUM AKTIF) ===
    
    File yang perlu dimodifikasi saat diaktifkan:
    - app/db/models/membership.py  → tambah model UserMembership
    - app/api/v1/dependencies/auth.py → file ini, aktifkan logika di bawah
    
    Langkah implementasi:
    1. Konfirmasi nama tabel membership dengan tim Golang
       (kemungkinan: user_memberships / subscriptions / user_plans)
    2. Buat model SQLAlchemy di app/db/models/membership.py
    3. Query:
       membership = db.query(UserMembership).filter(
           UserMembership.user_id == current_user.id,
           UserMembership.status == "ACTIVE",
           UserMembership.expired_at > datetime.utcnow()
       ).first()
       if not membership:
           raise HTTPException(status_code=403, detail="Membership tidak aktif atau sudah expired")
    
    Untuk sekarang: semua user yang sudah lolos role check dianggap memiliki membership sah.
    """
    # TODO: Aktifkan pengecekan membership setelah nama tabel dikonfirmasi
    return current_user
```

### 1.2 Pemisahan Route: RECOMMENDATION vs FIT_CHECK

Pengecekan persona (`PATHFINDER`, `BUILDER`, `ACHIEVER`) **bukan tanggung jawab FastAPI**. Flutter yang menentukan endpoint mana yang dipanggil berdasarkan persona user. FastAPI cukup menyediakan **dua endpoint terpisah** untuk membedakan tujuan tes:

| Endpoint | Tujuan | Alur | Token |
|---|---|---|---|
| `POST /career-profile/recommendation/start` | Rekomendasi profesi | RIASEC → Ikigai | 3 token |
| `POST /career-profile/fit-check/start` | Cek kecocokan profesi target | RIASEC saja | Gratis (saat ini) |

Kedua alur **menggunakan RIASEC yang sama** — perbedaannya hanya di downstream (setelah RIASEC selesai, alur RECOMMENDATION lanjut ke Ikigai, FIT_CHECK tidak).

---

## Bagian 2 — Pengecekan & Pemotongan Token

### 2.1 Aturan Token

- **RECOMMENDATION**: potong 3 token dari `public.token_wallet`, catat di `public.token_ledger`
- **FIT_CHECK**: gratis (bebas akses untuk saat ini)

### File: `app/db/models/token.py` — **FILE BARU**

```python
# app/db/models/token.py
# Model ini membaca tabel milik Golang — JANGAN buat migrasi untuk tabel ini.
# Alembic hanya untuk tabel milik FastAPI.

from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base
import uuid

class TokenWallet(Base):
    __tablename__ = "token_wallet"
    __table_args__ = {"schema": "public"}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    balance = Column(Integer, nullable=False, default=0)
    updated_at = Column(DateTime(timezone=True))


class TokenLedger(Base):
    __tablename__ = "token_ledger"
    __table_args__ = {"schema": "public"}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    occurred_at = Column(DateTime(timezone=True), nullable=False)
    wallet_id = Column(UUID(as_uuid=True), nullable=False)
    direction = Column(String(3), nullable=False)   # "IN" atau "OUT"
    amount = Column(Integer, nullable=False)
    balance_before = Column(Integer, nullable=False)
    balance_after = Column(Integer, nullable=False)
    source_type = Column(String(100))               # "CAREER_PROFILE_TEST"
    source_id = Column(UUID(as_uuid=True))
    reference_id = Column(UUID(as_uuid=True))
    description = Column(String(500))
    metadata = Column(String)
    operator_id = Column(UUID(as_uuid=True))
    created_at = Column(DateTime(timezone=True), nullable=False)
    ref = Column(String)
```

### File: `app/api/v1/dependencies/token.py` — **FILE BARU**

```python
# app/api/v1/dependencies/token.py
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.db.models.token import TokenWallet, TokenLedger
from app.db.models.user import User
from datetime import datetime
import uuid

TOKEN_COST_RECOMMENDATION = 3

def check_and_deduct_token(
    user: User,
    db: Session,
    amount: int = TOKEN_COST_RECOMMENDATION,
    description: str = "Pemakaian Tes Profil Karier"
) -> TokenWallet:
    """
    Cek saldo token dan kurangi jika mencukupi.
    Update token_wallet dan tambah baris baru di token_ledger.
    
    Gunakan with_for_update() untuk hindari race condition
    saat user memulai tes dari beberapa device sekaligus.
    
    Raises:
        HTTP 402: Token tidak mencukupi
        HTTP 404: Wallet tidak ditemukan
    """
    wallet = db.query(TokenWallet).filter(
        TokenWallet.user_id == user.id
    ).with_for_update().first()

    if not wallet:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Token wallet user tidak ditemukan"
        )

    if wallet.balance < amount:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail=(
                f"Token tidak mencukupi. "
                f"Saldo: {wallet.balance} token, dibutuhkan: {amount} token."
            )
        )

    balance_before = wallet.balance
    balance_after = wallet.balance - amount

    # Update saldo di token_wallet
    wallet.balance = balance_after
    wallet.updated_at = datetime.utcnow()

    # Catat transaksi di token_ledger
    ledger_entry = TokenLedger(
        id=uuid.uuid4(),
        occurred_at=datetime.utcnow(),
        wallet_id=wallet.id,
        direction="OUT",
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        source_type="CAREER_PROFILE_TEST",
        description=description,
        created_at=datetime.utcnow()
    )
    db.add(ledger_entry)
    # CATATAN: commit dilakukan bersama insert sesi tes di session_service
    # agar atomic — kalau insert sesi gagal, potongan token juga di-rollback

    return wallet

# === CATATAN FIT_CHECK — PERLU DIROMBAK KE DEPAN ===
# FIT_CHECK saat ini bebas akses tanpa pengecekan token/kuota.
# Jika ke depan ada pembatasan (misal: 3x per bulan, atau berbayar token):
#
# File yang perlu dimodifikasi:
# - app/db/models/token.py → tambah model FitCheckQuota atau kolom kuota
# - app/api/v1/dependencies/token.py → file ini, tambah fungsi check_fit_check_quota()
# - app/api/v1/categories/career_profile/routers/session.py → tambah dependency di endpoint fit-check/start
# - app/api/v1/categories/career_profile/services/session_service.py → catat penggunaan kuota
```

---

## Bagian 3 — Memulai Tes (Insert Entity Awal)

Ketika user memulai tes, satu endpoint bertugas melakukan seluruh setup awal dalam **satu transaksi atomik**:

1. Potong token (hanya RECOMMENDATION)
2. INSERT `careerprofile_test_sessions`
3. INSERT `kenalidiri_history`
4. Generate urutan 72 soal acak (12 per tipe) → INSERT `riasec_question_sets`
5. Return `session_token` + `question_ids` ke Flutter

### 3.1 Model Session (Diperbaiki)

### File: `app/api/v1/categories/career_profile/models/session.py` — **MODIFIKASI**

```python
# app/api/v1/categories/career_profile/models/session.py
from sqlalchemy import Column, BigInteger, Boolean, String, TIMESTAMP, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.base import Base

class CareerProfileTestSession(Base):
    __tablename__ = "careerprofile_test_sessions"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    session_token = Column(String(100), nullable=False, unique=True)

    # Snapshot persona saat tes dibuat (tidak berubah meski user ganti persona)
    persona_type = Column(String(20), nullable=False)   # PATHFINDER / BUILDER / ACHIEVER

    # Tujuan tes
    test_goal = Column(String(20), nullable=False)          # RECOMMENDATION / FIT_CHECK
    target_profession_id = Column(BigInteger, nullable=True) # Hanya untuk FIT_CHECK
    uses_ikigai = Column(Boolean, nullable=False)            # True = RECOMMENDATION, False = FIT_CHECK

    # Status alur
    # Nilai yang valid: riasec_ongoing → riasec_completed → ikigai_ongoing → ikigai_completed → completed
    # Untuk FIT_CHECK: riasec_ongoing → riasec_completed → completed (skip ikigai)
    status = Column(String(30), nullable=False, default="riasec_ongoing")

    # Timestamp — PERBAIKAN: nullable=True, bukan server_default=now()
    started_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), nullable=False)
    riasec_completed_at = Column(TIMESTAMP(timezone=True), nullable=True)   # Diisi saat RIASEC selesai
    ikigai_completed_at = Column(TIMESTAMP(timezone=True), nullable=True)   # Diisi saat Ikigai selesai
    completed_at = Column(TIMESTAMP(timezone=True), nullable=True)          # Diisi saat seluruh tes selesai

    # Versioning untuk keperluan audit
    algorithm_version = Column(String(20), nullable=True, default="1.0")
    question_set_version = Column(String(20), nullable=True, default="1.0")

    __table_args__ = (
        Index("idx_careerprofile_sessions_user_id", "user_id"),
        Index("idx_careerprofile_sessions_token", "session_token"),
        Index("idx_careerprofile_sessions_status", "status"),
    )

    def __repr__(self):
        return f"<CareerProfileTestSession id={self.id} goal={self.test_goal} status={self.status}>"
```

### 3.2 Model RIASEC (Diperbaiki Total)

### File: `app/api/v1/categories/career_profile/models/riasec.py` — **MODIFIKASI (perbaiki semua model)**

```python
# app/api/v1/categories/career_profile/models/riasec.py
from sqlalchemy import (
    Column, BigInteger, String, Boolean, Integer,
    ForeignKey, Index, CheckConstraint
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.sql import func
from sqlalchemy import TIMESTAMP
from app.db.base import Base


class RIASECCode(Base):
    """Master data 156 kode RIASEC (6 single + 30 dual + 120 triple). Di-seed via scripts."""
    __tablename__ = "riasec_codes"

    id = Column(BigInteger, primary_key=True)
    riasec_code = Column(String(3), unique=True, nullable=False)
    riasec_title = Column(String(255), nullable=False)
    riasec_description = Column(String, nullable=True)
    strengths = Column(JSONB, server_default="'[]'")
    challenges = Column(JSONB, server_default="'[]'")
    strategies = Column(JSONB, server_default="'[]'")
    work_environments = Column(JSONB, server_default="'[]'")
    interaction_styles = Column(JSONB, server_default="'[]'")
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class RIASECQuestionSet(Base):
    """
    Menyimpan urutan 12 ID soal yang di-generate untuk satu sesi.
    PERBAIKAN: kolom ini hanya berisi question_ids (JSONB array), bukan skor.
    Skor ada di riasec_results, bukan di sini.
    """
    __tablename__ = "riasec_question_sets"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True   # One-to-one dengan session
    )
    # Array 72 integer, contoh: [15, 23, 8, 45, 67, 2, 38, 51, 12, 60, 19, 44, ...]
    # (72 soal total = 12 soal × 6 tipe, diacak urutannya — bukan dikelompokkan per tipe)
    # Urutan array = urutan tampil soal ke user
    question_ids = Column(JSONB, nullable=False)
    generated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class RIASECResponse(Base):
    """
    Menyimpan semua 72 jawaban user dalam satu baris JSONB.
    INSERT sekali saat user submit, tidak ada update bertahap.
    One-to-one dengan session.
    """
    __tablename__ = "riasec_responses"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True   # Satu baris per sesi, tidak boleh double insert
    )
    # Format: {"responses": [...72 items...], "total_questions": 72, "completed": true, "submitted_at": "..."}
    responses_data = Column(JSONB, nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class RIASECResult(Base):
    """
    Menyimpan hasil akhir klasifikasi RIASEC.
    One-to-one dengan session.
    """
    __tablename__ = "riasec_results"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )

    # Skor mentah per tipe (range 12-60: 12 soal × nilai 1-5)
    score_r = Column(Integer, nullable=False)
    score_i = Column(Integer, nullable=False)
    score_a = Column(Integer, nullable=False)
    score_s = Column(Integer, nullable=False)
    score_e = Column(Integer, nullable=False)
    score_c = Column(Integer, nullable=False)

    # Hasil klasifikasi
    riasec_code_id = Column(
        BigInteger,
        ForeignKey("riasec_codes.id", ondelete="RESTRICT"),
        nullable=False
    )
    riasec_code_type = Column(String(20), nullable=False)  # "single" / "dual" / "triple"
    is_inconsistent_profile = Column(Boolean, default=False, nullable=False)

    calculated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    __table_args__ = (
        CheckConstraint(
            "riasec_code_type IN ('single', 'dual', 'triple')",
            name="chk_riasec_results_classification_type"
        ),
        Index("idx_riasec_results_session", "test_session_id"),
    )
```

### 3.3 Model Kandidat Profesi

### File: `app/api/v1/categories/career_profile/models/profession.py` — **MODIFIKASI** (pastikan ada model ini)

```python
# app/api/v1/categories/career_profile/models/profession.py
from sqlalchemy import Column, BigInteger, Integer, String, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.sql import func
from sqlalchemy import TIMESTAMP
from app.db.base import Base


class IkigaiCandidateProfession(Base):
    """
    Menyimpan seluruh kandidat profesi hasil ekspansi 4-tier dari RIASEC.

    Berisi 1-30 profesi dalam JSONB candidates_data.
    Data ini IMMUTABLE setelah insert — tidak pernah di-UPDATE.

    Kolom display_order di dalam candidates_data menentukan profesi mana
    yang ditampilkan sebagai opsi UI (top 3-5) vs yang hanya jadi backup scoring.

    Insert terjadi tepat setelah submit RIASEC, sebelum Ikigai dimulai.

    Catatan generation_strategy:
    - "4_tier_expansion"  : profil normal (single/dual/triple non-opposite)
    - "split_path"        : profil inkonsisten (dua huruf dominant berlawanan,
                            misal R-S, I-E, A-C) — kandidat dikumpulkan dari
                            dua cluster adjacent terpisah, bukan kode gabungan.
    """
    __tablename__ = "ikigai_candidate_professions"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True  # One-to-one dengan session
    )

    # JSONB candidates_data — format lengkap lihat dokumentasi brief Ikigai Part 1
    # Struktur metadata mencakup field split_path_strategy: bool untuk
    # memberi sinyal ke Brief Part 2 bahwa profil ini perlu narasi dua jalur.
    candidates_data = Column(JSONB, nullable=False)

    # Denormalisasi untuk analytics cepat (tanpa parse JSON)
    # Minimum 1 bukan 5 — constraint 5 terlalu ketat saat data profesi masih sedikit.
    # Validasi "idealnya >= 5" dilakukan di level service sebagai warning log, bukan hard fail.
    total_candidates = Column(Integer, nullable=False)

    # "4_tier_expansion" atau "split_path"
    generation_strategy = Column(String(50))

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
```

### 3.4 Schema Request & Response (Session)

### File: `app/api/v1/categories/career_profile/schemas/session.py` — **MODIFIKASI**

```python
# app/api/v1/categories/career_profile/schemas/session.py
from pydantic import BaseModel, field_validator
from typing import Optional, List

class StartRecommendationRequest(BaseModel):
    persona_type: str  # PATHFINDER / BUILDER / ACHIEVER

    @field_validator("persona_type")
    def validate_persona(cls, v):
        if v not in {"PATHFINDER", "BUILDER", "ACHIEVER"}:
            raise ValueError("persona_type tidak valid")
        return v


class StartFitCheckRequest(BaseModel):
    persona_type: str
    target_profession_id: int  # Wajib: ID profesi yang mau dicek kecocokannya

    @field_validator("persona_type")
    def validate_persona(cls, v):
        if v not in {"BUILDER", "ACHIEVER"}:
            raise ValueError("FIT_CHECK hanya tersedia untuk BUILDER dan ACHIEVER")
        return v


class StartSessionResponse(BaseModel):
    session_token: str
    test_goal: str          # RECOMMENDATION / FIT_CHECK
    status: str             # riasec_ongoing
    question_ids: List[int] # Urutan 72 ID soal — Flutter harus tampilkan sesuai urutan ini
    total_questions: int    # Selalu 72
    message: str
```

### 3.5 Router Session (Dua Endpoint)

### File: `app/api/v1/categories/career_profile/routers/session.py` — **MODIFIKASI**

```python
# app/api/v1/categories/career_profile/routers/session.py
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.dependencies.auth import require_active_membership
from app.api.v1.categories.career_profile.services.session_service import SessionService
from app.api.v1.categories.career_profile.schemas.session import (
    StartRecommendationRequest,
    StartFitCheckRequest,
    StartSessionResponse
)
from app.db.models.user import User

router = APIRouter(prefix="/career-profile")


@router.post("/recommendation/start", response_model=StartSessionResponse)
@limiter.limit("10/hour")
async def start_recommendation(
    request: Request,
    body: StartRecommendationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Mulai tes Profil Karier — tujuan REKOMENDASI PROFESI.
    Alur lengkap: RIASEC → Ikigai → 2 rekomendasi profesi.
    Biaya: 3 token dipotong di awal.
    
    Dipanggil Flutter untuk semua persona, tapi umumnya PATHFINDER.
    """
    service = SessionService(db)
    return service.start_session(
        user=current_user,
        persona_type=body.persona_type,
        test_goal="RECOMMENDATION",
        uses_ikigai=True,
        target_profession_id=None
    )


@router.post("/fit-check/start", response_model=StartSessionResponse)
@limiter.limit("20/hour")
async def start_fit_check(
    request: Request,
    body: StartFitCheckRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Mulai tes Profil Karier — tujuan CEK KECOCOKAN PROFESI TARGET.
    Alur: RIASEC saja (kode RIASEC user disandingkan kode RIASEC profesi target).
    Biaya: Gratis saat ini.
    
    CATATAN — PERLU DIROMBAK KE DEPAN:
    Saat ini FIT_CHECK tidak ada pembatasan akses sama sekali.
    Jika ke depan ada kuota (misal 3x/bulan) atau berbayar token,
    tambahkan dependency check_fit_check_quota() dari token.py di sini.
    Lihat komentar di app/api/v1/dependencies/token.py untuk panduan implementasi.
    """
    service = SessionService(db)
    return service.start_session(
        user=current_user,
        persona_type=body.persona_type,
        test_goal="FIT_CHECK",
        uses_ikigai=False,
        target_profession_id=body.target_profession_id
    )
```

### 3.6 Session Service

### File: `app/api/v1/categories/career_profile/services/session_service.py` — **MODIFIKASI**

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
        3. INSERT kenalidiri_history
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
        
        Struktur riasec_questions.json (72 soal total):
        - ID 1-12   → tipe R (Realistic)
        - ID 13-24  → tipe I (Investigative)
        - ID 25-36  → tipe A (Artistic)
        - ID 37-48  → tipe S (Social)
        - ID 49-60  → tipe E (Enterprising)
        - ID 61-72  → tipe C (Conventional)
        
        Semua 72 soal diambil, lalu diacak urutannya (tidak dikelompokkan per tipe).
        Flutter yang handle pembagian per halaman dari 72 soal ini.
        
        Contoh output: [15, 23, 8, 45, 67, 2, 38, 51, 12, 60, 19, 44, ...]
        Urutan inilah yang dikirim ke Flutter untuk ditampilkan ke user.
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

        # Ambil SEMUA 72 soal (12 per tipe), bukan sample
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

## Bagian 4 — Submit Jawaban RIASEC

Flutter menampilkan 72 soal dalam beberapa halaman (Flutter yang membagi-bagi di sisi klien). Semua jawaban **dikumpulkan di Flutter** dan dikirim **sekali** saat user submit di halaman terakhir.

> **Kenapa tidak per halaman?**  
> Karena `riasec_responses` dirancang sebagai 1 baris per sesi — INSERT sekali, tidak ada UPDATE bertahap. Flutter cukup menyimpan jawaban sementara di state-nya, lalu kirim semua 72 sekaligus saat selesai.

### 4.1 Schema Submit

### File: `app/api/v1/categories/career_profile/schemas/riasec.py` — **MODIFIKASI**

```python
# app/api/v1/categories/career_profile/schemas/riasec.py
from pydantic import BaseModel, field_validator
from typing import List, Optional
from datetime import datetime

class RIASECAnswerItem(BaseModel):
    question_id: int
    question_type: str       # "R", "I", "A", "S", "E", atau "C"
    answer_value: int        # 1 (Sangat Tidak Setuju) - 5 (Sangat Setuju)
    answered_at: datetime    # Waktu user menjawab soal ini (untuk analytics)

    @field_validator("answer_value")
    def validate_answer(cls, v):
        if not (1 <= v <= 5):
            raise ValueError("answer_value harus antara 1 dan 5")
        return v

    @field_validator("question_type")
    def validate_question_type(cls, v):
        if v not in {"R", "I", "A", "S", "E", "C"}:
            raise ValueError(f"question_type tidak valid: {v}")
        return v


class RIASECSubmitRequest(BaseModel):
    session_token: str
    responses: List[RIASECAnswerItem]  # Harus tepat 72 item (12 soal × 6 tipe)

    @field_validator("responses")
    def validate_response_count(cls, v):
        if len(v) != 72:
            raise ValueError(f"Harus ada tepat 72 jawaban (12 per tipe RIASEC), diterima {len(v)}")
        return v


class RIASECScores(BaseModel):
    R: int
    I: int
    A: int
    S: int
    E: int
    C: int


class RIASECCodeInfo(BaseModel):
    riasec_code: str
    riasec_title: str
    riasec_description: Optional[str]
    strengths: List[str]
    challenges: List[str]
    strategies: List[str]
    work_environments: List[str]
    interaction_styles: List[str]


class CandidateProfessionItem(BaseModel):
    profession_id: int
    riasec_code_id: int
    expansion_tier: int          # 1=Exact, 2=Kongruen, 3=Subset, 4=Dominan
    congruence_type: str         # "exact_match", "congruent_permutation", dll
    congruence_score: float      # 0.0-1.0
    display_order: int           # Urutan untuk UI. Top 3-5 yang ditampilkan sebagai opsi Ikigai
    path: Optional[str] = None   # "A" atau "B" — hanya ada jika is_inconsistent_profile=True


class RIASECSubmitResponse(BaseModel):
    session_token: str
    test_goal: str
    status: str                             # "riasec_completed"
    scores: RIASECScores
    classification_type: str               # "single" / "dual" / "triple"
    is_inconsistent_profile: bool
    riasec_code_info: RIASECCodeInfo
    candidates: List[CandidateProfessionItem]
    total_candidates: int
    display_candidates_count: int          # Jumlah profesi yang ditampilkan sebagai opsi UI
    validity_warning: Optional[str] = None # Peringatan jika skor rendah
    next_step: str                          # "ikigai" atau "fit_check_result"
```

### 4.2 Router RIASEC

### File: `app/api/v1/categories/career_profile/routers/riasec.py` — **MODIFIKASI (bersihkan duplikasi)**

```python
# app/api/v1/categories/career_profile/routers/riasec.py
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.dependencies.auth import require_active_membership
from app.api.v1.categories.career_profile.services.riasec_service import RIASECService
from app.api.v1.categories.career_profile.schemas.riasec import (
    RIASECSubmitRequest,
    RIASECSubmitResponse
)
from app.db.models.user import User

router = APIRouter(prefix="/career-profile/riasec")


@router.post("/submit", response_model=RIASECSubmitResponse)
@limiter.limit("10/hour")
async def submit_riasec(
    request: Request,
    body: RIASECSubmitRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Submit 72 jawaban RIASEC sekaligus (12 soal × 6 tipe).
    
    Endpoint ini berlaku untuk RECOMMENDATION maupun FIT_CHECK.
    Perbedaannya hanya di field next_step pada response:
    - RECOMMENDATION → next_step: "ikigai"
    - FIT_CHECK       → next_step: "fit_check_result"
    """
    service = RIASECService(db)
    return service.submit_riasec_test(
        user=current_user,
        session_token=body.session_token,
        responses=body.responses
    )


@router.get("/result/{session_token}", response_model=RIASECSubmitResponse)
@limiter.limit("60/minute")
async def get_riasec_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil hasil RIASEC yang sudah tersimpan.
    Digunakan Flutter untuk reload halaman hasil tanpa submit ulang.
    """
    service = RIASECService(db)
    return service.get_result(session_token=session_token, user=current_user)
```

---

## Bagian 5 — Logic Inti: RIASEC Service (DITULIS ULANG TOTAL)

Ini bagian paling kritis. File lama **harus diganti total** karena ada duplikasi class dan logika klasifikasi yang tidak lengkap.

### File: `app/api/v1/categories/career_profile/services/riasec_service.py` — **GANTI TOTAL**

```python
# app/api/v1/categories/career_profile/services/riasec_service.py
"""
RIASEC Service — Ditulis Ulang

Mencakup:
1. Kalkulasi skor mentah (raw sum, bukan rata-rata)
2. Klasifikasi kode RIASEC LENGKAP (semua kondisi, bridge table, tie-breaker)
3. Validasi profil (low overall, severe low, invalid)
4. Lookup detail kode dari database
5. Ekspansi kandidat profesi (4-tier + Split-Path untuk profil inkonsisten)
6. Penyimpanan ke semua tabel
"""
from typing import Dict, List, Tuple, Optional, Any, Set
from itertools import permutations, combinations
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from datetime import datetime

from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from app.api.v1.categories.career_profile.models.riasec import (
    RIASECQuestionSet, RIASECResponse, RIASECResult, RIASECCode
)
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession
from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
from app.api.v1.categories.career_profile.schemas.riasec import RIASECAnswerItem
from app.db.models.user import User


# ============================================================
# KONSTANTA HEKSAGON HOLLAND
# ============================================================

# Pasangan opposite (berseberangan di heksagon)
OPPOSITE_PAIRS: Set[Tuple[str, str]] = {
    ("R", "S"), ("S", "R"),
    ("I", "E"), ("E", "I"),
    ("A", "C"), ("C", "A")
}

# Tipe adjacent (bersebelahan di heksagon)
ADJACENT_MAP: Dict[str, List[str]] = {
    "R": ["I", "C"],
    "I": ["R", "A"],
    "A": ["I", "S"],
    "S": ["A", "E"],
    "E": ["S", "C"],
    "C": ["E", "R"]
}

# Urutan default untuk tie-breaker
RIASEC_DEFAULT_ORDER = ["R", "I", "A", "S", "E", "C"]


# ============================================================
# FUNGSI HELPER (Bisa diuji unit secara independen)
# ============================================================

def sort_scores(scores: Dict[str, int]) -> List[Tuple[str, int]]:
    """
    Urutkan skor descending.
    
    Tie-breaker hierarki (sesuai PDF):
    1. Skor kompetensi user (jika tersedia dari data tambahan)
    2. Urutan default R-I-A-S-E-C sebagai fallback final
    
    CATATAN IMPLEMENTASI:
    Saat ini hanya menggunakan tie-breaker urutan default (langkah 2).
    Jika ke depan data skor kompetensi tersedia (misal dari asesmen tambahan),
    tambahkan parameter `competency_scores: Dict[str, int] = None` dan
    gunakan sebagai primary tie-breaker sebelum urutan default.
    
    Untuk mayoritas kasus praktis, tie-breaker urutan default sudah cukup
    karena tie exact antar tipe sangat jarang terjadi.
    
    Returns: [(type, score), ...] dari tertinggi ke terendah
    """
    return sorted(
        scores.items(),
        key=lambda x: (-x[1], RIASEC_DEFAULT_ORDER.index(x[0]))
    )


def validate_scores(scores: Dict[str, int]) -> Optional[str]:
    """
    Validasi skor untuk mendeteksi profil tidak valid / skor rendah.
    
    Range skor: per tipe 12-60 (12 soal × nilai 1-5), total 72-360.
    
    Kategori dan tindakan:
    - Semua 6 tipe identik ekstrem → HTTP 422, wajib ulang (bukan sekadar tie)
    - Severe Low (total < 120)     → HTTP 422, tidak disimpan sebagai profil final
    - Low Overall Interest (< 150) → return warning string, tetap diproses
    - Normal                        → return None
    
    CATATAN: Tie Rank1-2, Rank1-2-3, atau Rank2-3 BUKAN invalid —
    itu ditangani oleh tie-breaker di sort_scores() dan classify_riasec_code().
    Hanya "semua 6 tipe identik" yang benar-benar tidak valid dan harus ditolak.
    """
    total = sum(scores.values())
    values = list(scores.values())

    # Invalid: semua 6 tipe identik (pola ekstrem — user asal pilih semua sama)
    # Berbeda dari tie rank 1-2 atau 1-2-3 yang masih bisa diproses
    if len(set(values)) == 1:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=(
                "Profil tidak valid: semua skor RIASEC identik. "
                "Hasil tidak dapat diproses. Silakan ulangi asesmen dengan lebih cermat."
            )
        )

    # Severe Low: total < 120 dari maksimum 360 (72 soal × nilai 5)
    if total < 120:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=(
                f"Skor keseluruhan terlalu rendah (total: {total} dari maksimum 360). "
                "Hasil tidak dapat disimpan sebagai profil final. "
                "Silakan ulangi asesmen."
            )
        )

    # Low Overall Interest: total < 150 — tetap diproses tapi beri peringatan
    if total < 150:
        return (
            f"Skor keseluruhan rendah (total: {total}). "
            "Hasil profil mungkin belum optimal. Disarankan untuk eksplorasi minat lebih lanjut."
        )

    return None  # Skor normal, tidak ada peringatan


def classify_riasec_code(scores: Dict[str, int]) -> Tuple[str, str, bool]:
    """
    Klasifikasi kode RIASEC: 1 huruf, 2 huruf, atau 3 huruf.
    
    Alur: cek 1 huruf → jika gagal cek 2 huruf → jika gagal fallback 3 huruf.
    
    Returns:
        Tuple[riasec_code, classification_type, is_inconsistent_profile]
        Contoh: ("RIA", "triple", False) atau ("RS", "dual", True)
    
    Aturan lengkap:
    
    KODE 1 HURUF — semua syarat harus terpenuhi:
        - Syarat 1 (Gap Absolut): rank1 - rank2 >= 9
        - Syarat 2 (Gap Relatif): (rank1 - rank2) / rank1 >= 0.15
        - Syarat 3 (Skor Minimum): rank1 >= 40
    
    KODE 2 HURUF — semua syarat harus terpenuhi:
        - Syarat 1: rank1 - rank2 < 9  (dua tipe teratas berdekatan)
        - Syarat 2: rank2 - rank3 >= 9 (ada jarak jelas antara tipe ke-2 dan ke-3)
        - Syarat 3: rank2 >= 30        (tipe kedua tidak boleh lemah)
        - Syarat 4: rank1 >= 40        (tipe pertama harus cukup kuat)
        Note: Jika rank1 dan rank2 adalah opposite → is_inconsistent = True
        
    KODE 3 HURUF (Fallback):
        - Low Differentiation: gap 1-2 < 9 DAN gap 2-3 < 9
        - Low Overall Interest: rank1 < 40
        - Forced Fallback: gagal syarat 2 huruf
    
    Bridge Table (2 huruf → 3 huruf):
        rank1 >= 40, gap 1-2 < 9, gap 2-3 >= 9, rank2 >= 30 → 2 HURUF
        rank1 >= 40, gap 1-2 < 9, gap 2-3 < 9,  rank2 >= 30 → 3 HURUF
        rank1 >= 40, gap 1-2 < 9, gap 2-3 >= 9, rank2 < 30  → 3 HURUF
        rank1 < 40,  apapun                                   → 3 HURUF

    KASUS TIE:
        - Tie Rank1-2      → bisa tetap jadi 2 huruf jika syarat terpenuhi.
                             PDF: cek skor kompetensi dulu, fallback ke R-I-A-S-E-C.
                             Brief saat ini: pakai urutan default R-I-A-S-E-C langsung
                             (lihat catatan di sort_scores tentang skor kompetensi).
        - Tie Rank1-2-3    → fallback 3 huruf otomatis (gap 1-2=0 < 9 DAN gap 2-3=0 < 9)
        - Tie Rank1-2-3-4  → low differentiation → 3 huruf. PDF: pilih 3 huruf berdasarkan
                             skor kompetensi; jika masih tied → Unranked Set.
                             Brief saat ini: tie-breaker urutan default R-I-A-S-E-C (edge case).
        - Tie Rank2-3      → rank1 tetap dominan, bisa jadi 1 huruf. Keduanya diperlakukan
                             setara di ekspansi kandidat Tier 2 dan Tier 3.
        - Tie semua 6      → sudah ditolak di validate_scores() sebelum sampai ke sini
    """
    sorted_scores = sort_scores(scores)

    rank1_type, rank1_score = sorted_scores[0]
    rank2_type, rank2_score = sorted_scores[1]
    rank3_type, rank3_score = sorted_scores[2]

    gap_1_2 = rank1_score - rank2_score
    gap_2_3 = rank2_score - rank3_score

    # ===== CEK KODE 1 HURUF =====
    if (
        rank1_score >= 40
        and gap_1_2 >= 9
        and (gap_1_2 / rank1_score) >= 0.15
    ):
        return (rank1_type, "single", False)

    # ===== CEK KODE 2 HURUF =====
    if (
        rank1_score >= 40
        and gap_1_2 < 9
        and gap_2_3 >= 9
        and rank2_score >= 30
    ):
        code = rank1_type + rank2_type
        is_inconsistent = (rank1_type, rank2_type) in OPPOSITE_PAIRS
        return (code, "dual", is_inconsistent)

    # ===== FALLBACK: KODE 3 HURUF =====
    # Termasuk kondisi: Tie Rank1-2-3 (gap keduanya = 0), Low Differentiation, Low Overall.
    # Profil 3 huruf juga bisa inkonsisten jika rank1-rank2 adalah opposite pair.
    # Dalam kasus ini split-path tetap diterapkan di ekspansi kandidat agar tidak ada
    # profesi "gabungan" yang dipaksakan dari dua kutub kepribadian yang berlawanan.
    code = rank1_type + rank2_type + rank3_type
    is_inconsistent = (rank1_type, rank2_type) in OPPOSITE_PAIRS
    return (code, "triple", is_inconsistent)


# ============================================================
# FUNGSI EKSPANSI KANDIDAT PROFESI
# ============================================================

def expand_profession_candidates(
    riasec_code: str,
    classification_type: str,
    is_inconsistent_profile: bool,
    sorted_scores: List[Tuple[str, int]],
    profession_repo: "ProfessionRepository"
) -> List[Dict[str, Any]]:
    """
    Ekspansi kandidat profesi menggunakan 4-tier algorithm.
    
    Target: 5-30 profesi disimpan (semua tier dikumpulkan).
    Dari total ini, top 3-5 (display_order 1-5) ditampilkan sebagai opsi UI Ikigai.
    Semua profesi tetap dinilai AI — termasuk yang tidak ditampilkan sebagai opsi,
    dipakai sebagai backup scoring saat user tidak memilih opsi apapun.

    CATATAN — 30 kandidat vs PDF maks 5:
    PDF menyebut "minimal 3, maksimal 5 profesi" untuk opsi UI.
    Brief ini menyimpan hingga 30 profesi karena Ikigai butuh pool kandidat lebih besar
    untuk scoring AI — termasuk profesi yang tidak ditampilkan sebagai opsi (backup scoring).
    Ini konsisten dengan prinsip "compute all, display top-N" di bagian Ikigai PDF.
    Yang ditampilkan ke user sebagai opsi pilihan tetap hanya top 3-5 (display_order <= 5).
    
    PENTING — Perbedaan Tier 2 untuk profil dual vs triple:

    Profil DUAL (2 huruf, misal RI):
      - Lapisan Primer: RI dan IR diperlakukan setara (gap kecil, urutan tidak signifikan)
      - Lapisan Sekunder: tambah huruf ketiga (Rank3) yang bukan opposite → RIA, IRA, dst
        Huruf ketiga masuk SETELAH lapisan primer, tidak dicampur dari awal.

    Profil TRIPLE (3 huruf, misal RIA):
      - Semua 6 permutasi (3! = 6) langsung dianggap setara — Unranked Set.
      - Tidak ada prioritas urutan karena gap antar ketiganya kecil.

    Tie Rank2-Rank3: kedua huruf diperlakukan setara di Tier 2 dan Tier 3.
    """
    if is_inconsistent_profile and len(riasec_code) >= 2:
        return _expand_split_path(riasec_code, sorted_scores, profession_repo)

    top_3_types = [t for t, _ in sorted_scores[:3]]
    rank2_score = sorted_scores[1][1]
    rank3_score = sorted_scores[2][1]

    candidates = []
    seen_ids: Set[int] = set()
    display_order = 1

    # === TIER 1: Exact Match ===
    for p in profession_repo.find_by_riasec_code(riasec_code):
        if p.id not in seen_ids:
            candidates.append(_build_candidate(p, 1, "exact_match", 1.0, display_order))
            seen_ids.add(p.id)
            display_order += 1

    # === TIER 2: Kode Kongruen ===
    if len(candidates) < 30:
        if classification_type == "dual":
            # Profil 2 huruf: Lapisan Primer (permutasi 2 huruf saja: RI dan IR)
            letter_a, letter_b = riasec_code[0], riasec_code[1]
            for pcode in [letter_a + letter_b, letter_b + letter_a]:
                if pcode != riasec_code:
                    for p in profession_repo.find_by_riasec_code(pcode):
                        if p.id not in seen_ids:
                            candidates.append(_build_candidate(p, 2, "congruent_primer", 0.95, display_order))
                            seen_ids.add(p.id)
                            display_order += 1

            # Lapisan Sekunder: tambah huruf ketiga yang bukan opposite
            rank3_type = top_3_types[2]
            opposite_of_a = next((b for a, b in OPPOSITE_PAIRS if a == letter_a), None)
            opposite_of_b = next((b for a, b in OPPOSITE_PAIRS if a == letter_b), None)
            if rank3_type not in {opposite_of_a, opposite_of_b}:
                for scode in [letter_a + letter_b + rank3_type, letter_b + letter_a + rank3_type]:
                    for p in profession_repo.find_by_riasec_code(scode):
                        if p.id not in seen_ids:
                            candidates.append(_build_candidate(p, 2, "congruent_secondary", 0.88, display_order))
                            seen_ids.add(p.id)
                            display_order += 1
        else:
            # Profil 3 huruf: Unranked Set — semua 6 permutasi setara
            for perm_code in ["".join(p) for p in permutations(top_3_types) if "".join(p) != riasec_code]:
                for p in profession_repo.find_by_riasec_code(perm_code):
                    if p.id not in seen_ids:
                        is_adj = _first_two_adjacent(perm_code)
                        ctype = "congruent_adjacent" if is_adj else "congruent_permutation"
                        candidates.append(_build_candidate(p, 2, ctype, 0.95 if is_adj else 0.85, display_order))
                        seen_ids.add(p.id)
                        display_order += 1

    # === TIER 3: Subset 2 Huruf dari Top 3 ===
    # Jika Rank2-Rank3 tied, semua subset diperlakukan setara
    if len(candidates) < 30:
        for subset_code in ["".join(pair) for pair in combinations(top_3_types, 2)]:
            for p in profession_repo.find_by_riasec_code(subset_code):
                if p.id not in seen_ids:
                    is_adj = _letters_adjacent(subset_code[0], subset_code[1])
                    ctype = "subset_adjacent" if is_adj else "subset_alternate"
                    candidates.append(_build_candidate(p, 3, ctype, 0.75 if is_adj else 0.65, display_order))
                    seen_ids.add(p.id)
                    display_order += 1

    # === TIER 4: Huruf Dominan Tunggal ===
    if len(candidates) < 30:
        for p in profession_repo.find_by_riasec_code(top_3_types[0]):
            if p.id not in seen_ids:
                candidates.append(_build_candidate(p, 4, "dominant_single", 0.55, display_order))
                seen_ids.add(p.id)
                display_order += 1

    return candidates[:30]


def _expand_split_path(
    riasec_code: str,
    sorted_scores: List[Tuple[str, int]],
    profession_repo: "ProfessionRepository"
) -> List[Dict[str, Any]]:
    """
    Split-Path Strategy untuk profil inkonsisten (opposite pair: RS, IE, atau AC).
    
    Dua huruf opposite diperlakukan sebagai dua jalur terpisah.
    Tidak dipaksakan jadi satu profesi gabungan karena tidak ada profesi
    yang benar-benar cocok untuk kepribadian yang saling berlawanan.
    
    Path A: huruf pertama + adjacent-nya
    Path B: huruf kedua + adjacent-nya
    
    Contoh profil RS (R opposite S):
    - Path A: cari profesi R, RI, RC
    - Path B: cari profesi S, SA, SE
    
    Tag path="A" atau path="B" dikirim ke Flutter agar bisa tampilkan
    narasi "Profilmu mencakup dua kutub yang berbeda..."
    """
    letter_a = riasec_code[0]
    letter_b = riasec_code[1]
    candidates = []
    seen_ids: Set[int] = set()
    display_order = 1

    def expand_one_path(letter: str, path_label: str):
        nonlocal display_order

        # Exact match huruf tunggal
        for p in profession_repo.find_by_riasec_code(letter):
            if p.id not in seen_ids:
                c = _build_candidate(p, 1, "exact_match", 1.0, display_order)
                c["path"] = path_label
                candidates.append(c)
                seen_ids.add(p.id)
                display_order += 1

        # Adjacent 2-huruf: cari KEDUA urutan (letter+adj dan adj+letter)
        # karena profil non-split memperlakukan RI dan IR setara,
        # split-path juga perlu konsisten mencari kedua arah.
        for adj in ADJACENT_MAP.get(letter, []):
            for code2 in [letter + adj, adj + letter]:
                for p in profession_repo.find_by_riasec_code(code2):
                    if p.id not in seen_ids:
                        c = _build_candidate(p, 2, "congruent_adjacent", 0.85, display_order)
                        c["path"] = path_label
                        candidates.append(c)
                        seen_ids.add(p.id)
                        display_order += 1

    expand_one_path(letter_a, "A")
    expand_one_path(letter_b, "B")
    return candidates[:30]


def _build_candidate(profession, tier: int, ctype: str, score: float, order: int) -> Dict:
    """
    Buat dict kandidat profesi untuk disimpan di JSONB candidates_data.

    CATATAN — Model Profession & ProfessionRepository:
    Fungsi ini mengasumsikan objek `profession` punya field .id dan .riasec_code_id.
    Model Profession dan ProfessionRepository tidak didefinisikan di brief ini
    karena scope-nya adalah RIASEC saja — profesi belum relevan di tahap ini.
    Penjelasan lengkap model Profession, FK ke riasec_codes, dan implementasi
    ProfessionRepository akan dibahas di Brief Part 2 (Ikigai).
    """
    return {
        "profession_id": profession.id,
        "riasec_code_id": profession.riasec_code_id,
        "expansion_tier": tier,
        "congruence_type": ctype,
        "congruence_score": score,
        "display_order": order,
        # "path" hanya ditambahkan jika is_inconsistent_profile=True (oleh pemanggil)
    }


def _first_two_adjacent(code: str) -> bool:
    """Cek apakah 2 huruf pertama kode bersifat adjacent di heksagon."""
    if len(code) < 2:
        return False
    return code[1] in ADJACENT_MAP.get(code[0], [])


def _letters_adjacent(a: str, b: str) -> bool:
    """Cek apakah dua huruf RIASEC bersifat adjacent."""
    return b in ADJACENT_MAP.get(a, [])


# ============================================================
# RIASEC SERVICE CLASS
# ============================================================

class RIASECService:
    """
    Orchestrator untuk seluruh alur submit RIASEC:
    validasi → kalkulasi → klasifikasi → simpan → ekspansi kandidat
    """

    def __init__(self, db: Session):
        self.db = db
        self.profession_repo = ProfessionRepository(db)

    def submit_riasec_test(
        self,
        user: User,
        session_token: str,
        responses: List[RIASECAnswerItem]
    ) -> dict:
        """
        Main method: terima 72 jawaban (12 per tipe), proses semua, return hasil lengkap.
        
        Alur di dalamnya:
        1. Validasi sesi (token valid, status benar, milik user ini)
        2. Validasi question_ids sesuai yang di-generate
        3. Hitung skor mentah (raw sum per tipe)
        4. Validasi skor (red flag check)
        5. Klasifikasi kode RIASEC
        6. Lookup detail kode dari tabel riasec_codes
        7. INSERT riasec_responses
        8. INSERT riasec_results
        9. Ekspansi kandidat profesi (4-tier / split-path)
        10. INSERT ikigai_candidate_professions
        11. UPDATE status sesi → riasec_completed
        12. Jika FIT_CHECK: UPDATE kenalidiri_history → completed, sesi → completed
        13. Return hasil lengkap
        """
        # 1. Validasi sesi
        session = self._validate_session(session_token, user)

        # 2. Validasi question_ids
        self._validate_question_ids(session.id, responses)

        # 3. Hitung skor
        scores = self._calculate_scores(responses)

        # 4. Validasi skor (raise jika invalid/severe, return warning jika low)
        validity_warning = validate_scores(scores)

        # 5. Klasifikasi kode RIASEC
        riasec_code, classification_type, is_inconsistent = classify_riasec_code(scores)

        # 6. Lookup detail kode dari database
        code_obj = self._get_riasec_code(riasec_code)

        # 7. Simpan jawaban
        self._save_responses(session.id, responses)

        # 8. Simpan hasil klasifikasi
        self._save_result(session.id, scores, code_obj.id, classification_type, is_inconsistent)

        # 9. Ekspansi kandidat profesi
        sorted_sc = sort_scores(scores)
        candidates = expand_profession_candidates(
            riasec_code=riasec_code,
            classification_type=classification_type,
            is_inconsistent_profile=is_inconsistent,
            sorted_scores=sorted_sc,
            profession_repo=self.profession_repo
        )

        # Peringatan jika kandidat kurang dari 3 (setelah semua tier)
        if len(candidates) < 3 and not validity_warning:
            validity_warning = (
                f"Hanya ditemukan {len(candidates)} profesi kandidat. "
                "Disarankan untuk eksplorasi minat lebih lanjut."
            )

        # 10. Simpan kandidat
        self._save_candidates(session.id, riasec_code, code_obj.id, scores, candidates, is_inconsistent)

        # 11. Update status sesi → riasec_completed
        self._mark_riasec_completed(session)

        # 12. Tentukan next step dan update history jika FIT_CHECK
        if session.test_goal == "FIT_CHECK":
            self._mark_fit_check_completed(session)
            next_step = "fit_check_result"
        else:
            next_step = "ikigai"

        # Hitung berapa yang ditampilkan sebagai opsi UI (display_order 1-5)
        display_count = len([c for c in candidates if c["display_order"] <= 5])

        self.db.commit()

        return {
            "session_token": session_token,
            "test_goal": session.test_goal,
            "status": session.status,
            "scores": {
                "R": scores["R"], "I": scores["I"], "A": scores["A"],
                "S": scores["S"], "E": scores["E"], "C": scores["C"]
            },
            "classification_type": classification_type,
            "is_inconsistent_profile": is_inconsistent,
            "riasec_code_info": {
                "riasec_code": code_obj.riasec_code,
                "riasec_title": code_obj.riasec_title,
                "riasec_description": code_obj.riasec_description,
                "strengths": code_obj.strengths or [],
                "challenges": code_obj.challenges or [],
                "strategies": code_obj.strategies or [],
                "work_environments": code_obj.work_environments or [],
                "interaction_styles": code_obj.interaction_styles or [],
            },
            "candidates": candidates,
            "total_candidates": len(candidates),
            "display_candidates_count": display_count,
            "validity_warning": validity_warning,
            "next_step": next_step
        }

    # ============================================================
    # PRIVATE HELPERS
    # ============================================================

    def _validate_session(self, session_token: str, user: User) -> CareerProfileTestSession:
        """Validasi sesi: ada, milik user ini, dan statusnya riasec_ongoing."""
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()

        if not session:
            raise HTTPException(status_code=404, detail="Session token tidak ditemukan")

        if str(session.user_id) != str(user.id):
            raise HTTPException(
                status_code=403,
                detail="Session ini bukan milik user yang sedang login"
            )

        if session.status != "riasec_ongoing":
            if session.status == "riasec_completed":
                detail_msg = "RIASEC sudah pernah disubmit untuk sesi ini. Gunakan GET /riasec/result/{token} untuk melihat hasilnya."
            elif session.status == "completed":
                detail_msg = "Sesi ini sudah selesai sepenuhnya."
            else:
                detail_msg = f"Status sesi tidak valid untuk submit RIASEC: '{session.status}'."
            raise HTTPException(status_code=400, detail=detail_msg)

        return session

    def _validate_question_ids(self, session_id: int, responses: List[RIASECAnswerItem]):
        """
        Pastikan question_id yang dikirim user persis sama dengan
        yang di-generate di awal sesi (tersimpan di riasec_question_sets).
        Total harus tepat 72 ID, tidak boleh ada duplikat.
        """
        question_set = self.db.query(RIASECQuestionSet).filter(
            RIASECQuestionSet.test_session_id == session_id
        ).first()

        if not question_set:
            raise HTTPException(
                status_code=404,
                detail="Question set tidak ditemukan untuk sesi ini. Mulai ulang sesi."
            )

        provided_ids = [r.question_id for r in responses]
        provided_ids_set = set(provided_ids)

        # Cek duplikat question_id — set() menghilangkan duplikat,
        # jadi 73 jawaban dengan satu ID double akan kelihatan seperti 72 unik
        # tanpa pengecekan ini. Flutter harusnya tidak kirim duplikat tapi tetap harus dicegah.
        if len(provided_ids) != len(provided_ids_set):
            dupes = [qid for qid in provided_ids_set if provided_ids.count(qid) > 1]
            raise HTTPException(
                status_code=400,
                detail=f"Terdapat question_id yang dikirim lebih dari satu kali: {dupes}"
            )

        expected_ids = set(question_set.question_ids)

        if expected_ids != provided_ids_set:
            missing = expected_ids - provided_ids_set
            extra = provided_ids_set - expected_ids
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Question ID tidak sesuai dengan soal yang diberikan. "
                    f"Kurang: {missing}, Berlebih: {extra}"
                )
            )

    def _calculate_scores(self, responses: List[RIASECAnswerItem]) -> Dict[str, int]:
        """
        Hitung skor mentah (RAW SUM) per tipe RIASEC.
        
        PENTING — Gunakan RAW SUM, BUKAN rata-rata:
        - 12 soal per tipe, nilai 1-5 per soal
        - Range skor per tipe: 12-60
        - Skor total range: 72-360
        
        Threshold klasifikasi (sesuai PDF):
        - Rank1 >= 40  → valid untuk kode 1 atau 2 huruf
        - Total < 120  → Severe Low (HTTP 422)
        - Total < 150  → Low Overall Interest (warning)
        
        question_type di setiap response dikirim langsung oleh Flutter
        berdasarkan data riasec_questions.json (tipe soal sudah diketahui Flutter).
        """
        scores = {"R": 0, "I": 0, "A": 0, "S": 0, "E": 0, "C": 0}
        for r in responses:
            scores[r.question_type] += r.answer_value
        return scores

    def _get_riasec_code(self, riasec_code: str) -> RIASECCode:
        """Ambil detail kode RIASEC dari tabel riasec_codes."""
        code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.riasec_code == riasec_code
        ).first()

        if not code_obj:
            raise HTTPException(
                status_code=404,
                detail=(
                    f"Kode RIASEC '{riasec_code}' tidak ditemukan di database. "
                    "Pastikan seed data riasec_codes sudah dijalankan (scripts/seed_riasec_codes.py)."
                )
            )
        return code_obj

    def _save_responses(self, session_id: int, responses: List[RIASECAnswerItem]):
        """INSERT ke riasec_responses — satu baris per sesi, tidak pernah di-update."""
        responses_data = {
            "responses": [
                {
                    "question_id": r.question_id,
                    "question_type": r.question_type,
                    "answer_value": r.answer_value,
                    "answered_at": r.answered_at.isoformat()
                }
                for r in responses
            ],
            "total_questions": 72,
            "completed": True,
            "submitted_at": datetime.utcnow().isoformat()
        }

        response_record = RIASECResponse(
            test_session_id=session_id,
            responses_data=responses_data
        )
        self.db.add(response_record)

    def _save_result(
        self,
        session_id: int,
        scores: Dict[str, int],
        riasec_code_id: int,
        classification_type: str,
        is_inconsistent: bool
    ):
        """INSERT ke riasec_results."""
        result = RIASECResult(
            test_session_id=session_id,
            score_r=scores["R"],
            score_i=scores["I"],
            score_a=scores["A"],
            score_s=scores["S"],
            score_e=scores["E"],
            score_c=scores["C"],
            riasec_code_id=riasec_code_id,
            riasec_code_type=classification_type,
            is_inconsistent_profile=is_inconsistent
        )
        self.db.add(result)

    def _save_candidates(
        self,
        session_id: int,
        riasec_code: str,
        riasec_code_id: int,
        scores: Dict[str, int],
        candidates: List[Dict],
        is_inconsistent: bool
    ):
        """
        INSERT ke ikigai_candidate_professions.
        
        Satu baris JSONB per sesi. IMMUTABLE — tidak pernah di-UPDATE setelah ini.
        
        Kolom candidates_data berisi metadata lengkap untuk keperluan Ikigai service:
        - Semua kandidat (5-30 profesi)
        - Metadata ekspansi
        - Strategi yang digunakan (4_tier_expansion atau split_path)
        """
        expansion_strategy = "split_path" if is_inconsistent else "4_tier_expansion"

        candidates_data = {
            "candidates": candidates,
            "metadata": {
                "total_candidates": len(candidates),
                "user_riasec_code_id": riasec_code_id,
                "user_riasec_code": riasec_code,
                "user_riasec_scores": scores,
                "is_inconsistent_profile": is_inconsistent,
                "expansion_strategy": expansion_strategy,
                "expansion_summary": {
                    "tier_1_exact": sum(1 for c in candidates if c["expansion_tier"] == 1),
                    "tier_2_congruent": sum(1 for c in candidates if c["expansion_tier"] == 2),
                    "tier_3_subset": sum(1 for c in candidates if c["expansion_tier"] == 3),
                    "tier_4_dominant": sum(1 for c in candidates if c["expansion_tier"] == 4),
                },
                "display_count": len([c for c in candidates if c["display_order"] <= 5]),
                "generated_at": datetime.utcnow().isoformat()
            }
        }

        candidate_record = IkigaiCandidateProfession(
            test_session_id=session_id,
            candidates_data=candidates_data,
            total_candidates=len(candidates),
            generation_strategy=expansion_strategy,
            max_candidates_limit=30
        )
        self.db.add(candidate_record)

    def _mark_riasec_completed(self, session: CareerProfileTestSession):
        """Update status sesi ke riasec_completed dan isi timestamp."""
        session.status = "riasec_completed"
        session.riasec_completed_at = datetime.utcnow()

    def _mark_fit_check_completed(self, session: CareerProfileTestSession):
        """
        Untuk FIT_CHECK: override status riasec_completed → completed sekaligus.

        CATATAN ALUR STATUS:
        _mark_riasec_completed() dipanggil duluan → status = "riasec_completed" (in-memory).
        Method ini lalu override ke "completed" sebelum commit terjadi.
        Jadi di database, status langsung masuk sebagai "completed" — tidak pernah
        tersimpan sebagai "riasec_completed" untuk sesi FIT_CHECK.

        Alur status FIT_CHECK (in-memory sebelum commit):
          riasec_ongoing → riasec_completed → completed  (hanya completed yang ter-commit)

        Alur status RECOMMENDATION:
          riasec_ongoing → riasec_completed  (ter-commit di sini)
          → ikigai_ongoing → ikigai_completed → completed  (di-commit di Ikigai service)
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

    def get_result(self, session_token: str, user: User) -> dict:
        """Ambil hasil RIASEC yang sudah tersimpan untuk reload halaman."""
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()

        if not session or str(session.user_id) != str(user.id):
            raise HTTPException(
                status_code=404,
                detail="Sesi tidak ditemukan atau bukan milik user ini"
            )

        result = self.db.query(RIASECResult).filter(
            RIASECResult.test_session_id == session.id
        ).first()

        if not result:
            raise HTTPException(
                status_code=404,
                detail="Hasil RIASEC belum tersedia untuk sesi ini"
            )

        code_obj = self.db.query(RIASECCode).filter(
            RIASECCode.id == result.riasec_code_id
        ).first()

        candidates_record = self.db.query(IkigaiCandidateProfession).filter(
            IkigaiCandidateProfession.test_session_id == session.id
        ).first()

        candidates = []
        if candidates_record:
            candidates = candidates_record.candidates_data.get("candidates", [])

        display_count = len([c for c in candidates if c.get("display_order", 99) <= 5])
        next_step = "ikigai" if session.test_goal == "RECOMMENDATION" else "fit_check_result"

        return {
            "session_token": session_token,
            "test_goal": session.test_goal,
            "status": session.status,
            "scores": {
                "R": result.score_r, "I": result.score_i, "A": result.score_a,
                "S": result.score_s, "E": result.score_e, "C": result.score_c
            },
            "classification_type": result.riasec_code_type,
            "is_inconsistent_profile": result.is_inconsistent_profile,
            "riasec_code_info": {
                "riasec_code": code_obj.riasec_code,
                "riasec_title": code_obj.riasec_title,
                "riasec_description": code_obj.riasec_description,
                "strengths": code_obj.strengths or [],
                "challenges": code_obj.challenges or [],
                "strategies": code_obj.strategies or [],
                "work_environments": code_obj.work_environments or [],
                "interaction_styles": code_obj.interaction_styles or [],
            },
            "candidates": candidates,
            "total_candidates": len(candidates),
            "display_candidates_count": display_count,
            "validity_warning": None,
            "next_step": next_step
        }
```

---

## Bagian 6 — user_career_profile (Pointer Profil Aktif)

Tabel ini **dikelola oleh Golang** sebagai CRUD system. FastAPI tidak perlu membuat atau memodifikasi tabel ini secara langsung. Namun FastAPI perlu tahu kapan harus memicu insert di tabel ini.

**Aturan bisnis:**
- Saat user **pertama kali** menyelesaikan sesi tes (baik RECOMMENDATION maupun FIT_CHECK), Golang akan otomatis INSERT ke `user_career_profile` dengan `active_session_id = sesi ini` dan `set_source = AUTO_FIRST_TIME`.
- Retake berikutnya tidak mengubah profil aktif secara otomatis.
- User bisa secara manual menetapkan profil aktif via CTA "Tetapkan sebagai Profil Karier" → Golang mengubah `active_session_id` dan `set_source = USER_SELECTED`.

**Implikasi untuk FastAPI:** FastAPI cukup menyelesaikan sesi dengan benar (update status, isi `completed_at`). Logika `user_career_profile` ada di Golang.

---

## Bagian 7 — Ringkasan File yang Dibuat / Dimodifikasi

| File | Status | Keterangan |
|---|---|---|
| `app/core/config.py` | **Modifikasi** | Tambah DB pool settings |
| `app/db/session.py` | **Modifikasi** | Tambah pool_recycle + pool_pre_ping |
| `app/db/models/token.py` | **Baru** | Model TokenWallet + TokenLedger (read tabel Golang) |
| `app/api/v1/dependencies/auth.py` | **Baru** | Dependency: role check + membership check (TODO) |
| `app/api/v1/dependencies/token.py` | **Baru** | Dependency: potong token + catat ledger |
| `app/api/v1/categories/career_profile/models/session.py` | **Modifikasi** | Perbaiki semua kolom + timestamp nullable |
| `app/api/v1/categories/career_profile/models/riasec.py` | **Modifikasi** | Perbaiki semua model — hapus kolom salah di QuestionSet |
| `app/api/v1/categories/career_profile/models/profession.py` | **Modifikasi** | Pastikan IkigaiCandidateProfession ada dan benar |
| `app/api/v1/categories/career_profile/schemas/session.py` | **Modifikasi** | Schema request/response untuk dua endpoint start |
| `app/api/v1/categories/career_profile/schemas/riasec.py` | **Modifikasi** | Schema submit + response lengkap termasuk candidates |
| `app/api/v1/categories/career_profile/routers/session.py` | **Modifikasi** | Dua endpoint: /recommendation/start + /fit-check/start |
| `app/api/v1/categories/career_profile/routers/riasec.py` | **Modifikasi** | Bersihkan duplikasi, tambah dependency auth |
| `app/api/v1/categories/career_profile/services/session_service.py` | **Modifikasi** | Logic start session: token + insert 3 tabel + question gen |
| `app/api/v1/categories/career_profile/services/riasec_service.py` | **GANTI TOTAL** | Klasifikasi penuh, validasi, ekspansi kandidat — tulis ulang |

---

## Bagian 8 — Daftar Endpoint RIASEC

| Method | Endpoint | Auth | Token | Deskripsi |
|---|---|---|---|---|
| `POST` | `/api/v1/career-profile/recommendation/start` | ✅ | 3 token | Mulai sesi rekomendasi profesi |
| `POST` | `/api/v1/career-profile/fit-check/start` | ✅ | Gratis | Mulai sesi cek kecocokan profesi |
| `POST` | `/api/v1/career-profile/riasec/submit` | ✅ | — | Submit 72 jawaban, proses semua, simpan hasil |
| `GET` | `/api/v1/career-profile/riasec/result/{session_token}` | ✅ | — | Ambil hasil RIASEC yang sudah tersimpan |

Kedua alur (RECOMMENDATION dan FIT_CHECK) menggunakan **endpoint submit RIASEC yang sama**. Perbedaannya hanya di field `next_step` pada response:
- `RECOMMENDATION` → `"next_step": "ikigai"`
- `FIT_CHECK` → `"next_step": "fit_check_result"`

---

## Bagian 9 — Alur Data Lengkap (Ringkasan Visual)

```
Flutter panggil /recommendation/start atau /fit-check/start
    ↓
FastAPI: cek role → cek membership (TODO) → potong token (khusus RECOMMENDATION)
    ↓
INSERT careerprofile_test_sessions (status: riasec_ongoing)
INSERT kenalidiri_history (status: ongoing, category_id: 3)
Generate urutan 72 soal acak (seed dari session_token, 12 soal per tipe)
INSERT riasec_question_sets (question_ids: [72 integers])
    ↓
Return ke Flutter: session_token + question_ids (72 ID terurut acak)
    ↓
Flutter tampilkan 72 soal dalam beberapa halaman (Flutter yang bagi, sesuai urutan question_ids)
Flutter kumpulkan 72 jawaban di state-nya (tidak ada API per halaman)
    ↓
Flutter submit semua 72 jawaban sekaligus ke /riasec/submit
    ↓
FastAPI: validasi sesi → validasi question_ids → hitung skor raw sum
    ↓
Validasi skor (invalid? severe low? low overall?)
    ↓
Klasifikasi kode RIASEC: coba 1 huruf → coba 2 huruf → fallback 3 huruf
    ↓
Lookup riasec_codes → ambil detail (title, strengths, challenges, dll)
    ↓
INSERT riasec_responses (semua 72 jawaban dalam 1 baris JSONB)
INSERT riasec_results (skor per tipe + kode RIASEC + classification_type)
    ↓
Ekspansi kandidat profesi (4-tier atau split-path jika inkonsisten)
INSERT ikigai_candidate_professions (5-30 profesi dalam 1 baris JSONB)
    ↓
UPDATE careerprofile_test_sessions → status: riasec_completed
    ↓ (jika FIT_CHECK)
UPDATE careerprofile_test_sessions → status: completed
UPDATE kenalidiri_history → status: completed
    ↓
Return hasil ke Flutter (skor + kode RIASEC + candidates + next_step)
```

---

*Brief ini mencakup scope RIASEC penuh. Beberapa hal yang sengaja tidak dibahas di sini karena baru relevan di tahap Ikigai:*

- *Model `Profession` / `CareerProfession` dan kolomnya (termasuk FK ke `riasec_codes`)*
- *Implementasi `ProfessionRepository` dan method `find_by_riasec_code()`*
- *Scoring AI per kandidat profesi (semantic relevance, click adjustment, normalisasi)*
- *Pemilihan 2 profesi utama dari pool kandidat*

*Semua hal di atas akan dibahas di Brief Part 2 (Ikigai).*