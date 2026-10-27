import uuid
from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class CropScan(Base):
    __tablename__ = "crop_scans"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey("fields.id", ondelete="SET NULL"), nullable=True, index=True)

    image_path = Column(String(512), nullable=False)
    image_quality_score = Column(Float, default=0.9, nullable=False)
    is_valid_plant = Column(Boolean, default=True, nullable=False)

    crop_identified = Column(String(255), nullable=False)
    crop_confidence = Column(Float, default=0.95, nullable=False)

    disease_name = Column(String(255), nullable=True)  # Null or "Healthy" if no disease
    disease_confidence = Column(Float, default=0.0, nullable=False)
    severity = Column(String(50), default="none", nullable=False)  # none, mild, moderate, severe

    symptoms_observed = Column(Text, nullable=True)
    recommended_treatment = Column(Text, nullable=True)
    preventive_measures = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", backref="crop_scans")
    field = relationship("Field", backref="crop_scans")
