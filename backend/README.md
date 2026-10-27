# Khetopedia Backend API

FastAPI-based backend for Khetopedia AI-powered agriculture platform.

## Features

- ✅ **Database Migrations**: Alembic for schema version control
- ✅ **PostgreSQL Support**: Connection pooling and async operations
- ✅ **Redis Integration**: Caching, rate limiting, JWT token blocklist
- ✅ **S3-Compatible Storage**: Image uploads to AWS S3 or MinIO
- ✅ **Weather API**: OpenWeatherMap integration with caching
- ✅ **Authentication**: JWT tokens with secure logout
- ✅ **Image Validation**: MIME type checking and size limits
- ✅ **ML Service**: Crop disease detection using PyTorch with prediction caching

## Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 15+ (optional, SQLite works for dev)
- Redis 7+ (optional)
- S3 or MinIO (optional)

### Installation

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

Server will run at http://localhost:8000
- API docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Configuration

### Environment Variables

Create `.env` file from `.env.example`:

```bash
# Database
DATABASE_URL=sqlite+aiosqlite:///./khetopedia.db
# For PostgreSQL: postgresql+asyncpg://user:password@localhost:5432/khetopedia
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=20

# Redis (optional)
REDIS_URL=redis://localhost:6379/0
USE_REDIS=false

# S3 Storage (optional)
S3_ACCESS_KEY_ID=your_key
S3_SECRET_ACCESS_KEY=your_secret
S3_BUCKET_NAME=khetopedia-images
USE_S3=false

# Weather API
WEATHER_API_KEY=your_openweathermap_api_key
USE_MOCK_WEATHER=true  # Set false to use real API
```

### Development vs Production

**Development (default)**:
- SQLite database (zero setup)
- No Redis required
- Filesystem storage for images
- Mock weather data

**Production**:
- PostgreSQL with connection pooling
- Redis for caching and rate limiting
- S3 for image storage
- Real weather API

## Database Management

### Alembic Migrations

```bash
# Create new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Check current migration
alembic current
```

### CLI Commands

```bash
# Initialize database
python -m app.cli db init

# Seed sample data
python -m app.cli db seed

# Reset database (dev only)
python -m app.cli db reset

# Create migration
python -m app.cli db migrate --message "add new column"
```

## PostgreSQL Setup

```sql
CREATE DATABASE khetopedia;
CREATE USER khetopedia_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE khetopedia TO khetopedia_user;
```

Update `.env`:
```
DATABASE_URL=postgresql+asyncpg://khetopedia_user:your_password@localhost:5432/khetopedia
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=20
DB_POOL_RECYCLE=3600
DB_POOL_PRE_PING=true
```

## Redis Setup

### Ubuntu/Debian
```bash
sudo apt install redis-server
sudo systemctl start redis
```

### macOS
```bash
brew install redis
brew services start redis
```

### Windows
Download from https://github.com/microsoftarchive/redis/releases

Update `.env`:
```
REDIS_URL=redis://localhost:6379/0
USE_REDIS=true
```

## MinIO Setup (S3-compatible self-hosted)

```bash
# Using Docker
docker run -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"
```

1. Open http://localhost:9001
2. Login with minioadmin/minioadmin
3. Create bucket: `khetopedia-images`
4. Create access key

Update `.env`:
```
S3_ENDPOINT_URL=http://localhost:9000
S3_ACCESS_KEY_ID=your_access_key
S3_SECRET_ACCESS_KEY=your_secret_key
S3_BUCKET_NAME=khetopedia-images
USE_S3=true
```

## Weather API Setup

1. Sign up at https://openweathermap.org/api
2. Get free API key (1000 calls/day)
3. Update `.env`:

```
WEATHER_API_KEY=your_api_key
USE_MOCK_WEATHER=false
WEATHER_CACHE_TTL=1800  # 30 minutes
```

## Testing

```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# Run specific test file
pytest tests/test_weather.py -v
```

## Architecture

### Directory Structure

