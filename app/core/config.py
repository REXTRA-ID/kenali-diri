from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str
    APP_VERSION: str
    ENV: str = "development"

    DATABASE_URL: str
    SQLALCHEMY_POOL_SIZE: int = 20
    SQLALCHEMY_MAX_OVERFLOW: int = 40

    # Redis
    REDIS_URL: str

    # Celery
    CELERY_BROKER_URL: str

    # OpenRouter AI
    OPENROUTER_API_KEY: str
    OPENROUTER_BASE_URL: str = "https://openrouter.ai/api/v1"
    OPENROUTER_MODEL: str = "google/gemini-3.0-flash"

    # AI Settings
    AI_MAX_TOKENS: int = 2000
    AI_TEMPERATURE: float = 0.7

    # Security
    SECRET_KEY: str

    # Monitoring
    SENTRY_DSN: str | None = None
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
