import json
from typing import Optional, Any
from app.core.redis import get_redis


class CacheService:
    """Redis caching helpers with graceful fallback."""

    @staticmethod
    async def get(key: str) -> Optional[str]:
        """Get value from cache."""
        redis = get_redis()
        if redis:
            try:
                return await redis.get(key)
            except Exception as e:
                print(f"[Cache] Get failed for key '{key}': {e}")
        return None

    @staticmethod
    async def set(key: str, value: str, ttl: int) -> bool:
        """Set value in cache with TTL (seconds)."""
        redis = get_redis()
        if redis:
            try:
                await redis.setex(key, ttl, value)
                return True
            except Exception as e:
                print(f"[Cache] Set failed for key '{key}': {e}")
        return False

    @staticmethod
    async def delete(key: str) -> bool:
        """Delete key from cache."""
        redis = get_redis()
        if redis:
            try:
                await redis.delete(key)
                return True
            except Exception as e:
                print(f"[Cache] Delete failed for key '{key}': {e}")
        return False

    @staticmethod
    async def get_json(key: str) -> Optional[Any]:
        """Get JSON value from cache."""
        value = await CacheService.get(key)
        if value:
            try:
                return json.loads(value)
            except json.JSONDecodeError as e:
                print(f"[Cache] JSON decode failed for key '{key}': {e}")
        return None

    @staticmethod
    async def set_json(key: str, value: Any, ttl: int) -> bool:
        """Set JSON value in cache with TTL."""
        try:
            json_str = json.dumps(value, default=str)
            return await CacheService.set(key, json_str, ttl)
        except Exception as e:
            print(f"[Cache] JSON encode failed for key '{key}': {e}")
            return False


cache_service = CacheService()
