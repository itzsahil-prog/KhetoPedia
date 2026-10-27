"""Integration tests for weather service"""
import pytest
from datetime import datetime

from app.services.weather_service import weather_service
from app.core.config import settings


class TestWeatherService:
    """Test weather service integration"""

    @pytest.mark.asyncio
    async def test_weather_mock_mode_returns_data(self):
        """Test that mock weather mode returns valid data"""
        original_mock = settings.USE_MOCK_WEATHER
        
        try:
            # Force mock mode
            settings.USE_MOCK_WEATHER = True
            
            # Coordinates for test location (New Delhi, India)
            latitude = 28.6139
            longitude = 77.2090
            location_name = "Test Farm Delhi"
            
            # Fetch weather
            weather = await weather_service.get_weather(latitude, longitude, location_name)
            
            # Verify response structure
            assert weather is not None
            assert hasattr(weather, 'temperature_celsius')
            assert hasattr(weather, 'humidity_percentage')
            assert hasattr(weather, 'rain_probability_percentage')
            assert hasattr(weather, 'condition')
            assert hasattr(weather, 'advisory')
            assert hasattr(weather, 'last_updated')
            
            # Verify data types
            assert isinstance(weather.temperature_celsius, (int, float))
            assert isinstance(weather.humidity_percentage, (int, float))
            assert isinstance(weather.rain_probability_percentage, int)
            assert isinstance(weather.condition, str)
            assert isinstance(weather.advisory, str)
            assert isinstance(weather.last_updated, datetime)
            
            # Verify reasonable ranges for mock data
            assert -10 <= weather.temperature_celsius <= 50
            assert 0 <= weather.humidity_percentage <= 100
            assert 0 <= weather.rain_probability_percentage <= 100
            
        finally:
            settings.USE_MOCK_WEATHER = original_mock

    @pytest.mark.asyncio
    async def test_weather_caching(self):
        """Test that weather data is cached and doesn't hit API twice"""
        original_mock = settings.USE_MOCK_WEATHER
        
        try:
            settings.USE_MOCK_WEATHER = True
            
            latitude = 28.6139
            longitude = 77.2090
            location = "Cache Test Farm"
            
            # First call
            weather1 = await weather_service.get_weather(latitude, longitude, location)
            timestamp1 = weather1.last_updated
            
            # Second call immediately after (should be cached)
            weather2 = await weather_service.get_weather(latitude, longitude, location)
            timestamp2 = weather2.last_updated
            
            # Both should have same data (cached)
            assert weather1.temperature_celsius == weather2.temperature_celsius
            assert weather1.humidity_percentage == weather2.humidity_percentage
            # Timestamps should be very close (within 1 second) if cached
            # Note: In mock mode without Redis, timestamps may differ slightly
            time_diff = abs((timestamp2 - timestamp1).total_seconds())
            assert time_diff < 2, f"Timestamps differ by {time_diff}s, caching may not be working"
            
        finally:
            settings.USE_MOCK_WEATHER = original_mock

    @pytest.mark.asyncio
    async def test_weather_coordinate_rounding(self):
        """Test that similar coordinates share cache"""
        original_mock = settings.USE_MOCK_WEATHER
        
        try:
            settings.USE_MOCK_WEATHER = True
            
            # Very close coordinates (should round to same cache key)
            lat1, lon1 = 28.6139123, 77.2090456
            lat2, lon2 = 28.6139789, 77.2090987
            
            weather1 = await weather_service.get_weather(lat1, lon1, "Farm A")
            weather2 = await weather_service.get_weather(lat2, lon2, "Farm B")
            
            # Should return same cached data
            assert weather1.temperature_celsius == weather2.temperature_celsius
            
        finally:
            settings.USE_MOCK_WEATHER = original_mock

    @pytest.mark.asyncio
    async def test_weather_api_failure_fallback(self):
        """Test that service falls back to mock data on API failure"""
        original_mock = settings.USE_MOCK_WEATHER
        original_api_key = settings.WEATHER_API_KEY
        
        try:
            # Force API mode with invalid key to trigger failure
            settings.USE_MOCK_WEATHER = False
            settings.WEATHER_API_KEY = "INVALID_KEY_12345"
            
            latitude = 28.6139
            longitude = 77.2090
            location = "Failure Test Farm"
            
            # Should fallback to mock data without raising exception
            weather = await weather_service.get_weather(latitude, longitude, location)
            
            # Should still return valid weather data (mock fallback)
            assert weather is not None
            assert isinstance(weather.temperature_celsius, (int, float))
            assert isinstance(weather.condition, str)
            
        finally:
            settings.USE_MOCK_WEATHER = original_mock
            settings.WEATHER_API_KEY = original_api_key

    @pytest.mark.asyncio
    async def test_weather_advisory_generation(self):
        """Test that weather advisory text is generated"""
        original_mock = settings.USE_MOCK_WEATHER
        
        try:
            settings.USE_MOCK_WEATHER = True
            
            latitude = 28.6139
            longitude = 77.2090
            location = "Advisory Test Farm"
            
            weather = await weather_service.get_weather(latitude, longitude, location)
            
            # Advisory should be non-empty string
            assert weather.advisory is not None
            assert len(weather.advisory) > 0
            assert isinstance(weather.advisory, str)
            
            # Advisory should contain some useful keywords
            advisory_lower = weather.advisory.lower()
            # Should mention either conditions or recommendations
            has_useful_content = any(
                keyword in advisory_lower
                for keyword in [
                    "temperature", "rain", "humid", "dry", "spray", "irrigat",
                    "suitable", "postpone", "recommended", "weather", "condition"
                ]
            )
            assert has_useful_content, f"Advisory lacks useful content: {weather.advisory}"
            
        finally:
            settings.USE_MOCK_WEATHER = original_mock

    @pytest.mark.asyncio
    async def test_weather_different_locations(self):
        """Test that different locations can have different weather"""
        original_mock = settings.USE_MOCK_WEATHER
        
        try:
            settings.USE_MOCK_WEATHER = True
            
            # Two different locations
            location1 = await weather_service.get_weather(28.6139, 77.2090, "Delhi Farm")
            location2 = await weather_service.get_weather(19.0760, 72.8777, "Mumbai Farm")
            
            # Both should return valid data
            assert location1 is not None
            assert location2 is not None
            
            # Should have valid structure
            assert hasattr(location1, 'temperature_celsius')
            assert hasattr(location2, 'temperature_celsius')
            
        finally:
            settings.USE_MOCK_WEATHER = original_mock
