# Khetopedia Deployment Guide

**Version:** 1.0.0  
**Last Updated:** October 27, 2026  
**Status:** Production Ready

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Backend Deployment](#2-backend-deployment)
3. [Database Setup](#3-database-setup)
4. [Redis Configuration](#4-redis-configuration)
5. [Object Storage Setup](#5-object-storage-setup)
6. [Frontend Deployment](#6-frontend-deployment)
7. [Environment Configuration](#7-environment-configuration)
8. [Database Migrations](#8-database-migrations)
9. [Initial Setup & Seeding](#9-initial-setup--seeding)
10. [Monitoring & Maintenance](#10-monitoring--maintenance)
11. [Troubleshooting](#11-troubleshooting)
12. [Security Checklist](#12-security-checklist)

---

## 1. Prerequisites

### 1.1 System Requirements

**Development Environment:**
- Python 3.11 or higher
- Flutter SDK 3.13.0 or higher
- Dart SDK (included with Flutter)
- Node.js 18+ (optional, for tooling)
- Git

**Production Environment:**
- Ubuntu 22.04 LTS or similar Linux distribution
- 4GB RAM minimum (8GB recommended with ML model)
- 2 CPU cores minimum (4 cores recommended)
- 50GB storage minimum
- HTTPS/TLS certificate (Let's Encrypt recommended)

### 1.2 Required Services

**Essential:**
- PostgreSQL 14+ (production database)
- Redis 7+ (caching and rate limiting)
- S3-compatible object storage (AWS S3, MinIO, DigitalOcean Spaces)

**Optional but Recommended:**
- NGINX or Traefik (load balancer and reverse proxy)
- Sentry (error monitoring)
- Prometheus + Grafana (metrics and monitoring)
- Docker & Docker Compose (containerization)

### 1.3 External API Keys

**Required:**
- OpenWeatherMap API key (free tier available)
- SMTP credentials (for password reset emails)

**Optional:**
- OpenAI API key (for AI assistant)
- Anthropic API key (alternative for AI assistant)
- AWS credentials (for S3 storage)

---

## 2. Backend Deployment

### 2.1 Local Development Setup

**Step 1: Clone Repository**
```bash
git clone <repository-url>
cd khetopedia
```

**Step 2: Create Virtual Environment**
```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

**Step 3: Install Dependencies**
```bash
# Install in editable mode
pip install -e .

# Or install specific dependencies
pip install fastapi uvicorn sqlalchemy asyncpg aiosqlite pyjwt argon2-cffi \
    redis slowapi boto3 torch torchvision pillow httpx alembic pytest
```

**Step 4: Configure Environment**
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your settings
nano .env
```

**Step 5: Run Database Migrations**
```bash
# Ensure PostgreSQL or SQLite is configured
alembic upgrade head
```

**Step 6: Start Development Server**
```bash
# Single worker (development)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# With multiple workers (production-like)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2
```

**Step 7: Verify Installation**
```bash
# Test health endpoint
curl http://localhost:8000/health

# Access API documentation
# Open browser: http://localhost:8000/docs
```

### 2.2 Production Deployment (Systemd)

**Step 1: Create System User**
```bash
sudo useradd -r -s /bin/false khetopedia
```

**Step 2: Install Application**
```bash
sudo mkdir -p /opt/khetopedia
sudo chown khetopedia:khetopedia /opt/khetopedia

# Copy application files
sudo cp -r backend /opt/khetopedia/
sudo chown -R khetopedia:khetopedia /opt/khetopedia

# Create virtual environment
cd /opt/khetopedia/backend
sudo -u khetopedia python3.11 -m venv venv
sudo -u khetopedia venv/bin/pip install -e .
```

**Step 3: Configure Environment**
```bash
sudo cp /opt/khetopedia/backend/.env.example /opt/khetopedia/backend/.env
sudo chown khetopedia:khetopedia /opt/khetopedia/backend/.env
sudo chmod 600 /opt/khetopedia/backend/.env

# Edit environment variables
sudo nano /opt/khetopedia/backend/.env
```

**Step 4: Create Systemd Service**
```bash
sudo nano /etc/systemd/system/khetopedia.service
```

**Service File Content:**
```ini
[Unit]
Description=Khetopedia FastAPI Backend
After=network.target postgresql.service redis.service

[Service]
Type=notify
User=khetopedia
Group=khetopedia
WorkingDirectory=/opt/khetopedia/backend
Environment="PATH=/opt/khetopedia/backend/venv/bin"
ExecStart=/opt/khetopedia/backend/venv/bin/uvicorn \
    app.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --workers 4 \
    --log-config logging.conf

# Restart policy
Restart=always
RestartSec=10

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/khetopedia/backend/uploads

# Resource limits
LimitNOFILE=65536
MemoryMax=2G

[Install]
WantedBy=multi-user.target
```

**Step 5: Start Service**
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service on boot
sudo systemctl enable khetopedia

# Start service
sudo systemctl start khetopedia

# Check status
sudo systemctl status khetopedia

# View logs
sudo journalctl -u khetopedia -f
```

### 2.3 Docker Deployment

**Step 1: Create Dockerfile**
```dockerfile
# File: backend/Dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -s /bin/bash khetopedia

# Set working directory
WORKDIR /app

# Copy requirements
COPY pyproject.toml ./
COPY app ./app

# Install Python dependencies
RUN pip install --no-cache-dir -e .

# Switch to app user
USER khetopedia

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:8000/health')"

# Start application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

**Step 2: Create Docker Compose File**
```yaml
# File: docker-compose.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: khetopedia-backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://khetopedia:${DB_PASSWORD}@postgres:5432/khetopedia
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY}
      - USE_REDIS=true
      - USE_S3=true
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend/uploads:/app/uploads
    networks:
      - khetopedia-network
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    container_name: khetopedia-postgres
    environment:
      - POSTGRES_DB=khetopedia
      - POSTGRES_USER=khetopedia
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - khetopedia-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U khetopedia"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: khetopedia-redis
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - khetopedia-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    container_name: khetopedia-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
    networks:
      - khetopedia-network
    restart: unless-stopped

volumes:
  postgres-data:
  redis-data:

networks:
  khetopedia-network:
    driver: bridge
```

**Step 3: Create Environment File**
```bash
# File: .env
SECRET_KEY=<generate-secure-key>
DB_PASSWORD=<secure-postgres-password>
```

**Step 4: Deploy with Docker Compose**
```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f backend

# Run migrations
docker-compose exec backend alembic upgrade head
```

### 2.4 NGINX Configuration

**Create NGINX Config:**
```nginx
# File: nginx.conf
upstream khetopedia_backend {
    server backend:8000;
}

server {
    listen 80;
    server_name api.khetopedia.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.khetopedia.com;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Client Body Size (for image uploads)
    client_max_body_size 20M;

    # Timeouts
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # Proxy to Backend
    location / {
        proxy_pass http://khetopedia_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files (if any)
    location /static/ {
        alias /opt/khetopedia/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint (bypass proxy for load balancer)
    location /health {
        access_log off;
        proxy_pass http://khetopedia_backend;
    }
}
```

---

## 3. Database Setup

### 3.1 PostgreSQL Installation

**Ubuntu/Debian:**
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**macOS (Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Windows:**
- Download installer from https://www.postgresql.org/download/windows/
- Run installer and follow prompts

### 3.2 Database Creation

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE khetopedia;
CREATE USER khetopedia WITH PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE khetopedia TO khetopedia;

# Exit psql
\q
```

### 3.3 Connection Configuration

**Update .env file:**
```bash
DATABASE_URL=postgresql+asyncpg://khetopedia:your-secure-password@localhost:5432/khetopedia
```

**Connection Pooling Settings:**
```python
# In app/core/database.py (already configured)
SQLALCHEMY_DATABASE_URL = settings.DATABASE_URL

engine = create_async_engine(
    SQLALCHEMY_DATABASE_URL,
    echo=False,
    pool_size=10,          # Number of persistent connections
    max_overflow=20,       # Maximum overflow connections
    pool_pre_ping=True,    # Verify connections before use
    pool_recycle=3600,     # Recycle connections after 1 hour
)
```

### 3.4 Database Backup Strategy

**Automated Backup Script:**
```bash
#!/bin/bash
# File: /opt/khetopedia/scripts/backup.sh

BACKUP_DIR="/opt/khetopedia/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/khetopedia_$TIMESTAMP.sql.gz"

# Create backup
pg_dump -U khetopedia khetopedia | gzip > $BACKUP_FILE

# Remove backups older than 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE"
```

**Setup Cron Job:**
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /opt/khetopedia/scripts/backup.sh >> /var/log/khetopedia-backup.log 2>&1
```

### 3.5 Database Restore

```bash
# Restore from backup
gunzip < backup_file.sql.gz | psql -U khetopedia khetopedia
```

---

## 4. Redis Configuration

### 4.1 Redis Installation

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install redis-server

# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

**macOS (Homebrew):**
```bash
brew install redis
brew services start redis
```

**Windows:**
- Use WSL2 and follow Ubuntu instructions
- Or use Docker: `docker run -d -p 6379:6379 redis:7-alpine`

### 4.2 Redis Configuration

**Edit Redis Config:**
```bash
sudo nano /etc/redis/redis.conf
```

**Recommended Settings:**
```ini
# Bind to localhost only (if backend is on same server)
bind 127.0.0.1

# Require password
requirepass your-redis-password

# Enable persistence (AOF for token blocklist durability)
appendonly yes
appendfilename "appendonly.aof"

# Memory management
maxmemory 2gb
maxmemory-policy allkeys-lru

# Save snapshots
save 900 1
save 300 10
save 60 10000
```

**Restart Redis:**
```bash
sudo systemctl restart redis-server
```

### 4.3 Application Configuration

**Update .env file:**
```bash
USE_REDIS=true
REDIS_URL=redis://:your-redis-password@localhost:6379/0

# Cache TTL settings
CACHE_TTL_WEATHER=1800      # 30 minutes
CACHE_TTL_DASHBOARD=300     # 5 minutes
CACHE_TTL_PREDICTIONS=604800 # 7 days
```

### 4.4 Redis Monitoring

**Check Redis Status:**
```bash
# Connect to Redis CLI
redis-cli -a your-redis-password

# Check info
INFO

# Monitor commands
MONITOR

# Check memory usage
MEMORY STATS

# Exit
EXIT
```

---

## 5. Object Storage Setup

### 5.1 AWS S3 Setup

**Step 1: Create S3 Bucket**
```bash
# Using AWS CLI
aws s3 mb s3://khetopedia-uploads --region us-east-1

# Enable versioning (optional)
aws s3api put-bucket-versioning \
    --bucket khetopedia-uploads \
    --versioning-configuration Status=Enabled
```

**Step 2: Configure Bucket Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::khetopedia-uploads/*"
    }
  ]
}
```

**Step 3: Enable Encryption**
```bash
aws s3api put-bucket-encryption \
    --bucket khetopedia-uploads \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
```

**Step 4: Create IAM User**
```bash
# Create IAM user for application
aws iam create-user --user-name khetopedia-app

# Attach S3 policy
aws iam attach-user-policy \
    --user-name khetopedia-app \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create access key
aws iam create-access-key --user-name khetopedia-app
```

**Step 5: Configure Application**
```bash
# Update .env
USE_S3=true
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=khetopedia-uploads
AWS_REGION=us-east-1
```

### 5.2 MinIO Setup (Self-Hosted Alternative)

**Install MinIO:**
```bash
# Download MinIO
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/

# Create data directory
sudo mkdir -p /opt/minio/data
sudo chown -R khetopedia:khetopedia /opt/minio
```

**Create Systemd Service:**
```ini
[Unit]
Description=MinIO Object Storage
After=network.target

[Service]
Type=notify
User=khetopedia
Group=khetopedia
ExecStart=/usr/local/bin/minio server /opt/minio/data --console-address ":9001"
Environment="MINIO_ROOT_USER=minioadmin"
Environment="MINIO_ROOT_PASSWORD=your-secure-password"
Restart=always

[Install]
WantedBy=multi-user.target
```

**Start MinIO:**
```bash
sudo systemctl daemon-reload
sudo systemctl start minio
sudo systemctl enable minio

# Access console: http://localhost:9001
```

**Configure Application:**
```bash
# Update .env
USE_S3=true
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=your-secure-password
AWS_S3_BUCKET=khetopedia-uploads
AWS_ENDPOINT_URL=http://localhost:9000
```

### 5.3 Filesystem Fallback

**For development or small deployments:**
```bash
# Update .env
USE_S3=false
UPLOAD_DIR=./uploads

# Create upload directory
mkdir -p /opt/khetopedia/backend/uploads
chown khetopedia:khetopedia /opt/khetopedia/backend/uploads
```

**Note:** Filesystem storage is not recommended for production with multiple backend instances.

---

## 6. Frontend Deployment

### 6.1 Development Setup

**Step 1: Install Flutter**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

**Step 2: Install Dependencies**
```bash
cd khetopedia
flutter pub get
```

**Step 3: Run Development Build**
```bash
# Android emulator
flutter run

# iOS simulator (macOS only)
flutter run -d ios

# Web (for testing)
flutter run -d chrome
```

### 6.2 Configure Backend URL

**Edit environment configuration:**
```dart
// File: lib(frontend)/core/config/app_config.dart
class AppConfig {
  // Development
  static const String devApiUrl = 'http://localhost:8000';
  
  // Production
  static const String prodApiUrl = 'https://api.khetopedia.com';
  
  // Get current API URL based on build mode
  static String get apiUrl {
    return const bool.fromEnvironment('dart.vm.product')
        ? prodApiUrl
        : devApiUrl;
  }
}
```

### 6.3 Android Build & Release

**Step 1: Configure Signing**
```bash
# Generate keystore
keytool -genkey -v -keystore ~/khetopedia-release-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias khetopedia
```

**Step 2: Configure Gradle**
```groovy
// File: android/app/build.gradle

android {
    ...
    
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
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

**Step 3: Build APK/Bundle**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output location:
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

**Step 4: Upload to Play Store**
1. Create developer account at https://play.google.com/console
2. Create new application
3. Upload app bundle
4. Complete store listing
5. Submit for review

### 6.4 iOS Build & Release

**Step 1: Configure Xcode**
```bash
# Open Xcode project
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner project
# 2. Go to Signing & Capabilities
# 3. Select your development team
# 4. Set bundle identifier
```

**Step 2: Build IPA**
```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode:
# Product -> Archive -> Distribute App
```

**Step 3: Upload to App Store**
1. Create App Store Connect account
2. Create new app
3. Upload IPA via Xcode or Transporter
4. Complete app information
5. Submit for review

### 6.5 Web Deployment (Optional)

**Build Web App:**
```bash
# Build for web
flutter build web --release

# Output: build/web/
```

**Deploy to NGINX:**
```nginx
server {
    listen 80;
    server_name app.khetopedia.com;
    
    root /var/www/khetopedia;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 7. Environment Configuration

### 7.1 Backend Environment Variables

**Complete .env Template:**
```bash
# ═══════════════════════════════════════════════
# KHETOPEDIA BACKEND CONFIGURATION
# ═══════════════════════════════════════════════

# ────────────────────────────────────────────────
# Application Settings
# ────────────────────────────────────────────────
APP_NAME=Khetopedia
APP_VERSION=1.0.0
ENVIRONMENT=production  # development, staging, production
DEBUG=false

# ────────────────────────────────────────────────
# Security (⚠️ CHANGE IN PRODUCTION)
# ────────────────────────────────────────────────
SECRET_KEY=your-secret-key-min-32-characters-long-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440  # 24 hours
REFRESH_TOKEN_EXPIRE_DAYS=30

# ────────────────────────────────────────────────
# Database Configuration
# ────────────────────────────────────────────────
# PostgreSQL (Production - REQUIRED)
DATABASE_URL=postgresql+asyncpg://khetopedia:secure-password@localhost:5432/khetopedia

# SQLite (Development only - NOT for production)
# DATABASE_URL=sqlite+aiosqlite:///./khetopedia.db

# ────────────────────────────────────────────────
# Redis Configuration
# ────────────────────────────────────────────────
USE_REDIS=true
REDIS_URL=redis://:redis-password@localhost:6379/0
CACHE_TTL_WEATHER=1800       # 30 minutes
CACHE_TTL_DASHBOARD=300      # 5 minutes
CACHE_TTL_PREDICTIONS=604800 # 7 days

# ────────────────────────────────────────────────
# CORS Settings
# ────────────────────────────────────────────────
CORS_ORIGINS=["https://app.khetopedia.com","https://api.khetopedia.com"]

# ────────────────────────────────────────────────
# Object Storage (S3/MinIO)
# ────────────────────────────────────────────────
USE_S3=true
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=khetopedia-uploads
AWS_REGION=us-east-1
# AWS_ENDPOINT_URL=http://localhost:9000  # For MinIO

# Filesystem fallback (if USE_S3=false)
UPLOAD_DIR=./uploads

# ────────────────────────────────────────────────
# Weather API
# ────────────────────────────────────────────────
USE_MOCK_WEATHER=false
OPENWEATHER_API_KEY=your-openweather-api-key
WEATHER_CACHE_TTL=1800  # 30 minutes

# ────────────────────────────────────────────────
# AI/LLM Configuration
# ────────────────────────────────────────────────
USE_LLM=true
LLM_PROVIDER=openai  # openai, anthropic
OPENAI_API_KEY=your-openai-api-key
# ANTHROPIC_API_KEY=your-anthropic-api-key

# ────────────────────────────────────────────────
# Email Configuration (SMTP)
# ────────────────────────────────────────────────
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@khetopedia.com
SMTP_FROM_NAME=Khetopedia

# ────────────────────────────────────────────────
# ML Model Configuration
# ────────────────────────────────────────────────
ML_MODEL_PATH=./models/crop_disease_model.pth
ML_MODEL_DEVICE=cpu  # cpu, cuda
ML_CONFIDENCE_THRESHOLD=0.5

# ────────────────────────────────────────────────
# Rate Limiting
# ────────────────────────────────────────────────
RATE_LIMIT_ENABLED=true
RATE_LIMIT_STORAGE=redis  # memory, redis
RATE_LIMIT_DEFAULT=100/minute
RATE_LIMIT_AUTH=10/hour
RATE_LIMIT_SCAN=20/hour

# ────────────────────────────────────────────────
# File Upload Limits
# ────────────────────────────────────────────────
MAX_UPLOAD_SIZE=10485760  # 10 MB in bytes
ALLOWED_IMAGE_TYPES=["image/jpeg","image/png","image/webp"]

# ────────────────────────────────────────────────
# Logging
# ────────────────────────────────────────────────
LOG_LEVEL=INFO  # DEBUG, INFO, WARNING, ERROR, CRITICAL
LOG_FORMAT=json  # text, json
```

### 7.2 Security Best Practices

**Generate Secure SECRET_KEY:**
```python
import secrets
print(secrets.token_urlsafe(32))
```

**Or using OpenSSL:**
```bash
openssl rand -base64 32
```

**Environment Variable Security:**
- Never commit .env files to version control
- Use environment-specific files (.env.production, .env.staging)
- Use secret management tools (AWS Secrets Manager, HashiCorp Vault)
- Rotate secrets regularly (SECRET_KEY, API keys, passwords)

### 7.3 Frontend Configuration

**Update API URL:**
```dart
// File: lib(frontend)/core/config/app_config.dart

class AppConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.khetopedia.com',
  );
  
  // Build with custom API URL:
  // flutter build apk --dart-define=API_URL=https://api.example.com
}
```

---

## 8. Database Migrations

### 8.1 Running Migrations

**Check Current Version:**
```bash
cd backend
alembic current
```

**View Migration History:**
```bash
alembic history --verbose
```

**Upgrade to Latest:**
```bash
alembic upgrade head
```

**Upgrade to Specific Version:**
```bash
alembic upgrade <revision_id>
```

**Downgrade:**
```bash
# Downgrade one version
alembic downgrade -1

# Downgrade to specific version
alembic downgrade <revision_id>

# Downgrade all
alembic downgrade base
```

### 8.2 Creating New Migrations

**Auto-generate Migration:**
```bash
alembic revision --autogenerate -m "Add new table or column"
```

**Manual Migration:**
```bash
alembic revision -m "Description of changes"
```

**Edit Generated Migration:**
```python
# File: backend/alembic/versions/xxx_description.py

from alembic import op
import sqlalchemy as sa

revision = 'xxx'
down_revision = 'yyy'

def upgrade() -> None:
    # Add your upgrade logic
    op.create_table(
        'new_table',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('name', sa.String(100), nullable=False),
    )

def downgrade() -> None:
    # Add your downgrade logic
    op.drop_table('new_table')
```

### 8.3 Migration Best Practices

**Pre-Migration Checklist:**
1. ✅ Backup database before migration
2. ✅ Test migration on staging environment
3. ✅ Review generated SQL
4. ✅ Verify downgrade path works
5. ✅ Check for data loss risks

**Safe Migration Strategies:**
- Add columns as nullable first, then populate, then make NOT NULL
- Create new tables before dropping old ones
- Use transactions for data migrations
- Test with production-sized data sets

---

## 9. Initial Setup & Seeding

### 9.1 Create Admin User

**Option 1: Using Python Script**
```python
# File: backend/scripts/create_admin.py

import asyncio
from app.core.database import get_db_session
from app.core.security import get_password_hash
from app.models.user import User

async def create_admin():
    async for db in get_db_session():
        admin = User(
            email="admin@khetopedia.com",
            name="Admin User",
            hashed_password=get_password_hash("secure-admin-password"),
            is_active=True,
        )
        db.add(admin)
        await db.commit()
        print(f"Admin user created: {admin.email}")

if __name__ == "__main__":
    asyncio.run(create_admin())
```

**Run Script:**
```bash
cd backend
python scripts/create_admin.py
```

**Option 2: Using API**
```bash
curl -X POST http://localhost:8000/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@khetopedia.com",
    "password": "secure-admin-password",
    "name": "Admin User",
    "phone": "+1234567890"
  }'
```

### 9.2 Seed Sample Data (Optional)

**Create Seed Script:**
```python
# File: backend/scripts/seed_data.py

import asyncio
from app.core.database import get_db_session
from app.models.user import User
from app.models.farm import Farm
from app.models.field import Field

async def seed_data():
    async for db in get_db_session():
        # Create test user
        user = User(...)
        db.add(user)
        await db.commit()
        
        # Create test farm
        farm = Farm(user_id=user.id, ...)
        db.add(farm)
        await db.commit()
        
        # Create test fields
        field = Field(farm_id=farm.id, ...)
        db.add(field)
        await db.commit()
        
        print("Sample data seeded successfully")

if __name__ == "__main__":
    asyncio.run(seed_data())
```

### 9.3 Verify Installation

**Health Check:**
```bash
curl http://localhost:8000/health
# Expected: {"status": "healthy"}
```

**API Documentation:**
```bash
# Open in browser
http://localhost:8000/docs
```

**Test Authentication:**
```bash
# Login
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@khetopedia.com",
    "password": "your-password"
  }'

# Expected: {"access_token": "...", "refresh_token": "...", ...}
```

---

## 10. Monitoring & Maintenance

### 10.1 Application Monitoring

**Setup Sentry (Error Tracking):**
```bash
pip install sentry-sdk[fastapi]
```

```python
# File: app/main.py

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,
    environment=settings.ENVIRONMENT,
)
```

**Setup Prometheus (Metrics):**
```bash
pip install prometheus-fastapi-instrumentator
```

```python
# File: app/main.py

from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
Instrumentator().instrument(app).expose(app)

# Metrics available at: /metrics
```

### 10.2 Log Aggregation

**Setup Structured Logging:**
```python
# File: app/core/logging.py

import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
        }
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_data)

# Configure logging
logging.basicConfig(level=logging.INFO)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logging.getLogger().addHandler(handler)
```

**Log Rotation:**
```python
from logging.handlers import RotatingFileHandler

handler = RotatingFileHandler(
    "app.log",
    maxBytes=10485760,  # 10MB
    backupCount=5,
)
```

### 10.3 Performance Monitoring

**Database Query Monitoring:**
```python
# File: app/core/database.py

from sqlalchemy import event
from sqlalchemy.engine import Engine
import time
import logging

logger = logging.getLogger(__name__)

@event.listens_for(Engine, "before_cursor_execute")
def before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    context._query_start_time = time.time()

@event.listens_for(Engine, "after_cursor_execute")
def after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    total = time.time() - context._query_start_time
    if total > 1.0:  # Log slow queries (> 1 second)
        logger.warning(f"Slow query ({total:.2f}s): {statement}")
```

### 10.4 Health Checks

**Enhanced Health Check Endpoint:**
```python
# File: app/api/v1/endpoints/health.py

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from redis import Redis
import httpx

router = APIRouter()

@router.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    health = {
        "status": "healthy",
        "version": settings.APP_VERSION,
        "checks": {}
    }
    
    # Database check
    try:
        await db.execute("SELECT 1")
        health["checks"]["database"] = "healthy"
    except Exception as e:
        health["checks"]["database"] = f"unhealthy: {str(e)}"
        health["status"] = "unhealthy"
    
    # Redis check
    try:
        redis = Redis.from_url(settings.REDIS_URL)
        redis.ping()
        health["checks"]["redis"] = "healthy"
    except Exception as e:
        health["checks"]["redis"] = f"unhealthy: {str(e)}"
    
    # External API check (optional)
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"https://api.openweathermap.org/...")
            health["checks"]["weather_api"] = "healthy"
    except Exception:
        health["checks"]["weather_api"] = "degraded"
    
    return health
```

### 10.5 Maintenance Tasks

**Weekly Tasks:**
- Review error logs
- Check database size and growth
- Verify backup integrity
- Review security alerts

**Monthly Tasks:**
- Update dependencies (security patches)
- Review and optimize slow queries
- Analyze resource usage trends
- Test disaster recovery procedures

**Quarterly Tasks:**
- Rotate secrets and API keys
- Review and update documentation
- Perform load testing
- Security audit

---

## 11. Troubleshooting

### 11.1 Common Issues

**Issue: Backend won't start - ModuleNotFoundError**
```bash
# Solution: Reinstall dependencies
cd backend
pip install -e .
```

**Issue: Database connection error**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Verify connection string
psql postgresql://khetopedia:password@localhost:5432/khetopedia

# Check logs
sudo journalctl -u postgresql -f
```

**Issue: Redis connection failed**
```bash
# Check Redis is running
sudo systemctl status redis-server

# Test connection
redis-cli ping

# Check password
redis-cli -a your-password ping
```

**Issue: File upload fails**
```bash
# Check upload directory permissions
ls -la /opt/khetopedia/backend/uploads
chmod 755 uploads
chown khetopedia:khetopedia uploads

# Check S3 credentials
aws s3 ls s3://khetopedia-uploads --profile khetopedia
```

**Issue: ML model not loading**
```bash
# Check model file exists
ls -lh backend/models/crop_disease_model.pth

# Check Python dependencies
pip list | grep torch

# Check memory availability
free -h
```

**Issue: Rate limiting not working**
```bash
# Verify Redis is connected
redis-cli -a password
127.0.0.1:6379> KEYS slowapi:*

# Check USE_REDIS setting
grep USE_REDIS .env
```

### 11.2 Performance Issues

**Issue: Slow API responses**
```python
# Enable query logging
# File: .env
DEBUG=true

# Check slow queries in logs
sudo journalctl -u khetopedia -f | grep "Slow query"
```

**Issue: High memory usage**
```bash
# Check process memory
ps aux | grep uvicorn

# Check for memory leaks
# Use memory profiler
pip install memory-profiler
python -m memory_profiler app/main.py
```

**Issue: Database connection pool exhausted**
```python
# Increase pool size
# File: app/core/database.py
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,  # Increase from 10
    max_overflow=40,  # Increase from 20
)
```

### 11.3 Getting Help

**Check Logs:**
```bash
# Backend logs (systemd)
sudo journalctl -u khetopedia -f

# Backend logs (Docker)
docker-compose logs -f backend

# NGINX logs
sudo tail -f /var/log/nginx/error.log

# PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-15-main.log
```

**Debug Mode:**
```bash
# Enable debug mode temporarily
# File: .env
DEBUG=true

# Restart application
sudo systemctl restart khetopedia
```

---

## 12. Security Checklist

### 12.1 Pre-Deployment Security Review

**Configuration:**
- [ ] SECRET_KEY changed from default
- [ ] Database credentials are strong and unique
- [ ] Redis password set
- [ ] CORS origins restricted to production domains
- [ ] DEBUG=false in production
- [ ] HTTPS/TLS enabled
- [ ] SSL certificates installed and auto-renewing

**Authentication & Authorization:**
- [ ] JWT secret is secure (32+ characters)
- [ ] Token expiration times reviewed
- [ ] Token blocklist enabled (Redis)
- [ ] Password hashing verified (Argon2)
- [ ] Rate limiting enabled
- [ ] Admin endpoints protected

**Data Protection:**
- [ ] Database encryption at rest configured
- [ ] S3 bucket encryption enabled
- [ ] Backups encrypted
- [ ] Sensitive data never logged
- [ ] EXIF data stripping implemented (if required)

**Network Security:**
- [ ] Firewall configured (only ports 80, 443, 22 open)
- [ ] SSH key-based authentication
- [ ] Database not exposed to public internet
- [ ] Redis not exposed to public internet
- [ ] Internal services on private network

**Application Security:**
- [ ] All dependencies up to date
- [ ] No known CVEs in dependencies
- [ ] File upload validation active
- [ ] File size limits enforced
- [ ] SQL injection protection verified
- [ ] XSS protection verified

**Monitoring & Logging:**
- [ ] Error tracking configured (Sentry)
- [ ] Log aggregation configured
- [ ] Security alerts configured
- [ ] Uptime monitoring configured
- [ ] Backup verification automated

### 12.2 Post-Deployment Security

**Continuous Monitoring:**
- Review error logs daily
- Monitor failed authentication attempts
- Check for unusual traffic patterns
- Review resource usage trends

**Regular Updates:**
- Apply security patches weekly
- Update dependencies monthly
- Rotate secrets quarterly
- Review access logs monthly

**Incident Response Plan:**
1. Identify and contain the issue
2. Preserve evidence (logs)
3. Notify affected users if data breach
4. Fix vulnerability
5. Document incident
6. Update security procedures

---

## 13. Scaling Recommendations

### 13.1 Horizontal Scaling

**Backend Scaling:**
```bash
# Add more uvicorn workers
uvicorn app.main:app --workers 8

# Or deploy multiple instances behind load balancer
# Instance 1: server1.example.com:8000
# Instance 2: server2.example.com:8000
# Load balancer: api.example.com -> [server1, server2]
```

**Database Scaling:**
- Implement read replicas for read-heavy workloads
- Use connection pooling (already configured)
- Consider database sharding for very large datasets

**Caching:**
- Redis cluster for distributed caching
- CDN for static assets
- Edge caching for API responses

### 13.2 Vertical Scaling

**Increase Resources:**
- Upgrade to larger instance types
- Add more CPU cores for ML inference
- Add more RAM for larger models
- Use SSD storage for database

### 13.3 Performance Optimization

**Database Optimization:**
- Add indexes on frequently queried columns
- Analyze and optimize slow queries
- Implement database query caching
- Use materialized views for complex queries

**Application Optimization:**
- Implement async job queue (Celery + Redis)
- Optimize ML model (quantization, ONNX)
- Implement response compression
- Use HTTP/2

---

## 14. Disaster Recovery

### 14.1 Backup Strategy

**What to Backup:**
- PostgreSQL database (daily)
- Redis data (if persistence enabled)
- Uploaded images (S3 versioning)
- Application configuration (.env files)
- SSL certificates

**Backup Retention:**
- Daily backups: 7 days
- Weekly backups: 4 weeks
- Monthly backups: 12 months

**Backup Verification:**
- Test restore monthly
- Document restore procedures
- Measure RTO (Recovery Time Objective)
- Measure RPO (Recovery Point Objective)

### 14.2 Restore Procedures

**Database Restore:**
```bash
# Stop application
sudo systemctl stop khetopedia

# Restore database
gunzip < backup.sql.gz | psql -U khetopedia khetopedia

# Restart application
sudo systemctl start khetopedia
```

**Full System Recovery:**
1. Provision new server
2. Install dependencies
3. Restore database from backup
4. Restore configuration files
5. Restore uploaded files from S3
6. Update DNS (if needed)
7. Verify functionality
8. Monitor for issues

---

## 15. Support & Resources

**Documentation:**
- Backend README: `backend/README.md`
- API Docs: `http://localhost:8000/docs`
- Final Review: `.agents/tasks/.../final-review.md`

**External Resources:**
- FastAPI: https://fastapi.tiangolo.com/
- Flutter: https://flutter.dev/docs
- PostgreSQL: https://www.postgresql.org/docs/
- Redis: https://redis.io/documentation

**Getting Help:**
- Check troubleshooting section above
- Review application logs
- Check GitHub issues (if applicable)
- Contact development team

---

**Document Version:** 1.0.0  
**Last Updated:** October 27, 2026  
**Maintained by:** Khetopedia Development Team
