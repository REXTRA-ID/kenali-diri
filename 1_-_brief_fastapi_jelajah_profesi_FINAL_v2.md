# Brief Penugasan Backend — Entity & Repository Jelajah Profesi (FastAPI Kenali Diri)

**Modul:** Kamus Karier → Jelajah Profesi  
**Fitur terkait:** Analisis Kecocokan Profesi (RIASEC), Ikigai, Fit Check, Result  
**Stack:** Python · FastAPI · SQLAlchemy (sync) · psycopg2 · PostgreSQL  
**Status:** Final — siap implementasi  
**DB:** PostgreSQL online — tabel sudah ada, **tidak perlu migration untuk tabel profesi**

---

## Perbedaan dari Brief Original (MD 1 asli)

Brief ini adalah **adaptasi sync** dari brief async asli, yang sudah **diselaraskan dengan MD 2–6** (revisi RIASEC, Ikigai, Fit Check, Result, Migration). Semua keputusan tentang struktur repo mengikuti MD 3 (Ikigai) sebagai sumber kebenaran.

| Aspek | MD 1 Asli (async) | Brief ini (sync, diselaraskan) |
|---|---|---|
| Session SQLAlchemy | `AsyncSession` | `Session` |
| Method | `async def` + `await` | `def` (sync) |
| Base import | `app.database.config` | `app.db.base` |
| Lokasi model | `app/models/` | `app/api/v1/categories/career_profile/models/` |
| Lokasi repo | `app/repositories/` | `app/api/v1/categories/career_profile/repositories/` |
| Nama class SQLAlchemy | `Profession` | `Profession` *(lihat catatan)*  |
| Nama class data (JSONB) | *(tidak ada)* | `Profession` *(data class lama — tetap ada)* |
| Struktur ProfessionRepository | *(tidak ada di MD asli)* | **Satu class** sesuai MD 3 |

> ⚠️ **Catatan penting tentang nama class `Profession`:**  
> MD 3 (Ikigai) mendefinisikan `ProfessionRepository` yang query tabel relasional menggunakan  
> class `Profession` (SQLAlchemy model). Sementara `profession_repo.py` lama juga punya  
> data class `Profession` (Python biasa, bukan SQLAlchemy).  
> **Solusi:** Data class lama **dihapus** dari `profession_repo.py` karena MD 3 sudah  
> merombak total file tersebut. `Profession` di brief ini = SQLAlchemy model, bukan data class.

---

## Changelog Pembaruan (Diselaraskan dengan MD 2–6)

| # | Label | File | Masalah | Perbaikan |
|---|---|---|---|---|
| 1 | **[FIX-1]** | `models/profession_relational.py` | Semua `DateTime` tanpa timezone | Semua `DateTime` → `DateTime(timezone=True)` |
| 2 | **[FIX-2]** | `models/profession_relational.py` | Model `Profession` belum ada `back_populates` lengkap | Tambah semua `back_populates` dua arah |
| 3 | **[FIX-3]** | `repositories/profession_repo.py` | Masih query `DigitalProfession` (model lama flat) | Rombak total ke tabel relasional sesuai MD 3 |
| 4 | **[FIX-4]** | `repositories/profession_repo.py` | `create_candidates` signature lama tidak punya `total_candidates`, `generation_strategy`, `max_candidates_limit` | Update signature sesuai MD 2 (Temuan 3) |
| 5 | **[FIX-5]** | `repositories/profession_repo.py` | Belum ada `get_by_id()` dan `get_by_ids()` | Tambah sesuai kebutuhan MD 4 (result_service) |
| 6 | **[FIX-6]** | `models/profession_relational.py` | Semua PK/FK pakai `BigInteger` (int8) — tidak cocok dengan tipe `int4` yang dibuat Go/GORM | Semua PK/FK → `Integer` (int4), sesuai kolom aktual di PostgreSQL |
| 7 | **[FIX-7]** | `repositories/profession_repo.py` | Belum ada `get_by_slug()` | Tambah untuk kebutuhan halaman detail profesi dari hasil rekomendasi |

---

## Struktur Folder

