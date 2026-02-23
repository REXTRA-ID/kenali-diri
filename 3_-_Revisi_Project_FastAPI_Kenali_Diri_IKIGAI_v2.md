# Revisi Project FastAPI Kenali Diri — IKIGAI TEST

**Tanggal:** 23 Februari 2026  
**Scope:** Fase Ikigai — Session start, submit dimensi, AI scoring pipeline, Redis cache, schema response, migrasi tabel  
**Acuan:** Brief Penugasan Backend — Tes Ikigai Part 1 & Part 2  
**Status:** Siap implementasi

---

## Daftar Isi

1. [Latar Belakang](#1-latar-belakang)
2. [Daftar Temuan & Masalah](#2-daftar-temuan--masalah)
3. [File yang Harus Diubah](#3-file-yang-harus-diubah)
4. [Source Code Lengkap Per File](#4-source-code-lengkap-per-file)

---

## 1. Latar Belakang

Setelah fase RIASEC selesai, pipeline berlanjut ke fase Ikigai — fase di mana user menjawab 4 dimensi dan sistem melakukan AI scoring paralel terhadap semua kandidat profesi. Audit statis menemukan sejumlah deviasi signifikan pada fase ini, mulai dari kerentanan yang memungkinkan manipulasi data, crash saat Redis mati, hingga struktur JSONB yang tidak sesuai spesifikasi sehingga akan merusak integrasi dengan sistem Golang dan hasil rekomendasi akhir.

Selain itu, ada inkonsistensi arsitektur Redis (dua modul Redis berjalan terpisah) dan masalah rate limit yang tidak sesuai brief. Semua temuan ini bersifat **static code review** tanpa akses DB.

---

## 2. Daftar Temuan & Masalah

---

### Temuan 1 — KRITIS: INSERT Placeholder `IkigaiResponse` Tidak Dilakukan di `/start`

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief §3.2 dan halaman 1475 mewajibkan: saat `/ikigai/start` dipanggil dan status diubah dari `riasec_completed` → `ikigai_ongoing`, harus ada INSERT baris kosong (placeholder) ke tabel `ikigai_responses` dalam transaksi yang sama.

Di project, `start_ikigai_session` hanya melakukan UPDATE status dan langsung commit — tidak ada INSERT `IkigaiResponse` sama sekali.

```python
# Kondisi sekarang — TIDAK ADA INSERT IkigaiResponse
if session.status == "riasec_completed":
    session.status = "ikigai_ongoing"
    self.db.commit()   # ← langsung commit, tanpa INSERT placeholder
```

Baris kosong baru dibuat di `submit_dimension` dengan pola `create if not exist`:
```python
ikigai_resp = self.db.query(IkigaiResponse).filter(...).first()
if not ikigai_resp:
    ikigai_resp = IkigaiResponse(test_session_id=session.id)
    self.db.add(ikigai_resp)
    self.db.commit()
```

**Dampak:**  
Jika user memulai Ikigai tapi keluar sebelum submit dimensi apapun, tabel `ikigai_responses` kosong untuk sesi itu. Ini menyalahi kontrak data yang dijanjikan brief: setiap sesi `ikigai_ongoing` harus punya baris di `ikigai_responses`.

**Solusi:**  
Tambahkan INSERT `IkigaiResponse` di dalam blok `if session.status == "riasec_completed":`, sebelum commit, dalam transaksi yang sama dengan UPDATE status.

---

### Temuan 2 — KRITIS: Tidak Ada Validasi `uses_ikigai` dan `test_goal` di `/start` dan `/content`

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief halaman 1667–1680 mewajibkan dua validasi di awal `start_ikigai_session` dan `get_ikigai_content`:

```python
if not session.uses_ikigai:
    raise HTTPException(400, "Sesi ini adalah FIT_CHECK — tidak memiliki alur Ikigai")
if session.test_goal != "RECOMMENDATION":
    raise HTTPException(400, "Hanya sesi RECOMMENDATION yang bisa masuk ke fase Ikigai")
```

Field `uses_ikigai` dan `test_goal` sudah ada di model `CareerProfileTestSession`, tapi kedua method tersebut hanya cek `session.status` — tidak pernah cek `uses_ikigai` maupun `test_goal`.

**Dampak:**  
Sesi `FIT_CHECK` yang status-nya sudah `riasec_completed` bisa dipaksa masuk ke endpoint `/ikigai/start` dan `/ikigai/content` tanpa ditolak. Ini merusak integritas alur: sesi `FIT_CHECK` tidak seharusnya pernah punya data Ikigai.

---

### Temuan 3 — KRITIS: Redis Down Akan Crash Aplikasi

**File:** `app/shared/cache.py`

**Masalah:**  
`cache.py` membuat sync Redis client langsung saat module diimport:
```python
redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
```

Tidak ada `try-except` di manapun. Di `ikigai_service.py`, semua operasi Redis dipanggil langsung:
```python
cached_data = redis_client.get(cache_key)       # ← akan raise ConnectionError jika Redis mati
redis_client.setex(cache_key, 7200, ...)        # ← sama
```

Brief halaman 758–793 mewajibkan pola **graceful degradation**: jika Redis down, skip cache dan lanjutkan proses normal. Redis adalah optimasi, bukan dependency wajib.

**Dampak:**  
Saat Redis mati (restart, network issue, dll), seluruh endpoint Ikigai mengembalikan HTTP 500 meski logika utama (DB + AI) tidak ada masalah.

**Catatan arsitektur:**  
Ada inkonsistensi dua modul Redis yang berjalan sepenuhnya terpisah:
- `app/core/redis.py` — sudah ada penanganan `None` saat inisialisasi gagal
- `app/shared/cache.py` — tidak ada proteksi apapun, inilah yang dipakai `ikigai_service.py`

Perbaikan dilakukan di `cache.py` dengan membungkus semua operasi Redis dalam try-except.

---

### Temuan 4 — KRITIS: Validasi Dimensi Sudah Dijawab Tidak Ada (No Overwrite Protection)

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief §1.2 poin 3 mewajibkan: jika kolom dimensi sudah terisi (tidak NULL), tolak dengan HTTP 400. User tidak boleh overwrite jawaban yang sudah ada.

Di project, `submit_dimension` langsung overwrite tanpa pengecekan apapun:
```python
if dimension_name == "what_you_love":
    ikigai_resp.dimension_1_love = dim_data   # ← langsung overwrite
```

Tidak ada satu baris pun yang mengecek `if ikigai_resp.dimension_1_love is not None`.

**Dampak:**  
User bisa submit dimensi yang sama berkali-kali untuk memanipulasi hasil scoring. Jawaban yang sudah disimpan bisa ditimpa tanpa jejak.

---

### Temuan 5 — KRITIS: Validasi `selected_profession_id` Terhadap Kandidat Sesi Tidak Ada di Titik Submit

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief §1.2 poin 5 mewajibkan: jika `selected_profession_id` diisi, pastikan ID tersebut ada di `ikigai_candidate_professions.candidates_data` untuk sesi ini sebelum menyimpan ke DB.

Di project, tidak ada validasi di titik `submit_dimension`. Validasi `selected_ids` baru dilakukan di `_finalize_ikigai` setelah semua 4 dimensi tersimpan, dan itu pun hanya **silent ignore** (set `None`), bukan penolakan:

```python
# Di _finalize_ikigai — ini BUKAN validasi di titik submit
if sel_id and sel_id not in valid_profession_ids:
    selected_ids[dim] = None   # ← silent ignore, tidak raise error
```

Brief menginginkan penolakan saat submit, bukan diam-diam diabaikan setelah tersimpan.

**Dampak:**  
User bisa submit `selected_profession_id` sembarang (ID yang bukan bagian dari kandidat sesi ini), data tersimpan ke DB, baru diabaikan saat scoring. Data di `ikigai_responses` menjadi tidak bisa dipercaya.

---

### Temuan 6 — KRITIS: Field `rank` Tidak Ada dalam JSONB `profession_scores`

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief §6.3 mendefinisikan setiap entri di `ikigai_total_scores.scores_data.profession_scores` harus punya field `rank`:
```json
{"rank": 1, "profession_id": 10, "total_score": 78.50, ...}
```

Di project, list `total_scores` di-sort lalu langsung disimpan ke JSONB tanpa assign `rank` sama sekali. Field `rank` baru di-assign di `get_ikigai_result` via `enumerate` — tapi itu hanya untuk response object, tidak tersimpan di JSONB.

```python
# Kondisi sekarang — rank tidak pernah ditambahkan ke dict sebelum disimpan
total_scores_jsonb = {
    "profession_scores": total_scores,   # ← tidak ada field "rank" di setiap item
    ...
}
```

**Dampak:**  
Sistem lain (Golang CRUD, analytics, dashboard) yang membaca langsung dari kolom `scores_data` di DB tidak akan menemukan field `rank`. Data JSONB tidak lengkap sesuai kontrak.

---

### Temuan 7 — MEDIUM: Nilai `tie_breaking_applied` Selalu `False` Meski Ada Tie

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Deteksi tie dilakukan **setelah** sort:
```python
# Kondisi sekarang — deteksi SETELAH sort
total_scores.sort(key=lambda x: (...), reverse=True)
tie_breaking_applied = (
    total_scores[0]["total_score"] == total_scores[1]["total_score"]
)
```

Setelah sort dengan key bertingkat, nilai `total_score` profesi #1 dan #2 hanya akan sama jika mereka identik di **semua** 4 kriteria sort sekaligus — kasus yang sangat jarang. Tie yang diselesaikan oleh `intrinsic_score`, `congruence_score`, atau `avg_r_normalized` tidak akan terdeteksi.

Logika yang benar: deteksi tie berdasarkan `total_score` saja **sebelum** sort, karena itulah definisi "ada tie yang perlu diselesaikan".

**Dampak:**  
`tie_breaking_applied` yang tersimpan di JSONB DB dan dikembalikan ke Flutter hampir selalu `False`, meskipun sebenarnya tie terjadi dan diselesaikan oleh kriteria lanjutan.

---

### Temuan 8 — MEDIUM: Metadata JSONB `ikigai_total_scores` Tidak Lengkap

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief §6.3 mendefinisikan struktur `metadata` di `ikigai_total_scores.scores_data`:
```json
"metadata": {
  "total_professions_ranked": 5,
  "tie_breaking_applied": false,
  "tie_breaking_details": null,        ← TIDAK ADA
  "top_2_professions": [10, 25],       ← TIDAK ADA
  "calculated_at": "2024-12-15T..."    ← TIDAK ADA
}
```

Project hanya punya `total_professions_ranked`, `tie_breaking_applied`, dan `scoring_formula` (field ini tidak ada di brief). Tiga field penting hilang:
- `tie_breaking_details` — penting untuk audit kenapa profesi tertentu menang
- `top_2_professions` — shortcut ID tanpa parse seluruh array
- `calculated_at` — timestamp kalkulasi

---

### Temuan 9 — MEDIUM: Metadata JSONB `ikigai_dimension_scores` Tidak Lengkap

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Brief §5.2 mendefinisikan struktur `metadata` di `ikigai_dimension_scores.scores_data`:
```json
"metadata": {
  "total_candidates_scored": 5,
  "scoring_strategy": "batch_semantic_matching",
  "fallback_used": false,
  "failed_dimensions": [],
  "calculated_at": "2024-12-15T..."
}
```

Project punya field dengan nama berbeda (`total_professions` bukan `total_candidates_scored`, `scoring_method` bukan `scoring_strategy`) dan tidak punya `fallback_used`, `failed_dimensions`, `calculated_at` sama sekali.

`fallback_used` dan `failed_dimensions` sangat penting untuk monitoring: tanpa ini tidak ada cara mendeteksi apakah Gemini gagal di satu dimensi dan skor-nya adalah nilai fallback `0.5`.

---

### Temuan 10 — MEDIUM: Migration Alembic Tidak Ada untuk Tiga Tabel Ikigai

**File:** `alembic/versions/`

**Masalah:**  
Setelah mengecek semua 4 file migration yang ada (`5260bdb10656`, `97caa26d93fb`, `a1b2c3d4e5f6`, `c6f96ad1d8f8`), tidak ada satu pun yang membuat tabel:
- `ikigai_responses`
- `ikigai_dimension_scores`
- `ikigai_total_scores`

Model Python untuk ketiga tabel sudah ada di `models/ikigai.py`, tapi jika `alembic upgrade head` dijalankan di environment baru atau DB di-recreate, ketiga tabel ini tidak akan terbuat. Aplikasi akan crash saat pertama kali mencoba INSERT.

---

### Temuan 11 — MEDIUM: Rate Limit Tidak Sesuai Brief

**File:** `app/api/v1/categories/career_profile/routers/ikigai.py`

**Masalah:**  
| Endpoint | Brief | Project |
|---|---|---|
| `POST /ikigai/start` | `10/hour` | `5/minute` |
| `GET /ikigai/content/{token}` | `30/minute` | `10/minute` |

Khusus `/start`: brief menetapkan `10/hour` (lebih ketat untuk mencegah abuse generate konten AI), tapi project pakai `5/minute` yang secara intent berbeda.

---

### Temuan 12 — MINOR: `from_cache` Tidak Ada di `IkigaiContentResponse`

**File:** `app/api/v1/categories/career_profile/schemas/ikigai.py`

**Masalah:**  
Brief halaman 1391–1393 mendefinisikan field `from_cache: bool` di response `GetIkigaiContentResponse`. Project punya `regenerated: bool` (semantik terbalik) tapi tidak ada `from_cache`.

Flutter tidak bisa membedakan apakah data dari Redis cache atau hasil generate baru.

---

### Temuan 13 — MINOR: Dead Import `calculate_min_max_normalization`

**File:** `app/api/v1/categories/career_profile/services/ikigai_service.py`

**Masalah:**  
Baris 28 mengimport fungsi DEPRECATED dari `scoring_utils.py`:
```python
from app.shared.scoring_utils import (
    calculate_min_max_normalization,   # ← DEPRECATED, tidak dipakai di mana pun
    calculate_text_score,
    calculate_click_score,
)
```

Normalisasi min-max dilakukan inline di `_finalize_ikigai`, bukan menggunakan fungsi ini. Import ini menyambung ke temuan RIASEC (blok DEPRECATED di `scoring_utils.py`) — setelah blok DEPRECATED dihapus, import ini akan menyebabkan `ImportError`.

---

## 3. File yang Harus Diubah

| File | Aksi | Temuan |
|---|---|---|
| `app/api/v1/categories/career_profile/services/ikigai_service.py` | **Modifikasi** | Temuan 1, 2, 4, 5, 6, 7, 8, 9, 13 |
| `app/shared/cache.py` | **Modifikasi** | Temuan 3 |
| `app/api/v1/categories/career_profile/routers/ikigai.py` | **Modifikasi** | Temuan 11 |
| `app/api/v1/categories/career_profile/schemas/ikigai.py` | **Modifikasi** | Temuan 12 |
| `alembic/versions/xxxx_create_ikigai_tables.py` | **Buat baru** | Temuan 10 |

> Migration Alembic untuk ketiga tabel Ikigai masih perlu dibuat terpisah.

---

## 4. Source Code Lengkap Per File

---

### File 1: `app/api/v1/categories/career_profile/services/ikigai_service.py`

```python
# app/api/v1/categories/career_profile/services/ikigai_service.py

import asyncio
import json
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional
import time

from sqlalchemy.orm import Session, joinedload
from fastapi import HTTPException, status
import structlog

from app.api.v1.categories.career_profile.repositories.session_repo import SessionRepository
from app.api.v1.categories.career_profile.repositories.profession_repo import ProfessionRepository
from app.api.v1.categories.career_profile.services.profession_expansion import ProfessionExpansionService
from app.api.v1.categories.career_profile.models.ikigai import (
    IkigaiResponse,
    IkigaiDimensionScores,
    IkigaiTotalScores,
)
from app.api.v1.categories.career_profile.schemas.ikigai import (
    IkigaiContentResponse,
    DimensionContent,
    CandidateWithContent,
    DimensionSubmitResponse,
    IkigaiCompletionResponse,
    ProfessionScoreBreakdown,
)
from app.db.models.user import User
from app.shared.ai_client import gemini_client
from app.shared.cache import redis_client, cache_get_raw, cache_set_raw
from app.shared.scoring_utils import (
    calculate_text_score,    # calculate_min_max_normalization DIHAPUS (DEPRECATED)
    calculate_click_score,
)
from app.api.v1.categories.career_profile.services.recommendation_narrative_service import (
    RecommendationNarrativeService,
)
from app.api.v1.categories.career_profile.models.result import CareerRecommendation
from app.api.v1.categories.career_profile.models.riasec import RIASECResult

# === PENTING: DigitalProfession DIHAPUS ===
# Semua query profesi harus menggunakan model Profession dari tabel relasional
# (professions, profession_activities, profession_skill_rels, profession_career_paths)
# sesuai brief Jelajah Profesi. Lihat ProfessionRepository untuk detail query.
from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession

logger = structlog.get_logger()

IKIGAI_DIMENSIONS = [
    "what_you_love",
    "what_you_are_good_at",
    "what_the_world_needs",
    "what_you_can_be_paid_for",
]


class IkigaiService:
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = SessionRepository(db)
        self.profession_repo = ProfessionRepository(db)
        self.expansion_service = ProfessionExpansionService(db)

    # --------------------------------------------------------------------------
    # PHASE 1: GENERATE CONTENT
    # --------------------------------------------------------------------------

    async def start_ikigai_session(
        self, user: User, session_token: str
    ) -> IkigaiContentResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")

        # === PERBAIKAN TEMUAN 2: Validasi uses_ikigai dan test_goal ===
        if not session.uses_ikigai:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Sesi ini adalah FIT_CHECK — tidak memiliki alur Ikigai",
            )
        if session.test_goal != "RECOMMENDATION":
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Hanya sesi RECOMMENDATION yang bisa masuk ke fase Ikigai",
            )

        if session.status not in ["riasec_completed", "ikigai_ongoing"]:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Status sesi tidak valid untuk memulai Ikigai: {session.status}",
            )

        if session.status == "riasec_completed":
            session.status = "ikigai_ongoing"

            # === PERBAIKAN TEMUAN 1: INSERT placeholder IkigaiResponse dalam transaksi yang sama ===
            # Menjamin setiap sesi ikigai_ongoing selalu punya baris di ikigai_responses.
            # Kolom dimensi dibiarkan NULL — diisi bertahap via submit_dimension.
            placeholder = IkigaiResponse(test_session_id=session.id)
            self.db.add(placeholder)
            self.db.commit()

        # Cek Redis cache
        cache_key = f"ikigai:content:{session_token}"
        cached_raw = cache_get_raw(cache_key)   # graceful — None jika Redis down atau miss
        if cached_raw:
            try:
                content = json.loads(cached_raw)
                return IkigaiContentResponse(
                    session_token=session_token,
                    status="ikigai_ongoing",
                    generated_at=content["generated_at"],
                    from_cache=True,
                    regenerated=False,
                    total_display_candidates=len(content["candidates"]),
                    message="Konten Ikigai diambil dari cache.",
                    candidates_with_content=content["candidates"],
                )
            except (json.JSONDecodeError, KeyError):
                pass  # Cache corrupt — lanjut generate ulang

        # Generate konten baru
        candidates = await self._generate_ikigai_content(session.id)
        now_str = datetime.now(timezone.utc).isoformat()
        cache_payload = {"generated_at": now_str, "candidates": candidates}
        cache_set_raw(cache_key, json.dumps(cache_payload), ttl=7200)  # graceful

        return IkigaiContentResponse(
            session_token=session_token,
            status="ikigai_ongoing",
            generated_at=now_str,
            from_cache=False,
            regenerated=True,
            total_display_candidates=len(candidates),
            message="Sesi dimulai dan konten Ikigai berhasil di-generate.",
            candidates_with_content=candidates,
        )

    async def get_ikigai_content(
        self, user: User, session_token: str
    ) -> IkigaiContentResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")

        # === PERBAIKAN TEMUAN 2: Validasi uses_ikigai dan test_goal ===
        if not session.uses_ikigai:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Sesi ini adalah FIT_CHECK — tidak memiliki alur Ikigai",
            )
        if session.test_goal != "RECOMMENDATION":
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Hanya sesi RECOMMENDATION yang bisa mengakses konten Ikigai",
            )

        if session.status != "ikigai_ongoing":
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Sesi Ikigai tidak dalam status ongoing",
            )

        cache_key = f"ikigai:content:{session_token}"
        cached_raw = cache_get_raw(cache_key)
        if cached_raw:
            try:
                content = json.loads(cached_raw)
                return IkigaiContentResponse(
                    session_token=session_token,
                    status="ikigai_ongoing",
                    generated_at=content["generated_at"],
                    from_cache=True,
                    regenerated=False,
                    total_display_candidates=len(content["candidates"]),
                    message="Berhasil mengambil konten Ikigai dari cache.",
                    candidates_with_content=content["candidates"],
                )
            except (json.JSONDecodeError, KeyError):
                pass

        # Cache miss atau corrupt — regenerate
        candidates = await self._generate_ikigai_content(session.id)
        now_str = datetime.now(timezone.utc).isoformat()
        cache_payload = {"generated_at": now_str, "candidates": candidates}
        cache_set_raw(cache_key, json.dumps(cache_payload), ttl=7200)

        return IkigaiContentResponse(
            session_token=session_token,
            status="ikigai_ongoing",
            generated_at=now_str,
            from_cache=False,
            regenerated=True,
            total_display_candidates=len(candidates),
            message="Konten lama expired, regenerasi berhasil.",
            candidates_with_content=candidates,
        )

    async def _generate_ikigai_content(self, session_id: int) -> List[Dict]:
        """
        Generate narasi konten Ikigai untuk kandidat display (display_order 1–5).
        Menggunakan ProfessionRepository untuk query relasional ke tabel professions.
        """
        candidates_data = self.expansion_service.get_candidates_with_details(session_id)
        top_candidates = [
            c for c in candidates_data["candidates"] if c.get("display_order", 99) <= 5
        ]

        top_profession_ids = [c["profession_id"] for c in top_candidates]

        # Query via ProfessionRepository — tabel relasional (bukan DigitalProfession)
        profession_contexts = self.profession_repo.get_profession_contexts_for_ikigai(
            top_profession_ids
        )
        prof_context_map = {pc["profession_id"]: pc for pc in profession_contexts}

        ai_responses = await gemini_client.generate_ikigai_content(profession_contexts)
        ai_map = {
            item["profession_id"]: item
            for item in ai_responses
            if "profession_id" in item
        }

        result_candidates = []
        for c in top_candidates:
            pid = c["profession_id"]
            pc = prof_context_map.get(pid, {})
            ai_data = ai_map.get(pid, {})

            result_candidates.append({
                "profession_id": pid,
                "profession_name": pc.get("name", c.get("profession_name", "Unknown")),
                "display_order": c.get("display_order", 0),
                "congruence_score": c.get("congruence_score", 0.5),
                "dimension_content": {
                    "what_you_love": ai_data.get("what_you_love", "Deskripsi tidak tersedia."),
                    "what_you_are_good_at": ai_data.get("what_you_are_good_at", "Deskripsi tidak tersedia."),
                    "what_the_world_needs": ai_data.get("what_the_world_needs", "Deskripsi tidak tersedia."),
                    "what_you_can_be_paid_for": ai_data.get("what_you_can_be_paid_for", "Deskripsi tidak tersedia."),
                },
            })

        return result_candidates

    # --------------------------------------------------------------------------
    # PHASE 2: SUBMIT DIMENSI
    # --------------------------------------------------------------------------

    async def submit_dimension(
        self,
        user: User,
        session_token: str,
        dimension_name: str,
        selected_profession_id: Optional[int],
        selection_type: str,
        reasoning_text: str,
    ):
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")

        if session.status != "ikigai_ongoing":
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Sesi tidak bisa di-submit (bukan ikigai_ongoing)",
            )

        ikigai_resp = (
            self.db.query(IkigaiResponse)
            .filter(IkigaiResponse.test_session_id == session.id)
            .first()
        )
        if not ikigai_resp:
            # Seharusnya sudah ada sejak /start — tapi defensif jika tidak ada
            ikigai_resp = IkigaiResponse(test_session_id=session.id)
            self.db.add(ikigai_resp)
            self.db.flush()

        # === PERBAIKAN TEMUAN 4: Cek apakah dimensi sudah dijawab sebelumnya ===
        dim_field_map = {
            "what_you_love":          "dimension_1_love",
            "what_you_are_good_at":   "dimension_2_good_at",
            "what_the_world_needs":   "dimension_3_world_needs",
            "what_you_can_be_paid_for": "dimension_4_paid_for",
        }
        field_name = dim_field_map[dimension_name]
        existing_value = getattr(ikigai_resp, field_name)
        if existing_value is not None:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Dimensi '{dimension_name}' sudah dijawab sebelumnya dan tidak bisa diubah.",
            )

        # === PERBAIKAN TEMUAN 5: Validasi selected_profession_id terhadap kandidat sesi ===
        if selected_profession_id is not None:
            candidate_record = (
                self.db.query(IkigaiCandidateProfession)
                .filter(IkigaiCandidateProfession.test_session_id == session.id)
                .first()
            )
            valid_ids = set()
            if candidate_record and candidate_record.candidates_data:
                valid_ids = {
                    c["profession_id"]
                    for c in candidate_record.candidates_data.get("candidates", [])
                }
            if selected_profession_id not in valid_ids:
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    f"selected_profession_id {selected_profession_id} "
                    f"bukan bagian dari kandidat profesi untuk sesi ini.",
                )

        dim_data = {
            "selected_profession_id": selected_profession_id,
            "selection_type": selection_type,
            "reasoning_text": reasoning_text,
            "answered_at": datetime.now(timezone.utc).isoformat(),
        }

        setattr(ikigai_resp, field_name, dim_data)
        self.db.commit()

        # Cek kelengkapan dimensi
        completed_dims = []
        if ikigai_resp.dimension_1_love:        completed_dims.append("what_you_love")
        if ikigai_resp.dimension_2_good_at:     completed_dims.append("what_you_are_good_at")
        if ikigai_resp.dimension_3_world_needs: completed_dims.append("what_the_world_needs")
        if ikigai_resp.dimension_4_paid_for:    completed_dims.append("what_you_can_be_paid_for")

        remaining = [d for d in IKIGAI_DIMENSIONS if d not in completed_dims]
        all_completed = len(remaining) == 0

        if not all_completed:
            return DimensionSubmitResponse(
                session_token=session_token,
                dimension_saved=dimension_name,
                dimensions_completed=completed_dims,
                dimensions_remaining=remaining,
                all_completed=False,
                message=f"Dimensi '{dimension_name}' berhasil disimpan.",
            )

        # Semua 4 dimensi selesai → trigger scoring pipeline
        try:
            result = await self._finalize_ikigai(session, ikigai_resp)
            return result
        except HTTPException:
            raise
        except Exception as e:
            logger.error("ikigai_finalize_failed", error=str(e), session_id=session.id)
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                f"Gagal menghitung skor final: {str(e)}",
            )

    # --------------------------------------------------------------------------
    # PHASE 2 INTERNAL: SCORING PIPELINE
    # --------------------------------------------------------------------------

    async def _finalize_ikigai(self, session, ikigai_resp: IkigaiResponse):
        """
        Pipeline scoring Ikigai sesuai Brief Part 2.

        STEP 1 : Ambil semua kandidat dari DB
        STEP 2 : Kumpulkan jawaban user
        STEP 3 : 4 Gemini call paralel (1 per dimensi)
        STEP 4 : Normalisasi min-max + hitung text_score & click_score
        STEP 5 : Deteksi tie SEBELUM sort → simpan di tie_info
        STEP 6 : Sort multi-level + assign rank ke setiap entri
        STEP 7 : INSERT ikigai_dimension_scores (metadata lengkap)
        STEP 8 : INSERT ikigai_total_scores (rank di JSONB + metadata lengkap)
        STEP 9 : Update status sesi + kenalidiri_history
        STEP 10: Generate narasi rekomendasi (best-effort, non-fatal)
        """
        start_time = time.time()

        # ------------------------------------------------------------------
        # STEP 1: Ambil semua kandidat dari DB
        # ------------------------------------------------------------------
        candidate_record = self.profession_repo.get_candidates_by_session_id(session.id)
        if not candidate_record or not candidate_record.candidates_data:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                "Data kandidat profesi tidak ditemukan untuk sesi ini.",
            )
        all_candidate_entries = candidate_record.candidates_data.get("candidates", [])
        all_profession_ids = [c["profession_id"] for c in all_candidate_entries]

        # Query profesi via tabel relasional (bukan DigitalProfession)
        profession_contexts = self.profession_repo.get_profession_contexts_for_scoring(
            all_profession_ids
        )
        prof_context_map = {pc["profession_id"]: pc for pc in profession_contexts}

        if not profession_contexts:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                "Tidak ada profesi valid yang bisa di-scoring.",
            )

        # ------------------------------------------------------------------
        # STEP 2: Kumpulkan jawaban user
        # ------------------------------------------------------------------
        answers = {
            "what_you_love":            ikigai_resp.dimension_1_love,
            "what_you_are_good_at":     ikigai_resp.dimension_2_good_at,
            "what_the_world_needs":     ikigai_resp.dimension_3_world_needs,
            "what_you_can_be_paid_for": ikigai_resp.dimension_4_paid_for,
        }

        valid_profession_id_set = {pc["profession_id"] for pc in profession_contexts}
        selected_ids: Dict[str, Optional[int]] = {}
        for dim, ans in answers.items():
            if not ans:
                selected_ids[dim] = None
                continue
            sel_id = ans.get("selected_profession_id")
            if sel_id and sel_id not in valid_profession_id_set:
                logger.warning(
                    "ikigai_invalid_selected_profession",
                    dimension=dim,
                    selected_profession_id=sel_id,
                    session_id=session.id,
                )
                selected_ids[dim] = None
            else:
                selected_ids[dim] = sel_id

        # ------------------------------------------------------------------
        # STEP 3: 4 Gemini call paralel (1 per dimensi, semua kandidat)
        # ------------------------------------------------------------------
        scoring_tasks = []
        dim_order = []
        for dim in IKIGAI_DIMENSIONS:
            ans = answers.get(dim)
            if not ans:
                continue
            reasoning_text = ans.get("reasoning_text", "").strip() or "(tidak ada teks jawaban)"
            scoring_tasks.append(
                gemini_client.score_all_professions_for_dimension(
                    dimension_name=dim,
                    user_reasoning_text=reasoning_text,
                    profession_contexts=profession_contexts,
                )
            )
            dim_order.append(dim)

        logger.info(
            "ikigai_scoring_start",
            session_id=session.id,
            dimensions=dim_order,
            total_professions=len(profession_contexts),
        )
        gemini_results = await asyncio.gather(*scoring_tasks, return_exceptions=True)

        # ------------------------------------------------------------------
        # STEP 4: Normalisasi min-max + text_score & click_score
        # ------------------------------------------------------------------
        # Catat dimensi yang gagal untuk metadata
        failed_dimensions: List[str] = []
        fallback_used = False

        dim_raw_scores: Dict[str, list] = {}
        for dim, result in zip(dim_order, gemini_results):
            if isinstance(result, Exception):
                logger.error(
                    "ikigai_scoring_dim_failed",
                    dimension=dim,
                    error=str(result),
                    session_id=session.id,
                )
                failed_dimensions.append(dim)
                fallback_used = True
                # Fallback: semua profesi r_raw = 0.5
                dim_raw_scores[dim] = [
                    {"profession_id": pc["profession_id"], "r_raw": 0.5}
                    for pc in profession_contexts
                ]
            else:
                dim_raw_scores[dim] = result

        # Normalisasi min-max per dimensi
        dim_scored: Dict[str, list] = {}
        normalization_params: Dict[str, dict] = {}

        for dim in dim_order:
            raw_list = dim_raw_scores[dim]
            r_values = [item["r_raw"] for item in raw_list]
            r_min = min(r_values) if r_values else 0.0
            r_max = max(r_values) if r_values else 1.0
            denom = r_max - r_min

            normalization_params[dim] = {
                "r_min": round(r_min, 4),
                "r_max": round(r_max, 4),
                "professions_evaluated": len(raw_list),
            }

            sel_id_for_dim = selected_ids.get(dim)
            scored_list = []
            for item in raw_list:
                r_raw = item["r_raw"]
                # denom = 0 berarti semua r_raw identik → r_norm = 0.5 (netral)
                r_norm = 0.5 if denom == 0 else (r_raw - r_min) / denom
                r_norm = max(0.0, min(1.0, round(r_norm, 4)))

                is_selected = (
                    sel_id_for_dim is not None
                    and item["profession_id"] == sel_id_for_dim
                )
                t_score = calculate_text_score(r_norm)           # 0.0–15.0
                c_score = calculate_click_score(r_raw, is_selected)  # 0.0–10.0

                scored_list.append({
                    "profession_id": item["profession_id"],
                    "r_raw": round(r_raw, 4),
                    "r_normalized": r_norm,
                    "text_score": t_score,
                    "click_score": c_score,
                    "dimension_total": round(t_score + c_score, 4),
                })
            dim_scored[dim] = scored_list

        # ------------------------------------------------------------------
        # STEP 5: Agregasi total_score per profesi
        # ------------------------------------------------------------------
        congruence_map = {
            c["profession_id"]: c.get("congruence_score", 0.5)
            for c in all_candidate_entries
        }
        dim_score_by_pid: Dict[str, Dict[int, dict]] = {
            dim: {item["profession_id"]: item for item in scored_list}
            for dim, scored_list in dim_scored.items()
        }

        total_scores = []
        for pid in all_profession_ids:
            score_per_dim: Dict[str, float] = {}
            sum_r_normalized = 0.0
            scored_dim_count = 0

            for dim in IKIGAI_DIMENSIONS:
                if dim in dim_score_by_pid and pid in dim_score_by_pid[dim]:
                    entry = dim_score_by_pid[dim][pid]
                    score_per_dim[dim] = entry["dimension_total"]
                    sum_r_normalized += entry["r_normalized"]
                    scored_dim_count += 1
                else:
                    score_per_dim[dim] = 0.0

            total_dim_score = sum(score_per_dim.values())
            intrinsic = score_per_dim.get("what_you_love", 0.0) + score_per_dim.get("what_you_are_good_at", 0.0)
            extrinsic = score_per_dim.get("what_the_world_needs", 0.0) + score_per_dim.get("what_you_can_be_paid_for", 0.0)
            avg_r_norm = sum_r_normalized / scored_dim_count if scored_dim_count > 0 else 0.0
            congruence = congruence_map.get(pid, 0.0)
            pc = prof_context_map.get(pid, {})

            total_scores.append({
                "profession_id": pid,
                "profession_name": pc.get("name", "Unknown"),
                "total_score": round(total_dim_score, 4),
                "intrinsic_score": round(intrinsic, 4),
                "extrinsic_score": round(extrinsic, 4),
                "congruence_score": round(congruence, 4),
                "avg_r_normalized": round(avg_r_norm, 4),
                "score_what_you_love": round(score_per_dim.get("what_you_love", 0.0), 4),
                "score_what_you_are_good_at": round(score_per_dim.get("what_you_are_good_at", 0.0), 4),
                "score_what_the_world_needs": round(score_per_dim.get("what_the_world_needs", 0.0), 4),
                "score_what_you_can_be_paid_for": round(score_per_dim.get("what_you_can_be_paid_for", 0.0), 4),
            })

        # ------------------------------------------------------------------
        # STEP 6 — PERBAIKAN TEMUAN 7: Deteksi tie SEBELUM sort
        # ------------------------------------------------------------------
        # Tie didefinisikan: ada 2 atau lebih profesi dengan total_score yang sama.
        # Deteksi dilakukan sebelum sort agar `tie_breaking_applied` akurat.
        top_score = max((p["total_score"] for p in total_scores), default=0.0)
        tied_professions = [p for p in total_scores if p["total_score"] == top_score]
        tie_breaking_applied = len(tied_professions) > 1

        tie_breaking_details = None
        if tie_breaking_applied:
            tie_breaking_details = {
                "tied_profession_ids": [p["profession_id"] for p in tied_professions],
                "tied_total_score": top_score,
                "tiebreak_criteria_used": ["intrinsic_score", "congruence_score", "avg_r_normalized"],
            }

        # Multi-level tie-breaking: total_score → intrinsic → congruence → avg_r_normalized
        total_scores.sort(
            key=lambda x: (
                x["total_score"],
                x["intrinsic_score"],
                x["congruence_score"],
                x["avg_r_normalized"],
            ),
            reverse=True,
        )

        # === PERBAIKAN TEMUAN 6: Assign rank ke setiap entri SETELAH sort ===
        for rank_idx, p in enumerate(total_scores, start=1):
            p["rank"] = rank_idx

        top_1_id = total_scores[0]["profession_id"] if total_scores else None
        top_2_id = total_scores[1]["profession_id"] if len(total_scores) > 1 else None
        calculated_at = datetime.now(timezone.utc).isoformat()

        # ------------------------------------------------------------------
        # STEP 7 — PERBAIKAN TEMUAN 9: INSERT ikigai_dimension_scores (metadata lengkap)
        # ------------------------------------------------------------------
        dimension_scores_jsonb = {
            "dimension_scores": dim_scored,
            "normalization_params": normalization_params,
            "metadata": {
                "total_candidates_scored": len(profession_contexts),   # nama sesuai brief
                "scoring_strategy": "batch_semantic_matching",         # nilai sesuai brief
                "fallback_used": fallback_used,                        # baru
                "failed_dimensions": failed_dimensions,                # baru
                "calculated_at": calculated_at,                        # baru
            },
        }

        dim_score_db = IkigaiDimensionScores(
            test_session_id=session.id,
            scores_data=dimension_scores_jsonb,
            ai_model_used="gemini-1.5-flash",
            total_api_calls=len(dim_order),
        )
        self.db.add(dim_score_db)

        # ------------------------------------------------------------------
        # STEP 8 — PERBAIKAN TEMUAN 6, 8: INSERT ikigai_total_scores (rank + metadata lengkap)
        # ------------------------------------------------------------------
        total_scores_jsonb = {
            "profession_scores": total_scores,   # setiap item sudah punya field "rank"
            "metadata": {
                "total_professions_ranked": len(total_scores),
                "tie_breaking_applied": tie_breaking_applied,
                "tie_breaking_details": tie_breaking_details,          # baru
                "top_2_professions": [top_1_id, top_2_id],            # baru
                "calculated_at": calculated_at,                        # baru
            },
        }

        tot_score_db = IkigaiTotalScores(
            test_session_id=session.id,
            scores_data=total_scores_jsonb,
            top_profession_1_id=top_1_id,
            top_profession_2_id=top_2_id,
        )
        self.db.add(tot_score_db)

        # ------------------------------------------------------------------
        # STEP 9: Update status sesi & kenalidiri_history
        # ------------------------------------------------------------------
        ikigai_resp.completed = True
        ikigai_resp.completed_at = datetime.now(timezone.utc)

        session.status = "completed"
        session.ikigai_completed_at = datetime.now(timezone.utc)
        session.completed_at = datetime.now(timezone.utc)

        from app.db.models.kenalidiri_history import KenaliDiriHistory
        history = (
            self.db.query(KenaliDiriHistory)
            .filter(KenaliDiriHistory.detail_session_id == session.id)
            .first()
        )
        if history:
            history.status = "completed"
            history.completed_at = datetime.now(timezone.utc)

        self.db.commit()

        elapsed = round(time.time() - start_time, 2)
        logger.info(
            "ikigai_finalize_success",
            session_id=session.id,
            total_professions=len(total_scores),
            top_1_id=top_1_id,
            top_2_id=top_2_id,
            tie_breaking_applied=tie_breaking_applied,
            elapsed_seconds=elapsed,
        )

        # ------------------------------------------------------------------
        # STEP 10: Generate narasi rekomendasi (best-effort, non-fatal)
        # ------------------------------------------------------------------
        try:
            top_2_scores = total_scores[:2]
            top_2_ids = [p["profession_id"] for p in top_2_scores]

            profession_details = self.profession_repo.get_profession_contexts_for_recommendation(
                top_2_ids
            )

            ikigai_responses_text = {
                dim: (answers.get(dim) or {}).get("reasoning_text", "")
                for dim in IKIGAI_DIMENSIONS
            }

            riasec_res = (
                self.db.query(RIASECResult)
                .filter(RIASECResult.test_session_id == session.id)
                .first()
            )
            user_riasec_code = riasec_res.riasec_code if riasec_res else "Unknown"

            narrative_service = RecommendationNarrativeService()
            narrative_data = await narrative_service.generate_recommendations_narrative(
                ikigai_responses=ikigai_responses_text,
                top_2_professions=top_2_scores,
                profession_details=profession_details,
                user_riasec_code=user_riasec_code,
            )

            recommended_professions = []
            for rank_idx, p in enumerate(top_2_scores, start=1):
                pid = p["profession_id"]
                pc = prof_context_map.get(pid, {})
                reasoning = narrative_data.get("match_reasoning", {}).get(str(pid), "")
                recommended_professions.append({
                    "rank": rank_idx,
                    "profession_id": pid,
                    "profession_name": p.get("profession_name", ""),
                    "match_percentage": round(p["total_score"], 2),
                    "match_reasoning": reasoning,
                    "riasec_alignment": {
                        "user_code": user_riasec_code,
                        "profession_code": pc.get("riasec_code", "-"),
                        "congruence_score": p.get("congruence_score", 0),
                    },
                    "score_breakdown": {
                        "total_score": round(p["total_score"], 2),
                        "intrinsic_score": round(p["intrinsic_score"], 2),
                        "extrinsic_score": round(p["extrinsic_score"], 2),
                        "score_what_you_love": round(p["score_what_you_love"], 2),
                        "score_what_you_are_good_at": round(p["score_what_you_are_good_at"], 2),
                        "score_what_the_world_needs": round(p["score_what_the_world_needs"], 2),
                        "score_what_you_can_be_paid_for": round(p["score_what_you_can_be_paid_for"], 2),
                    },
                })

            recommendations_data = {
                "ikigai_profile_summary": narrative_data.get("ikigai_profile_summary", {}),
                "recommended_professions": recommended_professions,
                "generation_context": {
                    "user_riasec_code": user_riasec_code,
                    "total_candidates_evaluated": len(total_scores),
                    "top_2_selection_method": "total_score_ranking",
                    "generation_timestamp": calculated_at,
                },
                "points_awarded": None,
            }

            career_rec = CareerRecommendation(
                test_session_id=session.id,
                recommendations_data=recommendations_data,
            )
            self.db.add(career_rec)
            self.db.commit()
            logger.info("recommendation_narrative_saved", session_id=session.id)

        except Exception as e:
            logger.error(
                "recommendation_narrative_failed",
                error=str(e),
                session_id=session.id,
            )
            # Non-fatal: scoring sudah tersimpan, narasi adalah best-effort

        # ------------------------------------------------------------------
        # FORMAT RESPONSE
        # ------------------------------------------------------------------
        breakdown = [
            ProfessionScoreBreakdown(
                rank=p["rank"],
                profession_id=p["profession_id"],
                total_score=round(p["total_score"], 4),
                score_what_you_love=round(p["score_what_you_love"], 4),
                score_what_you_are_good_at=round(p["score_what_you_are_good_at"], 4),
                score_what_the_world_needs=round(p["score_what_the_world_needs"], 4),
                score_what_you_can_be_paid_for=round(p["score_what_you_can_be_paid_for"], 4),
                intrinsic_score=round(p["intrinsic_score"], 4),
                extrinsic_score=round(p["extrinsic_score"], 4),
            )
            for p in total_scores
        ]

        return IkigaiCompletionResponse(
            session_token=session.session_token,
            status="completed",
            top_2_professions=breakdown[:2],
            total_professions_evaluated=len(total_scores),
            tie_breaking_applied=tie_breaking_applied,
            calculated_at=calculated_at,
            message="Ikigai berhasil di-submit dan diskor.",
        )

    # --------------------------------------------------------------------------
    # GET RESULT
    # --------------------------------------------------------------------------

    async def get_ikigai_result(
        self, user: User, session_token: str
    ) -> IkigaiCompletionResponse:
        session = self.session_repo.get_by_token(self.db, session_token)
        if not session or session.user_id != user.id:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Session not found")

        if session.status != "completed":
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Ikigai belum selesai."
            )

        total_scores_record = (
            self.db.query(IkigaiTotalScores)
            .filter(IkigaiTotalScores.test_session_id == session.id)
            .first()
        )
        if not total_scores_record:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Result tidak ditemukan.")

        prof_list = total_scores_record.scores_data.get("profession_scores", [])
        metadata = total_scores_record.scores_data.get("metadata", {})

        breakdown = [
            ProfessionScoreBreakdown(
                rank=p.get("rank", idx + 1),   # rank sudah ada di JSONB
                profession_id=p["profession_id"],
                total_score=round(p.get("total_score", 0.0), 4),
                score_what_you_love=round(p.get("score_what_you_love", 0.0), 4),
                score_what_you_are_good_at=round(p.get("score_what_you_are_good_at", 0.0), 4),
                score_what_the_world_needs=round(p.get("score_what_the_world_needs", 0.0), 4),
                score_what_you_can_be_paid_for=round(p.get("score_what_you_can_be_paid_for", 0.0), 4),
                intrinsic_score=round(p.get("intrinsic_score", 0.0), 4),
                extrinsic_score=round(p.get("extrinsic_score", 0.0), 4),
            )
            for idx, p in enumerate(prof_list)
        ]

        return IkigaiCompletionResponse(
            session_token=session.session_token,
            status="completed",
            top_2_professions=breakdown[:2],
            total_professions_evaluated=len(prof_list),
            tie_breaking_applied=metadata.get("tie_breaking_applied", False),
            calculated_at=total_scores_record.calculated_at.isoformat(),
            message="Berhasil mengambil hasil Ikigai.",
        )
```

---

### File 2: `app/shared/cache.py`

```python
# app/shared/cache.py
"""
Redis cache helper untuk Kenali Diri.

Semua operasi Redis di sini bersifat GRACEFUL DEGRADED:
jika Redis tidak tersedia (mati, network issue, timeout),
operasi di-skip dan aplikasi tetap berjalan normal.

Redis adalah OPTIMASI (cache), bukan dependency wajib.

Brief RIASEC halaman 758-793: Redis failure harus graceful degradation.
"""

import json
import logging
import redis
from typing import Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

# ── Inisialisasi client ───────────────────────────────────────────────────────
# redis_client bisa bernilai None jika koneksi gagal saat startup.
# Semua fungsi di bawah sudah menangani kasus None ini.
try:
    redis_client = redis.from_url(
        settings.REDIS_URL,
        decode_responses=True,
        socket_connect_timeout=2,    # Gagal cepat jika Redis tidak bisa dicapai
        socket_timeout=2,
    )
    # Ping untuk validasi koneksi awal
    redis_client.ping()
except Exception as e:
    logger.warning(f"Redis tidak tersedia saat startup: {e}. Cache akan di-skip.")
    redis_client = None


# ── Fungsi helper publik ──────────────────────────────────────────────────────

def cache_get(key: str) -> Optional[dict]:
    """
    Ambil value dari Redis dan parse sebagai dict.
    Return None jika Redis down, key tidak ada, atau value bukan JSON valid.
    """
    raw = cache_get_raw(key)
    if raw is None:
        return None
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return None


def cache_set(key: str, value: dict, ttl: int = 3600) -> bool:
    """
    Simpan dict ke Redis sebagai JSON string dengan TTL.
    Return True jika berhasil, False jika Redis down atau error.
    """
    try:
        serialized = json.dumps(value)
    except (TypeError, ValueError) as e:
        logger.warning(f"cache_set: gagal serialize value untuk key '{key}': {e}")
        return False
    return cache_set_raw(key, serialized, ttl=ttl)


def cache_get_raw(key: str) -> Optional[str]:
    """
    Ambil value mentah (string) dari Redis.
    Return None jika Redis down atau key tidak ada.
    Digunakan oleh ikigai_service yang menyimpan JSON string langsung.
    """
    if redis_client is None:
        return None
    try:
        return redis_client.get(key)
    except Exception as e:
        logger.warning(f"cache_get_raw: Redis error untuk key '{key}': {e}")
        return None


def cache_set_raw(key: str, value: str, ttl: int = 3600) -> bool:
    """
    Simpan string mentah ke Redis dengan TTL.
    Return True jika berhasil, False jika Redis down atau error.
    """
    if redis_client is None:
        return False
    try:
        redis_client.setex(key, ttl, value)
        return True
    except Exception as e:
        logger.warning(f"cache_set_raw: Redis error untuk key '{key}': {e}")
        return False


def cache_delete(key: str) -> bool:
    """
    Hapus key dari Redis.
    Return True jika berhasil, False jika Redis down atau error.
    """
    if redis_client is None:
        return False
    try:
        redis_client.delete(key)
        return True
    except Exception as e:
        logger.warning(f"cache_delete: Redis error untuk key '{key}': {e}")
        return False
```

---

---

### File 3: `app/api/v1/categories/career_profile/repositories/profession_repo.py`

File ini **dirombak total** — semua method lama yang query `DigitalProfession` dihapus, diganti dengan query ke tabel relasional `professions` + relasi-relasinya dari brief Jelajah Profesi.

Method yang dipertahankan (hanya yang berkaitan `IkigaiCandidateProfession`):
- `get_candidates_by_session_id` — tetap ada, tidak berubah
- `create_candidates` — tetap ada, tidak berubah

Method baru yang ditambahkan (menggantikan semua query `DigitalProfession`):
- `get_profession_contexts_for_ikigai(ids)` — query untuk generate narasi konten 5 display kandidat
- `get_profession_contexts_for_scoring(ids)` — query untuk scoring prompt Gemini (semua kandidat)
- `get_profession_contexts_for_recommendation(ids)` — query untuk narasi rekomendasi akhir, termasuk data gaji dari `profession_career_paths`
- `find_by_riasec_code(riasec_code)` — query `Profession` → join `riasec_codes`, menggantikan method lama yang query `DigitalProfession`

```python
# app/api/v1/categories/career_profile/repositories/profession_repo.py

from typing import List, Optional
from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import SQLAlchemyError
from fastapi import HTTPException, status

from app.api.v1.categories.career_profile.models.profession import IkigaiCandidateProfession

# === Model relasional dari brief Jelajah Profesi ===
# Import dari lokasi model Jelajah Profesi yang sudah ada di project
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
          - riasec_codes (via FK riasec_code_id): riasec_code, riasec_title, riasec_description
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

            # Ambil riasec_code string per profesi via join terpisah
            # (riasec_code_id ada di Profession, tapi relasinya tidak di-declare di model Jelajah Profesi)
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
                    "profession_id": p.id,
                    "name": p.name,
                    "riasec_code": rc.get("riasec_code", "-"),
                    "riasec_title": rc.get("riasec_title", "-"),
                    "about_description": (p.about_description or "")[:400],
                    "riasec_description": p.riasec_description or "",
                    "activities": [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                    "soft_skills_required": soft_skills,
                    "tools_required": tools,
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
        Query konteks profesi yang lebih ringkas untuk AI scoring prompt (semua kandidat).

        Dipakai oleh: IkigaiService._finalize_ikigai() — STEP 3 (Gemini scoring)

        Data yang diambil:
          - professions: id, name, about_description
          - profession_activities: 5 aktivitas teratas
          - profession_skill_rels → skills: 3 hard skill wajib teratas
            (lebih sedikit dari ikigai content — scoring prompt lebih singkat)

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
                    "profession_id": p.id,
                    "name": p.name,
                    "about_description": (p.about_description or "")[:300],
                    "activities": [a.description for a in activities],
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
          - profession_career_paths: entry_level dan senior_level (salary_min, salary_max)
            → ini yang selama ini hilang di DigitalProfession — sekarang tersedia

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

                # Entry level = career_path sort_order pertama (junior)
                # Senior level = career_path sort_order terakhir
                entry_level = career_paths[0] if career_paths else None
                senior_level = career_paths[-1] if len(career_paths) > 1 else None

                rc = riasec_map.get(p.riasec_code_id, {})
                result.append({
                    "profession_id": p.id,
                    "name": p.name,
                    "riasec_code": rc.get("riasec_code", "-"),
                    "riasec_title": rc.get("riasec_title", "-"),
                    "about_description": p.about_description or "-",
                    "riasec_description": p.riasec_description or "-",
                    "activities": [a.description for a in activities],
                    "hard_skills_required": hard_skills,
                    # Data gaji dari profession_career_paths — tersedia karena pakai tabel relasional
                    "entry_level_path": {
                        "title": entry_level.title,
                        "experience_range": entry_level.experience_range,
                        "salary_min": entry_level.salary_min,
                        "salary_max": entry_level.salary_max,
                    } if entry_level else None,
                    "senior_level_path": {
                        "title": senior_level.title,
                        "experience_range": senior_level.experience_range,
                        "salary_min": senior_level.salary_min,
                        "salary_max": senior_level.salary_max,
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
        Digunakan oleh riasec_service saat ekspansi kandidat profesi (Tier 1–4).

        Menggantikan method lama find_by_riasec_code yang query DigitalProfession.
        """
        return (
            self.db.query(Profession)
            .join(RIASECCode, Profession.riasec_code_id == RIASECCode.id)
            .filter(RIASECCode.riasec_code == riasec_code)
            .limit(limit)
            .all()
        )

    # ──────────────────────────────────────────────────────────────────────────
    # IKIGAI CANDIDATE PROFESSIONS (JSONB) — tidak berubah
    # ──────────────────────────────────────────────────────────────────────────

    def get_candidates_by_session_id(
        self, test_session_id: int
    ) -> Optional[IkigaiCandidateProfession]:
        """Ambil data kandidat profesi berdasarkan test_session_id."""
        try:
            return (
                self.db.query(IkigaiCandidateProfession)
                .filter(IkigaiCandidateProfession.test_session_id == test_session_id)
                .first()
            )
        except SQLAlchemyError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal mengambil data kandidat: {str(e)}",
            )

    def create_candidates(
        self,
        test_session_id: int,
        candidates_data: dict,
        total_candidates: int,
        generation_strategy: str,
        max_candidates_limit: int = 30,
    ) -> IkigaiCandidateProfession:
        """
        Buat record kandidat profesi baru.
        Menyertakan kolom denormalisasi sesuai model yang sudah diperbaiki
        (total_candidates, generation_strategy, max_candidates_limit).
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

    # ──────────────────────────────────────────────────────────────────────────
    # PRIVATE HELPERS
    # ──────────────────────────────────────────────────────────────────────────

    def _get_riasec_map(self, profession_ids: List[int]) -> dict:
        """
        Ambil mapping riasec_code_id → {riasec_code, riasec_title} untuk
        daftar profesi yang diberikan. Satu query untuk semua profesi (tidak N+1).
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
                "riasec_code": row.riasec_code,
                "riasec_title": row.riasec_title,
                "riasec_description": row.riasec_description,
            }
            for row in rows
        }
```

---

## Catatan Penutup

---

### File 4: `app/api/v1/categories/career_profile/schemas/ikigai.py`

Perubahan dari versi lama:
- Tambah field `from_cache: bool` di `IkigaiContentResponse` (Temuan 12)
- Semua schema lama yang tidak berkaitan pipeline baru (`IkigaiSubmitRequest`, `IkigaiSubmitWithClicksRequest`, `IkigaiSubmitResponse`, `IkigaiResultResponse`, `DimensionScoreDetail`, `ProfessionIkigaiScore`, `IkigaiProfessionClickInput`, `IkigaiDimensionInput`) dipertahankan agar tidak breaking change, tapi schema utama yang dipakai pipeline baru sudah disesuaikan.

```python
# app/api/v1/categories/career_profile/schemas/ikigai.py

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator
from typing import List, Dict, Any, Optional
from datetime import datetime


# ============== REQUEST SCHEMAS ==============

class StartIkigaiRequest(BaseModel):
    session_token: str


class SubmitDimensionRequest(BaseModel):
    session_token: str
    dimension_name: str          # "what_you_love" | "what_you_are_good_at" |
                                 # "what_the_world_needs" | "what_you_can_be_paid_for"
    selected_profession_id: Optional[int] = None
    selection_type: str          # "selected" | "not_selected"
    reasoning_text: str

    @field_validator("dimension_name")
    @classmethod
    def validate_dimension(cls, v: str) -> str:
        valid = {
            "what_you_love",
            "what_you_are_good_at",
            "what_the_world_needs",
            "what_you_can_be_paid_for",
        }
        if v not in valid:
            raise ValueError(f"dimension_name tidak valid. Pilih dari: {valid}")
        return v

    @field_validator("selection_type")
    @classmethod
    def validate_selection_type(cls, v: str) -> str:
        if v not in {"selected", "not_selected"}:
            raise ValueError("selection_type harus 'selected' atau 'not_selected'")
        return v

    @field_validator("reasoning_text")
    @classmethod
    def validate_reasoning(cls, v: str) -> str:
        if len(v.strip()) < 10:
            raise ValueError("reasoning_text minimal 10 karakter")
        return v.strip()

    def validate_consistency(self):
        """Validasi konsistensi selected_profession_id dan selection_type."""
        if self.selected_profession_id is not None and self.selection_type != "selected":
            raise ValueError(
                "Jika selected_profession_id diisi, selection_type harus 'selected'"
            )
        if self.selected_profession_id is None and self.selection_type != "not_selected":
            raise ValueError(
                "Jika selected_profession_id null, selection_type harus 'not_selected'"
            )


# ============== RESPONSE SCHEMAS — CONTENT (Phase 1) ==============

class DimensionContent(BaseModel):
    what_you_love:           str
    what_you_are_good_at:    str
    what_the_world_needs:    str
    what_you_can_be_paid_for: str


class CandidateWithContent(BaseModel):
    profession_id:     int
    profession_name:   str
    display_order:     int
    congruence_score:  float
    dimension_content: DimensionContent


class IkigaiContentResponse(BaseModel):
    """
    Response untuk POST /ikigai/start dan GET /ikigai/content/{token}.

    === PERBAIKAN TEMUAN 12: Tambah from_cache field ===
    from_cache: True  → data diambil dari Redis cache
    from_cache: False → data baru di-generate (Redis miss atau session baru)

    Field regenerated dipertahankan untuk backward compat (semantik terbalik dari from_cache).
    Flutter sebaiknya menggunakan from_cache.
    """
    session_token:            str
    status:                   str
    generated_at:             str     # ISO8601
    from_cache:               bool    # BARU — True jika dari cache, False jika generate baru
    regenerated:              bool    # LAMA — True jika generate baru (invers from_cache)
    total_display_candidates: int
    message:                  str
    candidates_with_content:  List[CandidateWithContent]


# ============== RESPONSE SCHEMAS — SUBMIT DIMENSI (Phase 2) ==============

class DimensionSubmitResponse(BaseModel):
    """Response untuk submit dimensi yang bukan dimensi ke-4 (belum semua selesai)."""
    session_token:        str
    dimension_saved:      str           # nama dimensi yang baru disimpan
    dimensions_completed: List[str]
    dimensions_remaining: List[str]
    all_completed:        bool          # False jika masih ada yang belum dijawab
    message:              str


class ProfessionScoreBreakdown(BaseModel):
    rank:                        int
    profession_id:               int
    total_score:                 float
    score_what_you_love:         float
    score_what_you_are_good_at:  float
    score_what_the_world_needs:  float
    score_what_you_can_be_paid_for: float
    intrinsic_score:             float
    extrinsic_score:             float


class IkigaiCompletionResponse(BaseModel):
    """Response setelah dimensi ke-4 selesai dan scoring pipeline selesai."""
    session_token:                str
    status:                       str      # "completed"
    top_2_professions:            List[ProfessionScoreBreakdown]
    total_professions_evaluated:  int
    tie_breaking_applied:         bool
    calculated_at:                str      # ISO8601
    message:                      str
```

---

### File 5: `app/api/v1/categories/career_profile/routers/ikigai.py`

Perubahan dari versi lama:
- `POST /ikigai/start` → `10/hour` (dari `5/minute`) — Temuan 11
- `GET /ikigai/content/{token}` → `30/minute` (dari `10/minute`) — Temuan 11
- `POST /ikigai/submit-dimension` → `40/hour` dipertahankan (sudah sesuai brief)

```python
# app/api/v1/categories/career_profile/routers/ikigai.py

from fastapi import APIRouter, Depends, Request, HTTPException, status
from sqlalchemy.orm import Session
from typing import Union

from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.dependencies.auth import require_active_membership
from app.api.v1.categories.career_profile.services.ikigai_service import IkigaiService
from app.api.v1.categories.career_profile.schemas.ikigai import (
    StartIkigaiRequest,
    IkigaiContentResponse,
    SubmitDimensionRequest,
    DimensionSubmitResponse,
    IkigaiCompletionResponse,
)
from app.db.models.user import User

router = APIRouter(
    prefix="/career-profile/ikigai",
    tags=["Career Profile - Ikigai"],
)


@router.post("/start", response_model=IkigaiContentResponse)
@limiter.limit("10/hour")   # === PERBAIKAN TEMUAN 11: 5/minute → 10/hour ===
# Lebih ketat karena setiap call /start berpotensi trigger Gemini content generation.
# 10 kali per jam cukup untuk UX normal (user tidak akan restart sesi lebih dari itu).
async def start_ikigai_session(
    request: Request,
    body: StartIkigaiRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership),
):
    """
    Memulai fase Ikigai.
    - Validasi sesi harus status 'riasec_completed', uses_ikigai=True, test_goal='RECOMMENDATION'
    - UPDATE status sesi → 'ikigai_ongoing'
    - INSERT placeholder baris kosong ke ikigai_responses
    - Generate narasi dimensi untuk kandidat top-5 menggunakan Gemini
    - Cache konten di Redis selama 2 jam (from_cache=False pada response pertama)
    """
    service = IkigaiService(db)
    return await service.start_ikigai_session(
        user=current_user,
        session_token=body.session_token,
    )


@router.get("/content/{session_token}", response_model=IkigaiContentResponse)
@limiter.limit("30/minute")   # === PERBAIKAN TEMUAN 11: 10/minute → 30/minute ===
# Lebih longgar karena GET content biasanya hanya baca Redis cache (tidak trigger Gemini).
# 30/minute sesuai dengan pola Flutter yang mungkin reload konten saat kembali ke halaman.
async def get_ikigai_content(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership),
):
    """
    Mengambil konten soal Ikigai (kandidat profesi beserta narasi 4 dimensinya).
    - Ambil dari Redis cache jika masih valid (from_cache=True)
    - Jika expired, regenerate selama status sesi masih 'ikigai_ongoing' (from_cache=False)
    - Tidak mengubah status sesi.
    - Validasi: uses_ikigai=True dan test_goal='RECOMMENDATION'
    """
    service = IkigaiService(db)
    return await service.get_ikigai_content(
        user=current_user,
        session_token=session_token,
    )


@router.post(
    "/submit-dimension",
    response_model=Union[DimensionSubmitResponse, IkigaiCompletionResponse],
)
@limiter.limit("40/hour")
async def submit_dimension(
    request: Request,
    body: SubmitDimensionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership),
):
    """
    Submit jawaban untuk satu dimensi Ikigai.
    Endpoint ini dipanggil hingga 4 kali (satu per dimensi).

    Proteksi:
    - Dimensi yang sudah dijawab tidak bisa di-overwrite (HTTP 400)
    - selected_profession_id divalidasi terhadap kandidat sesi ini

    Jika ini adalah dimensi terakhir (ke-4):
      - Trigger AI scoring batch (4 Gemini call paralel)
      - INSERT ikigai_dimension_scores + ikigai_total_scores
      - UPDATE status sesi → 'completed'
      - Return IkigaiCompletionResponse dengan top-2 profesi + breakdown skor

    Jika bukan dimensi terakhir:
      - UPDATE kolom dimensi di ikigai_responses
      - Return DimensionSubmitResponse dengan info progres
    """
    body.validate_consistency()
    service = IkigaiService(db)
    return await service.submit_dimension(
        user=current_user,
        session_token=body.session_token,
        dimension_name=body.dimension_name,
        selected_profession_id=body.selected_profession_id,
        selection_type=body.selection_type,
        reasoning_text=body.reasoning_text,
    )


@router.get("/result/{session_token}", response_model=IkigaiCompletionResponse)
@limiter.limit("30/minute")
async def get_ikigai_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership),
):
    """
    Ambil hasil final Ikigai yang sudah tersimpan di DB.
    Digunakan Flutter untuk reload halaman hasil tanpa re-scoring.
    Hanya bisa diakses jika sesi sudah 'completed'.
    """
    service = IkigaiService(db)
    return await service.get_ikigai_result(
        session_token=session_token,
        user=current_user,
    )
```

---

**Urutan pengerjaan yang disarankan:**

1. `cache.py` — perbaiki dulu agar `ikigai_service.py` bisa diimport dengan benar
2. `profession_repo.py` — dirombak total, method baru pakai model relasional
3. `ikigai_service.py` — semua 13 temuan diselesaikan, query via `ProfessionRepository` baru
4. `schemas/ikigai.py` — tambah field `from_cache`
5. `routers/ikigai.py` — fix rate limit
6. Migration Alembic — buat tabel `ikigai_responses`, `ikigai_dimension_scores`, `ikigai_total_scores`

**Tentang `DigitalProfession`:**  
Setelah `profession_repo.py` dirombak, file `app/api/v1/categories/career_profile/models/digital_profession.py` tidak lagi digunakan oleh pipeline Ikigai. Cek apakah ada modul lain yang masih mengimportnya sebelum dihapus — terutama `riasec_service.py` yang mungkin masih pakai model lama untuk ekspansi kandidat.

**Tentang import path model Jelajah Profesi:**  
File `profession_repo.py` mengimport semua model relasional dari **satu file**: `app.api.v1.categories.career_profile.models.profession_relational` — sesuai MD 1 v2. Import lama yang tersebar di `app.models.*` sudah tidak digunakan.
