import httpx
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from app.schemas.weather import WeatherForecastItem, WeatherResponse
from app.core.config import settings
from app.services.cache_service import cache_service


class WeatherService:
    """Weather service with OpenWeatherMap API integration and Redis caching."""

    @staticmethod
    async def get_weather(
        latitude: float,
        longitude: float,
        location_name: Optional[str] = None,
    ) -> WeatherResponse:
        """
        Get weather data with caching.
        
        Args:
            latitude: Location latitude
            longitude: Location longitude
            location_name: Optional location name for display
            
        Returns:
            WeatherResponse with current and forecast data
        """
        # Round coordinates to 2 decimals to reduce cache key variations
        lat = round(latitude, 2)
        lon = round(longitude, 2)
        cache_key = f"weather:{lat}:{lon}"

        # Check cache
        cached = await cache_service.get_json(cache_key)
        if cached:
            print(f"[Weather] Cache hit for {lat},{lon}")
            return WeatherResponse(**cached)

        # If mock mode, return stub data
        if settings.USE_MOCK_WEATHER:
            return WeatherService._get_mock_weather(location_name or "Farmland Region")

        # Call real API
        try:
            weather_data = await WeatherService._fetch_from_api(lat, lon, location_name)
            # Cache result
            await cache_service.set_json(
                cache_key,
                weather_data.model_dump(),
                settings.WEATHER_CACHE_TTL
            )
            return weather_data
        except Exception as e:
            print(f"[Weather] API call failed: {e}, falling back to mock data")
            return WeatherService._get_mock_weather(location_name or "Farmland Region")

    @staticmethod
    async def _fetch_from_api(
        lat: float, lon: float, location_name: Optional[str]
    ) -> WeatherResponse:
        """Fetch weather data from OpenWeatherMap API."""
        if not settings.WEATHER_API_KEY:
            raise Exception("WEATHER_API_KEY not configured")

        base_url = settings.WEATHER_API_URL
        api_key = settings.WEATHER_API_KEY

        async with httpx.AsyncClient(timeout=10.0) as client:
            # Fetch current weather
            current_response = await client.get(
                f"{base_url}/weather",
                params={
                    "lat": lat,
                    "lon": lon,
                    "appid": api_key,
                    "units": "metric",
                }
            )
            current_response.raise_for_status()
            current_data = current_response.json()

            # Fetch forecast
            forecast_response = await client.get(
                f"{base_url}/forecast",
                params={
                    "lat": lat,
                    "lon": lon,
                    "appid": api_key,
                    "units": "metric",
                }
            )
            forecast_response.raise_for_status()
            forecast_data = forecast_response.json()

        # Transform to our schema
        location = location_name or current_data.get("name", "Unknown Location")
        temperature = current_data["main"]["temp"]
        humidity = current_data["main"]["humidity"]
        wind_speed = current_data["wind"]["speed"] * 3.6  # m/s to km/h
        condition = current_data["weather"][0]["main"]

        # Extract hourly forecast (next 6 intervals = 18 hours)
        hourly = []
        for item in forecast_data["list"][:6]:
            dt = datetime.fromtimestamp(item["dt"], tz=timezone.utc)
            hourly.append(WeatherForecastItem(
                time=dt.strftime("%H:%M"),
                temperature_c=item["main"]["temp"],
                rain_probability_pct=int(item.get("pop", 0) * 100),
                condition=item["weather"][0]["main"]
            ))

        # Calculate rain probability for next 6 hours
        rain_prob = int(forecast_data["list"][0].get("pop", 0) * 100) if forecast_data["list"] else 0

        # Generate agricultural advisory
        advisory = WeatherService._generate_advisory(
            rain_prob, wind_speed, temperature
        )

        return WeatherResponse(
            location=location,
            temperature_celsius=temperature,
            humidity_percentage=humidity,
            rain_probability_percentage=rain_prob,
            wind_speed_kmh=wind_speed,
            condition=condition,
            uv_index=None,  # UV requires separate API call
            advisory=advisory,
            last_updated=datetime.now(timezone.utc),
            hourly_forecast=hourly,
        )

    @staticmethod
    def _generate_advisory(rain_prob: int, wind_speed: float, temperature: float) -> str:
        """Generate agricultural advisory based on weather conditions."""
        if rain_prob > 70:
            return "High rain probability. Delay pesticide application."
        if wind_speed > 15:
            return "Moderate to high wind. Avoid spraying to prevent drift."
        if temperature > 35:
            return "High temperature. Irrigate in early morning or evening."
        if wind_speed < 12 and rain_prob < 20:
            return "Favorable conditions for foliar applications in morning hours."
        return "Monitor weather conditions for optimal field operations."

    @staticmethod
    def _get_mock_weather(location: str) -> WeatherResponse:
        """Return mock weather data for development."""
        now = datetime.now(timezone.utc)
        hourly = [
            WeatherForecastItem(time="06:00", temperature_c=22.5, rain_probability_pct=5, condition="Clear"),
            WeatherForecastItem(time="09:00", temperature_c=27.0, rain_probability_pct=10, condition="Sunny"),
            WeatherForecastItem(time="12:00", temperature_c=32.4, rain_probability_pct=15, condition="Partly Cloudy"),
            WeatherForecastItem(time="15:00", temperature_c=33.8, rain_probability_pct=25, condition="Cloudy"),
            WeatherForecastItem(time="18:00", temperature_c=29.1, rain_probability_pct=20, condition="Partly Cloudy"),
            WeatherForecastItem(time="21:00", temperature_c=25.2, rain_probability_pct=10, condition="Clear"),
        ]

        advisory = (
            "Favorable conditions for foliar applications in morning hours (06:00 - 09:30). "
            "Wind speeds below 12 km/h minimize spray drift. Rain probability low (15%)."
        )

        return WeatherResponse(
            location=location,
            temperature_celsius=29.5,
            humidity_percentage=58.0,
            rain_probability_percentage=15,
            wind_speed_kmh=8.5,
            condition="Partly Cloudy",
            uv_index=6.2,
            advisory=advisory,
            last_updated=now,
            hourly_forecast=hourly,
        )
    
    @staticmethod
    async def get_forecast_summary(
        latitude: float,
        longitude: float,
    ) -> Dict[str, Any]:
        """
        Get simplified weather forecast summary for recommendation engine.
        
        Args:
            latitude: Location latitude
            longitude: Location longitude
            
        Returns:
            Dictionary with rain_probability_24h, max_temp_24h, avg_wind_speed
        """
        weather_data = await WeatherService.get_weather(latitude, longitude)
        
        # Calculate 24h summary from hourly forecast
        rain_prob_24h = weather_data.rain_probability_percentage
        max_temp_24h = weather_data.temperature_celsius
        avg_wind = weather_data.wind_speed_kmh
        
        if weather_data.hourly_forecast:
            temps = [item.temperature_c for item in weather_data.hourly_forecast]
            max_temp_24h = max(temps) if temps else max_temp_24h
            
            rain_probs = [item.rain_probability_pct for item in weather_data.hourly_forecast]
            rain_prob_24h = max(rain_probs) if rain_probs else rain_prob_24h
        
        return {
            "rain_probability_24h": rain_prob_24h,
            "max_temp_24h": max_temp_24h,
            "avg_wind_speed": avg_wind,
            "condition": weather_data.condition,
        }


weather_service = WeatherService()
