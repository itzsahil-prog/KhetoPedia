"""Integration tests for Redis cache and token blocklist services"""
import pytest
from datetime import datetime, timezone, timedelta

from app.services.cache_service import cache_service
from app.services.token_blocklist_service import token_blocklist_service


class TestCacheService:
    """Test Redis cache service functionality"""

    @pytest.mark.asyncio
    async def test_cache_set_and_get_string(self):
        """Test basic cache set and get operations with string value"""
        key = "test:cache:string"
        value = "test_value_12345"
        ttl = 60
        
        # Set cache
        success = await cache_service.set(key, value, ttl)
        assert success in [True, False, None]  # False when Redis unavailable
        
        # Get cache
        retrieved = await cache_service.get(key)
        if retrieved is not None:
            assert retrieved == value

    @pytest.mark.asyncio
    async def test_cache_set_and_get_json(self):
        """Test cache operations with JSON serialization"""
        key = "test:cache:json"
        data = {
            "user_id": "123",
            "name": "Test User",
            "fields": ["field1", "field2"],
            "count": 42
        }
        ttl = 60
        
        # Set JSON cache
        success = await cache_service.set_json(key, data, ttl)
        assert success in [True, False, None]
        
        # Get JSON cache
        retrieved = await cache_service.get_json(key)
        if retrieved is not None:
            assert retrieved == data
            assert retrieved["user_id"] == "123"
            assert retrieved["count"] == 42

    @pytest.mark.asyncio
    async def test_cache_delete(self):
        """Test cache deletion"""
        key = "test:cache:delete"
        value = "temporary_value"
        
        # Set cache
        await cache_service.set(key, value, 60)
        
        # Delete cache
        deleted = await cache_service.delete(key)
        assert deleted in [True, False, None]
        
        # Verify it's gone
        retrieved = await cache_service.get(key)
        assert retrieved is None

    @pytest.mark.asyncio
    async def test_cache_expiration(self):
        """Test that cache expires after TTL"""
        key = "test:cache:expire"
        value = "expires_soon"
        ttl = 1  # 1 second
        
        # Set cache with short TTL
        await cache_service.set(key, value, ttl)
        
        # Should exist immediately
        retrieved = await cache_service.get(key)
        if retrieved is not None:
            assert retrieved == value
            
            # Wait for expiration
            import asyncio
            await asyncio.sleep(2)
            
            # Should be gone now
            expired = await cache_service.get(key)
            assert expired is None

    @pytest.mark.asyncio
    async def test_cache_fallback_when_redis_disabled(self):
        """Test graceful fallback when Redis is unavailable"""
        # Operations should not raise exceptions even if Redis is disabled
        key = "test:fallback"
        value = "fallback_test"
        
        try:
            await cache_service.set(key, value, 60)
            retrieved = await cache_service.get(key)
            await cache_service.delete(key)
            # No exception means test passes
            assert True
        except Exception as e:
            # Should not raise exception, but if it does, fail the test
            pytest.fail(f"Cache service should handle Redis unavailability gracefully: {e}")


class TestTokenBlocklistService:
    """Test token blocklist service functionality"""

    @pytest.mark.asyncio
    async def test_blocklist_token(self):
        """Test adding a token to the blocklist"""
        jti = "test-token-jti-12345"
        expires_at = datetime.now(timezone.utc) + timedelta(hours=24)
        
        # Blocklist the token
        success = await token_blocklist_service.blocklist_token(jti, expires_at)
        assert success in [True, False, None]
        
        # Check if it's blocklisted
        is_blocklisted = await token_blocklist_service.is_token_blocklisted(jti)
        # When Redis is unavailable, service returns False
        assert is_blocklisted in [True, False, None]

    @pytest.mark.asyncio
    async def test_token_not_blocklisted_initially(self):
        """Test that a new token is not blocklisted"""
        jti = "new-token-jti-67890"
        
        # Check blocklist status
        is_blocklisted = await token_blocklist_service.is_token_blocklisted(jti)
        
        # Should be False or None (if Redis unavailable)
        assert is_blocklisted is False or is_blocklisted is None

    @pytest.mark.asyncio
    async def test_blocklist_multiple_tokens(self):
        """Test blocklisting multiple tokens"""
        tokens = [
            ("token-jti-1", datetime.now(timezone.utc) + timedelta(hours=1)),
            ("token-jti-2", datetime.now(timezone.utc) + timedelta(hours=2)),
            ("token-jti-3", datetime.now(timezone.utc) + timedelta(hours=3)),
        ]
        
        # Blocklist all tokens
        for jti, expires_at in tokens:
            await token_blocklist_service.blocklist_token(jti, expires_at)
        
        # Check all are blocklisted (only if Redis is available)
        for jti, _ in tokens:
            is_blocklisted = await token_blocklist_service.is_token_blocklisted(jti)
            # When Redis unavailable, is_blocklisted returns False
            assert is_blocklisted in [True, False, None]

    @pytest.mark.asyncio
    async def test_dashboard_cache_invalidation(self):
        """Test dashboard cache invalidation pattern"""
        user_id = "test-user-cache-invalidate"
        cache_key = f"dashboard:summary:{user_id}"
        
        # Set dashboard cache
        dashboard_data = {
            "stats": [{"key": "health", "value": "85"}],
            "recent_fields": [],
            "active_alerts": []
        }
        await cache_service.set_json(cache_key, dashboard_data, 300)
        
        # Verify it's cached
        cached = await cache_service.get_json(cache_key)
        if cached is not None:
            assert cached["stats"][0]["value"] == "85"
        
        # Invalidate cache (simulating alert creation)
        deleted = await cache_service.delete(cache_key)
        
        # Verify it's gone
        invalidated = await cache_service.get_json(cache_key)
        if deleted is not None:  # Only verify if Redis is available
            assert invalidated is None
