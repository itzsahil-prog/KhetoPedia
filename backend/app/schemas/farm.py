from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class FarmCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=255)
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    total_area_acres: float = Field(default=1.0, gt=0)
    soil_type: Optional[str] = "Loamy"
    irrigation_source: Optional[str] = "Canal / Borewell"
    notes: Optional[str] = None


class FarmUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    total_area_acres: Optional[float] = None
    soil_type: Optional[str] = None
    irrigation_source: Optional[str] = None
    notes: Optional[str] = None


class FarmResponse(BaseModel):
    id: str
    user_id: str
    name: str
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    total_area_acres: float
    soil_type: Optional[str] = None
    irrigation_source: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
