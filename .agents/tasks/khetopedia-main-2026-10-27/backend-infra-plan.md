# Backend Infrastructure Implementation Plan

**Project:** Khetopedia Backend Infrastructure  
**Date:** January 2025  
**Location:** `f:\khetopedia\backend\`

---

## Overview

This plan implements production-ready infrastructure for the Khetopedia FastAPI backend:

1. **Database Infrastructure** - Alembic migrations, PostgreSQL support with connection pooling
2. **Object Storage** - S3-compatible image storage for crop scans and soil images
3. **Redis Integration** - Rate limiting, JWT blocklist, caching for weather and dashboard
4. **Weather API** - External API integration with caching

**Current State:** SQLite dev environment with async SQLAlchemy, all models defined, auth working  
**Target State:** Production-ready infrastructure with PostgreSQL, Redis, S3, and external APIs

---

## Implementation Plan

### Phase 1: Database Infrastructure

#### 1. Install Alembic and Configure Migration System

**What:** Set up Alembic for database schema version control with auto-detection of SQLAlchemy models.

**Files to Create:**
- `backend/alembic.ini` - Alembic configuration file
- `backend/alembic/env.py` - Migration environment with async support
- `backend/alembic/script.py.mako` - Migration template
- `backend/alembic/versions/.gitkeep` - Placeholder for migration files

**Files to Modify:**
- `backend/pyproject.toml` - Add `alembic>=1.13.0` to dependencies

**Steps:**
1. Add Alembic dependency to pyproject.toml
2. Initialize Alembic structure: `alembic init alembic`
3. Configure `alembic.ini` to use async SQLAlchemy and read `DATABASE_URL` from config
4. Update `alembic/env.py` to import all models from `app.models` and use async engine
5. Configure `script_location`, `version_locations`, and `prepend_sys_path` settings

**Verify:** Run `alembic check` from `backend/` directory - should report "No issues detected"

---

#### 2. Create Initial Migration for All Existing Models

**What:** Generate an initial Alembic migration capturing the current schema (users, fields, alerts, crop_scans, soil_tests, sensor_devices, farms, recommendations, ai_conversations, profiles, password_reset_tokens).

**Files to Create:**
- `backend/alembic/versions/YYYY_MM_DD_HHMM_initial_schema.py` - Auto-generated migration

**Steps:**
1. Ensure all models are imported in `app/models/__init__.py`
2. Run `alembic revision --autogenerate -m "initial schema"`
3. Review generated migration - verify all 11 tables are included with proper indexes and foreign keys
4. Run `alembic upgrade head` against a fresh SQLite database to validate

**Verify:** Run `alembic upgrade head` on clean database, then `alembic current` - should show the migration revision hash

---

#### 3. Add PostgreSQL Connection Pooling Configuration

**What:** Extend `config.py` to support PostgreSQL connection pooling with configurable pool size, max overflow, and connection health checks.

**Files to Modify:**
- `backend/app/core/config.py` - Add PostgreSQL-specific settings
- `backend/app/core/database.py` - Configure connection pool parameters

**Changes:**
1. Add to `Settings` class:
   - `DB_POOL_SIZE: int = 10` (number of permanent connections)
   - `DB_MAX_OVERFLOW: int = 20` (max temporary connections beyond pool size)
   - `DB_POOL_RECYCLE: int = 3600` (recycle connections after 1 hour to prevent stale connections)
   - `DB_POOL_PRE_PING: bool = True` (enable connection health checks before use)
2. Update `create_async_engine()` in `database.py` to use these settings when PostgreSQL is detected
3. Add logic: if `DATABASE_URL.startswith("postgresql")`, apply pool settings; if SQLite, skip pooling

**Verify:** Start backend with `DATABASE_URL=postgresql+asyncpg://user:pass@localhost/testdb` and check logs for "DB pool initialized with size=10" message (add log statement)

---

#### 4. Create Database Management CLI Utilities

**What:** Add CLI commands for common database operations (init, migrate, seed, reset).

**Files to Create:**
- `backend/app/cli.py` - Click-based CLI with database commands

