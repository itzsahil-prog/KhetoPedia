from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class FieldCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=255)
    crop_name: Optional[str] = "Wheat"
    acreage: float = Field(default=1.0, gt=0)
    location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    health_score: int = Field(default=85, ge=0, le=100)
    soil_status: str = "Healthy"
    water_status: str = "Adequate"


class FieldUpdate(BaseModel):
    name: Optional[str] = None
    crop_name: Optional[str] = None
    acreage: Optional[float] = None
    location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    health_score: Optional[int] = Field(None, ge=0, le=100)
    soil_status: Optional[str] = None
    water_status: Optional[str] = None


class FieldResponse(BaseModel):
    id: str
    user_id: str
    name: str
    crop_name: Optional[str] = None
    acreage: Optional[float] = None
    location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    health_score: int
    soil_status: str
    water_status: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
