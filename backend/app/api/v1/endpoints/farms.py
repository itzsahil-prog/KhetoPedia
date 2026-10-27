from typing import List, Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.auth import MessageResponse
from app.schemas.farm import FarmCreate, FarmResponse, FarmUpdate
from app.schemas.field import FieldCreate, FieldResponse, FieldUpdate
from app.services.farm_service import farm_service
from app.services.cache_service import cache_service

router = APIRouter(prefix="/farms", tags=["Farms & Fields"])


# ── Farms ─────────────────────────────────────────────────────────────────────

@router.get("", response_model=List[FarmResponse])
async def list_farms(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all farms owned by the authenticated farmer."""
    farms = await farm_service.list_farms(db, current_user)
    return [FarmResponse.model_validate(f) for f in farms]


@router.post("", response_model=FarmResponse, status_code=status.HTTP_201_CREATED)
async def create_farm(
    data: FarmCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Register a new farm under the authenticated farmer's account."""
    farm = await farm_service.create_farm(db, current_user, data)
    return FarmResponse.model_validate(farm)


@router.get("/{farm_id}", response_model=FarmResponse)
async def get_farm(
    farm_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a specific farm by ID."""
    farm = await farm_service.get_farm(db, current_user, farm_id)
    return FarmResponse.model_validate(farm)


@router.put("/{farm_id}", response_model=FarmResponse)
async def update_farm(
    farm_id: str,
    data: FarmUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update farm details."""
    farm = await farm_service.update_farm(db, current_user, farm_id, data)
    return FarmResponse.model_validate(farm)


@router.delete("/{farm_id}", response_model=MessageResponse)
async def delete_farm(
    farm_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a farm and all associated data."""
    await farm_service.delete_farm(db, current_user, farm_id)
    return MessageResponse(message="Farm deleted successfully.")


# ── Fields ────────────────────────────────────────────────────────────────────

@router.get("/fields/all", response_model=List[FieldResponse])
async def list_all_fields(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all fields across all farms owned by the authenticated farmer."""
    fields = await farm_service.list_fields(db, current_user)
    return [FieldResponse.model_validate(f) for f in fields]


@router.post("/fields", response_model=FieldResponse, status_code=status.HTTP_201_CREATED)
async def create_field(
    data: FieldCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Register a new crop field under the authenticated farmer's account."""
    field = await farm_service.create_field(db, current_user, data)
    # Invalidate dashboard cache
    await cache_service.delete(f"dashboard:summary:{current_user.id}")
    return FieldResponse.model_validate(field)


@router.get("/fields/{field_id}", response_model=FieldResponse)
async def get_field(
    field_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a specific crop field by ID."""
    field = await farm_service.get_field(db, current_user, field_id)
    return FieldResponse.model_validate(field)


@router.put("/fields/{field_id}", response_model=FieldResponse)
async def update_field(
    field_id: str,
    data: FieldUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update crop field details (crop name, acreage, soil/water status)."""
    field = await farm_service.update_field(db, current_user, field_id, data)
    # Invalidate dashboard cache
    await cache_service.delete(f"dashboard:summary:{current_user.id}")
    return FieldResponse.model_validate(field)


@router.delete("/fields/{field_id}", response_model=MessageResponse)
async def delete_field(
    field_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a field and all associated scans, soil tests, and readings."""
    await farm_service.delete_field(db, current_user, field_id)
    return MessageResponse(message="Field deleted successfully.")
