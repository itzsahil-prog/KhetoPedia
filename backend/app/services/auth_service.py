import random
import string
from datetime import datetime, timedelta, timezone
from typing import Optional, Tuple
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.core.config import settings
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.models.user import User, PasswordResetToken
from app.schemas.auth import SignupRequest, TokenPair, AuthResponse
from app.schemas.user import UserResponse


class AuthService:
    @staticmethod
    async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
        stmt = select(User).where(User.email == email.lower().strip())
        result = await db.execute(stmt)
        return result.scalars().first()

    @staticmethod
    async def get_user_by_id(db: AsyncSession, user_id: str) -> Optional[User]:
        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        return result.scalars().first()

    @staticmethod
    async def register_user(db: AsyncSession, signup_data: SignupRequest) -> Tuple[User, TokenPair]:
        clean_email = signup_data.email.lower().strip()
        existing = await AuthService.get_user_by_email(db, clean_email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="An account with this email already exists.",
                headers={"X-Error-Code": "EMAIL_EXISTS"}
            )

        new_user = User(
            email=clean_email,
            name=signup_data.name.strip(),
            phone=signup_data.phone.strip() if signup_data.phone else None,
            hashed_password=get_password_hash(signup_data.password),
            preferred_locale=signup_data.preferred_locale or "en",
            is_active=True,
            is_email_verified=False,
        )
        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)

        tokens = AuthService.create_token_pair(new_user)
        return new_user, tokens

    @staticmethod
    async def authenticate(db: AsyncSession, email: str, password: str) -> Tuple[User, TokenPair]:
        user = await AuthService.get_user_by_email(db, email)
        if not user or not verify_password(password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
                headers={"WWW-Authenticate": "Bearer"}
            )
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="This account has been deactivated."
            )

        tokens = AuthService.create_token_pair(user)
        return user, tokens

    @staticmethod
    def create_token_pair(user: User) -> TokenPair:
        access_tok, access_exp = create_access_token(subject=user.id, extra_claims={"email": user.email})
        refresh_tok, refresh_exp = create_refresh_token(subject=user.id)
        return TokenPair(
            access_token=access_tok,
            refresh_token=refresh_tok,
            access_token_expires_at=access_exp,
            refresh_token_expires_at=refresh_exp,
        )

    @staticmethod
    async def refresh_tokens(db: AsyncSession, refresh_token: str) -> TokenPair:
        payload = decode_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token."
            )

        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token subject invalid."
            )

        user = await AuthService.get_user_by_id(db, user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive."
            )

        return AuthService.create_token_pair(user)

    @staticmethod
    async def create_password_reset_otp(db: AsyncSession, email: str) -> str:
        clean_email = email.lower().strip()
        user = await AuthService.get_user_by_email(db, clean_email)
        # Even if user does not exist, return a dummy OTP without leaking account existence
        otp = "".join(random.choices(string.digits, k=6))
        
        if user:
            expires_at = datetime.now(timezone.utc) + timedelta(minutes=settings.OTP_EXPIRE_MINUTES)
            reset_record = PasswordResetToken(
                user_id=user.id,
                email=clean_email,
                otp_code=otp,
                expires_at=expires_at,
                is_used=False,
            )
            db.add(reset_record)
            await db.commit()
            print(f"[AUTH] Generated password reset OTP for {clean_email}: {otp}")

        return otp

    @staticmethod
    async def verify_reset_otp(db: AsyncSession, email: str, otp: str) -> PasswordResetToken:
        clean_email = email.lower().strip()
        now = datetime.now(timezone.utc)
        stmt = (
            select(PasswordResetToken)
            .where(
                and_(
                    PasswordResetToken.email == clean_email,
                    PasswordResetToken.otp_code == otp.strip(),
                    PasswordResetToken.is_used == False,
                    PasswordResetToken.expires_at > now,
                )
            )
            .order_by(PasswordResetToken.created_at.desc())
        )
        result = await db.execute(stmt)
        record = result.scalars().first()
        if not record:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired OTP verification code.",
                headers={"X-Error-Code": "INVALID_OTP"}
            )
        return record

    @staticmethod
    async def reset_password_with_otp(
        db: AsyncSession, email: str, otp: str, new_password: str
    ) -> None:
        token_record = await AuthService.verify_reset_otp(db, email, otp)
        user = await AuthService.get_user_by_id(db, token_record.user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Associated user not found."
            )

        user.hashed_password = get_password_hash(new_password)
        token_record.is_used = True
        await db.commit()


auth_service = AuthService()
