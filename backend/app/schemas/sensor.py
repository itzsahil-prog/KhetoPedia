from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class SensorDeviceCreate(BaseModel):
    device_uid: str = Field(..., min_length=3, max_length=100)
    field_id: Optional[str] = None
    model_name: Optional[str] = "AgriSense ESP32 Soil Probe"


class SensorDeviceResponse(BaseModel):
    id: str
    device_uid: str
    user_id: str
    field_id: Optional[str] = None
    field_name: Optional[str] = None
    model_name: str
    is_active: bool
    battery_level: Optional[float] = None
    last_seen_at: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class SensorReadingCreate(BaseModel):
    device_uid: str
    api_key: Optional[str] = None
    soil_moisture_percentage: float = Field(..., ge=0.0, le=100.0)
    soil_temperature_celsius: Optional[float] = None
    ambient_temperature_celsius: Optional[float] = None
    ambient_humidity_percentage: Optional[float] = None
    soil_ph: Optional[float] = None
    soil_ec_ds_m: Optional[float] = None


class SensorReadingResponse(BaseModel):
    id: str
    sensor_id: str
    field_id: Optional[str] = None
    soil_moisture_percentage: float
    soil_temperature_celsius: Optional[float] = None
    ambient_temperature_celsius: Optional[float] = None
    ambient_humidity_percentage: Optional[float] = None
    soil_ph: Optional[float] = None
    soil_ec_ds_m: Optional[float] = None
    recorded_at: datetime

    model_config = ConfigDict(from_attributes=True)