**Commands to Implement:**
1. `python -m app.cli db init` - Run Alembic migrations to latest
2. `python -m app.cli db seed` - Populate development database with sample data (admin user, 3 fields, sample alerts)
3. `python -m app.cli db reset` - Drop all tables and re-run migrations (dev only, requires confirmation)
4. `python -m app.cli db migrate --message "description"` - Create new migration

**Files to Modify:**
- `backend/pyproject.toml` - Add `click>=8.1.0` dependency

**Verify:** Run `python -m app.cli db init` and `python -m app.cli db seed` - database should have tables and sample data

---

### Phase 2: Object Storage for Images

#### 5. Install and Configure S3-Compatible Storage Client

**What:** Add boto3 client with support for AWS S3 and MinIO (self-hosted S3 alternative).

**Files to Modify:**
- `backend/pyproject.toml` - Add `boto3>=1.34.0`, `python-magic>=0.4.27` (MIME type detection)
- `backend/app/core/config.py` - Add S3 configuration settings

**Settings to Add:**
```python
# Object Storage (S3-compatible)
S3_ENDPOINT_URL: Optional[str] = None  # None for AWS, "http://localhost:9000" for MinIO
S3_ACCESS_KEY_ID: str = ""
S3_SECRET_ACCESS_KEY: str = ""
S3_BUCKET_NAME: str = "khetopedia-images"
S3_REGION: str = "us-east-1"
USE_S3: bool = False  # Set True to enable S3, False for local filesystem fallback
```

**Files to Create:**
- `backend/app/services/storage_service.py` - Abstract storage interface with S3 and filesystem implementations

**Verify:** Set `USE_S3=false` and start backend - should log "Storage: Using filesystem backend"

---

#### 6. Implement Image Upload Service with Validation

**What:** Create reusable image upload handler with MIME validation, randomized IDs, size limits, and storage backend abstraction.

**Files to Create:**
- `backend/app/services/image_service.py` - Image validation and upload orchestration

**Implementation:**
1. `validate_image(file_bytes: bytes, allowed_types: List[str]) -> ValidationResult`
   - Check MIME type with `python-magic` (not just extension)
   - Validate size: min 5KB, max 10MB
   - Return `(is_valid: bool, mime_type: str, error_message: Optional[str])`

2. `upload_image(file_bytes: bytes, category: str, user_id: str) -> str`
   - Generate secure random filename: `{uuid4().hex}.{ext}`
   - Determine S3 key or filesystem path: `{category}/{user_id[:8]}/{filename}`
   - Upload via `storage_service` (S3 or local)
   - Return public URL or relative path

**Allowed Types:** `image/jpeg`, `image/png`, `image/webp`

**Verify:** Unit test `validate_image()` with JPEG (valid), PDF (invalid), oversized PNG (invalid)

---

#### 7. Integrate Storage with Crop Scan Endpoint

**What:** Modify `crop_scanner_service.py` to use the new image upload service instead of generating fake paths.

**Files to Modify:**
- `backend/app/services/crop_scanner_service.py` - Replace line 150-151 with `image_service.upload_image()`
- `backend/app/api/v1/endpoints/crop_scans.py` - Add image validation before processing

**Changes:**
1. In `analyze_crop_image()`: call `image_service.validate_image(file_bytes, ["image/jpeg", "image/png", "image/webp"])`
2. If validation fails, raise `HTTPException(400, detail=error_message)`
3. Replace `save_path = f"/uploads/crops/{random_name}"` with `save_path = await image_service.upload_image(file_bytes, "crops", user.id)`
4. Update `CropScan.image_path` to store full URL if S3 enabled, or relative path for filesystem

**Verify:** POST to `/v1/crop-scans` with JPEG - database record should have `image_path` like `crops/abc12345/f3e4d5c6.jpg` or `https://s3.amazonaws.com/khetopedia-images/crops/...`

---

#### 8. Integrate Storage with Soil Test Endpoint

**What:** Add image upload support to soil tests for lab report photos.

