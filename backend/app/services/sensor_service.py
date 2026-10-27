import uuid
from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.sensor import SensorDevice, SensorReading
from app.models.dashboard import Field, Alert
from app.models.user import User
from app.schemas.sensor import SensorDeviceCreate, SensorReadingCreate


class SensorService:
    @staticmethod
    async def register_sensor(
        db: AsyncSession, user: User, data: SensorDeviceCreate
    ) -> SensorDevice:
        clean_uid = data.device_uid.strip()
        existing_stmt = select(SensorDevice).where(SensorDevice.device_uid == clean_uid)
        existing = (await db.execute(existing_stmt)).scalars().first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Sensor with Device UID '{clean_uid}' is already registered.",
            )

        # Validate field ownership if field_id provided
        if data.field_id:
            field_stmt = select(Field).where(Field.id == data.field_id, Field.user_id == user.id)
            field = (await db.execute(field_stmt)).scalars().first()
            if not field:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Specified field does not exist.")

        device = SensorDevice(
            device_uid=clean_uid,
            user_id=user.id,
            field_id=data.field_id,
            model_name=data.model_name or "AgriSense ESP32 Soil Probe",
            is_active=True,
            last_seen_at=datetime.now(timezone.utc),
        )
        db.add(device)
        await db.commit()
        await db.refresh(device)
        return device

    @staticmethod
    async def list_sensors(db: AsyncSession, user: User) -> List[SensorDevice]:
        stmt = select(SensorDevice).where(SensorDevice.user_id == user.id).order_by(desc(SensorDevice.created_at))
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def record_reading(
        db: AsyncSession, data: SensorReadingCreate
    ) -> SensorReading:
        # Authenticate device UID
        stmt = select(SensorDevice).where(SensorDevice.device_uid == data.device_uid.strip())
        device = (await db.execute(stmt)).scalars().first()
        if not device or not device.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Unauthorized or unregistered sensor device.",
            )

        now = datetime.now(timezone.utc)
        device.last_seen_at = now

        reading = SensorReading(
            sensor_id=device.id,
            field_id=device.field_id,
            soil_moisture_percentage=data.soil_moisture_percentage,
            soil_temperature_celsius=data.soil_temperature_celsius,
            ambient_temperature_celsius=data.ambient_temperature_celsius,
            ambient_humidity_percentage=data.ambient_humidity_percentage,
            soil_ph=data.soil_ph,
            soil_ec_ds_m=data.soil_ec_ds_m,
            recorded_at=now,
        )
        db.add(reading)

        # If sensor is attached to a field, update field condition in real-time
        if device.field_id:
            field_stmt = select(Field).where(Field.id == device.field_id)
            field = (await db.execute(field_stmt)).scalars().first()
            if field:
                if data.soil_moisture_percentage < 25.0:
                    field.water_status = "Needs Irrigation"
                    # Trigger alert if moisture is severely depleted
                    if data.soil_moisture_percentage < 18.0:
                        alert = Alert(
                            user_id=device.user_id,
                            field_id=field.id,
                            title="Critical Low Soil Moisture",
                            message=f"IoT Sensor on '{field.name}' reported {data.soil_moisture_percentage}% moisture. Water stress imminent.",
                            severity="critical",
                            alert_type="soil",
                            is_read=False,
                        )
                        db.add(alert)
                elif data.soil_moisture_percentage > 75.0:
                    field.water_status = "Waterlogged"
                else:
                    field.water_status = "Adequate"

                if data.soil_ph is not None:
                    field.soil_status = "Healthy" if 6.0 <= data.soil_ph <= 7.8 else "Attention"

        await db.commit()
        await db.refresh(reading)
        return reading

    @staticmethod
    async def get_historical_readings(
        db: AsyncSession, user: User, sensor_id: str, limit: int = 50
    ) -> List[SensorReading]:
        device_stmt = select(SensorDevice).where(SensorDevice.id == sensor_id, SensorDevice.user_id == user.id)
        device = (await db.execute(device_stmt)).scalars().first()
        if not device:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sensor device not found.")

        stmt = (
            select(SensorReading)
            .where(SensorReading.sensor_id == sensor_id)
            .order_by(desc(SensorReading.recorded_at))
            .limit(limit)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())


sensor_service = SensorService()
