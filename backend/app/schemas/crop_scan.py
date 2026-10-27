from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class CropScanRequest(BaseModel):
    field_id: Optional[str] = None
    crop_hint: Optional[str] = None


class CropScanResponse(BaseModel):
    id: str
    field_id: Optional[str] = None
    image_path: str
    image_quality_score: float
    is_valid_plant: bool

    crop_identified: str
    crop_confidence: float

    disease_name: Optional[str] = None
    disease_confidence: float = 0.0
    severity: str  # none, mild, moderate, severe

    symptoms_observed: Optional[str] = None
    recommended_treatment: Optional[str] = None
    preventive_measures: Optional[str] = None

    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class CropScanHistoryResponse(BaseModel):
    scans: list[CropScanResponse]
    total: int
    page: int
    page_size: int