**Files to Modify:**
- `backend/app/models/soil.py` - Add `report_image_path: Optional[str]` column
- `backend/app/schemas/soil.py` - Add `report_image_url` to `SoilTestResponse`
- `backend/app/api/v1/endpoints/soil.py` - Add optional `File(...)` parameter
- `backend/app/services/soil_service.py` - Upload image if provided

**Changes:**
1. Add nullable `report_image_path` column to `SoilTest` model
2. Modify `POST /soil/tests` to accept `report_image: Optional[UploadFile] = File(None)`
3. If `report_image` provided, validate and upload via `image_service.upload_image(file_bytes, "soil", user.id)`
4. Store path in `SoilTest.report_image_path`

**Verify:** POST with multipart form data including soil metrics + lab report image - response should include `report_image_url`

---

#### 9. Create Database Migration for Image Columns

**What:** Generate Alembic migration adding `report_image_path` to `soil_tests` table.

**Files to Create:**
- `backend/alembic/versions/YYYY_MM_DD_HHMM_add_soil_report_images.py`

**Steps:**
1. Run `alembic revision --autogenerate -m "add soil report images"`
2. Review migration - should add `report_image_path VARCHAR(512) NULL` to `soil_tests`
3. Run `alembic upgrade head`

**Verify:** Run migration on dev database, then `alembic current` - should show new revision

---

### Phase 3: Redis Integration

#### 10. Install Redis Client and Configure Connection

**What:** Add async Redis client with connection pooling.

**Files to Modify:**
- `backend/pyproject.toml` - Add `redis[hiredis]>=5.0.0` (hiredis is C parser for performance)
- `backend/app/core/config.py` - Add Redis settings

**Settings to Add:**
```python
# Redis
REDIS_URL: str = "redis://localhost:6379/0"
REDIS_MAX_CONNECTIONS: int = 50
USE_REDIS: bool = False  # Enable Redis features
```

**Files to Create:**
- `backend/app/core/redis.py` - Redis connection factory and lifecycle management

**Implementation:**
```python
from redis.asyncio import Redis, ConnectionPool
from app.core.config import settings

_redis_pool: Optional[ConnectionPool] = None
_redis_client: Optional[Redis] = None

async def init_redis():
    global _redis_pool, _redis_client
    if settings.USE_REDIS:
        _redis_pool = ConnectionPool.from_url(settings.REDIS_URL, max_connections=settings.REDIS_MAX_CONNECTIONS)
        _redis_client = Redis(connection_pool=_redis_pool)

async def close_redis():
    if _redis_client:
        await _redis_client.close()
    if _redis_pool:
        await _redis_pool.disconnect()

def get_redis() -> Optional[Redis]:
    return _redis_client
```

**Files to Modify:**
- `backend/app/main.py` - Call `init_redis()` in lifespan startup, `close_redis()` in shutdown

**Verify:** Set `USE_REDIS=true`, start backend, check logs for "Redis connected to localhost:6379"

---

#### 11. Implement Rate Limiting Middleware

**What:** Add rate limiting middleware using Redis for distributed tracking (falls back to memory if Redis disabled).

**Files to Create:**
- `backend/app/middleware/rate_limit.py` - Rate limiting middleware with sliding window algorithm

**Implementation:**
1. Use `slowapi` library for FastAPI-compatible rate limiting (add `slowapi>=0.1.9` to dependencies)
2. Configure limits:
   - Anonymous: 100 requests/hour per IP
   - Authenticated: 1000 requests/hour per user ID
   - Specific endpoints:
     - `/v1/crop-scans`: 20 uploads/hour per user
     - `/v1/auth/login`: 10 attempts/hour per IP (prevent brute force)
     - `/v1/auth/forgot-password`: 3 requests/hour per IP (prevent email enumeration)
3. Use Redis for storage if enabled, otherwise in-memory dict (not distributed, dev only)
4. Return `429 Too Many Requests` with `Retry-After` header

**Files to Modify:**
- `backend/app/main.py` - Add rate limit middleware

**Verify:** Make 11 login requests in 1 minute - 11th should return 429 with `{"detail": "Rate limit exceeded. Try again in 3540 seconds."}`

---

#### 12. Implement JWT Token Blocklist for Logout

