from typing import List, Optional
from fastapi import APIRouter, Body, Depends, File, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.soil import SoilSummaryResponse, SoilTestCreate, SoilTestResponse, SoilTrendResponse
from app.services.soil_service import soil_service

router = APIRouter(prefix="/soil", tags=["Soil Analysis"])


@router.post("/tests", response_model=SoilTestResponse, status_code=status.HTTP_201_CREATED)
async def submit_soil_test(
    data: SoilTestCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Submit manual laboratory soil test results.

    Evaluates:
    - pH against optimal agronomic range (5.5 – 8.2)
    - Electrical conductivity for salinity risk
    - Heavy metals (Lead, Cadmium, Arsenic) against regulatory thresholds
    - Moisture for irrigation status
    - Macronutrients (N, P, K) with Low/Adequate/High classification

    Updates the linked field's soil_status and generates critical alerts for toxicity.
    
    For submitting with lab report image, use POST /v1/soil/tests/with-image endpoint.
    """
    test = await soil_service.create_soil_test(db, current_user, data, None)
    return SoilTestResponse.model_validate(test)


@router.get("/tests", response_model=List[SoilTestResponse])
async def list_soil_tests(
    field_id: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve paginated history of all soil tests for the authenticated farmer."""
    tests = await soil_service.list_soil_tests(db, current_user, field_id, page, page_size)
    return [SoilTestResponse.model_validate(t) for t in tests]


@router.get("/tests/{test_id}", response_model=SoilTestResponse)
async def get_soil_test(
    test_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a specific soil test by ID."""
    test = await soil_service.get_soil_test(db, current_user, test_id)
    return SoilTestResponse.model_validate(test)


@router.get("/summary/{field_id}", response_model=SoilSummaryResponse)
async def get_field_soil_summary(
    field_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieve aggregated soil health summary for a specific field.
    Includes pH, moisture, NPK status (Low/Adequate/High), and advisory text.
    """
    return await soil_service.get_soil_summary(db, current_user, field_id)


@router.get("/trends/{field_id}", response_model=SoilTrendResponse)
async def get_field_soil_trends(
    field_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Analyze soil health trends over time based on historical soil tests.
    
    Returns:
    - Trend indicators for pH, moisture, NPK levels
    - Toxicity progression (Improving/Stable/Worsening)
    - Historical test results (up to 5 most recent)
    - Advisory text with actionable recommendations
    
    Requires at least 2 soil tests for trend analysis.
    Results are cached for 1 hour.
    """
    return await soil_service.get_soil_trends(db, current_user, field_id)
