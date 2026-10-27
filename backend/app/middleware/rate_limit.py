from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from app.core.config import settings
from app.core.redis import get_redis


def get_limiter_storage():
    """Get storage backend for rate limiter (Redis or in-memory)."""
    redis = get_redis()
    if redis and settings.USE_REDIS:
        from slowapi.extension import SlowAPIRedisStorage
        return SlowAPIRedisStorage(redis=redis)
    # Fallback to in-memory (not distributed, dev only)
    print("[RateLimit] Using in-memory storage (not distributed)")
    return None


# Create rate limiter instance
limiter = Limiter(
    key_func=get_remote_address,
    storage_uri=None,  # We'll use custom storage
    enabled=settings.USE_REDIS,  # Only enable if Redis available
)
