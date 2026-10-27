from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict


class QuickStatSchema(BaseModel):
    key: str
    label: str
    value: str
    unit: Optional[str] = None
    trend: Optional[str] = None  # up, down, stable


class FieldSummarySchema(BaseModel):
    id: str
    name: str
    crop_name: str
    area_hectares: float
    health_score: Optional[int] = None
    status: Optional[str] = None  # healthy, at_risk, critical
    last_scanned_at: Optional[datetime] = None
    thumbnail_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class AlertItemSchema(BaseModel):
    id: str
    title: str
    description: str
    severity: str  # info, warning, critical
    field_id: Optional[str] = None
    field_name: Optional[str] = None
    created_at: Optional[datetime] = None
    is_read: bool = False

    model_config = ConfigDict(from_attributes=True)


class WeatherCardSchema(BaseModel):
    temperature_celsius: float
    humidity_percentage: float
    rain_probability_percentage: int
    condition: str
    advisory: str
    last_updated: datetime


class DashboardSummaryResponse(BaseModel):
    stats: List[QuickStatSchema]
    recent_fields: List[FieldSummarySchema]
    active_alerts: List[AlertItemSchema]
    weather: Optional[WeatherCardSchema] = None


class AlertsListResponse(BaseModel):
    alerts: List[AlertItemSchema]
    total: int
    page: int
    page_size: int