```
app/
├── db/
│   └── base.py                          ← Base SQLAlchemy — sudah ada, jangan ubah
├── api/v1/categories/career_profile/
│   ├── models/
│   │   ├── digital_profession.py        ← LAMA — JANGAN HAPUS (masih dipakai expansion)
│   │   ├── profession_relational.py     ← BARU — semua model relasional profesi
│   │   ├── profession.py                ← sudah ada (IkigaiCandidateProfession)
│   │   ├── ikigai.py                    ← sudah ada
│   │   ├── result.py                    ← sudah ada
│   │   ├── riasec.py                    ← sudah ada
│   │   └── session.py                   ← sudah ada
│   └── repositories/
│       └── profession_repo.py           ← DIROMBAK TOTAL sesuai MD 3
```

---

## File: `app/api/v1/categories/career_profile/models/profession_relational.py`

> File **baru**. Berisi semua SQLAlchemy model untuk tabel profesi relasional.  
> Nama file `profession_relational.py` agar tidak konflik dengan `profession.py`  
> yang sudah ada (berisi `IkigaiCandidateProfession`).  
> Tabel-tabel ini sudah ada di DB — file ini hanya merefleksikan, tidak membuat tabel baru.

```python
# app/api/v1/categories/career_profile/models/profession_relational.py
"""
Model SQLAlchemy untuk tabel profesi relasional dari Jelajah Profesi.

PENTING: Semua tabel sudah ada di DB (di-manage Golang CRUD service).
         FastAPI hanya READ dari tabel ini. Tidak ada migration untuk file ini.

Tabel yang di-map:
    profession_main_categories
    profession_sub_categories
    professions                    ← class Profession (SQLAlchemy model)
    profession_activities
    profession_market_insights
    profession_career_paths
    skills
    profession_skill_rels
    tools
    profession_tool_rels
    study_programs
    profession_study_program_rels

Diimport oleh:
    profession_repo.py → ProfessionRepository (semua query relasional)
"""

from typing import Optional, List
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text,
    ForeignKey, DateTime
)
from sqlalchemy.orm import relationship
from app.db.base import Base


# ── Konstanta validasi (dipakai service layer) ────────────────────────────────
VALID_SKILL_TYPES = ("hard", "soft")
VALID_PRIORITIES  = ("wajib", "dianjurkan")
VALID_USAGE_TYPES = ("wajib", "umum")


class ProfessionMainCategory(Base):
    """
    Kategori utama profesi.
    Contoh: Engineering, Data, Product, Design, Marketing
    """
    __tablename__ = "profession_main_categories"

    id          = Column(Integer, primary_key=True, autoincrement=True)
    code        = Column(String(50),  unique=True, nullable=False)
    name        = Column(String(100), nullable=False)
    description = Column(Text,        nullable=False)
    created_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    sub_categories = relationship(
        "ProfessionSubCategory",
        back_populates="main_category",
        lazy="select",
    )
    professions = relationship(
        "Profession",
        back_populates="main_category",
        lazy="select",
    )

    def __repr__(self) -> str:
        return f"<ProfessionMainCategory id={self.id} code={self.code}>"


class ProfessionSubCategory(Base):
    """
    Sub kategori profesi.
    Contoh: Backend, Frontend, Mobile (di bawah Engineering)
    """
    __tablename__ = "profession_sub_categories"

    id               = Column(Integer, primary_key=True, autoincrement=True)
    main_category_id = Column(
        Integer,
        ForeignKey("profession_main_categories.id", ondelete="RESTRICT"),
        nullable=False, index=True
    )
    code        = Column(String(50),  nullable=False)
    name        = Column(String(100), nullable=False)
    description = Column(Text,        nullable=False)
    created_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    main_category = relationship(
        "ProfessionMainCategory",
        back_populates="sub_categories",
        lazy="select",
    )
    professions = relationship(
        "Profession",
        back_populates="sub_category",
        lazy="select",
    )

    def __repr__(self) -> str:
        return f"<ProfessionSubCategory id={self.id} code={self.code}>"


class Profession(Base):
    """
    Master tabel profesi relasional dari Jelajah Profesi.

    PENTING tentang nama class:
      Class ini bernama `Profession` (SQLAlchemy model, tabel: professions).
      Ini BERBEDA dari data class `Profession` yang ada di profession_repo.py lama.
      Setelah profession_repo.py dirombak sesuai MD 3, data class lama sudah dihapus.
      Tidak ada konflik nama.

    riasec_code_id nullable — profesi tanpa nilai ini tidak ikut matching RIASEC.
    Relasi ke RIASECCode via riasec_code_id.
    """
    __tablename__ = "professions"

    id                 = Column(Integer, primary_key=True, autoincrement=True)
    slug               = Column(String(120), unique=True,  nullable=False)
    name               = Column(String(100), nullable=False)
    image_url          = Column(Text,        nullable=True)
    main_category_id   = Column(
        Integer,
        ForeignKey("profession_main_categories.id", ondelete="RESTRICT"),
        nullable=False, index=True
    )
    sub_category_id    = Column(
        Integer,
        ForeignKey("profession_sub_categories.id", ondelete="RESTRICT"),
        nullable=False, index=True
    )
    riasec_code_id     = Column(
        Integer,
        ForeignKey("riasec_codes.id", ondelete="RESTRICT"),
        nullable=True, index=True
    )
    about_description  = Column(Text, nullable=True)
    riasec_description = Column(Text, nullable=True)
    created_at         = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at         = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    # Relasi — back_populates dua arah semua [FIX-2]
    main_category = relationship(
        "ProfessionMainCategory",
        back_populates="professions",
        lazy="select"
    )
    sub_category = relationship(
        "ProfessionSubCategory",
        back_populates="professions",
        lazy="select"
    )
    # Tidak ada back_populates ke RIASECCode — keputusan sengaja.
    # RIASECCode sudah punya backref="digital_professions" ke DigitalProfession.
    # Menambahkan back_populates ke sini akan menyebabkan konflik mapper di SQLAlchemy
    # karena satu class (RIASECCode) tidak bisa punya dua relasi berbeda ke dua target
    # berbeda dengan nama yang bertabrakan. Selama RIASECCode tidak diubah, ini aman.
    riasec_code_obj = relationship(
        "RIASECCode",
        foreign_keys=[riasec_code_id],
        lazy="select"
    )
    activities = relationship(
        "ProfessionActivity",
        back_populates="profession",
        cascade="all, delete-orphan",
        order_by="ProfessionActivity.sort_order",
        lazy="select",
    )
    market_insights = relationship(
        "ProfessionMarketInsight",
        back_populates="profession",
        cascade="all, delete-orphan",
        order_by="ProfessionMarketInsight.sort_order",
        lazy="select",
    )
    career_paths = relationship(
        "ProfessionCareerPath",
        back_populates="profession",
        cascade="all, delete-orphan",
        order_by="ProfessionCareerPath.sort_order",
        lazy="select",
    )
    skill_rels = relationship(
        "ProfessionSkillRel",
        back_populates="profession",
        cascade="all, delete-orphan",
        lazy="select",
    )
    tool_rels = relationship(
        "ProfessionToolRel",
        back_populates="profession",
        cascade="all, delete-orphan",
        lazy="select",
    )
    study_program_rels = relationship(
        "ProfessionStudyProgramRel",
        back_populates="profession",
        cascade="all, delete-orphan",
        lazy="select",
    )

    def __repr__(self) -> str:
        return f"<Profession id={self.id} slug={self.slug}>"


class ProfessionActivity(Base):
    """
    Aktivitas kerja utama suatu profesi — ordered by sort_order.
    Dipakai ikigai_service untuk context AI prompt (max 5 items).
    """
    __tablename__ = "profession_activities"

    id            = Column(Integer, primary_key=True, autoincrement=True)
    profession_id = Column(
        Integer,
        ForeignKey("professions.id", ondelete="CASCADE"),
        nullable=False, index=True
    )
    description = Column(Text,    nullable=False)
    sort_order  = Column(Integer, nullable=False)
    created_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession = relationship("Profession", back_populates="activities", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionActivity id={self.id} sort={self.sort_order}>"


class ProfessionMarketInsight(Base):
    """
    Kondisi pasar kerja — bullet list, ordered by sort_order.
    """
    __tablename__ = "profession_market_insights"

    id            = Column(Integer, primary_key=True, autoincrement=True)
    profession_id = Column(
        Integer,
        ForeignKey("professions.id", ondelete="CASCADE"),
        nullable=False, index=True
    )
    description = Column(Text,    nullable=False)
    sort_order  = Column(Integer, nullable=False)
    created_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at  = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession = relationship("Profession", back_populates="market_insights", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionMarketInsight id={self.id} sort={self.sort_order}>"


class ProfessionCareerPath(Base):
    """
    Jenjang karier dengan salary range.
    Dipakai ikigai untuk context 'what_you_can_be_paid_for'.
    get_profession_contexts_for_recommendation() ambil entry_level + senior_level.
    """
    __tablename__ = "profession_career_paths"

    id               = Column(Integer, primary_key=True, autoincrement=True)
    profession_id    = Column(
        Integer,
        ForeignKey("professions.id", ondelete="CASCADE"),
        nullable=False, index=True
    )
    title            = Column(String(100), nullable=False)   # "Junior Data Engineer"
    experience_range = Column(String(50),  nullable=False)   # "0–2 tahun"
    salary_min       = Column(Integer,     nullable=True)
    salary_max       = Column(Integer,     nullable=True)
    sort_order       = Column(Integer,     nullable=False)
    created_at       = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at       = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession = relationship("Profession", back_populates="career_paths", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionCareerPath id={self.id} title={self.title}>"


class Skill(Base):
    """Master skill global — reusable lintas profesi."""
    __tablename__ = "skills"

    id         = Column(Integer, primary_key=True, autoincrement=True)
    name       = Column(String(100), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession_rels = relationship(
        "ProfessionSkillRel", back_populates="skill", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<Skill id={self.id} name={self.name}>"


class ProfessionSkillRel(Base):
    """
    Pivot profesi ↔ skill.
    skill_type: "hard" | "soft"  (CHECK constraint di DB)
    priority:   "wajib" | "dianjurkan"  (CHECK constraint di DB)
    """
    __tablename__ = "profession_skill_rels"

    profession_id = Column(
        Integer,
        ForeignKey("professions.id", ondelete="CASCADE"),
        primary_key=True
    )
    skill_id = Column(
        Integer,
        ForeignKey("skills.id", ondelete="RESTRICT"),
        primary_key=True
    )
    skill_type = Column(String(20), nullable=False)
    priority   = Column(String(20), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession = relationship("Profession", back_populates="skill_rels", lazy="select")
    skill      = relationship("Skill", back_populates="profession_rels", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionSkillRel profession={self.profession_id} skill={self.skill_id}>"


class Tool(Base):
    """Master tool/teknologi global — reusable lintas profesi."""
    __tablename__ = "tools"

    id         = Column(Integer, primary_key=True, autoincrement=True)
    name       = Column(String(100), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession_rels = relationship(
        "ProfessionToolRel", back_populates="tool", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<Tool id={self.id} name={self.name}>"


class ProfessionToolRel(Base):
    """
    Pivot profesi ↔ tool.
    usage_type: "wajib" | "umum"  (CHECK constraint di DB)
    """
    __tablename__ = "profession_tool_rels"

    profession_id = Column(
        Integer,
        ForeignKey("professions.id", ondelete="CASCADE"),
        primary_key=True
    )
    tool_id = Column(
        Integer,
        ForeignKey("tools.id", ondelete="RESTRICT"),
        primary_key=True
    )
    usage_type = Column(String(20), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession = relationship("Profession", back_populates="tool_rels", lazy="select")
    tool       = relationship("Tool", back_populates="profession_rels", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionToolRel profession={self.profession_id} tool={self.tool_id}>"


class StudyProgram(Base):
    """Master program studi / jurusan formal."""
    __tablename__ = "study_programs"

    id         = Column(Integer, primary_key=True, autoincrement=True)
    name       = Column(String(150), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession_rels = relationship(
        "ProfessionStudyProgramRel", back_populates="study_program", lazy="select"
    )

    def __repr__(self) -> str:
        return f"<StudyProgram id={self.id} name={self.name}>"


class ProfessionStudyProgramRel(Base):
    """Pivot profesi ↔ program studi."""
    __tablename__ = "profession_study_program_rels"

    profession_id    = Column(
        Integer,
        ForeignKey("professions.id", ondelete="CASCADE"),
        primary_key=True
    )
    study_program_id = Column(
        Integer,
        ForeignKey("study_programs.id", ondelete="RESTRICT"),
        primary_key=True
    )
    created_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]
    updated_at = Column(DateTime(timezone=True), nullable=False)  # [FIX-1]

    profession    = relationship("Profession", back_populates="study_program_rels", lazy="select")
    study_program = relationship("StudyProgram", back_populates="profession_rels", lazy="select")

    def __repr__(self) -> str:
        return f"<ProfessionStudyProgramRel profession={self.profession_id} sp={self.study_program_id}>"
```

