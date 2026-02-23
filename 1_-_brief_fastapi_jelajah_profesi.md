# Brief Penugasan Backend — Entity & Repository Jelajah Profesi (FastAPI)

**Modul:** Kamus Karier → Jelajah Profesi  
**Fitur terkait:** Analisis Kecocokan Profesi (RIASEC)  
**Stack:** Python · FastAPI · SQLAlchemy (async) · asyncpg · PostgreSQL  
**Status:** Final — siap implementasi  
**DB:** PostgreSQL online — tabel sudah ada, **tidak perlu migration**

---

## Changelog Pembaruan

> Bagian ini mencatat semua perubahan dari versi sebelumnya. Setiap fix diberi label **[FIX-N]** yang bisa ditelusuri langsung ke kode yang diperbaiki.

| # | Label | File | Masalah | Perbaikan |
|---|---|---|---|---|
| 1 | **[FIX-1]** | `app/database/config.py` | `get_db()` melakukan `await session.commit()` otomatis — berbahaya untuk request GET dan menyebabkan transaksi tidak terkontrol | Hapus auto-commit dari `get_db()`. Commit sekarang dilakukan **eksplisit di service layer** setelah semua operasi write selesai |
| 2 | **[FIX-2]** | `app/models/profession.py` | `Profession.main_category` tidak memiliki `back_populates="professions"` — menyebabkan SQLAlchemy warning dan relasi dua arah tidak sinkron | Tambahkan `back_populates="professions"` agar konsisten dengan `ProfessionMainCategory.professions` |
| 3 | **[FIX-3]** | `app/models/*.py` — semua kolom `DateTime` | `DateTime` tanpa `timezone=True` menyebabkan mismatch dengan nilai `datetime.now(timezone.utc)` yang dipakai di repository | Ganti semua `DateTime` menjadi `DateTime(timezone=True)` di seluruh model |
| 4 | **[FIX-4]** | `app/repositories/profession_repository.py` | Method `update()` tidak bisa men-set field nullable ke `None` karena kondisi `if field is not None` — admin tidak bisa menghapus `image_url`, `riasec_code_id`, dll | Gunakan sentinel `_UNSET = object()` agar bisa membedakan antara "tidak diisi" vs "diisi None secara sengaja" |
| 5 | **[FIX-5]** | `app/seeders/profession_sub_category_seeder.py` | Komentar tidak menjelaskan kenapa hanya 4 main category yang di-cache, membingungkan developer | Tambahkan komentar eksplisit bahwa hanya 4 main category yang memiliki sub_category di data awal |
| 6 | **[FIX-6]** | `app/services/profession_service.py` | Komentar `# Commit otomatis dilakukan oleh get_db() dependency` tidak lagi akurat setelah FIX-1 | Ganti dengan `await db.commit()` eksplisit dan hapus komentar yang menyesatkan |

---

## Kredensial Database

```
DB_HOST = 103.171.84.248
DB_PORT = 5433
DB_USER = postgres
DB_PASS = password
DB_NAME = rextra
```

> ⚠️ **Catatan akses DB:**  
> Semua model di bawah ini **TIDAK membuat tabel baru**.  
> Model hanya memetakan (`reflect`) tabel yang **sudah ada** di database.  
> SQLAlchemy menggunakan `autoload` secara implisit — nama kolom di model  
> **harus sama persis** dengan nama kolom di tabel PostgreSQL.

---

## Struktur Folder

```
app/
├── database/
│   └── config.py                        ← koneksi & session DB
├── models/
│   ├── __init__.py
│   ├── profession_main_category.py
│   ├── profession_sub_category.py
│   ├── profession.py
│   ├── profession_alias.py
│   ├── profession_activity.py
│   ├── profession_market_insight.py
│   ├── profession_career_path.py
│   ├── skill.py
│   ├── profession_skill_rel.py
│   ├── tool.py
│   ├── profession_tool_rel.py
│   ├── study_program.py
│   └── profession_study_program_rel.py
├── repositories/
│   ├── __init__.py
│   ├── profession_main_category_repository.py
│   ├── profession_sub_category_repository.py
│   ├── profession_repository.py
│   ├── profession_alias_repository.py
│   ├── profession_activity_repository.py
│   ├── profession_market_insight_repository.py
│   ├── profession_career_path_repository.py
│   ├── skill_repository.py
│   ├── tool_repository.py
│   └── study_program_repository.py
└── seeders/
    ├── profession_main_category_seeder.py
    └── profession_sub_category_seeder.py
requirements.txt
.env
```

---

## File: `.env`

```env
DB_HOST=103.171.84.248
DB_PORT=5433
DB_USER=postgres
DB_PASS=password
DB_NAME=rextra
```

---

## File: `requirements.txt`

```txt
fastapi>=0.111.0
uvicorn[standard]>=0.29.0
sqlalchemy>=2.0.0
asyncpg>=0.29.0
python-dotenv>=1.0.0
```

---

## File: `app/database/config.py`

> **[FIX-1]** — Dihapus `await session.commit()` dari `get_db()`.  
> Sebelumnya commit dilakukan otomatis di sini sehingga request GET pun ikut commit,  
> dan transaksi multi-step di service layer tidak bisa dikontrol dengan benar.  
> Sekarang commit **wajib dilakukan eksplisit di service layer** setelah semua operasi write selesai.

```python
"""
app/database/config.py
----------------------
Konfigurasi koneksi ke PostgreSQL online menggunakan SQLAlchemy async.

⚠️  Akses DB:
    Tabel sudah ada di DB. Model Python hanya merefleksikan tabel yang ada.
    TIDAK ada create_all() atau migration di sini.

Kredensial aktif (dari .env):
    HOST : 103.171.84.248
    PORT : 5433
    USER : postgres
    DB   : rextra
"""

import os
from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase

load_dotenv()

# ── Bangun DATABASE_URL dari env ─────────────────────────────────────────────
DB_HOST = os.getenv("DB_HOST", "103.171.84.248")
DB_PORT = os.getenv("DB_PORT", "5433")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "password")
DB_NAME = os.getenv("DB_NAME", "rextra")

DATABASE_URL = f"postgresql+asyncpg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# ── Engine ────────────────────────────────────────────────────────────────────
engine = create_async_engine(
    DATABASE_URL,
    echo=False,          # ubah True untuk debug query SQL di terminal
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,  # validasi koneksi sebelum dipakai (penting untuk DB remote)
)

# ── Session factory ───────────────────────────────────────────────────────────
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# ── Base declarative ──────────────────────────────────────────────────────────
class Base(DeclarativeBase):
    """Base class semua model SQLAlchemy. Import Base dari sini."""
    pass


# ── Dependency FastAPI ────────────────────────────────────────────────────────
async def get_db() -> AsyncSession:
    """
    Dependency injection session DB untuk dipakai di router / service.

    ⚠️  COMMIT tidak dilakukan otomatis di sini.
        Panggil `await db.commit()` secara eksplisit di service layer
        setelah semua operasi write dalam satu transaksi selesai.

    Contoh pemakaian di router:
        @router.get("/professions")
        async def list_professions(db: AsyncSession = Depends(get_db)):
            repo = ProfessionRepository(db)
            return await repo.get_all()
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        # [FIX-1] Dihapus: await session.commit()
        # Commit dilakukan eksplisit di service layer, bukan di sini.
```

---

## File: `app/models/__init__.py`

```python
"""
app/models/__init__.py
----------------------
Re-export semua model agar bisa diimport dari satu tempat.

Contoh:
    from app.models import Profession, Skill, Tool
"""

from app.models.profession_main_category import ProfessionMainCategory
from app.models.profession_sub_category import ProfessionSubCategory
from app.models.profession import Profession
from app.models.profession_alias import ProfessionAlias
from app.models.profession_activity import ProfessionActivity
from app.models.profession_market_insight import ProfessionMarketInsight
from app.models.profession_career_path import ProfessionCareerPath
from app.models.skill import Skill
from app.models.profession_skill_rel import ProfessionSkillRel
from app.models.tool import Tool
from app.models.profession_tool_rel import ProfessionToolRel
from app.models.study_program import StudyProgram
from app.models.profession_study_program_rel import ProfessionStudyProgramRel

__all__ = [
    "ProfessionMainCategory",
    "ProfessionSubCategory",
    "Profession",
    "ProfessionAlias",
    "ProfessionActivity",
    "ProfessionMarketInsight",
    "ProfessionCareerPath",
    "Skill",
    "ProfessionSkillRel",
    "Tool",
    "ProfessionToolRel",
    "StudyProgram",
    "ProfessionStudyProgramRel",
]
```

