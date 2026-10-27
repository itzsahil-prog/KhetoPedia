from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.auth import MessageResponse
from app.schemas.profile import (
    ChangePasswordRequest,
    ProfileResponse,
    ProfileUpdate,
    UserSettingsResponse,
    UserSettingsUpdate,
)
from app.services.user_service import user_service

router = APIRouter(prefix="/users", tags=["Users & Profile"])


@router.get("/profile", response_model=ProfileResponse)
async def get_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve complete farmer profile with acreage and farm statistics."""
    return await user_service.get_profile_response(db, current_user)


@router.put("/profile", response_model=ProfileResponse)
async def update_profile(
    data: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update farmer profile details, location, and farming preferences."""
    return await user_service.update_profile(db, current_user, data)


@router.put("/change-password", response_model=MessageResponse)
async def change_password(
    data: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Securely update account password verifying current password."""
    await user_service.change_password(db, current_user, data.current_password, data.new_password)
    return MessageResponse(message="Password successfully updated.")


@router.get("/settings", response_model=UserSettingsResponse)
async def get_settings(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve app settings and notification preferences."""
    settings_record = await user_service.get_or_create_settings(db, current_user)
    return UserSettingsResponse.model_validate(settings_record)


@router.put("/settings", response_model=UserSettingsResponse)
async def update_settings(
    data: UserSettingsUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update notification preferences, theme mode, and font size."""
    return await user_service.update_settings(db, current_user, data)