**What:** Store invalidated tokens in Redis with TTL matching token expiry.

**Files to Create:**
- `backend/app/services/token_blocklist_service.py`

**Implementation:**
```python
async def blocklist_token(jti: str, expires_at: datetime):
    redis = get_redis()
    if redis:
        ttl = int((expires_at - datetime.now(timezone.utc)).total_seconds())
        await redis.setex(f"blocklist:{jti}", ttl, "1")

async def is_token_blocklisted(jti: str) -> bool:
    redis = get_redis()
    if redis:
        return await redis.exists(f"blocklist:{jti}") == 1
    return False  # If Redis disabled, can't enforce blocklist (logged warning)
```

**Files to Modify:**
- `backend/app/core/security.py` - Add `jti` (JWT ID) claim to tokens (random UUID)
- `backend/app/api/deps.py` - Check `is_token_blocklisted(jti)` in `get_current_user()`
- `backend/app/api/v1/endpoints/auth.py` - Call `blocklist_token()` in logout endpoint

**Verify:** Login, get token, logout, try using same token - should return 401 with "Token has been revoked"

---

#### 13. Implement Weather Data Caching

**What:** Cache weather API responses in Redis with 30-minute TTL.

**Files to Modify:**
- `backend/app/services/weather_service.py` - Add Redis caching layer

**Implementation:**
1. Before calling external API, check Redis key `weather:{latitude}:{longitude}` (rounded to 2 decimals)
2. If found and not expired, deserialize JSON and return
3. If not found, call external API, store result with `ttl=1800` (30 minutes)
4. Add `last_updated` timestamp to response
5. If Redis unavailable, bypass cache and call API directly (log warning)

**Verify:** GET `/v1/weather?latitude=28.61&longitude=77.23` twice in 1 minute - second call should not hit external API (check logs)

---

#### 14. Implement Dashboard Summary Caching

**What:** Cache dashboard summary per user with 5-minute TTL to reduce database queries.

**Files to Modify:**
- `backend/app/api/v1/endpoints/dashboard.py` - Add Redis caching to `GET /summary`

**Implementation:**
1. Check Redis key `dashboard:summary:{user_id}`
2. If found, deserialize and return
3. If not found, query database, serialize response, store with `ttl=300` (5 minutes)
4. Invalidate cache on actions that affect dashboard: field creation/update, alert creation

**Cache Invalidation Triggers:**
- Field created/updated/deleted → delete `dashboard:summary:{user_id}`
- Alert created → delete `dashboard:summary:{user_id}`
- Crop scan created → delete `dashboard:summary:{user_id}` (affects health score)

**Verify:** GET `/v1/dashboard/summary`, then update field health score, then GET again - should see updated data immediately (cache invalidated)

---

### Phase 4: Weather API Integration

#### 15. Configure External Weather API Integration

**What:** Integrate with OpenWeatherMap API (free tier: 1000 calls/day, 60 calls/minute).

**Files to Modify:**
- `backend/pyproject.toml` - Already has `httpx>=0.27.2` for async HTTP
- `backend/app/core/config.py` - Add weather API settings

**Settings to Add:**
```python
# Weather API
WEATHER_API_KEY: str = ""  # OpenWeatherMap API key
WEATHER_API_URL: str = "https://api.openweathermap.org/data/2.5"
WEATHER_CACHE_TTL: int = 1800  # 30 minutes
USE_MOCK_WEATHER: bool = True  # False to use real API
```

**Verify:** Set `WEATHER_API_KEY=your_key` and `USE_MOCK_WEATHER=false` in .env file

---

#### 16. Implement Real Weather Service with Caching

**What:** Replace stub weather data with real OpenWeatherMap API calls.

**Files to Modify:**
- `backend/app/services/weather_service.py` - Complete rewrite

