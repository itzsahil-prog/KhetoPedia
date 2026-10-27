from typing import Optional
from redis.asyncio import Redis, ConnectionPool
from app.core.config import settings

_redis_pool: Optional[ConnectionPool] = None
_redis_client: Optional[Redis] = None


async def init_redis() -> None:
    """Initialize Redis connection pool if USE_REDIS is enabled."""
    global _redis_pool, _redis_client
    if settings.USE_REDIS:
        try:
            _redis_pool = ConnectionPool.from_url(
                settings.REDIS_URL,
                max_connections=settings.REDIS_MAX_CONNECTIONS,
                decode_responses=True,
            )
            _redis_client = Redis(connection_pool=_redis_pool)
            # Test connection
            await _redis_client.ping()
            print(f"[Redis] Connected to {settings.REDIS_URL}")
        except Exception as e:
            print(f"[Redis] Connection failed: {e}")
            _redis_client = None
            _redis_pool = None
    else:
        print("[Redis] Disabled (USE_REDIS=false)")


async def close_redis() -> None:
    """Close Redis connections."""
    global _redis_client, _redis_pool
    if _redis_client:
        await _redis_client.aclose()
        _redis_client = None
    if _redis_pool:
        await _redis_pool.aclose()
        _redis_pool = None


def get_redis() -> Optional[Redis]:
    """Get Redis client instance."""
    return _redis_client
