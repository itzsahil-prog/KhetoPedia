import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi.errors import RateLimitExceeded

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.database import init_db
from app.core.logging_config import configure_logging
from app.core.redis import init_redis, close_redis
from app.middleware.rate_limit import limiter

# Configure structured logging as early as possible.
# Set JSON_LOGS=true in the environment for production JSON output.
import os as _os
configure_logging(
    json_logs=_os.environ.get("JSON_LOGS", "").lower() in ("1", "true", "yes"),
    level=_os.environ.get("LOG_LEVEL", "INFO"),
)

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialize database tables and Redis
    await init_db()
    await init_redis()
    yield
    # Shutdown: close Redis connections
    await close_redis()


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="REST API backend for Khetopedia - AI-Powered Agriculture Assistant",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
)

# Set rate limiter state
app.state.limiter = limiter

# Rate limit exceeded handler
@app.exception_handler(RateLimitExceeded)
async def _rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(
        status_code=status.HTTP_429_TOO_MANY_REQUESTS,
        content={
            "detail": f"Rate limit exceeded. Try again in {exc.retry_after} seconds.",
            "code": "RATE_LIMIT_EXCEEDED",
        },
    )

# Set CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Unified global exception handling
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # Log exception for debugging
    logger.error(
        "Unhandled exception on %s %s: %s",
        request.method,
        request.url.path,
        exc,
        exc_info=True,
    )
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": "An internal server error occurred. Please try again later.",
            "code": "INTERNAL_SERVER_ERROR",
        },
    )


# Health check endpoint
@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
    }


@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Welcome to Khetopedia Agriculture API",
        "documentation": "/docs",
        "version": settings.VERSION,
    }


# Mount v1 API router
app.include_router(api_router, prefix=settings.API_V1_STR)