**Implementation:**
1. `async def get_weather(latitude: float, longitude: float) -> WeatherResponse`
   - Check Redis cache: `weather:{lat:.2f}:{lon:.2f}`
   - If cached and `last_updated` < 30 min ago, return cached
   - Else, call OpenWeatherMap `/weather` endpoint (current conditions)
   - Call `/forecast` endpoint (5-day 3-hour forecast)
   - Transform API response to `WeatherResponse` schema:
     - `temperature_celsius` from `main.temp` (convert from Kelvin if needed)
     - `humidity_percentage` from `main.humidity`
     - `rain_probability_percentage` from `pop` (probability of precipitation)
     - `wind_speed_kmh` from `wind.speed` (convert m/s to km/h)
     - `condition` from `weather[0].main`
     - `uv_index` from separate `/uvi` endpoint or return null
   - Generate agricultural advisory:
     - If rain > 70% next 6 hours: "High rain probability. Delay pesticide application."
     - If wind > 15 km/h: "Moderate to high wind. Avoid spraying."
     - If temp > 35°C: "High temperature. Irrigate in early morning or evening."
     - Else: "Favorable conditions for field operations."
   - Cache result with 30-minute TTL
   - Add `last_updated: datetime.now(utc)` to response
2. If `USE_MOCK_WEATHER=true`, return existing stub data (for dev without API key)
3. Handle API errors gracefully: if OpenWeatherMap returns error, log warning and return last cached data or fallback stub

**Error Handling:**
- 401 (invalid API key) → log error, return mock data, set `advisory="Weather data temporarily unavailable"`
- 429 (rate limit) → return cached data if available, else mock
- Network timeout → return cached data, else mock

**Verify:** GET `/v1/weather?latitude=28.61&longitude=77.23` with real API key - response should have current temperature for New Delhi and `last_updated` timestamp within last 30 minutes

---

#### 17. Add Weather Data to Dashboard Summary

**What:** Include weather card data in dashboard summary endpoint.

**Files to Modify:**
- `backend/app/schemas/dashboard.py` - Add `weather: WeatherCardSchema` to `DashboardSummaryResponse`
- `backend/app/api/v1/endpoints/dashboard.py` - Fetch weather data for user's primary field location

**Implementation:**
1. Add `WeatherCardSchema` to schema file:
   ```python
   class WeatherCardSchema(BaseModel):
       temperature_celsius: float
       humidity_percentage: float
       rain_probability_percentage: int
       condition: str
       advisory: str
       last_updated: datetime
   ```
2. In `GET /v1/dashboard/summary`:
   - Get user's primary field (first field or most recently updated)
   - If field has `latitude` and `longitude`, call `weather_service.get_weather(lat, lon)`
   - Transform to `WeatherCardSchema`
   - Add to summary response
   - If no fields or no coordinates, return default weather with `location="Your Area"` and mock data

**Verify:** GET `/v1/dashboard/summary` - response should include `weather` object with current temperature

---

### Phase 5: Testing and Documentation

#### 18. Write Integration Tests for New Features

**What:** Add pytest tests covering database migrations, S3 uploads, Redis caching, and weather API.

**Files to Create:**
- `backend/tests/test_storage.py` - Test image upload, validation, S3/filesystem backends
- `backend/tests/test_redis.py` - Test rate limiting, token blocklist, caching
- `backend/tests/test_weather.py` - Test weather API integration, caching, error handling
- `backend/tests/test_migrations.py` - Test Alembic migrations (up/down)

**Test Cases:**
1. Storage:
   - Upload valid JPEG → returns URL
   - Upload PDF → raises 400 error
   - Upload 15MB image → raises 400 error
   - Upload with S3 enabled → stored in S3 bucket
   - Upload with S3 disabled → stored in `uploads/` directory
2. Redis:
   - 11th login attempt in 1 hour → 429 error
   - Logout invalidates token → subsequent requests with same token return 401
   - Dashboard summary cached → second call doesn't query database
   - Cache invalidated on field update → fresh data returned
3. Weather:
   - Valid coordinates → returns current weather
   - Invalid API key → returns mock data with advisory
   - Cached data → second call doesn't hit external API
   - No coordinates → returns default weather
4. Migrations:
   - `alembic upgrade head` creates all tables
   - `alembic downgrade -1` removes last migration
   - Auto-generate detects new column

**Verify:** Run `pytest tests/` - all tests pass with at least 80% coverage of new code

---

