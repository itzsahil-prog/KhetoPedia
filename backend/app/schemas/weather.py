from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class WeatherForecastItem(BaseModel):
    time: str
    temperature_c: float
    rain_probability_pct: int
    condition: str


class WeatherResponse(BaseModel):
    location: str
    temperature_celsius: float
    humidity_percentage: float
    rain_probability_percentage: int
    wind_speed_kmh: float
    condition: str  # Sunny, Partly Cloudy, Light Rain, etc.
    uv_index: float
    advisory: str
    last_updated: datetime
    hourly_forecast: List[WeatherForecastItem] = []
