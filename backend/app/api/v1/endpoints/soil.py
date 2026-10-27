from typing import List, Optional
from fastapi import APIRouter, Depends, File, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.soil import SoilSummaryResponse, SoilTestCreate, SoilTestResponse
from app.services.soil_service import soil_service

router = APIRouter(prefix="/soil", tags=["Soil Analysis"])


@router.post("/tests", response_model=SoilTestResponse, status_code=status.HTTP_201_CREATED)
async def submit_soil_test(
    data: SoilTestCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    report_image: Optional[UploadFile] = File(None),
):
    """
    Submit manual laboratory soil test results with optional lab report image.

    Evaluates:
    - pH against optimal agronomic range (5.5 – 8.2)
    - Electrical conductivity for salinity risk
    - Heavy metals (Lead, Cadmium, Arsenic) against regulatory thresholds
    - Moisture for irrigation status
    - Macronutrients (N, P, K) with Low/Adequate/High classification

    Updates the linked field's soil_status and generates critical alerts for toxicity.
    """
    test = await soil_service.create_soil_test(db, current_user, data, report_image)
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
