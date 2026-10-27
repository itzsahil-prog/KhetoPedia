import uuid
from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String, Text
from sqlalchemy.orm import relationship

from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class Recommendation(Base):
    __tablename__ = "recommendations"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    field_id = Column(String(36), ForeignKey("fields.id", ondelete="CASCADE"), nullable=False, index=True)

    category = Column(String(50), nullable=False)  # irrigation, fertilizer, disease_management, soil_health
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    action_required = Column(Text, nullable=False)
    recommended_dosage = Column(String(255), nullable=True)
    urgency = Column(String(50), default="medium", nullable=False)  # low, medium, high, critical
    is_completed = Column(Boolean, default=False, nullable=False)

    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)
    valid_until = Column(DateTime(timezone=True), nullable=True)

    user = relationship("User", backref="recommendations")
    field = relationship("Field", backref="recommendations")