```
backend/
├── alembic/              # Database migrations
│   ├── versions/         # Migration files
│   └── env.py           # Alembic async configuration
├── app/
│   ├── api/             # API routes
│   │   └── v1/
│   │       └── endpoints/
│   ├── core/            # Configuration and database
│   │   ├── config.py    # Settings
│   │   ├── database.py  # SQLAlchemy setup
│   │   ├── redis.py     # Redis connection
│   │   └── security.py  # JWT and password hashing
│   ├── models/          # SQLAlchemy models
│   ├── schemas/         # Pydantic schemas
│   ├── services/        # Business logic
│   │   ├── storage_service.py      # S3/filesystem
│   │   ├── image_service.py        # Image validation
│   │   ├── weather_service.py      # Weather API
│   │   ├── cache_service.py        # Redis caching
│   │   └── token_blocklist_service.py
│   ├── middleware/      # Custom middleware
│   └── cli.py           # Database CLI
├── tests/               # Unit and integration tests
├── .env.example         # Environment template
├── alembic.ini          # Alembic configuration
└── pyproject.toml       # Dependencies
```

### Database Models

- **users**: User accounts and authentication
- **fields**: Farm fields with location and crop data
- **alerts**: Notifications for farmers
- **crop_scans**: AI crop health analysis results
- **soil_tests**: Soil test results with lab images
- **recommendations**: AI-generated recommendations
- **sensor_devices**: IoT sensor registrations
- **sensor_readings**: Time-series sensor data
- **farms**: Farm management
- **profiles**: User profile data
- **ai_conversations**: AI assistant chat history
- **password_reset_tokens**: OTP tokens for password reset

### Services

**storage_service.py**: Abstract storage interface
- S3 backend (AWS S3, MinIO, DigitalOcean Spaces)
- Filesystem backend (development)
- UUID-based randomized filenames
- Directory sharding by user ID

**image_service.py**: Image validation and upload
- MIME type detection with python-magic
- Size limits: 5KB - 10MB
- Allowed types: JPEG, PNG, WebP
- Automatic extension detection

**weather_service.py**: Weather data integration
- OpenWeatherMap API client
- Redis caching (30-minute TTL)
- Agricultural advisories
- Graceful fallback to mock data

**cache_service.py**: Redis caching helpers
- JSON serialization
- TTL support
- Graceful fallback if Redis unavailable

**token_blocklist_service.py**: JWT logout
- Token invalidation on logout
- Redis-backed blocklist
- Automatic TTL matching token expiry

### Rate Limiting

Powered by slowapi + Redis:
- Anonymous: 100 requests/hour per IP
- Authenticated: 1000 requests/hour per user
- Login endpoint: 10 attempts/hour per IP
- Password reset: 3 requests/hour per IP
- Crop scan uploads: 20 uploads/hour per user

## ML Service - Crop Disease Detection

The ML service provides AI-powered crop disease detection using PyTorch with pre-trained ResNet50 models.

### Features

- 🧠 **PyTorch-based inference** with CPU/GPU support
- 🎯 **51 crop disease classes** covering major crops (wheat, rice, tomato, potato, cotton, etc.)
- 💾 **Redis-based prediction caching** (7-day TTL, SHA256 keying)
- 📊 **Confidence thresholding** (uncertain predictions marked explicitly)
- 🔄 **Lazy model loading** (loads on first request, not startup)
- 📈 **Image quality validation** (blur detection using Laplacian variance)
- 🌾 **Treatment recommendations** with agronomic advice from knowledge base
- ⚡ **Batch processing support** for future scaling

### Supported Crops & Diseases

**Crops**: Apple, Blueberry, Cherry, Corn/Maize, Grape, Orange, Peach, Pepper, Potato, Raspberry, Rice, Soybean, Squash, Strawberry, Tomato, Wheat, Cotton, Sugarcane, Mango

**Disease Examples**:
- Tomato: Late blight, Early blight, Bacterial spot, Leaf mold, Septoria, Spider mites, Yellow leaf curl virus
- Wheat: Yellow rust, Brown rust
- Rice: Bacterial leaf blight, Brown spot, Leaf blast
- Potato: Early blight, Late blight
- Cotton: Leaf curl virus

See `app/ml/model_wrapper.py` for complete disease list.

### Configuration

Add to `.env`:

```bash
# ML Service Configuration
ML_MODEL_PATH=app/ml/models/crop_disease_resnet50_v1.pth
ML_MODEL_VERSION=v1
ML_DEVICE=cpu  # or "cuda" for GPU
ML_CONFIDENCE_THRESHOLD=0.65  # Min confidence for positive diagnosis
ML_BATCH_SIZE=8  # Batch size for inference
ML_CACHE_TTL=604800  # 7 days in seconds
ML_BATCH_WAIT_MS=50  # Batching wait time (0 to disable)
```

### Development Mode (Default)

No additional setup required! The service automatically uses a pre-trained ResNet50 from torchvision as a placeholder:

