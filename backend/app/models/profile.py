import uuid
from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text, Float
from sqlalchemy.orm import relationship

from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class Profile(Base):
    __tablename__ = "profiles"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    village = Column(String(255), nullable=True)
    district = Column(String(255), nullable=True)
    state = Column(String(255), nullable=True)
    country = Column(String(100), default="India", nullable=False)
    address = Column(Text, nullable=True)
    primary_crops = Column(String(255), nullable=True)
    total_area_acres = Column(Float, default=0.0, nullable=False)
    farm_count = Column(Integer, default=1, nullable=False)
    farming_experience_years = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now, nullable=False)

    user = relationship("User", backref="profile")


class UserSettings(Base):
    __tablename__ = "user_settings"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    theme_mode = Column(String(20), default="system", nullable=False)  # light, dark, system
    font_size = Column(String(20), default="medium", nullable=False)  # small, medium, large, extra_large
    disease_alerts_enabled = Column(Boolean, default=True, nullable=False)
    soil_alerts_enabled = Column(Boolean, default=True, nullable=False)
    irrigation_reminders_enabled = Column(Boolean, default=True, nullable=False)
    weather_alerts_enabled = Column(Boolean, default=True, nullable=False)
    fertilizer_reminders_enabled = Column(Boolean, default=True, nullable=False)
    preferred_language = Column(String(10), default="en", nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now, nullable=False)

    user = relationship("User", backref="settings")
