from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.recommendation import (
    GenerateRecommendationRequest,
    RecommendationResponse,
)
from app.services.recommendation_service import recommendation_service

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


@router.post("/generate/{field_id}", response_model=List[RecommendationResponse], status_code=status.HTTP_201_CREATED)
async def generate_recommendations(
    field_id: str,
    data: GenerateRecommendationRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Generate deterministic agronomic recommendations for a specific field.

    Produces recommendations for:
    - Irrigation scheduling (based on field water status and crop stage)
    - Fertilizer application (crop-specific and stage-specific dosage guidance)
    - Disease management (when health score < 75 or stress observed)

    All recommendations are based on validated regional agricultural guidelines,
    not invented by LLM. Quantities include appropriate uncertainty caveats.
    """
    recs = await recommendation_service.generate_field_recommendations(
        db, current_user, field_id, data
    )
    return [RecommendationResponse.model_validate(r) for r in recs]


@router.get("", response_model=List[RecommendationResponse])
async def list_recommendations(
    field_id: Optional[str] = Query(None),
    category: Optional[str] = Query(None, description="Filter by: irrigation, fertilizer, disease_management, soil_health"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all recommendations for the authenticated farmer, optionally filtered by field or category."""
    recs = await recommendation_service.list_recommendations(db, current_user, field_id, category)
    return [RecommendationResponse.model_validate(r) for r in recs]


@router.get("/{rec_id}", response_model=RecommendationResponse)
async def get_recommendation(
    rec_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a specific recommendation by ID."""
    rec = await recommendation_service.get_recommendation(db, current_user, rec_id)
    return RecommendationResponse.model_validate(rec)
