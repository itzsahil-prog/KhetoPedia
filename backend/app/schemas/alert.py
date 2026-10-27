"""
Alert Schemas - Pydantic models for alert API responses.
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class AlertResponse(BaseModel):
    """Response model for alert data."""
    id: str
    user_id: str
    field_id: Optional[str] = None
    title: str
    message: str
    severity: str  # info, warning, critical
    alert_type: str  # soil, crop, sensor, system
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class AlertUpdateRequest(BaseModel):
    """Request model for updating alert read status."""
    is_read: bool


class MessageResponse(BaseModel):
    """Generic message response."""
    message: str


class BulkMarkReadResponse(BaseModel):
    """Response for bulk mark as read operation."""
    count: int
    message: str