#### 19. Create Environment Configuration Examples

**What:** Document all new environment variables with example values.

**Files to Create:**
- `backend/.env.example` - Template with all settings

**Content:**
```bash
# Database
DATABASE_URL=sqlite+aiosqlite:///./khetopedia.db
# For PostgreSQL: postgresql+asyncpg://user:password@localhost:5432/khetopedia
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=20
DB_POOL_RECYCLE=3600
DB_POOL_PRE_PING=true

# Redis
REDIS_URL=redis://localhost:6379/0
REDIS_MAX_CONNECTIONS=50
USE_REDIS=false

# Object Storage
S3_ENDPOINT_URL=  # Leave empty for AWS S3, set to http://localhost:9000 for MinIO
S3_ACCESS_KEY_ID=your_access_key
S3_SECRET_ACCESS_KEY=your_secret_key
S3_BUCKET_NAME=khetopedia-images
S3_REGION=us-east-1
USE_S3=false

# Weather API
WEATHER_API_KEY=your_openweathermap_api_key
WEATHER_API_URL=https://api.openweathermap.org/data/2.5
WEATHER_CACHE_TTL=1800
USE_MOCK_WEATHER=true

# Security
SECRET_KEY=khetopedia-super-secret-development-key-change-in-production-2026
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
REFRESH_TOKEN_EXPIRE_MINUTES=43200
```

**Verify:** Copy `.env.example` to `.env`, fill in values, start backend - all features work

---

#### 20. Update Backend README with Setup Instructions

**What:** Document setup for PostgreSQL, Redis, MinIO, and environment configuration.

**Files to Modify:**
- `backend/README.md` - Add comprehensive setup guide

**Sections to Add:**
1. **Prerequisites:** Python 3.11+, PostgreSQL 15+, Redis 7+, MinIO (optional)
2. **Quick Start:**
   ```bash
   # Install dependencies
   pip install -e .
   
   # Copy environment template
   cp .env.example .env
   
   # Run migrations
   alembic upgrade head
   
   # Seed development data
   python -m app.cli db seed
   
   # Start server
   uvicorn app.main:app --reload
   ```
3. **PostgreSQL Setup:**
   ```sql
   CREATE DATABASE khetopedia;
   CREATE USER khetopedia_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE khetopedia TO khetopedia_user;
   ```
4. **Redis Setup:**
   ```bash
   # Ubuntu/Debian
   sudo apt install redis-server
   sudo systemctl start redis
   
   # macOS
   brew install redis
   brew services start redis
   
   # Windows
   # Download from https://github.com/microsoftarchive/redis/releases
   ```
5. **MinIO Setup (S3-compatible self-hosted):**
   ```bash
   # Docker
   docker run -p 9000:9000 -p 9001:9001 \
     -e MINIO_ROOT_USER=minioadmin \
     -e MINIO_ROOT_PASSWORD=minioadmin \
     minio/minio server /data --console-address ":9001"
   
   # Create bucket: http://localhost:9001 → Create Bucket → "khetopedia-images"
   ```
6. **Environment Variables:** Link to `.env.example` with explanations
7. **Testing:** `pytest tests/ -v --cov=app`
8. **CLI Commands:** Document all `app.cli` commands

**Verify:** Follow README from scratch on fresh system - backend starts successfully

---

## Configuration Requirements

### Environment Variables Summary

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | `sqlite+aiosqlite:///./khetopedia.db` | Database connection string |
| `DB_POOL_SIZE` | No | `10` | PostgreSQL connection pool size |
| `DB_MAX_OVERFLOW` | No | `20` | Max connections beyond pool |
| `DB_POOL_RECYCLE` | No | `3600` | Recycle connections after N seconds |
| `REDIS_URL` | No | `redis://localhost:6379/0` | Redis connection string |
| `USE_REDIS` | No | `false` | Enable Redis features |
| `S3_ACCESS_KEY_ID` | Conditional | - | Required if `USE_S3=true` |
| `S3_SECRET_ACCESS_KEY` | Conditional | - | Required if `USE_S3=true` |
| `S3_BUCKET_NAME` | No | `khetopedia-images` | S3 bucket name |
| `USE_S3` | No | `false` | Enable S3 storage |
| `WEATHER_API_KEY` | Conditional | - | Required if `USE_MOCK_WEATHER=false` |
| `USE_MOCK_WEATHER` | No | `true` | Use stub weather data |

