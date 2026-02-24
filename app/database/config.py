"""
app/database/config.py
-----------------------
Konfigurasi async SQLAlchemy session untuk dipakai oleh seeders dan
background tasks yang berjalan di luar konteks FastAPI request.

Membutuhkan driver `asyncpg` (pip install asyncpg).

Cara pakai:
    from app.database.config import AsyncSessionLocal

    async with AsyncSessionLocal() as session:
        ...
"""

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings

# Konversi sync URL → async URL (postgresql:// → postgresql+asyncpg://)
_sync_url: str = settings.DATABASE_URL
_async_url: str = _sync_url.replace("postgresql://", "postgresql+asyncpg://", 1)

_async_engine = create_async_engine(
    _async_url,
    pool_pre_ping=True,
    pool_size=settings.SQLALCHEMY_POOL_SIZE,
    max_overflow=settings.SQLALCHEMY_MAX_OVERFLOW,
    echo=False,
    pool_recycle=settings.DB_POOL_RECYCLE,
)

AsyncSessionLocal: async_sessionmaker[AsyncSession] = async_sessionmaker(
    bind=_async_engine,
    class_=AsyncSession,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,
)
