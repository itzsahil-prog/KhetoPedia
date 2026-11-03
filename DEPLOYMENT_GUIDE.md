# Khetopedia Deployment Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Database Setup (PostgreSQL)](#database-setup-postgresql)
4. [Redis Setup](#redis-setup)
5. [S3 Storage Setup](#s3-storage-setup)
6. [Backend Deployment](#backend-deployment)
7. [Frontend Deployment](#frontend-deployment)
8. [ML Model Setup](#ml-model-setup)
9. [Monitoring & Logging](#monitoring--logging)
10. [Production Checklist](#production-checklist)

---

## Prerequisites

### Required Software
- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Flutter 3.10+
- Docker & Docker Compose (recommended)
- Git

### Required API Keys
- OpenWeatherMap API key
- OpenAI API key (or Anthropic)
- AWS S3 credentials (or compatible service)
- Firebase credentials (for Flutter)

---

## Environment Setup

### 1. Clone and Navigate to Project
```bash
cd f:\khetopedia
```

### 2. Backend Environment Variables
Create `backend/.env`:

```bash
# Database
DATABASE_URL=postgresql://khetopedia_user:secure_password@localhost:5432/khetopedia_db

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-super-secret-key-min-32-chars
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# S3 Storage
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
S3_BUCKET_NAME=khetopedia-assets

# External APIs
OPENWEATHER_API_KEY=your_openweather_api_key
OPENAI_API_KEY=your_openai_api_key

# CORS
CORS_ORIGINS=["http://localhost:3000","https://yourdomain.com"]

# Environment
ENVIRONMENT=production
DEBUG=false
```

### 3. Frontend Environment Variables
Create `lib/config/environment.dart`:

```dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
  
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:8000/ws',
  );
  
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
}
```

---

## Database Setup (PostgreSQL)

### Option 1: Local PostgreSQL Installation

#### Windows
```powershell
# Install PostgreSQL
winget install PostgreSQL.PostgreSQL

# Start PostgreSQL service
Start-Service postgresql-x64-15

# Create database and user
psql -U postgres
```

```sql
CREATE DATABASE khetopedia_db;
CREATE USER khetopedia_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE khetopedia_db TO khetopedia_user;
\q
```

#### Linux/macOS
```bash
# Install PostgreSQL
sudo apt install postgresql  # Ubuntu/Debian
brew install postgresql      # macOS

# Start service
sudo systemctl start postgresql  # Linux
brew services start postgresql   # macOS

# Create database
sudo -u postgres psql
```

```sql
CREATE DATABASE khetopedia_db;
CREATE USER khetopedia_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE khetopedia_db TO khetopedia_user;
\q
```

### Option 2: Docker PostgreSQL

Create `backend/docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: khetopedia_postgres
    environment:
      POSTGRES_DB: khetopedia_db
      POSTGRES_USER: khetopedia_user
      POSTGRES_PASSWORD: secure_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: khetopedia_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

Start services:
```bash
cd backend
docker-compose up -d
```

### Run Migrations

```bash
cd backend

# Activate virtual environment
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # Linux/macOS

# Run migrations
alembic upgrade head

# Verify migrations
alembic current
```

### Create Initial Admin User

Create `backend/scripts/create_admin.py`:

```python
import asyncio
from app.core.database import get_db
from app.services.auth_service import AuthService
from app.schemas.auth import UserRegister

async def create_admin():
    async for db in get_db():
        auth_service = AuthService(db)
        
        admin_data = UserRegister(
            email="admin@khetopedia.com",
            password="Admin@12345",
            full_name="Admin User",
            phone_number="+919999999999",
            language_preference="en"
        )
        
        user = await auth_service.register_user(admin_data)
        print(f"Admin user created: {user.email}")
        break

if __name__ == "__main__":
    asyncio.run(create_admin())
```

Run:
```bash
python scripts/create_admin.py
```

---

## Redis Setup

### Option 1: Local Redis Installation

#### Windows
```powershell
# Install Redis via WSL or Windows port
# Download from: https://github.com/microsoftarchive/redis/releases
# Or use WSL:
wsl --install
wsl
sudo apt update
sudo apt install redis-server
sudo service redis-server start
```

#### Linux
```bash
sudo apt install redis-server
sudo systemctl start redis
sudo systemctl enable redis
```

#### macOS
```bash
brew install redis
brew services start redis
```

### Option 2: Docker Redis (Already in docker-compose.yml above)

### Test Redis Connection
```bash
redis-cli ping
# Should return: PONG
```

---

## S3 Storage Setup

### Option 1: AWS S3

1. **Create S3 Bucket**
   - Go to AWS Console → S3
   - Create bucket: `khetopedia-assets`
   - Enable versioning
   - Configure CORS:

```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedOrigins": ["*"],
    "ExposeHeaders": ["ETag"]
  }
]
```

2. **Create IAM User**
   - Go to IAM → Users → Add user
   - Attach policy: `AmazonS3FullAccess` (or custom policy)
   - Save Access Key ID and Secret Access Key

3. **Set Lifecycle Rules** (Optional)
   - Transition to Glacier after 90 days
   - Delete after 365 days

### Option 2: MinIO (Self-hosted S3-compatible)

Add to `docker-compose.yml`:

```yaml
  minio:
    image: minio/minio
    container_name: khetopedia_minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    restart: unless-stopped

volumes:
  minio_data:
```

Update `.env`:
```bash
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_ENDPOINT_URL=http://localhost:9000
S3_BUCKET_NAME=khetopedia-assets
```

Create bucket:
```bash
# Install MinIO client
wget https://dl.min.io/client/mc/release/windows-amd64/mc.exe

# Configure
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Create bucket
mc mb myminio/khetopedia-assets
```

---

## Backend Deployment

### Development Mode

```bash
cd backend
.venv\Scripts\activate  # Windows

# Install dependencies
uv pip install -e .

# Run with auto-reload
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Production Mode (Gunicorn + Uvicorn Workers)

Install production dependencies:
```bash
uv pip install gunicorn
```

Create `backend/gunicorn_conf.py`:

```python
import multiprocessing

# Server socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 50
timeout = 120
keepalive = 5

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = "khetopedia"

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# SSL (if needed)
# keyfile = "/path/to/key.pem"
# certfile = "/path/to/cert.pem"
```

Run production server:
```bash
gunicorn app.main:app -c gunicorn_conf.py
```

### Systemd Service (Linux)

Create `/etc/systemd/system/khetopedia-backend.service`:

```ini
[Unit]
Description=Khetopedia Backend API
After=network.target postgresql.service redis.service

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/khetopedia/backend
Environment="PATH=/var/www/khetopedia/backend/.venv/bin"
ExecStart=/var/www/khetopedia/backend/.venv/bin/gunicorn app.main:app -c gunicorn_conf.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable khetopedia-backend
sudo systemctl start khetopedia-backend
sudo systemctl status khetopedia-backend
```

### Docker Deployment

Create `backend/Dockerfile`:

```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv pip install --system -e .

# Copy application
COPY app ./app
COPY alembic ./alembic
COPY alembic.ini ./

# Expose port
EXPOSE 8000

# Run migrations and start server
CMD ["sh", "-c", "alembic upgrade head && gunicorn app.main:app -c gunicorn_conf.py"]
```

Build and run:
```bash
docker build -t khetopedia-backend .
docker run -p 8000:8000 --env-file .env khetopedia-backend
```

---

## Frontend Deployment

### Development Mode

```bash
flutter pub get
flutter run
```

### Build for Production

#### Android APK
```bash
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release

# Open in Xcode:
open ios/Runner.xcworkspace
```

#### Web
```bash
flutter build web --release

# Output: build/web/
```

### Configure API Endpoint

Build with production API:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.khetopedia.com/api/v1 --dart-define=PRODUCTION=true
```

### Deploy Web Version

1. **Static Hosting (Netlify/Vercel)**
   ```bash
   flutter build web --release
   
   # Deploy build/web/ folder
   netlify deploy --prod --dir=build/web
   ```

2. **Nginx Configuration**
   ```nginx
   server {
       listen 80;
       server_name khetopedia.com;
       
       root /var/www/khetopedia/web;
       index index.html;
       
       location / {
           try_files $uri $uri/ /index.html;
       }
       
       location /api/ {
           proxy_pass http://localhost:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

### App Store Deployment

#### Google Play Store
1. Create keystore:
   ```bash
   keytool -genkey -v -keystore khetopedia.jks -keyalg RSA -keysize 2048 -validity 10000 -alias khetopedia
   ```

2. Configure `android/key.properties`:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=khetopedia
   storeFile=../khetopedia.jks
   ```

3. Update `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   
   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. Build and upload:
   ```bash
   flutter build appbundle --release
   # Upload to Play Console
   ```

#### Apple App Store
1. Configure signing in Xcode
2. Build archive
3. Upload via Xcode or Transporter

---

## ML Model Setup

### Download Pre-trained Model

The disease detection model expects a ResNet-50 trained on PlantVillage dataset.

#### Option 1: Train Your Own Model

Create `backend/scripts/train_model.py`:

```python
import torch
import torch.nn as nn
import torchvision
from torchvision import transforms, datasets
from torch.utils.data import DataLoader

def train_model():
    # Data transforms
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    # Load PlantVillage dataset
    train_dataset = datasets.ImageFolder('path/to/plantvillage/train', transform=transform)
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
    
    # Model
    model = torchvision.models.resnet50(pretrained=True)
    num_classes = len(train_dataset.classes)
    model.fc = nn.Linear(model.fc.in_features, num_classes)
    
    # Training
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    
    for epoch in range(10):
        model.train()
        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
        
        print(f'Epoch {epoch+1}, Loss: {loss.item():.4f}')
    
    # Save model
    torch.save(model.state_dict(), 'crop_disease_model.pth')
    torch.save(train_dataset.classes, 'class_names.pth')

if __name__ == '__main__':
    train_model()
```

#### Option 2: Use Pre-trained Model

Download from model zoo or Hugging Face and place in:
```
backend/models/crop_disease_model.pth
backend/models/class_names.pth
```

### Update Model Path

Update `backend/app/services/crop_scanner_service.py`:

```python
MODEL_PATH = Path(__file__).parent.parent.parent / "models" / "crop_disease_model.pth"
CLASS_NAMES_PATH = Path(__file__).parent.parent.parent / "models" / "class_names.pth"
```

---

## Monitoring & Logging

### Application Logging

Update `backend/app/main.py`:

```python
import logging
from logging.handlers import RotatingFileHandler

# Configure logging
log_formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

file_handler = RotatingFileHandler(
    'logs/khetopedia.log',
    maxBytes=10485760,  # 10MB
    backupCount=10
)
file_handler.setFormatter(log_formatter)

logger = logging.getLogger()
logger.addHandler(file_handler)
logger.setLevel(logging.INFO)
```

### Health Check Endpoint

Add to `backend/app/main.py`:

```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "database": await check_database(),
        "redis": await check_redis(),
        "timestamp": datetime.utcnow().isoformat()
    }
```

### Monitoring Tools

1. **Prometheus + Grafana**
   - Add metrics endpoint
   - Track request rates, latency, errors

2. **Sentry** (Error Tracking)
   ```bash
   uv pip install sentry-sdk
   ```
   
   ```python
   import sentry_sdk
   
   sentry_sdk.init(
       dsn="your_sentry_dsn",
       environment="production"
   )
   ```

3. **New Relic / DataDog** (APM)
   - Install agent
   - Monitor performance

---

## Production Checklist

### Security
- [ ] Change all default passwords
- [ ] Generate strong SECRET_KEY (min 32 chars)
- [ ] Enable HTTPS/SSL
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Implement API key rotation
- [ ] Set up firewall rules
- [ ] Enable database encryption at rest
- [ ] Use environment variables (never commit secrets)

### Database
- [ ] Run migrations
- [ ] Set up automated backups
- [ ] Configure connection pooling
- [ ] Create indexes for performance
- [ ] Set up replication (if needed)

### Caching
- [ ] Enable Redis in production
- [ ] Configure cache TTLs
- [ ] Set up Redis persistence

### Storage
- [ ] Configure S3 bucket
- [ ] Set up CDN (CloudFront/Cloudflare)
- [ ] Enable object versioning
- [ ] Configure lifecycle policies

### Backend
- [ ] Set DEBUG=false
- [ ] Configure production CORS
- [ ] Set up process manager (systemd/supervisor)
- [ ] Configure reverse proxy (Nginx/Apache)
- [ ] Enable gzip compression
- [ ] Set up SSL certificate (Let's Encrypt)
- [ ] Configure logging
- [ ] Set up monitoring

### Frontend
- [ ] Build release APK/AAB
- [ ] Configure production API endpoint
- [ ] Test on multiple devices
- [ ] Optimize images and assets
- [ ] Enable ProGuard/R8 (Android)
- [ ] Test offline functionality
- [ ] Verify deep links

### ML Model
- [ ] Download/train disease detection model
- [ ] Place model files in correct location
- [ ] Test predictions
- [ ] Monitor inference performance

### Testing
- [ ] Run all unit tests
- [ ] Run integration tests
- [ ] Perform load testing
- [ ] Test on real devices
- [ ] Test all API endpoints
- [ ] Verify authentication flows

### Documentation
- [ ] API documentation (Swagger/ReDoc)
- [ ] User manual
- [ ] Admin guide
- [ ] Troubleshooting guide

### Monitoring
- [ ] Set up uptime monitoring
- [ ] Configure error tracking (Sentry)
- [ ] Set up log aggregation
- [ ] Create dashboards (Grafana)
- [ ] Set up alerts

### Compliance
- [ ] Privacy policy
- [ ] Terms of service
- [ ] GDPR compliance (if applicable)
- [ ] Data retention policy

---

## Quick Start Commands

### Full Stack Development
```bash
# Terminal 1: Start PostgreSQL + Redis
docker-compose up -d

# Terminal 2: Backend
cd backend
.venv\Scripts\activate
uvicorn app.main:app --reload

# Terminal 3: Frontend
flutter pub get
flutter run
```

### Production Deployment
```bash
# Backend
cd backend
alembic upgrade head
gunicorn app.main:app -c gunicorn_conf.py

# Frontend
flutter build apk --release --dart-define=API_BASE_URL=https://api.khetopedia.com/api/v1
```

---

## Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test connection
psql -U khetopedia_user -d khetopedia_db -h localhost

# Check logs
tail -f /var/log/postgresql/postgresql-15-main.log
```

### Redis Connection Issues
```bash
# Check Redis status
redis-cli ping

# Check connections
redis-cli client list

# Monitor commands
redis-cli monitor
```

### Backend Issues
```bash
# Check logs
tail -f logs/khetopedia.log

# Test health endpoint
curl http://localhost:8000/health

# Check running processes
ps aux | grep gunicorn
```

### Flutter Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Check doctor
flutter doctor -v

# Verbose build
flutter build apk --release -v
```

---

## Support & Resources

- **Backend API Docs**: http://localhost:8000/docs
- **Project Repository**: (your repo URL)
- **Issue Tracker**: (your issue tracker)
- **Documentation**: `docs/` folder

---

## Next Steps

1. Set up PostgreSQL and Redis
2. Configure environment variables
3. Run database migrations
4. Download/train ML model
5. Test backend APIs
6. Build and test Flutter app
7. Deploy to staging environment
8. Perform load testing
9. Deploy to production
10. Monitor and maintain

Good luck with your deployment! 🚀
