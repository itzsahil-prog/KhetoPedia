from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.schemas.user import UserResponse


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class SignupRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)
    phone: Optional[str] = None
    preferred_locale: str = "en"


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    access_token_expires_at: Optional[datetime] = None
    refresh_token_expires_at: Optional[datetime] = None


class AuthResponse(BaseModel):
    tokens: TokenPair
    user: UserResponse
    # Flat top-level keys for maximum client compatibility
    access_token: str
    refresh_token: str
    access_token_expires_at: Optional[datetime] = None
    refresh_token_expires_at: Optional[datetime] = None


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: str


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp: str
    new_password: str = Field(..., min_length=6, max_length=128)


class MessageResponse(BaseModel):
    message: str
    status: str = "success"
