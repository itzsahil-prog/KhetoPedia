from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timezone

from app.api.deps import get_current_user
from app.core.database import get_db
from app.core.security import decode_token
from app.models.user import User
from app.schemas.auth import (
    AuthResponse,
    ForgotPasswordRequest,
    LoginRequest,
    MessageResponse,
    RefreshTokenRequest,
    ResetPasswordRequest,
    SignupRequest,
    TokenPair,
    VerifyOtpRequest,
)
from app.schemas.user import UserResponse
from app.services.auth_service import auth_service
from app.services.token_blocklist_service import token_blocklist_service
from app.middleware.rate_limit import limiter

router = APIRouter(prefix="/auth", tags=["Authentication"])
security_bearer = HTTPBearer(auto_error=False)


def _format_auth_response(user: User, tokens: TokenPair) -> AuthResponse:
    user_dto = UserResponse.model_validate(user)
    return AuthResponse(
        tokens=tokens,
        user=user_dto,
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        access_token_expires_at=tokens.access_token_expires_at,
        refresh_token_expires_at=tokens.refresh_token_expires_at,
    )


@router.post("/signup", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def signup(
    data: SignupRequest,
    db: AsyncSession = Depends(get_db),
):
    """Register a new farmer account and issue JWT access & refresh tokens."""
    user, tokens = await auth_service.register_user(db, data)
    return _format_auth_response(user, tokens)


@router.post("/login", response_model=AuthResponse)
@limiter.limit("10/hour")
async def login(
    request: Request,
    data: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    """Authenticate with email and password and issue tokens."""
    user, tokens = await auth_service.authenticate(db, data.email, data.password)
    return _format_auth_response(user, tokens)


@router.post("/refresh", response_model=TokenPair)
async def refresh_token(
    data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
):
    """Exchange a valid refresh token for a fresh token pair."""
    return await auth_service.refresh_tokens(db, data.refresh_token)


@router.post("/logout", response_model=MessageResponse)
async def logout(
    cred: HTTPAuthorizationCredentials = Depends(security_bearer),
):
    """Logout by blocklisting the access token."""
    if not cred or not cred.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication credentials were not provided."
        )
    
    token = cred.credentials
    payload = decode_token(token)
    
    if payload and payload.get("jti") and payload.get("exp"):
        jti = payload.get("jti")
        exp_timestamp = payload.get("exp")
        expires_at = datetime.fromtimestamp(exp_timestamp, tz=timezone.utc)
        
        await token_blocklist_service.blocklist_token(jti, expires_at)
    
    return MessageResponse(message="Successfully logged out.")


@router.post("/forgot-password", response_model=MessageResponse)
@limiter.limit("10/hour")
async def forgot_password(
    request: Request,
    data: ForgotPasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    """Initiate password recovery. Generates short-lived secure OTP."""
    await auth_service.create_password_reset_otp(db, data.email)
    # Generic security message prevents email enumeration
    return MessageResponse(
        message="If an account exists with this email, a verification code has been dispatched."
    )


@router.post("/verify-otp", response_model=MessageResponse)
async def verify_otp(
    data: VerifyOtpRequest,
    db: AsyncSession = Depends(get_db),
):
    """Verify that an entered OTP code is valid and unexpired."""
    await auth_service.verify_reset_otp(db, data.email, data.otp)
    return MessageResponse(message="Verification code validated successfully.")


@router.post("/reset-password", response_model=MessageResponse)
async def reset_password(
    data: ResetPasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    """Reset password using verified OTP code."""
    await auth_service.reset_password_with_otp(
        db, data.email, data.otp, data.new_password
    )
    return MessageResponse(message="Password has been updated successfully. Please sign in.")


@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: User = Depends(get_current_user),
):
    """Retrieve profile of the currently authenticated user."""
    return UserResponse.model_validate(current_user)
