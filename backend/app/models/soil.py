import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, Float, ForeignKey, String, Text
from sqlalchemy.orm import relationship

from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class SoilTest(Base):
    __tablename__ = "soil_tests"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey("fields.id", ondelete="SET NULL"), nullable=True, index=True)

    test_date = Column(DateTime(timezone=True), default=utc_now, nullable=False)
    source = Column(String(50), default="manual", nullable=False)  # manual, laboratory, sensor

    # Primary chemical & physical metrics
    ph = Column(Float, nullable=False)  # e.g. 6.5
    ec_ds_m = Column(Float, nullable=True)  # Electrical conductivity dS/m
    moisture_percentage = Column(Float, nullable=True)
    organic_carbon_percentage = Column(Float, nullable=True)

    # Macronutrients (kg/ha or ppm)
    nitrogen_kg_ha = Column(Float, nullable=True)
    phosphorus_kg_ha = Column(Float, nullable=True)
    potassium_kg_ha = Column(Float, nullable=True)

    # Micronutrients (ppm)
    zinc_ppm = Column(Float, nullable=True)
    iron_ppm = Column(Float, nullable=True)
    boron_ppm = Column(Float, nullable=True)

    # Heavy Metals / Toxicity (mg/kg or ppm)
    lead_mg_kg = Column(Float, nullable=True)
    cadmium_mg_kg = Column(Float, nullable=True)
    arsenic_mg_kg = Column(Float, nullable=True)

    # Image storage
    report_image_path = Column(String(512), nullable=True)

    # Overall calculated condition
    soil_condition = Column(String(50), default="Healthy", nullable=False)  # Healthy, Attention, Critical
    toxicity_level = Column(String(50), default="Green", nullable=False)  # Green, Yellow, Orange, Red
    evaluation_summary = Column(Text, nullable=True)
    laboratory_name = Column(String(255), nullable=True)

    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", backref="soil_tests")
    field = relationship("Field", backref="soil_tests")
