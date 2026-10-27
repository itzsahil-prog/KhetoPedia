from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserBase(BaseModel):
    email: EmailStr
    name: str
    phone: Optional[str] = None
    preferred_locale: str = "en"


class UserCreate(UserBase):
    password: str = Field(..., min_length=6)


class UserUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    preferred_locale: Optional[str] = None


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    is_email_verified: bool = False
    preferred_locale: str = "en"
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
