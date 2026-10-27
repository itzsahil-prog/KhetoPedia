from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.dashboard import Alert, Field
from app.models.user import User
from app.schemas.dashboard import (
    AlertItemSchema,
    AlertsListResponse,
    DashboardSummaryResponse,
    FieldSummarySchema,
    QuickStatSchema,
    WeatherCardSchema,
)
from app.services.cache_service import cache_service
from app.services.weather_service import weather_service

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/summary", response_model=DashboardSummaryResponse)
async def get_dashboard_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve aggregated dashboard metrics, recent fields, and active alerts for the current farmer."""
    
    # Check cache first
    cache_key = f"dashboard:summary:{current_user.id}"
    cached = await cache_service.get_json(cache_key)
    if cached:
        return DashboardSummaryResponse(**cached)
    
    # 1. Fetch user fields
    fields_stmt = (
        select(Field)
        .where(Field.user_id == current_user.id)
        .order_by(desc(Field.updated_at))
        .limit(5)
    )
    fields_res = await db.execute(fields_stmt)
    user_fields = list(fields_res.scalars().all())

    # If new user has zero fields, let's seed an initial sample field so they can immediately see live data
    if not user_fields:
        sample_field = Field(
            user_id=current_user.id,
            name="North Wheat Field",
            crop_name="Wheat (PBW 343)",
            acreage=4.5,
            location_name="Sector 7 Farmland",
            health_score=86,
            soil_status="Healthy",
            water_status="Adequate",
        )
        sample_alert = Alert(
            user_id=current_user.id,
            title="Weather Advisory",
            message="Light precipitation expected tomorrow afternoon. Postpone foliar spraying.",
            severity="info",
            alert_type="weather",
            is_read=False,
        )
        db.add(sample_field)
        db.add(sample_alert)
        await db.commit()
        await db.refresh(sample_field)
        await db.refresh(sample_alert)
        user_fields = [sample_field]

    # 2. Fetch unresolved alerts
    alerts_stmt = (
        select(Alert)
        .where(Alert.user_id == current_user.id, Alert.is_read == False)
        .order_by(desc(Alert.created_at))
        .limit(10)
    )
    alerts_res = await db.execute(alerts_stmt)
    user_alerts = list(alerts_res.scalars().all())

    # 3. Calculate KPIs
    total_fields_count = len(user_fields)
    total_acres = sum(f.acreage or 0.0 for f in user_fields)
    avg_health = int(sum(f.health_score for f in user_fields) / total_fields_count) if total_fields_count > 0 else 80

    stats = [
        QuickStatSchema(
            key="crop_health",
            label="Crop Health",
            value=str(avg_health),
            unit="/100",
            trend="stable" if avg_health > 75 else "down",
        ),
        QuickStatSchema(
            key="total_area",
            label="Managed Area",
            value=f"{total_acres:.1f}",
            unit="acres",
            trend="up",
        ),
        QuickStatSchema(
            key="active_fields",
            label="Active Fields",
            value=str(total_fields_count),
            unit="plots",
            trend="stable",
        ),
        QuickStatSchema(
            key="soil_condition",
            label="Soil Condition",
            value="Optimal",
            unit="pH 6.8",
            trend="stable",
        ),
    ]

    recent_fields_dto = [
        FieldSummarySchema(
            id=f.id,
            name=f.name,
            crop_name=f.crop_name or "Mixed Crop",
            area_hectares=round((f.acreage or 1.0) * 0.404686, 2),  # acres to hectares
            health_score=f.health_score,
            status="healthy" if f.health_score >= 80 else ("at_risk" if f.health_score >= 60 else "critical"),
            last_scanned_at=f.updated_at,
            thumbnail_url=None,
        )
        for f in user_fields
    ]

    alerts_dto = [
        AlertItemSchema(
            id=a.id,
            title=a.title,
            description=a.message,
            severity=a.severity if a.severity in ("info", "warning", "critical") else "info",
            field_id=a.field_id,
            field_name=None,
            created_at=a.created_at,
            is_read=a.is_read,
        )
        for a in user_alerts
    ]

    # Fetch weather data for primary field
    weather_data = None
    if user_fields and user_fields[0].latitude and user_fields[0].longitude:
        try:
            weather_response = await weather_service.get_weather(
                user_fields[0].latitude,
                user_fields[0].longitude,
                user_fields[0].location_name
            )
            weather_data = WeatherCardSchema(
                temperature_celsius=weather_response.temperature_celsius,
                humidity_percentage=weather_response.humidity_percentage,
                rain_probability_percentage=weather_response.rain_probability_percentage,
                condition=weather_response.condition,
                advisory=weather_response.advisory,
                last_updated=weather_response.last_updated
            )
        except Exception as e:
            print(f"[Dashboard] Failed to fetch weather: {e}")
            # Continue without weather data

    response = DashboardSummaryResponse(
        stats=stats,
        recent_fields=recent_fields_dto,
        active_alerts=alerts_dto,
        weather=weather_data,
    )
    
    # Cache for 5 minutes
    await cache_service.set_json(cache_key, response.model_dump(), 300)
    
    return response


@router.get("/alerts", response_model=AlertsListResponse)
async def get_alerts_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve paginated alerts list for the current farmer."""
    offset = (page - 1) * page_size
    stmt = (
        select(Alert)
        .where(Alert.user_id == current_user.id)
        .order_by(desc(Alert.created_at))
        .offset(offset)
        .limit(page_size)
    )
    result = await db.execute(stmt)
    alerts = list(result.scalars().all())

    count_stmt = select(func.count(Alert.id)).where(Alert.user_id == current_user.id)
    total = (await db.execute(count_stmt)).scalar() or 0

    alerts_dto = [
        AlertItemSchema(
            id=a.id,
            title=a.title,
            description=a.message,
            severity=a.severity if a.severity in ("info", "warning", "critical") else "info",
            field_id=a.field_id,
            field_name=None,
            created_at=a.created_at,
            is_read=a.is_read,
        )
        for a in alerts
    ]

    return AlertsListResponse(
        alerts=alerts_dto,
        total=total,
        page=page,
        page_size=page_size,
    )
