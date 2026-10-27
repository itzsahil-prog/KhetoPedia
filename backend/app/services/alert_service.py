"""
Alert Service - Manages alert lifecycle and filtering.
"""

from typing import List, Optional
from sqlalchemy import select, desc, and_
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.dashboard import Alert
from app.models.user import User
from app.services.cache_service import cache_service


class AlertService:
    """Service for alert management and CRUD operations."""

    @staticmethod
    async def list_alerts(
        db: AsyncSession,
        user: User,
        severity: Optional[str] = None,
        alert_type: Optional[str] = None,
        is_read: Optional[bool] = None,
        field_id: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> List[Alert]:
        """
        List alerts with optional filtering.
        
        Args:
            db: Database session
            user: Current user
            severity: Filter by severity (info, warning, critical)
            alert_type: Filter by type (soil, crop, sensor, system)
            is_read: Filter by read status
            field_id: Filter by field
            page: Page number (1-indexed)
            page_size: Number of items per page
            
        Returns:
            List of alerts
        """
        stmt = select(Alert).where(Alert.user_id == user.id)
        
        if severity:
            stmt = stmt.where(Alert.severity == severity)
        if alert_type:
            stmt = stmt.where(Alert.alert_type == alert_type)
        if is_read is not None:
            stmt = stmt.where(Alert.is_read == is_read)
        if field_id:
            stmt = stmt.where(Alert.field_id == field_id)
        
        stmt = stmt.order_by(desc(Alert.created_at))
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)
        
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_alert(
        db: AsyncSession,
        user: User,
        alert_id: str,
    ) -> Alert:
        """
        Get a single alert by ID with ownership check.
        
        Args:
            db: Database session
            user: Current user
            alert_id: Alert ID
            
        Returns:
            Alert instance
            
        Raises:
            HTTPException: If alert not found or not owned by user
        """
        stmt = select(Alert).where(
            and_(Alert.id == alert_id, Alert.user_id == user.id)
        )
        alert = (await db.execute(stmt)).scalars().first()
        
        if not alert:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Alert not found."
            )
        
        return alert

    @staticmethod
    async def mark_as_read(
        db: AsyncSession,
        user: User,
        alert_id: str,
    ) -> Alert:
        """
        Mark an alert as read.
        
        Args:
            db: Database session
            user: Current user
            alert_id: Alert ID
            
        Returns:
            Updated alert
            
        Raises:
            HTTPException: If alert not found or not owned by user
        """
        alert = await AlertService.get_alert(db, user, alert_id)
        
        alert.is_read = True
        await db.commit()
        await db.refresh(alert)
        
        # Invalidate dashboard cache
        await cache_service.delete(f"dashboard:summary:{user.id}")
        
        return alert

    @staticmethod
    async def delete_alert(
        db: AsyncSession,
        user: User,
        alert_id: str,
    ) -> None:
        """
        Delete an alert with ownership check.
        
        Args:
            db: Database session
            user: Current user
            alert_id: Alert ID
            
        Raises:
            HTTPException: If alert not found or not owned by user
        """
        alert = await AlertService.get_alert(db, user, alert_id)
        
        await db.delete(alert)
        await db.commit()
        
        # Invalidate dashboard cache
        await cache_service.delete(f"dashboard:summary:{user.id}")

    @staticmethod
    async def mark_all_as_read(
        db: AsyncSession,
        user: User,
        field_id: Optional[str] = None,
    ) -> int:
        """
        Mark all unread alerts as read, optionally filtered by field.
        
        Args:
            db: Database session
            user: Current user
            field_id: Optional field ID filter
            
        Returns:
            Number of alerts marked as read
        """
        stmt = select(Alert).where(
            and_(Alert.user_id == user.id, Alert.is_read == False)
        )
        
        if field_id:
            stmt = stmt.where(Alert.field_id == field_id)
        
        result = await db.execute(stmt)
        alerts = list(result.scalars().all())
        
        count = 0
        for alert in alerts:
            alert.is_read = True
            count += 1
        
        if count > 0:
            await db.commit()
            # Invalidate dashboard cache
            await cache_service.delete(f"dashboard:summary:{user.id}")
        
        return count


alert_service = AlertService()