---

## File: `app/api/v1/categories/career_profile/repositories/profession_repo.py`

> **[FIX-3][FIX-4][FIX-5]** — File ini **dirombak total** sesuai MD 3 (Ikigai).  
> Data class `Profession` lama (Python biasa, bukan SQLAlchemy) **dihapus** karena  
> sudah tidak relevan setelah query beralih ke tabel relasional.  
> `ProfessionRepository` sekarang adalah **satu class** yang menangani semua kebutuhan.

```python
# app/api/v1/categories/career_profile/repositories/profession_repo.py
"""
Repository untuk data profesi di kenali-diri.

Sumber data:
  1. Tabel relasional `professions` + relasi (model dari profession_relational.py)
     → get_profession_contexts_for_ikigai()        : context AI untuk 5 kandidat display
     → get_profession_contexts_for_scoring()       : context AI untuk scoring semua kandidat
     → get_profession_contexts_for_recommendation(): context AI untuk narasi rekomendasi top-2
     → find_by_riasec_code()                       : expansion kandidat (tier 1-4)
     → get_by_id() / get_by_ids()                  : lookup simpel untuk result_service
     → get_by_slug()                                : lookup profesi by slug untuk halaman detail

  2. Tabel `ikigai_candidate_professions` (JSONB)
     → get_candidates_by_session_id()  : baca kandidat per sesi
     → create_candidates()             : simpan kandidat baru
     → update_candidates()             : update kandidat existing

Dipakai oleh: ikigai_service.py, profession_expansion.py, result_service.py

CATATAN: DigitalProfession (model lama) sudah tidak dipakai di repo ini.
         File digital_profession.py tetap ada karena masih diimport oleh
         profession_expansion.py (expansion tier 1-4) sampai ekspansi juga dimigrasikan.
"""

from typing import List, Optional
from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import SQLAlchemyError
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession

# === Model relasional dari brief Jelajah Profesi ===
# Import dari profession_relational.py — satu file berisi semua model relasional
from app.api.v1.categories.career_profile.models.profession_relational import (
    Profession,
    ProfessionActivity,
    ProfessionSkillRel,
    ProfessionToolRel,
    ProfessionCareerPath,
    Skill,
    Tool,
)
from app.api.v1.categories.career_profile.models.riasec import RIASECCode


class ProfessionRepository:
    """
    Repository untuk query data profesi.

    Sumber data:
      - Tabel relasional `professions` + relasi (dari brief Jelajah Profesi)
        → untuk context AI scoring, generate konten Ikigai, narasi rekomendasi
      - Tabel `ikigai_candidate_professions` (JSONB)
        → untuk manajemen kandidat per sesi tes
    """

    def __init__(self, db: Session):
        self.db = db

    # ──────────────────────────────────────────────────────────────────────────
    # PROFESSION CONTEXT QUERIES (untuk pipeline Ikigai)
    # Semua method di bawah query dari tabel relasional — bukan DigitalProfession
    # ──────────────────────────────────────────────────────────────────────────

    def get_profession_contexts_for_ikigai(
        self, profession_ids: List[int]
    ) -> List[dict]:
        """
        Query konteks profesi untuk generate narasi konten display Ikigai (5 kandidat).

        Dipakai oleh: IkigaiService._generate_ikigai_content()

        Data yang diambil:
          - professions: id, name, about_description, riasec_description
          - riasec_codes: riasec_code, riasec_title, riasec_description
          - profession_activities: 5 aktivitas teratas (sort_order ASC)
          - profession_skill_rels → skills: 5 hard skill wajib teratas
          - profession_skill_rels → skills: 3 soft skill teratas
          - profession_tool_rels → tools: 4 tool wajib teratas

        Returns:
            List[dict] — setiap dict adalah profession_context siap pakai di prompt AI
        """
        if not profession_ids:
            return []

        try:
            professions = (
                self.db.query(Profession)
                .options(
                    joinedload(Profession.activities),
                    joinedload(Profession.skill_rels).joinedload(ProfessionSkillRel.skill),
                    joinedload(Profession.tool_rels).joinedload(ProfessionToolRel.tool),
                )
                .filter(Profession.id.in_(profession_ids))
                .all()
            )

            riasec_map = self._get_riasec_map(profession_ids)

            result = []
            for p in professions:
                activities = sorted(p.activities, key=lambda a: a.sort_order)[:5]
                hard_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "hard" and rel.priority == "wajib"
                ][:5]
                soft_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "soft"
                ][:3]
                tools = [
                    rel.tool.name
                    for rel in p.tool_rels
                    if rel.usage_type == "wajib"
                ][:4]

                rc = riasec_map.get(p.riasec_code_id, {})
                result.append({
                    "profession_id":        p.id,
                    "name":                 p.name,
                    "riasec_code":          rc.get("riasec_code", "-"),
                    "riasec_title":         rc.get("riasec_title", "-"),
                    "about_description":    (p.about_description or "")[:400],
                    "riasec_description":   p.riasec_description or "",
                    "activities":           [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                    "soft_skills_required": soft_skills,
                    "tools_required":       tools,
                })

            return result

        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal query profession contexts for ikigai: {str(e)}",
            )

    def get_profession_contexts_for_scoring(
        self, profession_ids: List[int]
    ) -> List[dict]:
        """
        Query konteks profesi ringkas untuk AI scoring prompt (semua kandidat).

        Dipakai oleh: IkigaiService._finalize_ikigai() — STEP 3 (Gemini scoring)

        Data yang diambil (lebih sedikit dari ikigai_content — scoring prompt lebih singkat):
          - professions: id, name, about_description
          - profession_activities: 5 aktivitas teratas
          - profession_skill_rels → skills: 3 hard skill wajib teratas

        Returns:
            List[dict] — setiap dict adalah profession_context untuk scoring prompt
        """
        if not profession_ids:
            return []

        try:
            professions = (
                self.db.query(Profession)
                .options(
                    joinedload(Profession.activities),
                    joinedload(Profession.skill_rels).joinedload(ProfessionSkillRel.skill),
                )
                .filter(Profession.id.in_(profession_ids))
                .all()
            )

            result = []
            for p in professions:
                activities = sorted(p.activities, key=lambda a: a.sort_order)[:5]
                hard_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "hard" and rel.priority == "wajib"
                ][:3]

                result.append({
                    "profession_id":        p.id,
                    "name":                 p.name,
                    "about_description":    (p.about_description or "")[:300],
                    "activities":           [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                })

            return result

        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal query profession contexts for scoring: {str(e)}",
            )

    def get_profession_contexts_for_recommendation(
        self, profession_ids: List[int]
    ) -> List[dict]:
        """
        Query konteks profesi lengkap untuk generate narasi rekomendasi akhir (top-2).

        Dipakai oleh: IkigaiService._finalize_ikigai() — STEP 10 (narasi rekomendasi)

        Data yang diambil (paling lengkap dari tiga method):
          - professions: id, name, about_description, riasec_description
          - riasec_codes: riasec_code, riasec_title
          - profession_activities: 5 aktivitas teratas
          - profession_skill_rels → skills: 5 hard skill wajib teratas
          - profession_career_paths: entry_level + senior_level (salary_min, salary_max)
            → data gaji ini yang selama ini HILANG di DigitalProfession (hanya JSONB)

        Returns:
            List[dict] — setiap dict adalah profession_context untuk prompt narasi rekomendasi
        """
        if not profession_ids:
            return []

        try:
            professions = (
                self.db.query(Profession)
                .options(
                    joinedload(Profession.activities),
                    joinedload(Profession.skill_rels).joinedload(ProfessionSkillRel.skill),
                    joinedload(Profession.career_paths),
                )
                .filter(Profession.id.in_(profession_ids))
                .all()
            )

            riasec_map = self._get_riasec_map(profession_ids)

            result = []
            for p in professions:
                activities = sorted(p.activities, key=lambda a: a.sort_order)[:5]
                hard_skills = [
                    rel.skill.name
                    for rel in p.skill_rels
                    if rel.skill_type == "hard" and rel.priority == "wajib"
                ][:5]
                career_paths = sorted(p.career_paths, key=lambda cp: cp.sort_order)

                entry_level  = career_paths[0]  if career_paths else None
                senior_level = career_paths[-1] if len(career_paths) > 1 else None

                rc = riasec_map.get(p.riasec_code_id, {})
                result.append({
                    "profession_id":        p.id,
                    "name":                 p.name,
                    "riasec_code":          rc.get("riasec_code", "-"),
                    "riasec_title":         rc.get("riasec_title", "-"),
                    "about_description":    p.about_description or "-",
                    "riasec_description":   p.riasec_description or "-",
                    "activities":           [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                    # Data gaji dari profession_career_paths — BARU, tidak ada di DigitalProfession
                    "entry_level_path": {
                        "title":            entry_level.title,
                        "experience_range": entry_level.experience_range,
                        "salary_min":       entry_level.salary_min,
                        "salary_max":       entry_level.salary_max,
                    } if entry_level else None,
                    "senior_level_path": {
                        "title":            senior_level.title,
                        "experience_range": senior_level.experience_range,
                        "salary_min":       senior_level.salary_min,
                        "salary_max":       senior_level.salary_max,
                    } if senior_level else None,
                })

            return result

        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal query profession contexts for recommendation: {str(e)}",
            )

    def find_by_riasec_code(
        self, riasec_code: str, limit: int = 30
    ) -> List[Profession]:
        """
        Cari Profession berdasarkan string kode RIASEC (misal 'RIA', 'RI', 'R').
        Digunakan oleh profession_expansion.py saat ekspansi kandidat (Tier 1–4).

        Menggantikan method lama yang query DigitalProfession.
        """
        return (
            self.db.query(Profession)
            .join(RIASECCode, Profession.riasec_code_id == RIASECCode.id)
            .filter(RIASECCode.riasec_code == riasec_code)
            .limit(limit)
            .all()
        )

    # ──────────────────────────────────────────────────────────────────────────
    # SIMPLE LOOKUPS (dipakai result_service & halaman detail) [FIX-5] [FIX-7]
    # ──────────────────────────────────────────────────────────────────────────

    def get_by_id(self, profession_id: int) -> Optional[Profession]:
        """
        Ambil satu Profession dari tabel relasional berdasarkan ID.
        Dipakai oleh result_service.get_fit_check_result() untuk nama profesi target.
        """
        return self.db.query(Profession).filter(Profession.id == profession_id).first()

    def get_by_ids(self, profession_ids: List[int]) -> List[Profession]:
        """
        Ambil beberapa Profession dari tabel relasional berdasarkan list ID.
        Dipakai oleh result_service.get_recommendation_result() untuk enrich nama kandidat.
        """
        if not profession_ids:
            return []
        return self.db.query(Profession).filter(Profession.id.in_(profession_ids)).all()

    def get_by_slug(self, slug: str) -> Optional[Profession]:
        """
        Ambil satu Profession berdasarkan slug.

        Dipakai oleh: halaman detail profesi dari hasil rekomendasi.
        Slug adalah public identifier yang dilampirkan di response rekomendasi
        (contoh: "data-engineer") dan digunakan sebagai path URL menuju halaman
        detail di frontend (/professions/data-engineer).

        [FIX-7]
        """
        return self.db.query(Profession).filter(Profession.slug == slug).first()

    # ──────────────────────────────────────────────────────────────────────────
    # IKIGAI CANDIDATE PROFESSIONS (JSONB)
    # ──────────────────────────────────────────────────────────────────────────

    def get_candidates_by_session_id(
        self, test_session_id: int
    ) -> Optional[IkigaiCandidateProfession]:
        try:
            return self.db.query(IkigaiCandidateProfession).filter(
                IkigaiCandidateProfession.test_session_id == test_session_id
            ).first()
        except SQLAlchemyError as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, str(e))

    def create_candidates(
        self,
        test_session_id: int,
        candidates_data: dict,
        total_candidates: int,       # [FIX-4] sesuai MD 2 Temuan 3
        generation_strategy: str,    # [FIX-4]
        max_candidates_limit: int = 30,  # [FIX-4]
    ) -> IkigaiCandidateProfession:
        """
        Buat record kandidat profesi baru.
        Menyertakan kolom denormalisasi sesuai model yang sudah diperbaiki
        (total_candidates, generation_strategy, max_candidates_limit) dari MD 2 Temuan 3.
        """
        try:
            record = IkigaiCandidateProfession(
                test_session_id=test_session_id,
                candidates_data=candidates_data,
                total_candidates=total_candidates,
                generation_strategy=generation_strategy,
                max_candidates_limit=max_candidates_limit,
            )
            self.db.add(record)
            self.db.commit()
            self.db.refresh(record)
            return record
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal membuat data kandidat: {str(e)}",
            )

    def update_candidates(
        self, test_session_id: int, candidates_data: dict
    ) -> IkigaiCandidateProfession:
        obj = self.get_candidates_by_session_id(test_session_id)
        if not obj:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Candidates not found")
        try:
            obj.candidates_data = candidates_data
            self.db.commit()
            self.db.refresh(obj)
            return obj
        except SQLAlchemyError as e:
            self.db.rollback()
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, str(e))

    # ──────────────────────────────────────────────────────────────────────────
    # PRIVATE HELPERS
    # ──────────────────────────────────────────────────────────────────────────

    def _get_riasec_map(self, profession_ids: List[int]) -> dict:
        """
        Ambil mapping riasec_code_id → {riasec_code, riasec_title, riasec_description}
        untuk daftar profesi yang diberikan. Satu query untuk semua profesi (tidak N+1).
        """
        if not profession_ids:
            return {}

        rows = (
            self.db.query(
                Profession.riasec_code_id,
                RIASECCode.riasec_code,
                RIASECCode.riasec_title,
                RIASECCode.riasec_description,
            )
            .join(RIASECCode, Profession.riasec_code_id == RIASECCode.id)
            .filter(Profession.id.in_(profession_ids))
            .filter(Profession.riasec_code_id.isnot(None))
            .all()
        )

        return {
            row.riasec_code_id: {
                "riasec_code":        row.riasec_code,
                "riasec_title":       row.riasec_title,
                "riasec_description": row.riasec_description,
            }
            for row in rows
        }
```

