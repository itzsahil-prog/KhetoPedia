from typing import List, Optional
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.farm import Farm
from app.models.dashboard import Field
from app.models.user import User
from app.schemas.farm import FarmCreate, FarmUpdate, FarmResponse
from app.schemas.field import FieldCreate, FieldUpdate, FieldResponse


class FarmService:
    # ── Farms ─────────────────────────────────────────────────────────────
    @staticmethod
    async def list_farms(db: AsyncSession, user: User) -> List[Farm]:
        stmt = select(Farm).where(Farm.user_id == user.id).order_by(desc(Farm.created_at))
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_farm(db: AsyncSession, user: User, farm_id: str) -> Farm:
        stmt = select(Farm).where(Farm.id == farm_id, Farm.user_id == user.id)
        result = await db.execute(stmt)
        farm = result.scalars().first()
        if not farm:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Farm not found.")
        return farm

    @staticmethod
    async def create_farm(db: AsyncSession, user: User, data: FarmCreate) -> Farm:
        farm = Farm(
            user_id=user.id,
            name=data.name.strip(),
            location=data.location.strip() if data.location else None,
            latitude=data.latitude,
            longitude=data.longitude,
            total_area_acres=data.total_area_acres,
            soil_type=data.soil_type,
            irrigation_source=data.irrigation_source,
            notes=data.notes,
        )
        db.add(farm)
        await db.commit()
        await db.refresh(farm)
        return farm

    @staticmethod
    async def update_farm(db: AsyncSession, user: User, farm_id: str, data: FarmUpdate) -> Farm:
        farm = await FarmService.get_farm(db, user, farm_id)
        for key, val in data.model_dump(exclude_unset=True).items():
            setattr(farm, key, val)
        await db.commit()
        await db.refresh(farm)
        return farm

    @staticmethod
    async def delete_farm(db: AsyncSession, user: User, farm_id: str) -> None:
        farm = await FarmService.get_farm(db, user, farm_id)
        await db.delete(farm)
        await db.commit()

    # ── Fields ────────────────────────────────────────────────────────────
    @staticmethod
    async def list_fields(db: AsyncSession, user: User) -> List[Field]:
        stmt = select(Field).where(Field.user_id == user.id).order_by(desc(Field.updated_at))
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_field(db: AsyncSession, user: User, field_id: str) -> Field:
        stmt = select(Field).where(Field.id == field_id, Field.user_id == user.id)
        result = await db.execute(stmt)
        field = result.scalars().first()
        if not field:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Field not found.")
        return field

    @staticmethod
    async def create_field(db: AsyncSession, user: User, data: FieldCreate) -> Field:
        field = Field(
            user_id=user.id,
            name=data.name.strip(),
            crop_name=data.crop_name.strip() if data.crop_name else "Wheat",
            acreage=data.acreage,
            location_name=data.location_name.strip() if data.location_name else None,
            latitude=data.latitude,
            longitude=data.longitude,
            health_score=data.health_score,
            soil_status=data.soil_status,
            water_status=data.water_status,
        )
        db.add(field)
        await db.commit()
        await db.refresh(field)
        return field

    @staticmethod
    async def update_field(db: AsyncSession, user: User, field_id: str, data: FieldUpdate) -> Field:
        field = await FarmService.get_field(db, user, field_id)
        for key, val in data.model_dump(exclude_unset=True).items():
            setattr(field, key, val)
        await db.commit()
        await db.refresh(field)
        return field

    @staticmethod
    async def delete_field(db: AsyncSession, user: User, field_id: str) -> None:
        field = await FarmService.get_field(db, user, field_id)
        await db.delete(field)
        await db.commit()


farm_service = FarmService()
