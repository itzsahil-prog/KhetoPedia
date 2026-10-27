from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class ProfileBase(BaseModel):
    village: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    country: str = "India"
    address: Optional[str] = None
    primary_crops: Optional[str] = None
    farming_experience_years: int = 0


class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    village: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    address: Optional[str] = None
    primary_crops: Optional[str] = None
    farming_experience_years: Optional[int] = None
    preferred_locale: Optional[str] = None


class ProfileResponse(ProfileBase):
    id: str
    user_id: str
    user_name: str
    user_email: str
    user_phone: Optional[str] = None
    avatar_url: Optional[str] = None
    preferred_locale: str = "en"
    total_area_acres: float = 0.0
    farm_count: int = 1
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=6, max_length=128)


class UserSettingsUpdate(BaseModel):
    theme_mode: Optional[str] = None  # light, dark, system
    font_size: Optional[str] = None  # small, medium, large, extra_large
    disease_alerts_enabled: Optional[bool] = None
    soil_alerts_enabled: Optional[bool] = None
    irrigation_reminders_enabled: Optional[bool] = None
    weather_alerts_enabled: Optional[bool] = None
    fertilizer_reminders_enabled: Optional[bool] = None
    preferred_language: Optional[str] = None


class UserSettingsResponse(BaseModel):
    theme_mode: str = "system"
    font_size: str = "medium"
    disease_alerts_enabled: bool = True
    soil_alerts_enabled: bool = True
    irrigation_reminders_enabled: bool = True
    weather_alerts_enabled: bool = True
    fertilizer_reminders_enabled: bool = True
    preferred_language: str = "en"

    model_config = ConfigDict(from_attributes=True)