---

## Catatan Penting Lintas MD

### 1. Tentang `profession_expansion.py` — belum dimigrasikan

`profession_expansion.py` masih pakai `DigitalProfession` untuk enrichment di  
`get_candidates_with_details()`. MD 3 sudah catatan ini:

> *"terutama `riasec_service.py` yang mungkin masih pakai model lama untuk ekspansi kandidat"*

Sampai `profession_expansion.py` juga dimigrasikan, **jangan hapus `digital_profession.py`**.  
Setelah ekspansi juga dimigrasikan, ganti enrichment ke `Profession` relasional:

```python
# Di profession_expansion.py — get_candidates_with_details()
# GANTI:
#   from app.api.v1.categories.career_profile.models.digital_profession import DigitalProfession
#   professions = self.db.query(DigitalProfession).filter(...).all()
#   'profession_name': prof.title
# JADI:
from app.api.v1.categories.career_profile.models.profession_relational import Profession
professions = self.db.query(Profession).filter(Profession.id.in_(profession_ids)).all()
# lalu: 'profession_name': prof.name   (.name bukan .title)
```

### 2. Tentang import path model — SATU lokasi

Semua model relasional ada di satu file:  
`app/api/v1/categories/career_profile/models/profession_relational.py`

**Bukan** di `app/models/profession.py` (path yang muncul di MD 3 di bagian komentar  
"pastikan path sesuai struktur folder aktual"). Path yang benar untuk project kenali-diri  
adalah seperti di atas.

