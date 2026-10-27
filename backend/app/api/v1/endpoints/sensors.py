from typing import List
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.sensor import (
    SensorDeviceCreate,
    SensorDeviceResponse,
    SensorReadingCreate,
    SensorReadingResponse,
)
from app.services.sensor_service import sensor_service

router = APIRouter(prefix="/sensors", tags=["IoT Sensors"])


@router.post("/register", response_model=SensorDeviceResponse, status_code=status.HTTP_201_CREATED)
async def register_sensor(
    data: SensorDeviceCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Register an IoT soil sensor device to the authenticated farmer's account.

    Each device must have a unique Device UID. If a field_id is provided,
    the sensor readings will automatically update that field's moisture
    and water status in real-time.
    """
    device = await sensor_service.register_sensor(db, current_user, data)
    return SensorDeviceResponse(
        id=device.id,
        device_uid=device.device_uid,
        user_id=device.user_id,
        field_id=device.field_id,
        field_name=None,
        model_name=device.model_name,
        is_active=device.is_active,
        battery_level=device.battery_level,
        last_seen_at=device.last_seen_at,
        created_at=device.created_at,
    )


@router.get("", response_model=List[SensorDeviceResponse])
async def list_sensors(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all registered IoT sensor devices for the authenticated farmer."""
    devices = await sensor_service.list_sensors(db, current_user)
    return [
        SensorDeviceResponse(
            id=d.id,
            device_uid=d.device_uid,
            user_id=d.user_id,
            field_id=d.field_id,
            field_name=None,
            model_name=d.model_name,
            is_active=d.is_active,
            battery_level=d.battery_level,
            last_seen_at=d.last_seen_at,
            created_at=d.created_at,
        )
        for d in devices
    ]


@router.post("/readings", response_model=SensorReadingResponse, status_code=status.HTTP_201_CREATED)
async def submit_reading(
    data: SensorReadingCreate,
    db: AsyncSession = Depends(get_db),
):
    """
    Submit a sensor reading from an IoT device (no user auth required; device UID is the identifier).

    The device UID must match a registered sensor. Unauthorized device UIDs are rejected.
    Updates the associated field water status and generates low-moisture alerts.
    """
    reading = await sensor_service.record_reading(db, data)
    return SensorReadingResponse.model_validate(reading)


@router.get("/{sensor_id}/readings", response_model=List[SensorReadingResponse])
async def get_sensor_readings(
    sensor_id: str,
    limit: int = Query(50, ge=1, le=500),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve historical sensor readings for a specific device."""
    readings = await sensor_service.get_historical_readings(db, current_user, sensor_id, limit)
    return [SensorReadingResponse.model_validate(r) for r in readings]
