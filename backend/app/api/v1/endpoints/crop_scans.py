from typing import List, Optional
from fastapi import APIRouter, Depends, File, Form, Query, Request, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.crop_scan import CropScanHistoryResponse, CropScanResponse
from app.services.crop_scanner_service import crop_scanner_service
from app.middleware.rate_limit import limiter

router = APIRouter(prefix="/crop-scans", tags=["Crop AI Scanner"])


@router.post("", response_model=CropScanResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit("20/hour")
async def analyze_crop(
    request: Request,
    file: UploadFile = File(..., description="Crop leaf image (JPEG/PNG/WEBP, max 10 MB)"),
    field_id: Optional[str] = Form(None, description="Target field ID for health score update"),
    crop_hint: Optional[str] = Form(None, description="Optional crop name hint (wheat, rice, tomato, potato, cotton)"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Upload a crop leaf image and receive AI-powered crop identification and
    disease/deficiency diagnosis with evidence-based agronomic treatment recommendations.

    - Validates image quality (blur, resolution, size) before processing.
    - Classifies crop type and detects diseases with confidence scores.
    - Updates field health score and generates an alert for severe findings.
    - Never claims certainty beyond model confidence threshold.
    """
    file_bytes = await file.read()
    filename = file.filename or "upload.jpg"

    scan = await crop_scanner_service.analyze_crop_image(
        db=db,
        user=current_user,
        file_bytes=file_bytes,
        filename=filename,
        field_id=field_id,
        crop_hint=crop_hint,
    )
    return CropScanResponse.model_validate(scan)


@router.get("", response_model=CropScanHistoryResponse)
async def list_crop_scans(
    field_id: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve paginated history of crop scan records for the authenticated farmer."""
    scans, total = await crop_scanner_service.list_scans(
        db=db,
        user=current_user,
        field_id=field_id,
        page=page,
        page_size=page_size,
    )
    return CropScanHistoryResponse(
        scans=[CropScanResponse.model_validate(s) for s in scans],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{scan_id}", response_model=CropScanResponse)
async def get_crop_scan(
    scan_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a specific crop scan result by ID."""
    scan = await crop_scanner_service.get_scan_by_id(db, current_user, scan_id)
    return CropScanResponse.model_validate(scan)
