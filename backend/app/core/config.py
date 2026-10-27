from typing import List, Optional
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "Khetopedia API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/v1"

    # Security
    SECRET_KEY: str = "khetopedia-super-secret-development-key-change-in-production-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 days
    OTP_EXPIRE_MINUTES: int = 15

    # Database: defaults to a local async SQLite database for zero-config local run
    # For PostgreSQL production, set: postgresql+asyncpg://user:password@localhost:5432/khetopedia
    DATABASE_URL: str = "sqlite+aiosqlite:///./khetopedia.db"
    
    # Database Connection Pooling (PostgreSQL only)
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 20
    DB_POOL_RECYCLE: int = 3600
    DB_POOL_PRE_PING: bool = True

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_MAX_CONNECTIONS: int = 50
    USE_REDIS: bool = False

    # Object Storage (S3-compatible)
    S3_ENDPOINT_URL: Optional[str] = None  # None for AWS, "http://localhost:9000" for MinIO
    S3_ACCESS_KEY_ID: str = ""
    S3_SECRET_ACCESS_KEY: str = ""
    S3_BUCKET_NAME: str = "khetopedia-images"
    S3_REGION: str = "us-east-1"
    USE_S3: bool = False  # Set True to enable S3, False for local filesystem fallback

    # Weather API
    WEATHER_API_KEY: str = ""  # OpenWeatherMap API key
    WEATHER_API_URL: str = "https://api.openweathermap.org/data/2.5"
    WEATHER_CACHE_TTL: int = 1800  # 30 minutes
    USE_MOCK_WEATHER: bool = True  # False to use real API

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8000",
        "http://localhost:8080",
        "*"
    ]

    # ML Service Configuration
    ML_MODEL_PATH: str = "app/ml/models/crop_disease_resnet50_v1.pth"
    ML_MODEL_VERSION: str = "v1"
    ML_DEVICE: str = "cpu"  # "cpu" or "cuda" for GPU
    ML_CONFIDENCE_THRESHOLD: float = 0.65  # Minimum confidence for positive diagnosis
    ML_BATCH_SIZE: int = 8  # Batch size for batch inference
    ML_CACHE_TTL: int = 604800  # 7 days in seconds for prediction caching
    ML_BATCH_WAIT_MS: int = 50  # Milliseconds to wait for batching (0 to disable)

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
