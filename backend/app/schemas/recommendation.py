from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class RecommendationCreate(BaseModel):
    field_id: str
    category: str  # irrigation, fertilizer, disease_management, soil_health
    title: str
    description: str
    action_required: str
    recommended_dosage: Optional[str] = None
    urgency: str = "medium"  # low, medium, high, critical
    valid_until: Optional[datetime] = None


class RecommendationResponse(BaseModel):
    id: str
    user_id: str
    field_id: str
    field_name: Optional[str] = None
    category: str
    title: str
    description: str
    action_required: str
    recommended_dosage: Optional[str] = None
    urgency: str
    is_completed: bool
    created_at: datetime
    valid_until: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class GenerateRecommendationRequest(BaseModel):
    crop_stage: Optional[str] = "Vegetative"  # Germination, Vegetative, Flowering, Fruiting, Harvesting
    observed_stress: Optional[str] = None
