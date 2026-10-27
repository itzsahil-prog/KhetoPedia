"""
Alerts API Endpoints - CRUD operations for alert management.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from slowapi import Limiter
from slowapi.util import get_remote_address

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.alert import (
    AlertResponse,
    MessageResponse,
    BulkMarkReadResponse,
)
from app.services.alert_service import alert_service

router = APIRouter(prefix="/alerts", tags=["Alerts"])
limiter = Limiter(key_func=get_remote_address)


@router.get("", response_model=List[AlertResponse])
async def list_alerts(
    severity: Optional[str] = Query(None, description="Filter by severity: info, warning, critical"),
    alert_type: Optional[str] = Query(None, description="Filter by type: soil, crop, sensor, system"),
    is_read: Optional[bool] = Query(None, description="Filter by read status"),
    field_id: Optional[str] = Query(None, description="Filter by field ID"),
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(20, ge=1, le=100, description="Items per page"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieve paginated list of alerts with optional filtering.
    
    Filters:
    - severity: Filter by alert severity (info, warning, critical)
    - alert_type: Filter by alert type (soil, crop, sensor, system)
    - is_read: Filter by read status (true/false)
    - field_id: Filter alerts for a specific field
    
    Returns list of alerts ordered by creation date (newest first).
    """
    alerts = await alert_service.list_alerts(
        db=db,
        user=current_user,
        severity=severity,
        alert_type=alert_type,
        is_read=is_read,
        field_id=field_id,
        page=page,
        page_size=page_size,
    )
    return [AlertResponse.model_validate(a) for a in alerts]


@router.get("/{alert_id}", response_model=AlertResponse)
async def get_alert(
    alert_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieve a single alert by ID.
    
    Returns 404 if alert doesn't exist or doesn't belong to the current user.
    """
    alert = await alert_service.get_alert(db, current_user, alert_id)
    return AlertResponse.model_validate(alert)


@router.patch("/{alert_id}/read", response_model=AlertResponse)
async def mark_alert_read(
    alert_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Mark an alert as read.
    
    Updates the is_read flag to True and invalidates dashboard cache.
    Returns the updated alert.
    """
    alert = await alert_service.mark_as_read(db, current_user, alert_id)
    return AlertResponse.model_validate(alert)


@router.post("/mark-all-read", response_model=BulkMarkReadResponse)
async def mark_all_alerts_read(
    field_id: Optional[str] = Query(None, description="Optional: mark only alerts for this field"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Mark all unread alerts as read.
    
    Optionally filter by field_id to mark only alerts for a specific field.
    Returns count of alerts marked as read.
    """
    count = await alert_service.mark_all_as_read(db, current_user, field_id)
    return BulkMarkReadResponse(
        count=count,
        message=f"Marked {count} alert(s) as read."
    )


@router.delete("/{alert_id}", response_model=MessageResponse, status_code=status.HTTP_200_OK)
async def delete_alert(
    alert_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete an alert.
    
    Permanently removes the alert from the database.
    Returns 404 if alert doesn't exist or doesn't belong to the current user.
    """
    await alert_service.delete_alert(db, current_user, alert_id)
    return MessageResponse(message="Alert deleted successfully.")