```bash
# Install dependencies (includes torch, torchvision)
pip install -e .

# Start server - ML service loads on first crop scan request
uvicorn app.main:app --reload

# Check ML service health
curl http://localhost:8000/v1/ai/ml/health
```

**Response**:
```json
{
  "status": "ready",
  "model_version": "v1",
  "device": "cpu",
  "classes_count": 51,
  "is_placeholder": true
}
```

### Production Mode (Custom Model)

For production deployment with a trained crop disease model:

1. **Train or download** a custom PyTorch model (see `app/ml/models/README.md` for training guide)
2. **Place model file** in `backend/app/ml/models/` directory:
   ```bash
   # Example model file
   backend/app/ml/models/crop_disease_resnet50_v1.pth
   ```
3. **Update configuration** in `.env`:
   ```bash
   ML_MODEL_PATH=app/ml/models/crop_disease_resnet50_v1.pth
   ML_MODEL_VERSION=v1
   ```
4. **Restart server** - model loads automatically on first prediction request

**Model Requirements**:
- Format: PyTorch state_dict (`.pth` file)
- Input: 224×224 RGB images, ImageNet normalized
- Output: Logits for 51 disease classes
- Architecture: ResNet50, EfficientNet, or Vision Transformer

### GPU Support

For faster inference with CUDA GPU:

```bash
# Install PyTorch with CUDA support
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# Update .env
ML_DEVICE=cuda
```

**Performance**: ~50-100ms per image (GPU) vs ~200-500ms (CPU)

### API Usage

The ML service integrates automatically with the crop scan endpoint:

```bash
# Upload crop image for disease detection
curl -X POST http://localhost:8000/v1/crop-scanner/scan \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@crop_leaf.jpg" \
  -F "crop_hint=tomato"
```

**Response**:
```json
{
  "id": "uuid",
  "crop_identified": "Tomato",
  "crop_confidence": 0.94,
  "disease_name": "Tomato___Late_blight",
  "disease_confidence": 0.87,
  "severity": "severe",
  "symptoms_observed": "Water-soaked irregular lesions...",
  "recommended_treatment": "Apply Cymoxanil + Mancozeb...",
  "preventive_measures": "Space plants for air circulation...",
  "image_quality_score": 0.89,
  "created_at": "2026-10-27T10:30:00Z"
}
```

### Caching Behavior

Predictions are cached in Redis by image content hash (SHA256):

- **Cache Hit**: Instant response (~10ms), no model inference
- **Cache Miss**: Full inference (~200-500ms CPU), result cached for 7 days
- **Identical Images**: Same image always returns cached result
- **Graceful Fallback**: Works without Redis (caching disabled)

### Error Handling

The service handles errors gracefully:

| Error Type | Behavior |
|------------|----------|
| Model file not found | Falls back to placeholder ResNet50 (dev mode) |
| CUDA out of memory | Automatic fallback to CPU |
| Corrupt image | Returns structured error with actionable message |
| Low confidence (<65%) | Marks prediction as "Uncertain - Multiple Possibilities" |
| Inference timeout | Cancels and returns timeout error |

### Monitoring

Check inference logs for performance monitoring:

```bash
# View inference logs
tail -f logs/app.log | grep "ML analysis"

# Example output:
# INFO: ML analysis completed: Tomato___Late_blight (87%, inference: 245ms)
```

### Troubleshooting

**"Model file not found" warning**:
- Expected in development mode
- Service uses placeholder ResNet50 automatically
- For production, download/train custom model and place in `app/ml/models/`

**Slow inference (>1000ms)**:
- Switch to GPU with `ML_DEVICE=cuda` (requires CUDA-enabled PyTorch)
- Reduce batch size: `ML_BATCH_SIZE=4` or `ML_BATCH_SIZE=1`
- Enable Redis caching to avoid repeated inference

**Low confidence predictions**:
- Check image quality (ensure sharp, well-lit photos focused on affected leaves)
- Verify model was trained on similar crop varieties
- Consider fine-tuning with local field images

**Memory errors**:
- Reduce batch size in config
- Use CPU instead of GPU: `ML_DEVICE=cpu`
- Close other memory-intensive applications

### Files Structure

```
backend/app/ml/
├── __init__.py
├── model_wrapper.py         # PyTorch model loading & inference
├── preprocessing.py         # Image preprocessing pipeline
├── disease_knowledge.py     # Treatment recommendations database
├── models/                  # Model weights directory
│   ├── README.md           # Model setup guide
│   └── .gitkeep
└── services/ml_service.py   # Main ML service with caching
```