### Development vs Production Configuration

**Development (default):**
- SQLite database (no setup required)
- No Redis (rate limiting disabled, caching disabled)
- Filesystem storage in `backend/uploads/` (no S3)
- Mock weather data (no API key needed)

**Production:**
- PostgreSQL with connection pooling
- Redis for rate limiting, caching, token blocklist
- S3 or MinIO for image storage
- OpenWeatherMap API with caching

### Infrastructure Dependencies

**Required Services (Production):**
1. PostgreSQL 15+ server
2. Redis 7+ server
3. S3-compatible object storage (AWS S3, MinIO, DigitalOcean Spaces, etc.)
4. OpenWeatherMap API account (free tier: 1000 calls/day)

**Optional (Development):**
- All features work without external services
- Use SQLite, no Redis, filesystem storage, mock weather

---

## Implementation Order

### Phase 1: Database Infrastructure (Steps 1-4)
**Estimated Time:** 4-6 hours  
**Blockers:** None  
**Deliverable:** Alembic migrations working, PostgreSQL support, CLI tools

### Phase 2: Object Storage (Steps 5-9)
**Estimated Time:** 6-8 hours  
**Blockers:** None  
**Deliverable:** Image uploads to S3/filesystem, validation, integrated with crop/soil endpoints

### Phase 3: Redis Integration (Steps 10-14)
**Estimated Time:** 6-8 hours  
**Blockers:** None  
**Deliverable:** Rate limiting, JWT blocklist, weather + dashboard caching

### Phase 4: Weather API (Steps 15-17)
**Estimated Time:** 4-5 hours  
**Blockers:** Phase 3 (needs Redis caching)  
**Deliverable:** Real weather data in dashboard

### Phase 5: Testing & Documentation (Steps 18-20)
**Estimated Time:** 6-8 hours  
**Blockers:** All previous phases  
**Deliverable:** 80%+ test coverage, complete documentation

**Total Estimated Time:** 26-35 hours

---

## Verification Checklist

After completing all steps, verify the following:

### Database
- [ ] `alembic upgrade head` creates all tables in PostgreSQL
- [ ] `alembic current` shows latest migration
- [ ] `python -m app.cli db seed` populates sample data
- [ ] Connection pool logs show 10 permanent connections
- [ ] No "connection refused" or "too many connections" errors under load

### Object Storage
- [ ] POST `/v1/crop-scans` with JPEG → database has S3 URL or filesystem path
- [ ] Invalid MIME type (PDF) → 400 error with message
- [ ] 15MB image → 400 error with size limit message
- [ ] Images visible in S3 bucket or `uploads/` directory
- [ ] Randomized filenames (no predictable patterns)

### Redis
- [ ] 11th login attempt in 1 hour → 429 error
- [ ] Logout invalidates token → 401 on subsequent requests
- [ ] Dashboard summary cached → second call bypasses database (check logs)
- [ ] Update field → cache invalidated → fresh data returned
- [ ] Redis server stopped → graceful fallback (warnings logged, features disabled)

### Weather
- [ ] GET `/v1/weather` with valid coords → current weather for that location
- [ ] Response includes `last_updated` timestamp
- [ ] Second call within 30 min → served from cache (check logs: no external API call)
- [ ] Invalid API key → mock data returned with advisory
- [ ] Dashboard summary includes weather card

### Tests
- [ ] `pytest tests/` → all tests pass
- [ ] Coverage ≥ 80% for new code
- [ ] Tests run in CI pipeline (if configured)

### Documentation
- [ ] `.env.example` has all variables documented
- [ ] README has setup instructions for PostgreSQL, Redis, MinIO
- [ ] Inline code comments explain Redis key patterns, cache TTLs

---

## Risk Mitigation

### Potential Issues

