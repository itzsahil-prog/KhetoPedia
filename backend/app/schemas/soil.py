from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class SoilTestCreate(BaseModel):
    field_id: Optional[str] = None
    source: str = "manual"  # manual, laboratory, sensor
    test_date: Optional[datetime] = None

    ph: float = Field(..., ge=0.0, le=14.0)
    ec_ds_m: Optional[float] = Field(None, ge=0.0)  # Electrical conductivity
    moisture_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)
    organic_carbon_percentage: Optional[float] = Field(None, ge=0.0)

    nitrogen_kg_ha: Optional[float] = Field(None, ge=0.0)
    phosphorus_kg_ha: Optional[float] = Field(None, ge=0.0)
    potassium_kg_ha: Optional[float] = Field(None, ge=0.0)

    zinc_ppm: Optional[float] = None
    iron_ppm: Optional[float] = None
    boron_ppm: Optional[float] = None

    lead_mg_kg: Optional[float] = None
    cadmium_mg_kg: Optional[float] = None
    arsenic_mg_kg: Optional[float] = None

    laboratory_name: Optional[str] = None


class SoilTestResponse(BaseModel):
    id: str
    user_id: str
    field_id: Optional[str] = None
    test_date: datetime
    source: str

    ph: float
    ec_ds_m: Optional[float] = None
    moisture_percentage: Optional[float] = None
    organic_carbon_percentage: Optional[float] = None

    nitrogen_kg_ha: Optional[float] = None
    phosphorus_kg_ha: Optional[float] = None
    potassium_kg_ha: Optional[float] = None

    zinc_ppm: Optional[float] = None
    iron_ppm: Optional[float] = None
    boron_ppm: Optional[float] = None

    lead_mg_kg: Optional[float] = None
    cadmium_mg_kg: Optional[float] = None
    arsenic_mg_kg: Optional[float] = None

    soil_condition: str  # Healthy, Attention, Critical
    toxicity_level: str  # Green, Yellow, Orange, Red
    evaluation_summary: Optional[str] = None
    laboratory_name: Optional[str] = None
    report_image_url: Optional[str] = None  # Lab report image URL
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class SoilSummaryResponse(BaseModel):
    field_id: str
    field_name: str
    latest_ph: Optional[float] = None
    latest_moisture: Optional[float] = None
    soil_condition: str
    toxicity_level: str
    npk_status: dict[str, str]  # e.g. {"nitrogen": "Low", "phosphorus": "Adequate", "potassium": "High"}
    summary_advisory: str
