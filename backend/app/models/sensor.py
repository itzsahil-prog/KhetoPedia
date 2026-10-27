import uuid
from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, String
from sqlalchemy.orm import relationship

from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class SensorDevice(Base):
    __tablename__ = "sensor_devices"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    device_uid = Column(String(100), unique=True, nullable=False, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey("fields.id", ondelete="SET NULL"), nullable=True, index=True)
    model_name = Column(String(100), default="AgriSense ESP32 Soil Probe", nullable=False)
    api_key_hash = Column(String(255), nullable=True)  # Secret token for IoT gateway authentication
    is_active = Column(Boolean, default=True, nullable=False)
    battery_level = Column(Float, default=100.0, nullable=True)
    last_seen_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", backref="sensor_devices")
    field = relationship("Field", backref="sensor_devices")
    readings = relationship("SensorReading", back_populates="sensor", cascade="all, delete-orphan", order_by="desc(SensorReading.recorded_at)")


class SensorReading(Base):
    __tablename__ = "sensor_readings"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    sensor_id = Column(String(36), ForeignKey("sensor_devices.id", ondelete="CASCADE"), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey("fields.id", ondelete="SET NULL"), nullable=True, index=True)

    soil_moisture_percentage = Column(Float, nullable=False)
    soil_temperature_celsius = Column(Float, nullable=True)
    ambient_temperature_celsius = Column(Float, nullable=True)
    ambient_humidity_percentage = Column(Float, nullable=True)
    soil_ph = Column(Float, nullable=True)
    soil_ec_ds_m = Column(Float, nullable=True)

    recorded_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    sensor = relationship("SensorDevice", back_populates="readings")
    field = relationship("Field")