1. **PostgreSQL Connection Pool Exhaustion**
   - **Symptom:** "connection pool timeout" errors under high load
   - **Mitigation:** Tune `DB_POOL_SIZE` and `DB_MAX_OVERFLOW` based on load testing
   - **Monitoring:** Log active connections, set CloudWatch/Prometheus alerts

2. **Redis Single Point of Failure**
   - **Symptom:** Redis server down → rate limiting disabled, caching disabled, logout broken
   - **Mitigation:** All Redis operations have fallback behavior (log warning, continue without Redis)
   - **Production:** Use Redis Sentinel or Cluster for HA

3. **S3 Upload Failures**
   - **Symptom:** Network errors, credential errors, bucket permission errors
   - **Mitigation:** Retry logic with exponential backoff (3 attempts), fallback to filesystem if S3 unavailable
   - **Monitoring:** Log all S3 errors, alert on sustained failure rate

4. **Weather API Rate Limits**
   - **Symptom:** 429 errors from OpenWeatherMap (1000 calls/day limit on free tier)
   - **Mitigation:** 30-minute cache TTL reduces calls, round coordinates to 2 decimals (reduces unique keys)
   - **Fallback:** Serve cached data even if expired, return mock data if no cache

5. **Alembic Migration Conflicts**
   - **Symptom:** Multiple developers create migrations simultaneously → merge conflicts
   - **Mitigation:** Use migration naming convention with timestamps, run `alembic merge` to resolve heads
   - **Prevention:** Coordinate migrations in team, squash migrations before production deploy

### Rollback Plan

If deployment fails:
1. **Database:** `alembic downgrade -1` (revert last migration)
2. **S3:** Images persist (no data loss), update code to use old paths
3. **Redis:** Disable with `USE_REDIS=false` (graceful degradation)
4. **Weather:** Enable mock with `USE_MOCK_WEATHER=true`

---

## Success Criteria

**Stage 2 (Backend Infrastructure) is complete when:**

1. ✅ Alembic migrations working (init, autogenerate, upgrade, downgrade)
2. ✅ PostgreSQL connection pool configured and tested
3. ✅ S3 or MinIO image uploads functional with validation
4. ✅ Redis rate limiting, caching, and token blocklist operational
5. ✅ Real weather API integrated with caching
6. ✅ All integration tests passing (≥80% coverage)
7. ✅ `.env.example` and README documentation complete
8. ✅ Backend starts successfully with both SQLite (dev) and PostgreSQL (prod) configurations

---

## Next Steps (Post-Implementation)

After completing this plan:

1. **Stage 3: Dashboard Completion**
   - Fix `DashboardNotifier` type error
   - Add field selector dropdown
   - Verify weather card displays real data

2. **Stage 4: Crop AI Scanner**
   - Implement ML service (PyTorch/TensorFlow model integration)
   - Add async job queue (Celery + Redis or FastAPI BackgroundTasks)
   - Build camera capture flow in Flutter

3. **Stage 5: Soil Analysis UI**
   - Implement manual entry form
   - Add toxicity level indicators
   - Build historical charts with fl_chart

4. **Production Deployment:**
   - Set up Docker containers (backend, PostgreSQL, Redis, MinIO)
   - Configure CI/CD pipeline (GitHub Actions or GitLab CI)
   - Set up monitoring (Sentry for errors, Prometheus for metrics)
   - Enable HTTPS with TLS certificates (Let's Encrypt or AWS ACM)

---

## Notes for Implementation

- All Redis operations must check if Redis is enabled (`if get_redis()`) and have fallback behavior
- All S3 operations must handle credential errors gracefully (log error, fallback to filesystem)
- All external API calls must have timeout (10s connect, 30s read) and retry logic (3 attempts)
- All database operations use parameterized queries (SQLAlchemy ORM prevents SQL injection)
- All file uploads must validate MIME type with `python-magic`, not just extension
- All cache keys must include version prefix for cache invalidation on schema changes: `v1:weather:{lat}:{lon}`
- All datetime objects must use UTC timezone (`datetime.now(timezone.utc)`)
- All user-facing error messages must not leak implementation details (no stack traces, no table names)

---

**End of Plan**