---

## File: `app/models/profession_main_category.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_main_category.py
---------------------------------------
Entity  : profession_main_categories
Relasi  : (1) → (N) profession_sub_categories
Aturan  : Hard delete. Tidak ada soft delete / is_active / display_order.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, Text, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionMainCategory(Base):
    __tablename__ = "profession_main_categories"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    sub_categories: Mapped[list["ProfessionSubCategory"]] = relationship(
        "ProfessionSubCategory",
        back_populates="main_category",
        lazy="select",
    )
    professions: Mapped[list["Profession"]] = relationship(
        "Profession",
        back_populates="main_category",
        lazy="select",
    )

    def __repr__(self) -> str:
        return f"<ProfessionMainCategory id={self.id} code={self.code}>"
```

---

## File: `app/models/profession_sub_category.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_sub_category.py
---------------------------------------
Entity  : profession_sub_categories
Relasi  :
    (N) → (1) profession_main_categories  via main_category_id
    (1) → (N) professions

Constraint DB (sudah ada di tabel):
    UNIQUE (main_category_id, code)
    UNIQUE (main_category_id, name)

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionSubCategory(Base):
    __tablename__ = "profession_sub_categories"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    main_category_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("profession_main_categories.id", ondelete="RESTRICT"), nullable=False, index=True
    )
    code: Mapped[str] = mapped_column(String(50), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    main_category: Mapped["ProfessionMainCategory"] = relationship(
        "ProfessionMainCategory",
        back_populates="sub_categories",
        lazy="select",
    )
    professions: Mapped[list["Profession"]] = relationship(
        "Profession",
        back_populates="sub_category",
        lazy="select",
    )

    def __repr__(self) -> str:
        return f"<ProfessionSubCategory id={self.id} code={self.code}>"
```

---

## File: `app/models/profession.py`

> **[FIX-2]** — Ditambahkan `back_populates="professions"` pada relasi `main_category`.  
> Sebelumnya relasi ini tidak memiliki `back_populates` sehingga tidak sinkron dengan  
> `ProfessionMainCategory.professions` dan menyebabkan SQLAlchemy warning.  
>
> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession.py
-------------------------
Entity  : professions
Relasi  :
    (N) → (1) profession_main_categories  via main_category_id
    (N) → (1) profession_sub_categories   via sub_category_id
    (N) → (1) riasec_codes                via riasec_code_id  [nullable]
    (1) → (N) profession_aliases
    (1) → (N) profession_activities
    (1) → (N) profession_market_insights
    (1) → (N) profession_career_paths
    (N) ↔ (N) skills       via profession_skill_rels
    (N) ↔ (N) tools        via profession_tool_rels
    (N) ↔ (N) study_programs via profession_study_program_rels

Catatan kolom:
    slug             → public identifier di URL (/professions/data-engineer), UNIQUE
    riasec_code_id   → nullable; profesi tanpa nilai ini tidak ikut matching RIASEC
    riasec_description → wajib diisi bersamaan saat riasec_code_id diisi (validasi di service)
    image_url, about_description, riasec_description → nullable (isi bertahap)

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from typing import Optional
from sqlalchemy import Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class Profession(Base):
    __tablename__ = "professions"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)

    # Public identifier untuk URL — generate otomatis dari name di service layer
    # Contoh: "Data Engineer" → "data-engineer"
    slug: Mapped[str] = mapped_column(String(120), unique=True, nullable=False)

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    image_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    main_category_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("profession_main_categories.id", ondelete="RESTRICT"), nullable=False, index=True
    )
    sub_category_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("profession_sub_categories.id", ondelete="RESTRICT"), nullable=False, index=True
    )

    # Nullable FK ke riasec_codes — profesi tanpa nilai ini tidak ikut matching RIASEC
    riasec_code_id: Mapped[Optional[int]] = mapped_column(
        Integer, ForeignKey("riasec_codes.id", ondelete="RESTRICT"), nullable=True, index=True
    )

    about_description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Wajib diisi bersamaan dengan riasec_code_id — validasi di service layer
    riasec_description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    # [FIX-2] Ditambahkan back_populates="professions" — sebelumnya tidak ada
    main_category: Mapped["ProfessionMainCategory"] = relationship(
        "ProfessionMainCategory", back_populates="professions", lazy="select"
    )
    sub_category: Mapped["ProfessionSubCategory"] = relationship(
        "ProfessionSubCategory", back_populates="professions", lazy="select"
    )

    aliases: Mapped[list["ProfessionAlias"]] = relationship(
        "ProfessionAlias", back_populates="profession",
        cascade="all, delete-orphan", lazy="select",
    )
    activities: Mapped[list["ProfessionActivity"]] = relationship(
        "ProfessionActivity", back_populates="profession",
        cascade="all, delete-orphan", order_by="ProfessionActivity.sort_order", lazy="select",
    )
    market_insights: Mapped[list["ProfessionMarketInsight"]] = relationship(
        "ProfessionMarketInsight", back_populates="profession",
        cascade="all, delete-orphan", order_by="ProfessionMarketInsight.sort_order", lazy="select",
    )
    career_paths: Mapped[list["ProfessionCareerPath"]] = relationship(
        "ProfessionCareerPath", back_populates="profession",
        cascade="all, delete-orphan", order_by="ProfessionCareerPath.sort_order", lazy="select",
    )
    skill_rels: Mapped[list["ProfessionSkillRel"]] = relationship(
        "ProfessionSkillRel", back_populates="profession",
        cascade="all, delete-orphan", lazy="select",
    )
    tool_rels: Mapped[list["ProfessionToolRel"]] = relationship(
        "ProfessionToolRel", back_populates="profession",
        cascade="all, delete-orphan", lazy="select",
    )
    study_program_rels: Mapped[list["ProfessionStudyProgramRel"]] = relationship(
        "ProfessionStudyProgramRel", back_populates="profession",
        cascade="all, delete-orphan", lazy="select",
    )

    def __repr__(self) -> str:
        return f"<Profession id={self.id} slug={self.slug}>"
```

---

## File: `app/models/profession_alias.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_alias.py
--------------------------------
Entity  : profession_aliases
Relasi  : (N) → (1) professions via profession_id  [CASCADE delete]

Fungsi  : Menyimpan sinonim / variasi nama profesi untuk search pipeline.
Contoh  : "UI Designer", "User Interface Designer", "Desainer Antarmuka"
          → semua resolve ke 1 entitas Profession yang sama.

Constraint DB (sudah ada di tabel):
    UNIQUE (profession_id, alias_name)

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionAlias(Base):
    __tablename__ = "profession_aliases"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    alias_name: Mapped[str] = mapped_column(String(100), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="aliases", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionAlias id={self.id} alias={self.alias_name}>"
```

---

## File: `app/models/profession_activity.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_activity.py
-----------------------------------
Entity  : profession_activities
Relasi  : (N) → (1) professions via profession_id  [CASCADE delete]

Fungsi  : Ordered list aktivitas kerja utama suatu profesi.
          Dipisah dari JSONB agar bisa CRUD per item + drag-reorder oleh admin.
          Diurutkan berdasarkan sort_order (ASC) saat di-load via relasi.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionActivity(Base):
    __tablename__ = "profession_activities"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    description: Mapped[str] = mapped_column(Text, nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="activities", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionActivity id={self.id} sort={self.sort_order}>"
```

---

## File: `app/models/profession_market_insight.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_market_insight.py
-----------------------------------------
Entity  : profession_market_insights
Relasi  : (N) → (1) professions via profession_id  [CASCADE delete]

Fungsi  : Bullet list kondisi pasar kerja suatu profesi (tab Prospek Karier).
          Dipisah dari profession_activities karena domain berbeda dan
          kebutuhan query yang terpisah.
          Diurutkan berdasarkan sort_order (ASC) saat di-load via relasi.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionMarketInsight(Base):
    __tablename__ = "profession_market_insights"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    description: Mapped[str] = mapped_column(Text, nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="market_insights", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionMarketInsight id={self.id} sort={self.sort_order}>"
```

---

## File: `app/models/profession_career_path.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_career_path.py
--------------------------------------
Entity  : profession_career_paths
Relasi  : (N) → (1) professions via profession_id  [CASCADE delete]

Fungsi  : Jenjang karier terstruktur dan berurutan.
          Dipisah dari JSONB karena ada struktur numerik gaji (salary_min/max)
          yang berpotensi dipakai untuk analitik dan filter.
          Diurutkan berdasarkan sort_order (ASC) saat di-load via relasi.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from typing import Optional
from sqlalchemy import Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionCareerPath(Base):
    __tablename__ = "profession_career_paths"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(100), nullable=False)           # contoh: "Junior Data Engineer"
    experience_range: Mapped[str] = mapped_column(String(50), nullable=False) # contoh: "0–2 tahun"
    salary_min: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    salary_max: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="career_paths", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionCareerPath id={self.id} title={self.title}>"
```

---

## File: `app/models/skill.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/skill.py
--------------------
Entity  : skills  (Master)
Relasi  : (N) ↔ (N) professions via profession_skill_rels

Fungsi  : Tabel master kompetensi global yang reusable lintas profesi.
          Tipe skill (hard/soft) dan prioritas dikontrol di tabel pivot.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class Skill(Base):
    __tablename__ = "skills"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession_rels: Mapped[list["ProfessionSkillRel"]] = relationship(
        "ProfessionSkillRel", back_populates="skill", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<Skill id={self.id} name={self.name}>"
```

---

## File: `app/models/profession_skill_rel.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_skill_rel.py
------------------------------------
Entity  : profession_skill_rels  (Pivot)
Relasi  :
    (N) → (1) professions  via profession_id  [CASCADE delete]
    (N) → (1) skills        via skill_id       [RESTRICT delete]

Kolom atribut relasi:
    skill_type : "hard" | "soft"     — CHECK constraint di DB
    priority   : "wajib" | "dianjurkan" — CHECK constraint di DB

Validasi nilai skill_type dan priority sudah dijaga oleh CHECK constraint
di level DB. Di service layer cukup validasi sebelum insert.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base

# Konstanta nilai valid — dipakai di service layer untuk validasi input
VALID_SKILL_TYPES = ("hard", "soft")
VALID_PRIORITIES  = ("wajib", "dianjurkan")


class ProfessionSkillRel(Base):
    __tablename__ = "profession_skill_rels"

    # ── Composite PK ──────────────────────────────────────────────────────────
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), primary_key=True
    )
    skill_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("skills.id", ondelete="RESTRICT"), primary_key=True
    )

    # ── Atribut relasi ────────────────────────────────────────────────────────
    skill_type: Mapped[str] = mapped_column(String(20), nullable=False)  # "hard" | "soft"
    priority: Mapped[str] = mapped_column(String(20), nullable=False)    # "wajib" | "dianjurkan"

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="skill_rels", lazy="select"
    )
    skill: Mapped["Skill"] = relationship(
        "Skill", back_populates="profession_rels", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionSkillRel profession={self.profession_id} skill={self.skill_id}>"
```

---

## File: `app/models/tool.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/tool.py
-------------------
Entity  : tools  (Master)
Relasi  : (N) ↔ (N) professions via profession_tool_rels

Fungsi  : Tabel master perangkat/teknologi global yang reusable lintas profesi.
          Label penggunaan (wajib/umum) dikontrol di tabel pivot.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class Tool(Base):
    __tablename__ = "tools"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession_rels: Mapped[list["ProfessionToolRel"]] = relationship(
        "ProfessionToolRel", back_populates="tool", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<Tool id={self.id} name={self.name}>"
```

---

## File: `app/models/profession_tool_rel.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_tool_rel.py
-----------------------------------
Entity  : profession_tool_rels  (Pivot)
Relasi  :
    (N) → (1) professions  via profession_id  [CASCADE delete]
    (N) → (1) tools         via tool_id        [RESTRICT delete]

Kolom atribut relasi:
    usage_type : "wajib" | "umum" — CHECK constraint di DB

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base

# Konstanta nilai valid — dipakai di service layer untuk validasi input
VALID_USAGE_TYPES = ("wajib", "umum")


class ProfessionToolRel(Base):
    __tablename__ = "profession_tool_rels"

    # ── Composite PK ──────────────────────────────────────────────────────────
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), primary_key=True
    )
    tool_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("tools.id", ondelete="RESTRICT"), primary_key=True
    )

    # ── Atribut relasi ────────────────────────────────────────────────────────
    usage_type: Mapped[str] = mapped_column(String(20), nullable=False)  # "wajib" | "umum"

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="tool_rels", lazy="select"
    )
    tool: Mapped["Tool"] = relationship(
        "Tool", back_populates="profession_rels", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionToolRel profession={self.profession_id} tool={self.tool_id}>"
```

---

## File: `app/models/study_program.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/study_program.py
-----------------------------
Entity  : study_programs  (Master)
Relasi  : (N) ↔ (N) professions via profession_study_program_rels

Fungsi  : Tabel master program studi / jurusan formal.
          1 jurusan bisa relevan ke banyak profesi, 1 profesi bisa relevan
          ke banyak jurusan.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class StudyProgram(Base):
    __tablename__ = "study_programs"

    # ── Kolom ─────────────────────────────────────────────────────────────────
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(150), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession_rels: Mapped[list["ProfessionStudyProgramRel"]] = relationship(
        "ProfessionStudyProgramRel", back_populates="study_program", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<StudyProgram id={self.id} name={self.name}>"
```

---

## File: `app/models/profession_study_program_rel.py`

> **[FIX-3]** — Semua kolom `DateTime` diganti menjadi `DateTime(timezone=True)`.

```python
"""
app/models/profession_study_program_rel.py
--------------------------------------------
Entity  : profession_study_program_rels  (Pivot)
Relasi  :
    (N) → (1) professions    via profession_id     [CASCADE delete]
    (N) → (1) study_programs via study_program_id  [RESTRICT delete]

Tidak ada atribut tambahan di relasi ini.

⚠️  Akses DB:
    Tabel sudah ada di PostgreSQL online (103.171.84.248:5433/rextra).
    Model ini HANYA merefleksikan tabel — tidak membuat atau mengubah tabel.
"""

from datetime import datetime
from sqlalchemy import Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.config import Base


class ProfessionStudyProgramRel(Base):
    __tablename__ = "profession_study_program_rels"

    # ── Composite PK ──────────────────────────────────────────────────────────
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), primary_key=True
    )
    study_program_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("study_programs.id", ondelete="RESTRICT"), primary_key=True
    )

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # [FIX-3]

    # ── Relasi ────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="study_program_rels", lazy="select"
    )
    study_program: Mapped["StudyProgram"] = relationship(
        "StudyProgram", back_populates="profession_rels", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<ProfessionStudyProgramRel profession={self.profession_id} sp={self.study_program_id}>"
```

---

## File: `app/repositories/__init__.py`

```python
"""
app/repositories/__init__.py
"""
from app.repositories.profession_main_category_repository import ProfessionMainCategoryRepository
from app.repositories.profession_sub_category_repository import ProfessionSubCategoryRepository
from app.repositories.profession_repository import ProfessionRepository
from app.repositories.profession_alias_repository import ProfessionAliasRepository
from app.repositories.profession_activity_repository import ProfessionActivityRepository
from app.repositories.profession_market_insight_repository import ProfessionMarketInsightRepository
from app.repositories.profession_career_path_repository import ProfessionCareerPathRepository
from app.repositories.skill_repository import SkillRepository
from app.repositories.tool_repository import ToolRepository
from app.repositories.study_program_repository import StudyProgramRepository

__all__ = [
    "ProfessionMainCategoryRepository",
    "ProfessionSubCategoryRepository",
    "ProfessionRepository",
    "ProfessionAliasRepository",
    "ProfessionActivityRepository",
    "ProfessionMarketInsightRepository",
    "ProfessionCareerPathRepository",
    "SkillRepository",
    "ToolRepository",
    "StudyProgramRepository",
]
```

---

## File: `app/repositories/profession_main_category_repository.py`

```python
"""
app/repositories/profession_main_category_repository.py
---------------------------------------------------------
Repository untuk tabel profession_main_categories.

Aturan hard delete: validasi relasi sub_category sebelum delete
dilakukan di service layer, bukan di sini.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profession_main_category import ProfessionMainCategory


class ProfessionMainCategoryRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_all(self) -> list[ProfessionMainCategory]:
        result = await self.db.execute(select(ProfessionMainCategory))
        return result.scalars().all()

    async def get_by_id(self, category_id: int) -> Optional[ProfessionMainCategory]:
        result = await self.db.execute(
            select(ProfessionMainCategory).where(ProfessionMainCategory.id == category_id)
        )
        return result.scalar_one_or_none()

    async def get_by_code(self, code: str) -> Optional[ProfessionMainCategory]:
        result = await self.db.execute(
            select(ProfessionMainCategory).where(ProfessionMainCategory.code == code)
        )
        return result.scalar_one_or_none()

    async def create(self, code: str, name: str, description: str) -> ProfessionMainCategory:
        now = datetime.now(timezone.utc)
        obj = ProfessionMainCategory(
            code=code,
            name=name,
            description=description,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()  # flush agar id terisi, commit dilakukan eksplisit di service layer
        return obj

    async def update(
        self,
        category_id: int,
        name: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Optional[ProfessionMainCategory]:
        obj = await self.get_by_id(category_id)
        if not obj:
            return None
        if name is not None:
            obj.name = name
        if description is not None:
            obj.description = description
        obj.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        return obj

    async def delete(self, category_id: int) -> bool:
        """Hard delete. Pastikan tidak ada sub_category terkait sebelum memanggil ini."""
        result = await self.db.execute(
            delete(ProfessionMainCategory).where(ProfessionMainCategory.id == category_id)
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/profession_sub_category_repository.py`

```python
"""
app/repositories/profession_sub_category_repository.py
--------------------------------------------------------
Repository untuk tabel profession_sub_categories.

Business rule penting (dijaga di service layer, bukan di sini):
    Setiap sub_category HANYA dimiliki oleh 1 main_category.
    Validasi konsistensi sub_category ↔ main_category dilakukan
    di service layer sebelum memanggil create/update.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profession_sub_category import ProfessionSubCategory


class ProfessionSubCategoryRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_all(self) -> list[ProfessionSubCategory]:
        result = await self.db.execute(select(ProfessionSubCategory))
        return result.scalars().all()

    async def get_by_id(self, sub_id: int) -> Optional[ProfessionSubCategory]:
        result = await self.db.execute(
            select(ProfessionSubCategory).where(ProfessionSubCategory.id == sub_id)
        )
        return result.scalar_one_or_none()

    async def get_by_main_category(self, main_category_id: int) -> list[ProfessionSubCategory]:
        result = await self.db.execute(
            select(ProfessionSubCategory).where(
                ProfessionSubCategory.main_category_id == main_category_id
            )
        )
        return result.scalars().all()

    async def get_by_main_and_code(
        self, main_category_id: int, code: str
    ) -> Optional[ProfessionSubCategory]:
        result = await self.db.execute(
            select(ProfessionSubCategory).where(
                ProfessionSubCategory.main_category_id == main_category_id,
                ProfessionSubCategory.code == code,
            )
        )
        return result.scalar_one_or_none()

    async def create(
        self,
        main_category_id: int,
        code: str,
        name: str,
        description: str,
    ) -> ProfessionSubCategory:
        now = datetime.now(timezone.utc)
        obj = ProfessionSubCategory(
            main_category_id=main_category_id,
            code=code,
            name=name,
            description=description,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def update(
        self,
        sub_id: int,
        name: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Optional[ProfessionSubCategory]:
        obj = await self.get_by_id(sub_id)
        if not obj:
            return None
        if name is not None:
            obj.name = name
        if description is not None:
            obj.description = description
        obj.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        return obj

    async def delete(self, sub_id: int) -> bool:
        result = await self.db.execute(
            delete(ProfessionSubCategory).where(ProfessionSubCategory.id == sub_id)
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/profession_repository.py`

> **[FIX-4]** — Method `update()` sekarang menggunakan sentinel `_UNSET` agar bisa membedakan  
> antara "field tidak diisi" vs "field sengaja di-set ke `None`".  
> Sebelumnya, `if field is not None` membuat admin tidak bisa menghapus nilai nullable  
> seperti `image_url`, `riasec_code_id`, `about_description`, dan `riasec_description`.

```python
"""
app/repositories/profession_repository.py
-------------------------------------------
Repository untuk tabel professions.

Business rules yang dijaga di SERVICE LAYER (bukan di sini):
    1. sub_category_id HARUS berada di bawah main_category_id yang sama.
    2. slug di-generate otomatis dari name jika tidak diisi:
           slug = name.lower().replace(" ", "-")  → "Data Engineer" → "data-engineer"
    3. Jika riasec_code_id tidak None tapi riasec_description None
       → service layer wajib return error / warning.
    4. Profesi dengan riasec_code_id = None tidak diikutsertakan dalam
       matching RIASEC — filter ini diterapkan di service/query layer.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.profession import Profession

# [FIX-4] Sentinel untuk membedakan "tidak diisi" vs "sengaja di-set None"
_UNSET = object()


class ProfessionRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── READ ──────────────────────────────────────────────────────────────────

    async def get_all(self) -> list[Profession]:
        result = await self.db.execute(select(Profession))
        return result.scalars().all()

    async def get_by_id(self, profession_id: int) -> Optional[Profession]:
        result = await self.db.execute(
            select(Profession).where(Profession.id == profession_id)
        )
        return result.scalar_one_or_none()

    async def get_by_slug(self, slug: str) -> Optional[Profession]:
        """Dipakai untuk endpoint publik /professions/{slug}."""
        result = await self.db.execute(
            select(Profession).where(Profession.slug == slug)
        )
        return result.scalar_one_or_none()

    async def get_by_id_with_relations(self, profession_id: int) -> Optional[Profession]:
        """
        Load profesi beserta semua relasi turunan dalam 1 query (eager load).
        Gunakan untuk endpoint detail profesi.
        """
        result = await self.db.execute(
            select(Profession)
            .options(
                selectinload(Profession.main_category),
                selectinload(Profession.sub_category),
                selectinload(Profession.aliases),
                selectinload(Profession.activities),
                selectinload(Profession.market_insights),
                selectinload(Profession.career_paths),
                selectinload(Profession.skill_rels),
                selectinload(Profession.tool_rels),
                selectinload(Profession.study_program_rels),
            )
            .where(Profession.id == profession_id)
        )
        return result.scalar_one_or_none()

    async def get_by_slug_with_relations(self, slug: str) -> Optional[Profession]:
        """Load profesi by slug beserta semua relasi. Dipakai di endpoint publik."""
        result = await self.db.execute(
            select(Profession)
            .options(
                selectinload(Profession.main_category),
                selectinload(Profession.sub_category),
                selectinload(Profession.aliases),
                selectinload(Profession.activities),
                selectinload(Profession.market_insights),
                selectinload(Profession.career_paths),
                selectinload(Profession.skill_rels),
                selectinload(Profession.tool_rels),
                selectinload(Profession.study_program_rels),
            )
            .where(Profession.slug == slug)
        )
        return result.scalar_one_or_none()

    async def get_by_main_category(self, main_category_id: int) -> list[Profession]:
        result = await self.db.execute(
            select(Profession).where(Profession.main_category_id == main_category_id)
        )
        return result.scalars().all()

    async def get_by_sub_category(self, sub_category_id: int) -> list[Profession]:
        result = await self.db.execute(
            select(Profession).where(Profession.sub_category_id == sub_category_id)
        )
        return result.scalars().all()

    async def get_with_riasec(self) -> list[Profession]:
        """Ambil hanya profesi yang memiliki riasec_code_id (untuk matching RIASEC)."""
        result = await self.db.execute(
            select(Profession).where(Profession.riasec_code_id.is_not(None))
        )
        return result.scalars().all()

    # ── WRITE ─────────────────────────────────────────────────────────────────

    async def create(
        self,
        slug: str,
        name: str,
        main_category_id: int,
        sub_category_id: int,
        image_url: Optional[str] = None,
        riasec_code_id: Optional[int] = None,
        about_description: Optional[str] = None,
        riasec_description: Optional[str] = None,
    ) -> Profession:
        now = datetime.now(timezone.utc)
        obj = Profession(
            slug=slug,
            name=name,
            main_category_id=main_category_id,
            sub_category_id=sub_category_id,
            image_url=image_url,
            riasec_code_id=riasec_code_id,
            about_description=about_description,
            riasec_description=riasec_description,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()  # id terisi setelah flush
        return obj

    async def update(
        self,
        profession_id: int,
        slug=_UNSET,                  # [FIX-4] pakai sentinel, bukan Optional
        name=_UNSET,
        image_url=_UNSET,             # [FIX-4] bisa di-set ke None untuk hapus gambar
        main_category_id=_UNSET,
        sub_category_id=_UNSET,
        riasec_code_id=_UNSET,        # [FIX-4] bisa di-set ke None untuk hapus RIASEC
        about_description=_UNSET,     # [FIX-4] bisa di-set ke None
        riasec_description=_UNSET,    # [FIX-4] bisa di-set ke None
    ) -> Optional[Profession]:
        obj = await self.get_by_id(profession_id)
        if not obj:
            return None
        # [FIX-4] Cek sentinel _UNSET, bukan None — agar bisa set field ke None secara sengaja
        if slug is not _UNSET:
            obj.slug = slug
        if name is not _UNSET:
            obj.name = name
        if image_url is not _UNSET:
            obj.image_url = image_url
        if main_category_id is not _UNSET:
            obj.main_category_id = main_category_id
        if sub_category_id is not _UNSET:
            obj.sub_category_id = sub_category_id
        if riasec_code_id is not _UNSET:
            obj.riasec_code_id = riasec_code_id
        if about_description is not _UNSET:
            obj.about_description = about_description
        if riasec_description is not _UNSET:
            obj.riasec_description = riasec_description
        obj.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        return obj

    async def delete(self, profession_id: int) -> bool:
        """
        Hard delete. Relasi turunan (aliases, activities, dsb) ter-delete otomatis
        via CASCADE yang sudah ada di DB.
        """
        result = await self.db.execute(
            delete(Profession).where(Profession.id == profession_id)
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/profession_alias_repository.py`

```python
"""
app/repositories/profession_alias_repository.py
-------------------------------------------------
Repository untuk tabel profession_aliases.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profession_alias import ProfessionAlias


class ProfessionAliasRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_profession(self, profession_id: int) -> list[ProfessionAlias]:
        result = await self.db.execute(
            select(ProfessionAlias).where(ProfessionAlias.profession_id == profession_id)
        )
        return result.scalars().all()

    async def get_by_alias_name(self, alias_name: str) -> Optional[ProfessionAlias]:
        """Dipakai di search pipeline untuk resolve alias → profession."""
        result = await self.db.execute(
            select(ProfessionAlias).where(ProfessionAlias.alias_name == alias_name)
        )
        return result.scalar_one_or_none()

    async def create(self, profession_id: int, alias_name: str) -> ProfessionAlias:
        now = datetime.now(timezone.utc)
        obj = ProfessionAlias(
            profession_id=profession_id,
            alias_name=alias_name,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def delete(self, alias_id: int) -> bool:
        result = await self.db.execute(
            delete(ProfessionAlias).where(ProfessionAlias.id == alias_id)
        )
        return result.rowcount > 0

    async def delete_by_profession(self, profession_id: int) -> int:
        """Hapus semua alias milik satu profesi. Kembalikan jumlah baris terhapus."""
        result = await self.db.execute(
            delete(ProfessionAlias).where(ProfessionAlias.profession_id == profession_id)
        )
        return result.rowcount
```

---

## File: `app/repositories/profession_activity_repository.py`

```python
"""
app/repositories/profession_activity_repository.py
----------------------------------------------------
Repository untuk tabel profession_activities.
Diurutkan berdasarkan sort_order ASC.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profession_activity import ProfessionActivity


class ProfessionActivityRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_profession(self, profession_id: int) -> list[ProfessionActivity]:
        result = await self.db.execute(
            select(ProfessionActivity)
            .where(ProfessionActivity.profession_id == profession_id)
            .order_by(ProfessionActivity.sort_order)
        )
        return result.scalars().all()

    async def get_by_id(self, activity_id: int) -> Optional[ProfessionActivity]:
        result = await self.db.execute(
            select(ProfessionActivity).where(ProfessionActivity.id == activity_id)
        )
        return result.scalar_one_or_none()

    async def create(
        self, profession_id: int, description: str, sort_order: int
    ) -> ProfessionActivity:
        now = datetime.now(timezone.utc)
        obj = ProfessionActivity(
            profession_id=profession_id,
            description=description,
            sort_order=sort_order,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def update(
        self,
        activity_id: int,
        description: Optional[str] = None,
        sort_order: Optional[int] = None,
    ) -> Optional[ProfessionActivity]:
        obj = await self.get_by_id(activity_id)
        if not obj:
            return None
        if description is not None:
            obj.description = description
        if sort_order is not None:
            obj.sort_order = sort_order
        obj.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        return obj

    async def delete(self, activity_id: int) -> bool:
        result = await self.db.execute(
            delete(ProfessionActivity).where(ProfessionActivity.id == activity_id)
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/profession_market_insight_repository.py`

```python
"""
app/repositories/profession_market_insight_repository.py
----------------------------------------------------------
Repository untuk tabel profession_market_insights.
Diurutkan berdasarkan sort_order ASC.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profession_market_insight import ProfessionMarketInsight


class ProfessionMarketInsightRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_profession(self, profession_id: int) -> list[ProfessionMarketInsight]:
        result = await self.db.execute(
            select(ProfessionMarketInsight)
            .where(ProfessionMarketInsight.profession_id == profession_id)
            .order_by(ProfessionMarketInsight.sort_order)
        )
        return result.scalars().all()

    async def get_by_id(self, insight_id: int) -> Optional[ProfessionMarketInsight]:
        result = await self.db.execute(
            select(ProfessionMarketInsight).where(ProfessionMarketInsight.id == insight_id)
        )
        return result.scalar_one_or_none()

    async def create(
        self, profession_id: int, description: str, sort_order: int
    ) -> ProfessionMarketInsight:
        now = datetime.now(timezone.utc)
        obj = ProfessionMarketInsight(
            profession_id=profession_id,
            description=description,
            sort_order=sort_order,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def update(
        self,
        insight_id: int,
        description: Optional[str] = None,
        sort_order: Optional[int] = None,
    ) -> Optional[ProfessionMarketInsight]:
        obj = await self.get_by_id(insight_id)
        if not obj:
            return None
        if description is not None:
            obj.description = description
        if sort_order is not None:
            obj.sort_order = sort_order
        obj.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        return obj

    async def delete(self, insight_id: int) -> bool:
        result = await self.db.execute(
            delete(ProfessionMarketInsight).where(ProfessionMarketInsight.id == insight_id)
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/profession_career_path_repository.py`

```python
"""
app/repositories/profession_career_path_repository.py
-------------------------------------------------------
Repository untuk tabel profession_career_paths.
Diurutkan berdasarkan sort_order ASC.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profession_career_path import ProfessionCareerPath


class ProfessionCareerPathRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_profession(self, profession_id: int) -> list[ProfessionCareerPath]:
        result = await self.db.execute(
            select(ProfessionCareerPath)
            .where(ProfessionCareerPath.profession_id == profession_id)
            .order_by(ProfessionCareerPath.sort_order)
        )
        return result.scalars().all()

    async def get_by_id(self, path_id: int) -> Optional[ProfessionCareerPath]:
        result = await self.db.execute(
            select(ProfessionCareerPath).where(ProfessionCareerPath.id == path_id)
        )
        return result.scalar_one_or_none()

    async def create(
        self,
        profession_id: int,
        title: str,
        experience_range: str,
        sort_order: int,
        salary_min: Optional[int] = None,
        salary_max: Optional[int] = None,
    ) -> ProfessionCareerPath:
        now = datetime.now(timezone.utc)
        obj = ProfessionCareerPath(
            profession_id=profession_id,
            title=title,
            experience_range=experience_range,
            salary_min=salary_min,
            salary_max=salary_max,
            sort_order=sort_order,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def update(
        self,
        path_id: int,
        title: Optional[str] = None,
        experience_range: Optional[str] = None,
        salary_min: Optional[int] = None,
        salary_max: Optional[int] = None,
        sort_order: Optional[int] = None,
    ) -> Optional[ProfessionCareerPath]:
        obj = await self.get_by_id(path_id)
        if not obj:
            return None
        if title is not None:
            obj.title = title
        if experience_range is not None:
            obj.experience_range = experience_range
        if salary_min is not None:
            obj.salary_min = salary_min
        if salary_max is not None:
            obj.salary_max = salary_max
        if sort_order is not None:
            obj.sort_order = sort_order
        obj.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        return obj

    async def delete(self, path_id: int) -> bool:
        result = await self.db.execute(
            delete(ProfessionCareerPath).where(ProfessionCareerPath.id == path_id)
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/skill_repository.py`

```python
"""
app/repositories/skill_repository.py
--------------------------------------
Repository untuk tabel skills (master).
Termasuk operasi pada pivot profession_skill_rels.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.skill import Skill
from app.models.profession_skill_rel import ProfessionSkillRel, VALID_SKILL_TYPES, VALID_PRIORITIES


class SkillRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── Master skills ──────────────────────────────────────────────────────────

    async def get_all(self) -> list[Skill]:
        result = await self.db.execute(select(Skill).order_by(Skill.name))
        return result.scalars().all()

    async def get_by_id(self, skill_id: int) -> Optional[Skill]:
        result = await self.db.execute(select(Skill).where(Skill.id == skill_id))
        return result.scalar_one_or_none()

    async def get_by_name(self, name: str) -> Optional[Skill]:
        result = await self.db.execute(select(Skill).where(Skill.name == name))
        return result.scalar_one_or_none()

    async def create(self, name: str) -> Skill:
        now = datetime.now(timezone.utc)
        obj = Skill(name=name, created_at=now, updated_at=now)
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def delete(self, skill_id: int) -> bool:
        """RESTRICT — gagal jika masih ada relasi ke profesi."""
        result = await self.db.execute(delete(Skill).where(Skill.id == skill_id))
        return result.rowcount > 0

    # ── Pivot profession_skill_rels ────────────────────────────────────────────

    async def get_skills_by_profession(self, profession_id: int) -> list[ProfessionSkillRel]:
        result = await self.db.execute(
            select(ProfessionSkillRel).where(ProfessionSkillRel.profession_id == profession_id)
        )
        return result.scalars().all()

    async def add_skill_to_profession(
        self,
        profession_id: int,
        skill_id: int,
        skill_type: str,
        priority: str,
    ) -> ProfessionSkillRel:
        """
        Tambah skill ke profesi.
        Validasi nilai skill_type dan priority dilakukan di service layer
        menggunakan VALID_SKILL_TYPES dan VALID_PRIORITIES dari models.
        """
        now = datetime.now(timezone.utc)
        obj = ProfessionSkillRel(
            profession_id=profession_id,
            skill_id=skill_id,
            skill_type=skill_type,
            priority=priority,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def remove_skill_from_profession(
        self, profession_id: int, skill_id: int
    ) -> bool:
        result = await self.db.execute(
            delete(ProfessionSkillRel).where(
                ProfessionSkillRel.profession_id == profession_id,
                ProfessionSkillRel.skill_id == skill_id,
            )
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/tool_repository.py`

```python
"""
app/repositories/tool_repository.py
-------------------------------------
Repository untuk tabel tools (master).
Termasuk operasi pada pivot profession_tool_rels.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.tool import Tool
from app.models.profession_tool_rel import ProfessionToolRel, VALID_USAGE_TYPES


class ToolRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── Master tools ───────────────────────────────────────────────────────────

    async def get_all(self) -> list[Tool]:
        result = await self.db.execute(select(Tool).order_by(Tool.name))
        return result.scalars().all()

    async def get_by_id(self, tool_id: int) -> Optional[Tool]:
        result = await self.db.execute(select(Tool).where(Tool.id == tool_id))
        return result.scalar_one_or_none()

    async def get_by_name(self, name: str) -> Optional[Tool]:
        result = await self.db.execute(select(Tool).where(Tool.name == name))
        return result.scalar_one_or_none()

    async def create(self, name: str) -> Tool:
        now = datetime.now(timezone.utc)
        obj = Tool(name=name, created_at=now, updated_at=now)
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def delete(self, tool_id: int) -> bool:
        """RESTRICT — gagal jika masih ada relasi ke profesi."""
        result = await self.db.execute(delete(Tool).where(Tool.id == tool_id))
        return result.rowcount > 0

    # ── Pivot profession_tool_rels ─────────────────────────────────────────────

    async def get_tools_by_profession(self, profession_id: int) -> list[ProfessionToolRel]:
        result = await self.db.execute(
            select(ProfessionToolRel).where(ProfessionToolRel.profession_id == profession_id)
        )
        return result.scalars().all()

    async def add_tool_to_profession(
        self,
        profession_id: int,
        tool_id: int,
        usage_type: str,
    ) -> ProfessionToolRel:
        """
        Tambah tool ke profesi.
        Validasi nilai usage_type dilakukan di service layer
        menggunakan VALID_USAGE_TYPES dari models.
        """
        now = datetime.now(timezone.utc)
        obj = ProfessionToolRel(
            profession_id=profession_id,
            tool_id=tool_id,
            usage_type=usage_type,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def remove_tool_from_profession(
        self, profession_id: int, tool_id: int
    ) -> bool:
        result = await self.db.execute(
            delete(ProfessionToolRel).where(
                ProfessionToolRel.profession_id == profession_id,
                ProfessionToolRel.tool_id == tool_id,
            )
        )
        return result.rowcount > 0
```

---

## File: `app/repositories/study_program_repository.py`

```python
"""
app/repositories/study_program_repository.py
----------------------------------------------
Repository untuk tabel study_programs (master).
Termasuk operasi pada pivot profession_study_program_rels.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.study_program import StudyProgram
from app.models.profession_study_program_rel import ProfessionStudyProgramRel


class StudyProgramRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── Master study_programs ──────────────────────────────────────────────────

    async def get_all(self) -> list[StudyProgram]:
        result = await self.db.execute(select(StudyProgram).order_by(StudyProgram.name))
        return result.scalars().all()

    async def get_by_id(self, sp_id: int) -> Optional[StudyProgram]:
        result = await self.db.execute(select(StudyProgram).where(StudyProgram.id == sp_id))
        return result.scalar_one_or_none()

    async def get_by_name(self, name: str) -> Optional[StudyProgram]:
        result = await self.db.execute(select(StudyProgram).where(StudyProgram.name == name))
        return result.scalar_one_or_none()

    async def create(self, name: str) -> StudyProgram:
        now = datetime.now(timezone.utc)
        obj = StudyProgram(name=name, created_at=now, updated_at=now)
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def delete(self, sp_id: int) -> bool:
        """RESTRICT — gagal jika masih ada relasi ke profesi."""
        result = await self.db.execute(delete(StudyProgram).where(StudyProgram.id == sp_id))
        return result.rowcount > 0

    # ── Pivot profession_study_program_rels ────────────────────────────────────

    async def get_by_profession(self, profession_id: int) -> list[ProfessionStudyProgramRel]:
        result = await self.db.execute(
            select(ProfessionStudyProgramRel).where(
                ProfessionStudyProgramRel.profession_id == profession_id
            )
        )
        return result.scalars().all()

    async def add_to_profession(
        self, profession_id: int, study_program_id: int
    ) -> ProfessionStudyProgramRel:
        now = datetime.now(timezone.utc)
        obj = ProfessionStudyProgramRel(
            profession_id=profession_id,
            study_program_id=study_program_id,
            created_at=now,
            updated_at=now,
        )
        self.db.add(obj)
        await self.db.flush()
        return obj

    async def remove_from_profession(
        self, profession_id: int, study_program_id: int
    ) -> bool:
        result = await self.db.execute(
            delete(ProfessionStudyProgramRel).where(
                ProfessionStudyProgramRel.profession_id == profession_id,
                ProfessionStudyProgramRel.study_program_id == study_program_id,
            )
        )
        return result.rowcount > 0
```

---

## File: `app/seeders/profession_main_category_seeder.py`

```python
"""
app/seeders/profession_main_category_seeder.py
------------------------------------------------
Seeder untuk tabel profession_main_categories.
Menggunakan pola "insert jika belum ada" (idempotent / safe to re-run).

Cara menjalankan (dari root project):
    python -m app.seeders.profession_main_category_seeder
"""

import asyncio
from datetime import datetime, timezone
from sqlalchemy import select
from app.database.config import AsyncSessionLocal
from app.models.profession_main_category import ProfessionMainCategory

CATEGORIES = [
    ("ENGINEERING", "Engineering",  "Kategori profesi teknis yang bertanggung jawab atas perancangan, pengembangan, pengujian, dan pemeliharaan sistem digital."),
    ("DATA",        "Data",         "Kategori profesi analitis yang berfokus pada pengumpulan, pengolahan, dan analisis data untuk menghasilkan wawasan strategis."),
    ("PRODUCT",     "Product",      "Kategori profesi strategis yang menjembatani aspek teknis, bisnis, dan desain dalam pengelolaan produk digital."),
    ("DESIGN",      "Design",       "Kategori profesi kreatif yang berfokus pada perancangan antarmuka dan pengalaman pengguna."),
    ("MARKETING",   "Marketing",    "Kategori profesi komunikasi yang berfokus pada promosi, branding, dan akuisisi pengguna."),
    ("BUSINESS",    "Business",     "Kategori profesi komersial yang berfokus pada strategi pertumbuhan dan kemitraan."),
    ("FINANCE",     "Finance",      "Kategori profesi manajerial yang mengelola kesehatan finansial dan strategi pendanaan perusahaan."),
    ("PEOPLE",      "People",       "Kategori profesi organisasi yang mengelola siklus hidup talenta dan budaya kerja."),
    ("OPERATIONS",  "Operations",   "Kategori profesi eksekusi yang memastikan efisiensi proses bisnis dan operasional."),
    ("LEGAL",       "Legal",        "Kategori profesi hukum yang menangani kepatuhan regulasi dan mitigasi risiko hukum."),
]


async def seed_profession_main_category() -> None:
    async with AsyncSessionLocal() as session:
        for code, name, description in CATEGORIES:
            existing = await session.execute(
                select(ProfessionMainCategory).where(ProfessionMainCategory.code == code)
            )
            if existing.scalar_one_or_none() is not None:
                print(f"[SKIP] {code} — sudah ada")
                continue

            now = datetime.now(timezone.utc)
            session.add(ProfessionMainCategory(
                code=code, name=name, description=description,
                created_at=now, updated_at=now,
            ))
            print(f"[INSERT] {code}")

        await session.commit()
        print("✅ Seeder profession_main_category selesai.")


if __name__ == "__main__":
    asyncio.run(seed_profession_main_category())
```

---

## File: `app/seeders/profession_sub_category_seeder.py`

> **[FIX-5]** — Ditambahkan komentar yang menjelaskan kenapa hanya 4 main category yang di-cache,  
> agar developer tidak bingung saat melihat kode ini.

```python
"""
app/seeders/profession_sub_category_seeder.py
----------------------------------------------
Seeder untuk tabel profession_sub_categories.
Idempotent — aman dijalankan ulang.

Cara menjalankan (dari root project):
    python -m app.seeders.profession_sub_category_seeder

Pastikan profession_main_category_seeder sudah dijalankan lebih dulu.
"""

import asyncio
from datetime import datetime, timezone
from sqlalchemy import select
from app.database.config import AsyncSessionLocal
from app.models.profession_main_category import ProfessionMainCategory
from app.models.profession_sub_category import ProfessionSubCategory

# Format: (main_category_code, sub_code, sub_name, description)
SUB_CATEGORIES = [
    # ── ENGINEERING ────────────────────────────────────────────────────────────
    ("ENGINEERING", "BACKEND",          "Backend",          "Profesi engineering yang membangun dan merawat sisi server aplikasi, termasuk logika bisnis, basis data, dan API."),
    ("ENGINEERING", "FRONTEND",         "Frontend",         "Profesi engineering yang membangun antarmuka aplikasi di sisi pengguna dan menerjemahkan rancangan tampilan menjadi kode interaktif dan responsif."),
    ("ENGINEERING", "MOBILE",           "Mobile",           "Profesi engineering yang mengembangkan aplikasi pada perangkat bergerak (Android/iOS) serta menjaga kompatibilitas dan performa lintas perangkat."),
    ("ENGINEERING", "DEVOPS",           "DevOps",           "Profesi engineering yang mengelola proses rilis dan penyebaran aplikasi, termasuk otomasi CI/CD dan pemantauan stabilitas sistem."),
    ("ENGINEERING", "QUALITY_ASSURANCE","Quality Assurance","Profesi engineering yang memverifikasi kualitas perangkat lunak sebelum rilis melalui pengujian fungsional dan otomatis."),
    ("ENGINEERING", "SECURITY",         "Security",         "Profesi engineering yang melindungi sistem dan data dari ancaman siber melalui penilaian kerentanan dan respons insiden."),
    ("ENGINEERING", "NETWORK",          "Network",          "Profesi engineering yang merancang dan memelihara jaringan komunikasi agar konektivitas stabil dan aman."),
    ("ENGINEERING", "GAME",             "Game",             "Profesi engineering yang membangun sistem permainan digital, termasuk logika interaksi dan integrasi aset grafis/audio."),
    ("ENGINEERING", "EMBEDDED",         "Embedded",         "Profesi engineering yang mengembangkan perangkat lunak pada sistem tertanam (firmware) dan perangkat IoT."),
    ("ENGINEERING", "ROBOTICS",         "Robotics",         "Profesi engineering yang merancang sistem robotik, termasuk algoritma kontrol dan integrasi sensor untuk otomasi industri."),
    ("ENGINEERING", "CLOUD",            "Cloud",            "Profesi engineering yang merancang dan mengelola layanan berbasis cloud, mencakup arsitektur, skalabilitas, dan efisiensi biaya."),
    ("ENGINEERING", "AUTOMATION",       "Automation",       "Profesi engineering yang membangun otomasi proses teknis untuk mengurangi human error dan mempercepat waktu rilis."),
    ("ENGINEERING", "HARDWARE",         "Hardware",         "Profesi engineering yang merancang dan mengembangkan perangkat keras untuk produk teknologi, termasuk pengujian prototipe dan integrasi software."),
    # ── DATA ───────────────────────────────────────────────────────────────────
    ("DATA", "INFRASTRUCTURE", "Infrastructure", "Kategori profesi yang berfokus pada pembangunan dan pengelolaan infrastruktur data, termasuk data pipeline dan penyimpanan data warehouse/data lake."),
    ("DATA", "GOVERNANCE",     "Governance",     "Kategori profesi yang berfokus pada pengelolaan kualitas data, kepatuhan regulasi, dan keamanan data."),
    ("DATA", "ANALYTICS",      "Analytics",      "Kategori profesi yang berfokus pada analisis data historis untuk menghasilkan wawasan pengambilan keputusan bisnis."),
    ("DATA", "SCIENCE",        "Science",        "Kategori profesi yang berfokus pada prediksi berbasis data menggunakan teknik statistik dan machine learning."),
    ("DATA", "AI",             "AI",             "Kategori profesi yang berfokus pada pengembangan sistem machine learning dan kemampuan kognitif buatan."),
    # ── PRODUCT ────────────────────────────────────────────────────────────────
    ("PRODUCT", "MANAGEMENT", "Management", "Kategori profesi yang bertanggung jawab atas visi, strategi, prioritas fitur, dan eksekusi peluncuran produk."),
    ("PRODUCT", "GROWTH",     "Growth",     "Kategori profesi yang fokus pada akuisisi pengguna, retensi, dan optimasi produk untuk meningkatkan konversi dan pendapatan."),
    ("PRODUCT", "OPERATIONS", "Operations", "Kategori profesi yang berfokus pada efisiensi proses dan ritme kerja dalam tim produk."),
    ("PRODUCT", "ANALYTICS",  "Analytics",  "Kategori profesi yang bertanggung jawab untuk analisis perilaku pengguna dan wawasan data produk."),
    # ── DESIGN ─────────────────────────────────────────────────────────────────
    ("DESIGN", "UI_UX",   "UI/UX",    "Subkategori profesi yang bertanggung jawab atas perancangan antarmuka pengguna (UI) dan pengalaman pengguna (UX)."),
    ("DESIGN", "VISUAL",  "Visual",   "Subkategori yang berfokus pada komunikasi visual, branding, dan desain grafis untuk memperkuat identitas merek digital."),
    ("DESIGN", "RESEARCH","Research", "Subkategori yang bertanggung jawab untuk meneliti perilaku pengguna melalui wawancara, survei, dan usability testing."),
    ("DESIGN", "CONTENT", "Content",  "Subkategori yang berfokus pada penulisan microcopy dan teks dalam produk digital untuk membantu navigasi pengguna."),
]


async def seed_profession_sub_category() -> None:
    async with AsyncSessionLocal() as session:
        # [FIX-5] Hanya ENGINEERING, DATA, PRODUCT, DESIGN yang di-cache karena
        # hanya 4 main category tersebut yang memiliki sub_category di data awal.
        # Main category lain (MARKETING, BUSINESS, FINANCE, PEOPLE, OPERATIONS, LEGAL)
        # belum memiliki sub_category — akan ditambahkan di iterasi data berikutnya.
        main_cache: dict[str, int] = {}
        for main_code in ("ENGINEERING", "DATA", "PRODUCT", "DESIGN"):
            result = await session.execute(
                select(ProfessionMainCategory).where(ProfessionMainCategory.code == main_code)
            )
            main = result.scalar_one_or_none()
            if main is None:
                raise RuntimeError(f"Main category '{main_code}' tidak ditemukan. Jalankan main category seeder dulu.")
            main_cache[main_code] = main.id

        for main_code, sub_code, sub_name, desc in SUB_CATEGORIES:
            main_id = main_cache[main_code]
            existing = await session.execute(
                select(ProfessionSubCategory).where(
                    ProfessionSubCategory.main_category_id == main_id,
                    ProfessionSubCategory.code == sub_code,
                )
            )
            if existing.scalar_one_or_none() is not None:
                print(f"[SKIP] {main_code}/{sub_code} — sudah ada")
                continue

            now = datetime.now(timezone.utc)
            session.add(ProfessionSubCategory(
                main_category_id=main_id,
                code=sub_code,
                name=sub_name,
                description=desc,
                created_at=now,
                updated_at=now,
            ))
            print(f"[INSERT] {main_code}/{sub_code}")

        await session.commit()
        print("✅ Seeder profession_sub_category selesai.")


if __name__ == "__main__":
    asyncio.run(seed_profession_sub_category())
```

---

## Contoh Penggunaan di Service Layer (Transaksional)

> **[FIX-6]** — Ditambahkan `await db.commit()` eksplisit di akhir transaksi.  
> Sebelumnya komentar menyebut commit dilakukan otomatis oleh `get_db()`,  
> tapi setelah FIX-1 hal tersebut tidak lagi berlaku.

```python
"""
Contoh: app/services/profession_service.py
-------------------------------------------
Flow create profession lengkap dalam 1 transaksi.
Semua validasi business rule dilakukan di sini, bukan di repository.
"""

from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories import (
    ProfessionRepository,
    ProfessionSubCategoryRepository,
    ProfessionAliasRepository,
    ProfessionActivityRepository,
    ProfessionMarketInsightRepository,
    ProfessionCareerPathRepository,
    SkillRepository,
    ToolRepository,
    StudyProgramRepository,
)
from app.models.profession_skill_rel import VALID_SKILL_TYPES, VALID_PRIORITIES
from app.models.profession_tool_rel import VALID_USAGE_TYPES


def generate_slug(name: str) -> str:
    """Generate slug dari nama profesi. Contoh: 'Data Engineer' → 'data-engineer'."""
    return name.lower().strip().replace(" ", "-")


async def create_profession_full(db: AsyncSession, payload: dict) -> dict:
    """
    Buat profesi baru beserta semua data turunannya dalam 1 transaksi.
    Rollback otomatis dilakukan oleh get_db() jika terjadi exception.
    Commit dilakukan eksplisit di akhir fungsi ini setelah semua langkah berhasil.
    """

    # ── Langkah 1: Validasi sub_category konsisten dengan main_category ────────
    sub_repo = ProfessionSubCategoryRepository(db)
    sub = await sub_repo.get_by_id(payload["sub_category_id"])
    if sub is None:
        raise ValueError("sub_category_id tidak ditemukan")
    if sub.main_category_id != payload["main_category_id"]:
        raise ValueError("sub_category_id tidak berada di bawah main_category_id yang dipilih")

    # ── Langkah 2: Validasi RIASEC consistency ─────────────────────────────────
    if payload.get("riasec_code_id") and not payload.get("riasec_description"):
        raise ValueError("riasec_description wajib diisi bersamaan dengan riasec_code_id")

    # ── Langkah 3: Generate slug jika tidak disediakan ─────────────────────────
    slug = payload.get("slug") or generate_slug(payload["name"])

    # ── Langkah 4: Insert profession ───────────────────────────────────────────
    prof_repo = ProfessionRepository(db)
    profession = await prof_repo.create(
        slug=slug,
        name=payload["name"],
        main_category_id=payload["main_category_id"],
        sub_category_id=payload["sub_category_id"],
        image_url=payload.get("image_url"),
        riasec_code_id=payload.get("riasec_code_id"),
        about_description=payload.get("about_description"),
        riasec_description=payload.get("riasec_description"),
    )
    # profession.id sudah terisi setelah flush di dalam repo.create()

    # ── Langkah 5: Insert aliases (opsional) ───────────────────────────────────
    alias_repo = ProfessionAliasRepository(db)
    for alias_name in payload.get("aliases", []):
        await alias_repo.create(profession.id, alias_name)

    # ── Langkah 6: Insert activities ───────────────────────────────────────────
    activity_repo = ProfessionActivityRepository(db)
    for i, desc in enumerate(payload.get("activities", []), start=1):
        await activity_repo.create(profession.id, desc, sort_order=i)

    # ── Langkah 7: Insert market insights ─────────────────────────────────────
    insight_repo = ProfessionMarketInsightRepository(db)
    for i, desc in enumerate(payload.get("market_insights", []), start=1):
        await insight_repo.create(profession.id, desc, sort_order=i)

    # ── Langkah 8: Insert career paths ─────────────────────────────────────────
    path_repo = ProfessionCareerPathRepository(db)
    for path in payload.get("career_paths", []):
        await path_repo.create(
            profession_id=profession.id,
            title=path["title"],
            experience_range=path["experience_range"],
            sort_order=path["sort_order"],
            salary_min=path.get("salary_min"),
            salary_max=path.get("salary_max"),
        )

    # ── Langkah 9: Insert skill rels ───────────────────────────────────────────
    skill_repo = SkillRepository(db)
    for s in payload.get("skills", []):
        if s["skill_type"] not in VALID_SKILL_TYPES:
            raise ValueError(f"skill_type tidak valid: {s['skill_type']}")
        if s["priority"] not in VALID_PRIORITIES:
            raise ValueError(f"priority tidak valid: {s['priority']}")
        await skill_repo.add_skill_to_profession(profession.id, s["skill_id"], s["skill_type"], s["priority"])

    # ── Langkah 10: Insert tool rels ───────────────────────────────────────────
    tool_repo = ToolRepository(db)
    for t in payload.get("tools", []):
        if t["usage_type"] not in VALID_USAGE_TYPES:
            raise ValueError(f"usage_type tidak valid: {t['usage_type']}")
        await tool_repo.add_tool_to_profession(profession.id, t["tool_id"], t["usage_type"])

    # ── Langkah 11: Insert study program rels ──────────────────────────────────
    sp_repo = StudyProgramRepository(db)
    for sp_id in payload.get("study_program_ids", []):
        await sp_repo.add_to_profession(profession.id, sp_id)

    # [FIX-6] Commit eksplisit setelah semua langkah berhasil
    # (tidak lagi dilakukan otomatis di get_db())
    await db.commit()

    return {"id": profession.id, "slug": profession.slug}
```

---

## Catatan Integrasi Future

Saat tabel `explorations` tersedia di DB, tambahkan:

```
app/models/exploration.py                     ← master, independen
app/models/profession_exploration_rel.py      ← pivot FK → professions + explorations
app/repositories/exploration_repository.py
```

Tidak ada perubahan pada model yang sudah ada — modul ini dirancang berdiri sendiri.

---

*Brief ini final dan siap implementasi. Struktur model Python sama persis dengan skema tabel di brief Go/GORM.*
