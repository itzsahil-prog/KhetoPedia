from datetime import datetime, timezone
from app.core.redis import get_redis


class TokenBlocklistService:
    """JWT token blocklist for logout implementation."""

    @staticmethod
    async def blocklist_token(jti: str, expires_at: datetime) -> bool:
        """
        Add token to blocklist with TTL matching token expiry.
        
        Args:
            jti: JWT ID (unique token identifier)
            expires_at: Token expiration timestamp
            
        Returns:
            True if blocklisted successfully, False if Redis unavailable
        """
        redis = get_redis()
        if redis:
            try:
                now = datetime.now(timezone.utc)
                ttl = int((expires_at - now).total_seconds())
                if ttl > 0:
                    await redis.setex(f"blocklist:{jti}", ttl, "1")
                    return True
                # Token already expired, no need to blocklist
                return True
            except Exception as e:
                print(f"[TokenBlocklist] Failed to blocklist token {jti}: {e}")
        else:
            print("[TokenBlocklist] Warning: Redis unavailable, cannot enforce token blocklist")
        return False

    @staticmethod
    async def is_token_blocklisted(jti: str) -> bool:
        """
        Check if token is blocklisted.
        
        Args:
            jti: JWT ID
            
        Returns:
            True if blocklisted, False otherwise (or if Redis unavailable)
        """
        redis = get_redis()
        if redis:
            try:
                exists = await redis.exists(f"blocklist:{jti}")
                return exists == 1
            except Exception as e:
                print(f"[TokenBlocklist] Failed to check token {jti}: {e}")
        # If Redis unavailable, cannot enforce blocklist (security degradation)
        return False


token_blocklist_service = TokenBlocklistService()