### Testing

```bash
# Run ML service tests
pytest tests/test_ml_service.py -v

# Test with coverage
pytest tests/test_ml_service.py --cov=app.ml --cov=app.services.ml_service

# Quick smoke test
python -c "from app.ml.model_wrapper import CropDiseaseModel; \
           m = CropDiseaseModel('dummy.pth', 'cpu'); \
           print(f'Model loaded: {len(m.get_disease_classes())} classes')"
```

### Training Custom Models

See detailed guide in `app/ml/models/README.md` covering:
- Dataset preparation (PlantVillage, custom field data)
- PyTorch training loop
- Model architecture recommendations
- Versioning and deployment strategy
- Git LFS setup for large model files

## API Endpoints

### Authentication
- `POST /v1/auth/register` - Create account
- `POST /v1/auth/login` - Login with email/password
- `POST /v1/auth/logout` - Logout and invalidate token
- `POST /v1/auth/forgot-password` - Request OTP
- `POST /v1/auth/reset-password` - Reset with OTP

### Dashboard
- `GET /v1/dashboard/summary` - Dashboard overview (cached)
- `GET /v1/fields` - List user's fields
- `POST /v1/fields` - Create new field
- `GET /v1/alerts` - List alerts

### Crop Health
- `POST /v1/crop-scans` - Upload crop image for AI analysis
- `GET /v1/crop-scans` - List scan history

### Soil Analysis
- `POST /v1/soil/tests` - Submit soil test results (with optional lab image)
- `GET /v1/soil/tests` - List soil tests

### Weather
- `GET /v1/weather` - Current weather + forecast

### Sensors
- `POST /v1/sensors/devices` - Register IoT sensor
- `POST /v1/sensors/readings` - Submit sensor data

## Security

- JWT authentication with RS256
- Argon2 password hashing
- Token blocklist for secure logout
- Rate limiting to prevent abuse
- Input validation with Pydantic
- SQL injection protection (SQLAlchemy)
- CORS configuration

## Production Deployment

### Docker Compose Example

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: khetopedia
      POSTGRES_USER: khetopedia
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secure_password
    volumes:
      - minio_data:/data

  backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql+asyncpg://khetopedia:secure_password@postgres:5432/khetopedia
      REDIS_URL: redis://redis:6379/0
      USE_REDIS: "true"
      S3_ENDPOINT_URL: http://minio:9000
      S3_ACCESS_KEY_ID: admin
      S3_SECRET_ACCESS_KEY: secure_password
      USE_S3: "true"
      WEATHER_API_KEY: ${WEATHER_API_KEY}
      USE_MOCK_WEATHER: "false"
    depends_on:
      - postgres
      - redis
      - minio

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

### Environment Checklist

Production environment must have:
- [ ] `SECRET_KEY` changed from default
- [ ] PostgreSQL connection pooling configured
- [ ] Redis enabled for caching and rate limiting
- [ ] S3 configured for image storage
- [ ] Weather API key configured
- [ ] CORS origins restricted to frontend domain
- [ ] HTTPS/TLS enabled
- [ ] Database backups configured

## Monitoring

### Health Check

```bash
curl http://localhost:8000/health
```

Response:
```json
{
  "status": "healthy",
  "service": "Khetopedia API",
  "version": "1.0.0"
}
```

### Logs

Backend logs startup configuration:
```
[DB] PostgreSQL pool initialized with size=10, max_overflow=20
[Redis] Connected to redis://localhost:6379/0
[Storage] Using S3 backend (bucket: khetopedia-images)
```

## Troubleshooting

### Database connection fails
- Check `DATABASE_URL` format
- Verify PostgreSQL is running
- Check network connectivity and firewall
- Test with: `psql -U khetopedia_user -d khetopedia -h localhost`

### Redis connection fails
- Check `REDIS_URL`
- Verify Redis is running: `redis-cli ping`
- If not critical, set `USE_REDIS=false`

### S3 upload fails
- Verify credentials: `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`
- Check bucket exists and is accessible
- Test MinIO console: http://localhost:9001
- Fallback: Set `USE_S3=false` to use filesystem

### Weather API returns mock data
- Check `WEATHER_API_KEY` is set
- Verify key is valid at https://openweathermap.org
- Set `USE_MOCK_WEATHER=false`
- Check rate limits (1000 calls/day on free tier)

## Support

- Documentation: `/docs`
- Issues: Create GitHub issue
- Email: support@khetopedia.com
