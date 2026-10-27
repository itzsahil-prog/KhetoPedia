import os
import uuid
import logging
from datetime import datetime, timezone
from typing import List, Optional, Tuple
from fastapi import UploadFile, HTTPException, status
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.crop_scan import CropScan
from app.models.dashboard import Alert, Field
from app.models.user import User
from app.schemas.crop_scan import CropScanResponse
from app.services.image_service import image_service
from app.services.cache_service import cache_service
from app.services.ml_service import ml_service, MLServiceException

logger = logging.getLogger(__name__)


# Legacy agronomic diagnostic dictionary - now replaced by ML service
# Kept for reference only
# See app.ml.disease_knowledge for current treatment recommendations


class CropScannerService:

    @staticmethod
    async def analyze_crop_image(
        db: AsyncSession,
        user: User,
        file_bytes: bytes,
        filename: str,
        field_id: Optional[str] = None,
        crop_hint: Optional[str] = None,
    ) -> CropScan:
        # Validate image using image_service
        is_valid, mime_type, error_msg = image_service.validate_image(file_bytes, filename)
        
        # Upload image to storage (S3 or filesystem)
        try:
            save_path = await image_service.upload_image(file_bytes, filename, "crops", user.id)
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to store image: {str(e)}"
            )

        # Resolve field info if provided
        target_field = None
        if field_id:
            stmt = select(Field).where(Field.id == field_id, Field.user_id == user.id)
            target_field = (await db.execute(stmt)).scalars().first()

        # Use crop hint from field if available
        if not crop_hint and target_field:
            crop_hint = target_field.crop_name

        # Run ML inference
        try:
            logger.info(f"Running ML inference for user {user.id}, crop_hint: {crop_hint}")
            ml_result = await ml_service.predict_disease(file_bytes, crop_hint)
            
            # Create scan record from ML prediction
            scan = CropScan(
                user_id=user.id,
                field_id=field_id,
                image_path=save_path,
                image_quality_score=ml_result.image_quality_score,
                is_valid_plant=not ml_result.is_uncertain,
                crop_identified=ml_result.crop_type,
                crop_confidence=ml_result.crop_confidence,
                disease_name=ml_result.disease_name,
                disease_confidence=ml_result.disease_confidence,
                severity=ml_result.severity,
                symptoms_observed=ml_result.symptoms_observed,
                recommended_treatment=ml_result.recommended_treatment,
                preventive_measures=ml_result.preventive_measures,
            )
            
            # If a severe/moderate disease was identified and a field was targeted, update health score and create Alert
            if target_field and ml_result.severity in ("moderate", "severe"):
                # Decrease health score based on severity
                health_decrease = 15 if ml_result.severity == "moderate" else 25
                target_field.health_score = max(30, target_field.health_score - health_decrease)
                
                alert = Alert(
                    user_id=user.id,
                    field_id=target_field.id,
                    title=f"Disease Detected: {ml_result.disease_name}",
                    message=f"Scan on '{target_field.name}' identified {ml_result.disease_name} "
                            f"with {ml_result.disease_confidence:.0%} confidence. "
                            f"Recommended: {ml_result.recommended_treatment[:120]}...",
                    severity="warning" if ml_result.severity == "moderate" else "critical",
                    alert_type="disease",
                    is_read=False,
                )
                db.add(alert)
                
                # Invalidate dashboard cache
                await cache_service.delete(f"dashboard:summary:{user.id}")
            
            logger.info(
                f"ML analysis completed: {ml_result.disease_name} "
                f"({ml_result.disease_confidence:.2%}, inference: {ml_result.inference_time_ms:.0f}ms)"
            )
            
        except MLServiceException as e:
            logger.error(f"ML service error: {e}")
            # Fallback to error scan record
            scan = CropScan(
                user_id=user.id,
                field_id=field_id,
                image_path=save_path,
                image_quality_score=0.5,
                is_valid_plant=False,
                crop_identified="Unable to analyze",
                crop_confidence=0.0,
                disease_name="ML Service Unavailable",
                disease_confidence=0.0,
                severity="none",
                symptoms_observed=f"Analysis failed: {str(e)}",
                recommended_treatment="Please try again later or contact support if the issue persists.",
                preventive_measures="Ensure image is clear and properly focused on plant leaves.",
            )
        except Exception as e:
            logger.error(f"Unexpected error during ML analysis: {e}", exc_info=True)
            # Fallback for unexpected errors
            scan = CropScan(
                user_id=user.id,
                field_id=field_id,
                image_path=save_path,
                image_quality_score=0.5,
                is_valid_plant=False,
                crop_identified="Analysis error",
                crop_confidence=0.0,
                disease_name="System error occurred",
                disease_confidence=0.0,
                severity="none",
                symptoms_observed="An unexpected error occurred during analysis.",
                recommended_treatment="Please try again or contact support.",
                preventive_measures="",
            )

        db.add(scan)
        await db.commit()
        await db.refresh(scan)
        return scan

    @staticmethod
    async def list_scans(
        db: AsyncSession,
        user: User,
        field_id: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> Tuple[List[CropScan], int]:
        stmt = select(CropScan).where(CropScan.user_id == user.id)
        if field_id:
            stmt = stmt.where(CropScan.field_id == field_id)
        stmt = stmt.order_by(desc(CropScan.created_at)).offset((page - 1) * page_size).limit(page_size)

        result = await db.execute(stmt)
        scans = list(result.scalars().all())

        from sqlalchemy import func
        count_stmt = select(func.count(CropScan.id)).where(CropScan.user_id == user.id)
        if field_id:
            count_stmt = count_stmt.where(CropScan.field_id == field_id)
        total = (await db.execute(count_stmt)).scalar() or 0

        return scans, total

    @staticmethod
    async def get_scan_by_id(db: AsyncSession, user: User, scan_id: str) -> CropScan:
        stmt = select(CropScan).where(CropScan.id == scan_id, CropScan.user_id == user.id)
        scan = (await db.execute(stmt)).scalars().first()
        if not scan:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Scan record not found.")
        return scan


crop_scanner_service = CropScannerService()
