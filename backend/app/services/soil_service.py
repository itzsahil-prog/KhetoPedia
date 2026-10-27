from typing import List, Optional, Tuple
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, UploadFile, status

from app.models.soil import SoilTest
from app.models.dashboard import Alert, Field
from app.models.user import User
from app.schemas.soil import SoilSummaryResponse, SoilTestCreate, SoilTestResponse, SoilTrendResponse
from app.services.image_service import image_service
from app.services.cache_service import cache_service


class SoilService:
    @staticmethod
    def _evaluate_soil_metrics(data: SoilTestCreate) -> Tuple[str, str, str]:
        """Evaluates pH, EC, and heavy metals toxicity according to standard agronomic thresholds."""
        toxicity = "Green"
        status_eval = "Healthy"
        notes = []

        # 1. pH evaluation
        if data.ph < 5.5:
            status_eval = "Attention"
            notes.append(f"Strongly acidic soil (pH {data.ph}). Recommended: apply agricultural lime (calcium carbonate).")
        elif data.ph > 8.2:
            status_eval = "Attention"
            notes.append(f"Alkaline soil (pH {data.ph}). Recommended: apply agricultural gypsum or organic compost.")
        else:
            notes.append(f"Optimal soil reaction (pH {data.ph}).")

        # 2. Electrical conductivity (Salinity)
        if data.ec_ds_m is not None:
            if data.ec_ds_m > 4.0:
                status_eval = "Critical"
                toxicity = "Orange"
                notes.append(f"High salinity detected (EC {data.ec_ds_m} dS/m). Leaching required with good quality water.")
            elif data.ec_ds_m > 2.0:
                if status_eval != "Critical":
                    status_eval = "Attention"
                notes.append(f"Slight salinity (EC {data.ec_ds_m} dS/m). Select salt-tolerant crops.")

        # 3. Heavy metal toxicity evaluation (Lead, Cadmium, Arsenic)
        if data.lead_mg_kg is not None:
            if data.lead_mg_kg > 100.0:
                toxicity = "Red"
                status_eval = "Critical"
                notes.append(f"CRITICAL: Excessive Lead level ({data.lead_mg_kg} mg/kg) exceeds regulatory safety limit (100 mg/kg).")
            elif data.lead_mg_kg > 50.0:
                if toxicity in ("Green", "Yellow"):
                    toxicity = "Yellow"
                notes.append(f"Elevated Lead level ({data.lead_mg_kg} mg/kg). Avoid growing leafy vegetables.")

        if data.cadmium_mg_kg is not None:
            if data.cadmium_mg_kg > 3.0:
                toxicity = "Red"
                status_eval = "Critical"
                notes.append(f"CRITICAL: Cadmium contamination ({data.cadmium_mg_kg} mg/kg). Regulatory threshold is 3.0 mg/kg.")
            elif data.cadmium_mg_kg > 1.0:
                if toxicity in ("Green", "Yellow"):
                    toxicity = "Orange"
                notes.append(f"Caution: Elevated Cadmium ({data.cadmium_mg_kg} mg/kg).")

        if data.arsenic_mg_kg is not None:
            if data.arsenic_mg_kg > 20.0:
                toxicity = "Red"
                status_eval = "Critical"
                notes.append(f"CRITICAL: Arsenic level ({data.arsenic_mg_kg} mg/kg) exceeds permissible limits.")
            elif data.arsenic_mg_kg > 10.0:
                if toxicity == "Green":
                    toxicity = "Yellow"
                notes.append(f"Elevated Arsenic level ({data.arsenic_mg_kg} mg/kg).")

        summary = " ".join(notes)
        return status_eval, toxicity, summary

    @staticmethod
    async def create_soil_test(
        db: AsyncSession, user: User, data: SoilTestCreate, report_image: Optional[UploadFile] = None
    ) -> SoilTest:
        status_eval, toxicity_level, summary = SoilService._evaluate_soil_metrics(data)

        # Check field if provided
        target_field = None
        if data.field_id:
            stmt = select(Field).where(Field.id == data.field_id, Field.user_id == user.id)
            target_field = (await db.execute(stmt)).scalars().first()

        # Handle report image upload if provided
        report_image_path = None
        if report_image:
            file_bytes = await report_image.read()
            report_image_path = await image_service.upload_image(
                file_bytes, report_image.filename or "report.jpg", "soil", user.id
            )

        record = SoilTest(
            user_id=user.id,
            field_id=data.field_id,
            test_date=data.test_date or utc_now(),
            source=data.source,
            ph=data.ph,
            ec_ds_m=data.ec_ds_m,
            moisture_percentage=data.moisture_percentage,
            organic_carbon_percentage=data.organic_carbon_percentage,
            nitrogen_kg_ha=data.nitrogen_kg_ha,
            phosphorus_kg_ha=data.phosphorus_kg_ha,
            potassium_kg_ha=data.potassium_kg_ha,
            zinc_ppm=data.zinc_ppm,
            iron_ppm=data.iron_ppm,
            boron_ppm=data.boron_ppm,
            lead_mg_kg=data.lead_mg_kg,
            cadmium_mg_kg=data.cadmium_mg_kg,
            arsenic_mg_kg=data.arsenic_mg_kg,
            soil_condition=status_eval,
            toxicity_level=toxicity_level,
            evaluation_summary=summary,
            laboratory_name=data.laboratory_name,
            report_image_path=report_image_path,
        )
        db.add(record)

        # Update field's soil status if field specified
        if target_field:
            target_field.soil_status = status_eval
            if data.moisture_percentage is not None:
                if data.moisture_percentage < 25.0:
                    target_field.water_status = "Needs Irrigation"
                elif data.moisture_percentage > 70.0:
                    target_field.water_status = "Waterlogged"
                else:
                    target_field.water_status = "Adequate"

        # Generate alert if high or critical toxicity detected
        if toxicity_level in ("Orange", "Red"):
            alert = Alert(
                user_id=user.id,
                field_id=data.field_id,
                title=f"Soil Toxicity Alert [{toxicity_level.upper()}]",
                message=summary[:240],
                severity="critical" if toxicity_level == "Red" else "warning",
                alert_type="soil",
                is_read=False,
            )
            db.add(alert)
            # Invalidate dashboard cache
            await cache_service.delete(f"dashboard:summary:{user.id}")

        await db.commit()
        await db.refresh(record)
        return record

    @staticmethod
    async def list_soil_tests(
        db: AsyncSession,
        user: User,
        field_id: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> List[SoilTest]:
        stmt = select(SoilTest).where(SoilTest.user_id == user.id)
        if field_id:
            stmt = stmt.where(SoilTest.field_id == field_id)
        stmt = stmt.order_by(desc(SoilTest.test_date)).offset((page - 1) * page_size).limit(page_size)
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_soil_test(db: AsyncSession, user: User, test_id: str) -> SoilTest:
        stmt = select(SoilTest).where(SoilTest.id == test_id, SoilTest.user_id == user.id)
        record = (await db.execute(stmt)).scalars().first()
        if not record:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Soil test not found.")
        return record

    @staticmethod
    async def get_soil_summary(
        db: AsyncSession, user: User, field_id: str
    ) -> SoilSummaryResponse:
        field_stmt = select(Field).where(Field.id == field_id, Field.user_id == user.id)
        field = (await db.execute(field_stmt)).scalars().first()
        if not field:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Field not found.")

        # Get latest soil test for this field
        stmt = (
            select(SoilTest)
            .where(SoilTest.field_id == field_id, SoilTest.user_id == user.id)
            .order_by(desc(SoilTest.test_date))
            .limit(1)
        )
        test = (await db.execute(stmt)).scalars().first()

        latest_ph = test.ph if test else 6.8
        latest_moisture = test.moisture_percentage if test else 45.0
        condition = test.soil_condition if test else "Healthy"
        toxicity = test.toxicity_level if test else "Green"

        # Determine NPK status
        n_stat = "Adequate"
        p_stat = "Adequate"
        k_stat = "Adequate"
        if test and test.nitrogen_kg_ha is not None:
            n_stat = "Low" if test.nitrogen_kg_ha < 240 else ("High" if test.nitrogen_kg_ha > 480 else "Adequate")
        if test and test.phosphorus_kg_ha is not None:
            p_stat = "Low" if test.phosphorus_kg_ha < 15 else ("High" if test.phosphorus_kg_ha > 25 else "Adequate")
        if test and test.potassium_kg_ha is not None:
            k_stat = "Low" if test.potassium_kg_ha < 120 else ("High" if test.potassium_kg_ha > 280 else "Adequate")

        npk_dict = {"Nitrogen (N)": n_stat, "Phosphorus (P)": p_stat, "Potassium (K)": k_stat}
        advisory = (
            f"Soil is currently {condition.lower()} with pH {latest_ph:.1f}. "
            f"Nitrogen is {n_stat.lower()}, phosphorus is {p_stat.lower()}, and potassium is {k_stat.lower()}."
        )

        return SoilSummaryResponse(
            field_id=field.id,
            field_name=field.name,
            latest_ph=latest_ph,
            latest_moisture=latest_moisture,
            soil_condition=condition,
            toxicity_level=toxicity,
            npk_status=npk_dict,
            summary_advisory=advisory,
        )
    
    @staticmethod
    async def get_soil_trends(
        db: AsyncSession, user: User, field_id: str
    ) -> SoilTrendResponse:
        """
        Analyze soil trends over time based on historical soil tests.
        
        Args:
            db: Database session
            user: Current user
            field_id: Field ID to analyze
            
        Returns:
            SoilTrendResponse with trend analysis
            
        Raises:
            HTTPException: If field not found
        """
        # Verify field ownership
        field_stmt = select(Field).where(Field.id == field_id, Field.user_id == user.id)
        field = (await db.execute(field_stmt)).scalars().first()
        if not field:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Field not found.")
        
        # Get last 5 soil tests ordered by date
        stmt = (
            select(SoilTest)
            .where(SoilTest.field_id == field_id, SoilTest.user_id == user.id)
            .order_by(desc(SoilTest.test_date))
            .limit(5)
        )
        result = await db.execute(stmt)
        tests = list(result.scalars().all())
        
        if len(tests) < 2:
            # Insufficient data for trend analysis
            return SoilTrendResponse(
                field_id=field.id,
                field_name=field.name,
                tests_analyzed=len(tests),
                ph_trend="Insufficient Data",
                moisture_trend="Insufficient Data",
                npk_trend="Insufficient Data",
                toxicity_progression="N/A",
                historical_tests=[SoilTestResponse.model_validate(t) for t in tests],
                advisory="At least 2 soil tests are required for trend analysis. Continue regular soil testing.",
            )
        
        # Reverse to get chronological order (oldest first)
        tests_chrono = list(reversed(tests))
        oldest = tests_chrono[0]
        latest = tests_chrono[-1]
        
        # pH Trend Analysis
        ph_trend = "Stable"
        if abs(latest.ph - oldest.ph) > 0.5:
            if latest.ph > oldest.ph:
                # pH increasing
                if oldest.ph < 5.5:
                    ph_trend = "Improving"  # Was acidic, getting better
                elif latest.ph > 8.2:
                    ph_trend = "Degrading"  # Becoming too alkaline
                else:
                    ph_trend = "Stable"
            else:
                # pH decreasing
                if oldest.ph > 8.2:
                    ph_trend = "Improving"  # Was alkaline, getting better
                elif latest.ph < 5.5:
                    ph_trend = "Degrading"  # Becoming too acidic
                else:
                    ph_trend = "Stable"
        
        # Moisture Trend Analysis
        moisture_trend = "Stable"
        if oldest.moisture_percentage and latest.moisture_percentage:
            moisture_delta = latest.moisture_percentage - oldest.moisture_percentage
            if abs(moisture_delta) > 10:
                if moisture_delta > 0:
                    moisture_trend = "Increasing" if latest.moisture_percentage < 70 else "Degrading (Waterlogging Risk)"
                else:
                    moisture_trend = "Decreasing" if latest.moisture_percentage > 25 else "Degrading (Drought Stress)"
        else:
            moisture_trend = "Insufficient Data"
        
        # NPK Trend Analysis
        npk_trend = "Stable"
        npk_changes = []
        
        if oldest.nitrogen_kg_ha is not None and latest.nitrogen_kg_ha is not None:
            n_delta = latest.nitrogen_kg_ha - oldest.nitrogen_kg_ha
            if abs(n_delta) > 50:
                if n_delta < 0:
                    npk_changes.append("Nitrogen depleting")
                    npk_trend = "Degrading"
                else:
                    npk_changes.append("Nitrogen increasing")
                    if npk_trend != "Degrading":
                        npk_trend = "Improving"
        
        if oldest.phosphorus_kg_ha is not None and latest.phosphorus_kg_ha is not None:
            p_delta = latest.phosphorus_kg_ha - oldest.phosphorus_kg_ha
            if abs(p_delta) > 5:
                if p_delta < 0:
                    npk_changes.append("Phosphorus depleting")
                    npk_trend = "Degrading"
                else:
                    npk_changes.append("Phosphorus increasing")
        
        if oldest.potassium_kg_ha is not None and latest.potassium_kg_ha is not None:
            k_delta = latest.potassium_kg_ha - oldest.potassium_kg_ha
            if abs(k_delta) > 30:
                if k_delta < 0:
                    npk_changes.append("Potassium depleting")
                    npk_trend = "Degrading"
                else:
                    npk_changes.append("Potassium increasing")
        
        if not npk_changes:
            npk_trend = "Stable"
        
        # Toxicity Progression Analysis
        toxicity_levels = {"Green": 0, "Yellow": 1, "Orange": 2, "Red": 3}
        oldest_tox = toxicity_levels.get(oldest.toxicity_level, 0)
        latest_tox = toxicity_levels.get(latest.toxicity_level, 0)
        
        toxicity_progression = "N/A"
        if oldest_tox == 0 and latest_tox == 0:
            toxicity_progression = "Stable (No Toxicity)"
        elif latest_tox < oldest_tox:
            toxicity_progression = "Improving"
        elif latest_tox > oldest_tox:
            toxicity_progression = "Worsening"
        else:
            toxicity_progression = "Stable"
        
        # Generate Advisory
        advisory_parts = []
        advisory_parts.append(f"Analysis based on {len(tests)} soil tests from {oldest.test_date.strftime('%Y-%m-%d')} to {latest.test_date.strftime('%Y-%m-%d')}.")
        
        if ph_trend == "Improving":
            advisory_parts.append(f"pH is improving (from {oldest.ph:.1f} to {latest.ph:.1f}).")
        elif ph_trend == "Degrading":
            advisory_parts.append(f"pH is degrading (from {oldest.ph:.1f} to {latest.ph:.1f}). Consider soil amendments.")
        
        if npk_trend == "Degrading":
            advisory_parts.append(f"Nutrient depletion detected: {', '.join(npk_changes)}. Apply targeted fertilizers.")
        elif npk_trend == "Improving":
            advisory_parts.append("Nutrient levels are improving. Continue current fertilization program.")
        
        if toxicity_progression == "Worsening":
            advisory_parts.append(f"Toxicity levels worsening ({oldest.toxicity_level} → {latest.toxicity_level}). Investigate pollution sources.")
        elif toxicity_progression == "Improving":
            advisory_parts.append(f"Toxicity levels improving ({oldest.toxicity_level} → {latest.toxicity_level}). Remediation efforts are working.")
        
        advisory = " ".join(advisory_parts)
        
        return SoilTrendResponse(
            field_id=field.id,
            field_name=field.name,
            tests_analyzed=len(tests),
            ph_trend=ph_trend,
            moisture_trend=moisture_trend,
            npk_trend=npk_trend,
            toxicity_progression=toxicity_progression,
            historical_tests=[SoilTestResponse.model_validate(t) for t in tests],
            advisory=advisory,
        )


def utc_now():
    from datetime import datetime, timezone
    return datetime.now(timezone.utc)


soil_service = SoilService()
