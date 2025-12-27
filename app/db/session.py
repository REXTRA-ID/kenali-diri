from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from app.core.config import settings
from typing import Generator
import os

DATABASE_URL = settings.DATABASE_URL

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

# Create engine
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  # Verify connections before using
    pool_size=settings.SQLALCHEMY_POOL_SIZE,  # Connection pool size
    max_overflow=settings.SQLALCHEMY_MAX_OVERFLOW,  # Max connections beyond pool_size
    echo=False,  # Set to True to log SQL statements (dev only)
    pool_timeout=30,
    pool_recycle=3600
)


def get_db() -> Generator[Session, None, None]:
    """
    Dependency function for FastAPI endpoints
    
    Provides a database session and ensures it's properly closed
    after the request is complete.
    
    Usage in FastAPI:
        @app.get("/example")
        def example(db: Session = Depends(get_db)):
            # Use db here
            pass
    
    Yields:
        Session: SQLAlchemy database session
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_db_context():
    """
    Context manager for database sessions
    
    Usage outside FastAPI (scripts, background tasks):
        with get_db_context() as db:
            # Use db here
            pass
    
    Returns:
        Session: SQLAlchemy database session
    """
    db = SessionLocal()
    try:
        return db
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()