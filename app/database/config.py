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
