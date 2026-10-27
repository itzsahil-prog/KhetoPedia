from typing import Optional, Tuple
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.core.security import get_password_hash, verify_password
from app.models.user import User
from app.models.profile import Profile, UserSettings
from app.models.dashboard import Field
from app.schemas.profile import (
    ProfileResponse,
    ProfileUpdate,
    UserSettingsResponse,
    UserSettingsUpdate,
)


class UserService:
    @staticmethod
    async def get_or_create_profile(db: AsyncSession, user: User) -> Profile:
        stmt = select(Profile).where(Profile.user_id == user.id)
        result = await db.execute(stmt)
        profile = result.scalars().first()
        if not profile:
            # Count user fields and area
            fields_stmt = select(Field).where(Field.user_id == user.id)
            fields_res = await db.execute(fields_stmt)
            fields = list(fields_res.scalars().all())
            total_acres = sum(f.acreage or 0.0 for f in fields)

            profile = Profile(
                user_id=user.id,
                total_area_acres=total_acres,
                farm_count=1 if fields else 0,
            )
            db.add(profile)
            await db.commit()
            await db.refresh(profile)
        return profile

    @staticmethod
    async def get_profile_response(db: AsyncSession, user: User) -> ProfileResponse:
        profile = await UserService.get_or_create_profile(db, user)

        # Refresh area & farm count from current fields
        fields_stmt = select(Field).where(Field.user_id == user.id)
        fields = list((await db.execute(fields_stmt)).scalars().all())
        total_acres = sum(f.acreage or 0.0 for f in fields)

        return ProfileResponse(
            id=profile.id,
            user_id=user.id,
            user_name=user.name,
            user_email=user.email,
            user_phone=user.phone,
            avatar_url=user.avatar_url,
            preferred_locale=user.preferred_locale,
            village=profile.village,
            district=profile.district,
            state=profile.state,
            country=profile.country,
            address=profile.address,
            primary_crops=profile.primary_crops,
            total_area_acres=round(total_acres, 2),
            farm_count=len(fields),
            farming_experience_years=profile.farming_experience_years,
            created_at=profile.created_at,
        )

    @staticmethod
    async def update_profile(
        db: AsyncSession, user: User, update_data: ProfileUpdate
    ) -> ProfileResponse:
        profile = await UserService.get_or_create_profile(db, user)

        # Update User fields if provided
        if update_data.name is not None:
            user.name = update_data.name.strip()
        if update_data.phone is not None:
            user.phone = update_data.phone.strip()
        if update_data.avatar_url is not None:
            user.avatar_url = update_data.avatar_url.strip()
        if update_data.preferred_locale is not None:
            user.preferred_locale = update_data.preferred_locale.strip()

        # Update Profile fields if provided
        if update_data.village is not None:
            profile.village = update_data.village.strip()
        if update_data.district is not None:
            profile.district = update_data.district.strip()
        if update_data.state is not None:
            profile.state = update_data.state.strip()
        if update_data.country is not None:
            profile.country = update_data.country.strip()
        if update_data.address is not None:
            profile.address = update_data.address.strip()
        if update_data.primary_crops is not None:
            profile.primary_crops = update_data.primary_crops.strip()
        if update_data.farming_experience_years is not None:
            profile.farming_experience_years = update_data.farming_experience_years

        await db.commit()
        await db.refresh(user)
        await db.refresh(profile)

        return await UserService.get_profile_response(db, user)

    @staticmethod
    async def change_password(
        db: AsyncSession, user: User, current_password: str, new_password: str
    ) -> None:
        if not verify_password(current_password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect.",
            )
        user.hashed_password = get_password_hash(new_password)
        await db.commit()

    @staticmethod
    async def get_or_create_settings(db: AsyncSession, user: User) -> UserSettings:
        stmt = select(UserSettings).where(UserSettings.user_id == user.id)
        settings_record = (await db.execute(stmt)).scalars().first()
        if not settings_record:
            settings_record = UserSettings(
                user_id=user.id,
                preferred_language=user.preferred_locale or "en",
            )
            db.add(settings_record)
            await db.commit()
            await db.refresh(settings_record)
        return settings_record

    @staticmethod
    async def update_settings(
        db: AsyncSession, user: User, update_data: UserSettingsUpdate
    ) -> UserSettingsResponse:
        settings_record = await UserService.get_or_create_settings(db, user)

        for key, val in update_data.model_dump(exclude_unset=True).items():
            setattr(settings_record, key, val)

        await db.commit()
        await db.refresh(settings_record)
        return UserSettingsResponse.model_validate(settings_record)


user_service = UserService()
