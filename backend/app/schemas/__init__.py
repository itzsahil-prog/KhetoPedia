from app.schemas.user import UserBase, UserCreate, UserUpdate, UserResponse
from app.schemas.auth import (
    LoginRequest,
    SignupRequest,
    TokenPair,
    AuthResponse,
    RefreshTokenRequest,
    ForgotPasswordRequest,
    VerifyOtpRequest,
    ResetPasswordRequest,
    MessageResponse,
)
from app.schemas.dashboard import (
    QuickStatSchema,
    FieldSummarySchema,
    AlertItemSchema,
    DashboardSummaryResponse,
    AlertsListResponse,
)
from app.schemas.profile import (
    ProfileBase,
    ProfileUpdate,
    ProfileResponse,
    ChangePasswordRequest,
    UserSettingsUpdate,
    UserSettingsResponse,
)
from app.schemas.farm import FarmCreate, FarmUpdate, FarmResponse
from app.schemas.field import FieldCreate, FieldUpdate, FieldResponse
from app.schemas.crop_scan import (
    CropScanRequest,
    CropScanResponse,
    CropScanHistoryResponse,
)
from app.schemas.soil import (
    SoilTestCreate,
    SoilTestResponse,
    SoilSummaryResponse,
)
from app.schemas.recommendation import (
    RecommendationCreate,
    RecommendationResponse,
    GenerateRecommendationRequest,
)
from app.schemas.ai import (
    AiChatRequest,
    AiChatResponse,
    AiConversationResponse,
    AiMessageResponse,
)
from app.schemas.sensor import (
    SensorDeviceCreate,
    SensorDeviceResponse,
    SensorReadingCreate,
    SensorReadingResponse,
)
from app.schemas.weather import WeatherResponse, WeatherForecastItem

__all__ = [
    "UserBase",
    "UserCreate",
    "UserUpdate",
    "UserResponse",
    "LoginRequest",
    "SignupRequest",
    "TokenPair",
    "AuthResponse",
    "RefreshTokenRequest",
    "ForgotPasswordRequest",
    "VerifyOtpRequest",
    "ResetPasswordRequest",
    "MessageResponse",
    "QuickStatSchema",
    "FieldSummarySchema",
    "AlertItemSchema",
    "DashboardSummaryResponse",
    "AlertsListResponse",
    "ProfileBase",
    "ProfileUpdate",
    "ProfileResponse",
    "ChangePasswordRequest",
    "UserSettingsUpdate",
    "UserSettingsResponse",
    "FarmCreate",
    "FarmUpdate",
    "FarmResponse",
    "FieldCreate",
    "FieldUpdate",
    "FieldResponse",
    "CropScanRequest",
    "CropScanResponse",
    "CropScanHistoryResponse",
    "SoilTestCreate",
    "SoilTestResponse",
    "SoilSummaryResponse",
    "RecommendationCreate",
    "RecommendationResponse",
    "GenerateRecommendationRequest",
    "AiChatRequest",
    "AiChatResponse",
    "AiConversationResponse",
    "AiMessageResponse",
    "SensorDeviceCreate",
    "SensorDeviceResponse",
    "SensorReadingCreate",
    "SensorReadingResponse",
    "WeatherResponse",
    "WeatherForecastItem",
]