### 3. Urutan implementasi wajib

```
Step 1 — Buat file baru:
  app/api/v1/categories/career_profile/models/profession_relational.py

Step 2 — Ganti seluruh isi:
  app/api/v1/categories/career_profile/repositories/profession_repo.py

Step 3 — Terapkan MD 2 (config, session, session_service, schemas, models/profession.py)

Step 4 — Terapkan MD 3 (ikigai_service, cache, router, schemas)

Step 5 — Terapkan MD 4 (fit_check_classifier, result_service, models/result.py)

Step 6 — Jalankan migration MD 5 (buat dulu dengan alembic revision, tempel isi MD 5)

Step 7 — Jalankan migration MD 6 (idem)
```

### 4. Konflik nama yang sudah diselesaikan

| Konflik | Solusi |
|---|---|
| MD 1 asli pakai `async def` | Sudah diubah ke sync `def` di brief ini |
| MD 1 asli taruh model di `app/models/` | Sudah dipindah ke `app/api/v1/categories/career_profile/models/` |
| MD 1 versi sebelumnya pakai `ProfessionRelational` | Sudah diubah ke `Profession` sesuai MD 3 |
| MD 1 versi sebelumnya pakai `ProfessionMasterRepository` | Sudah dihapus, digabung ke satu `ProfessionRepository` sesuai MD 3 |
| MD 3 import dari `app.models.profession` (tidak ada di kenali-diri) | Sudah dikoreksi ke `app.api.v1.categories.career_profile.models.profession_relational` |
| Data class `Profession` lama vs SQLAlchemy class `Profession` | Data class lama dihapus dari `profession_repo.py` sesuai MD 3 yang rombak total |
| Semua PK/FK pakai `BigInteger` (int8) — tidak match dengan `int4` PostgreSQL dari Go | Semua → `Integer` [FIX-6] |
| `get_by_slug()` belum ada — hasil rekomendasi perlu slug untuk link ke halaman detail profesi | Ditambah ke `ProfessionRepository` [FIX-7] |
