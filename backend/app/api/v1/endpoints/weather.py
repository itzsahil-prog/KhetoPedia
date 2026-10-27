from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.weather import WeatherResponse
from app.services.weather_service import weather_service

router = APIRouter(prefix="/weather", tags=["Weather"])


@router.get("", response_model=WeatherResponse)
async def get_weather(
    latitude: Optional[float] = Query(None, description="Field or farm latitude"),
    longitude: Optional[float] = Query(None, description="Field or farm longitude"),
    location: Optional[str] = Query(None, description="Free-text location name (fallback if coords unavailable)"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieve current weather conditions and 6-hour forecast for the farmer's location.

    Includes:
    - Temperature, humidity, wind speed, UV index
    - Rain probability and condition
    - Agricultural advisory (spray windows, irrigation planning)
    - Hourly forecast items with rain probability

    Data is sourced from a backend weather provider and cached with last-updated timestamps.
    """
    # Default to New Delhi coordinates if not provided
    if latitude is None or longitude is None:
        latitude = 28.6139
        longitude = 77.2090
        
    return await weather_service.get_weather(
        latitude=latitude,
        longitude=longitude,
        location_name=location,
    )
