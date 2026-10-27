from datetime import datetime, timedelta, timezone
from typing import List, Optional
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.recommendation import Recommendation
from app.models.dashboard import Field
from app.models.soil import SoilTest
from app.models.user import User
from app.schemas.recommendation import GenerateRecommendationRequest, RecommendationResponse
from app.services.weather_service import weather_service


class RecommendationService:
    @staticmethod
    async def list_recommendations(
        db: AsyncSession,
        user: User,
        field_id: Optional[str] = None,
        category: Optional[str] = None,
    ) -> List[Recommendation]:
        stmt = select(Recommendation).where(Recommendation.user_id == user.id)
        if field_id:
            stmt = stmt.where(Recommendation.field_id == field_id)
        if category:
            stmt = stmt.where(Recommendation.category == category)
        stmt = stmt.order_by(desc(Recommendation.created_at))
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_recommendation(db: AsyncSession, user: User, rec_id: str) -> Recommendation:
        stmt = select(Recommendation).where(Recommendation.id == rec_id, Recommendation.user_id == user.id)
        rec = (await db.execute(stmt)).scalars().first()
        if not rec:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recommendation not found.")
        return rec

    @staticmethod
    async def generate_field_recommendations(
        db: AsyncSession,
        user: User,
        field_id: str,
        request: GenerateRecommendationRequest,
    ) -> List[Recommendation]:
        stmt = select(Field).where(Field.id == field_id, Field.user_id == user.id)
        field = (await db.execute(stmt)).scalars().first()
        if not field:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Field not found.")

        # Check latest soil test
        soil_stmt = select(SoilTest).where(SoilTest.field_id == field.id).order_by(desc(SoilTest.test_date)).limit(1)
        soil_test = (await db.execute(soil_stmt)).scalars().first()

        # Fetch weather forecast if field has coordinates
        weather_summary = None
        if hasattr(field, 'latitude') and hasattr(field, 'longitude') and field.latitude and field.longitude:
            try:
                weather_summary = await weather_service.get_forecast_summary(
                    field.latitude, field.longitude
                )
            except Exception as e:
                print(f"[Recommendation] Failed to fetch weather: {e}")
                # Continue without weather data
        
        # If no coordinates, try default location (can be configured)
        if not weather_summary:
            try:
                # Use a default location (e.g., central India) - can be made configurable
                weather_summary = await weather_service.get_forecast_summary(23.0, 77.0)
            except Exception as e:
                print(f"[Recommendation] Weather unavailable: {e}")

        crop = (field.crop_name or "Wheat").lower()
        stage = request.crop_stage or "Vegetative"
        now = datetime.now(timezone.utc)
        valid_until = now + timedelta(days=7)

        generated: List[Recommendation] = []

        # 1. Weather-Enhanced Irrigation Recommendation
        is_dry = field.water_status == "Needs Irrigation" or (soil_test and soil_test.moisture_percentage and soil_test.moisture_percentage < 30)
        
        if weather_summary:
            rain_prob = weather_summary.get("rain_probability_24h", 0)
            max_temp = weather_summary.get("max_temp_24h", 30)
            
            if is_dry:
                if rain_prob > 60:
                    # Defer irrigation due to expected rain
                    irrigation_rec = Recommendation(
                        user_id=user.id,
                        field_id=field.id,
                        category="irrigation",
                        title=f"Defer Irrigation - Rain Expected",
                        description=f"Current moisture is low, but weather forecast shows {rain_prob}% rain probability in next 24 hours. Natural rainfall may satisfy water needs.",
                        action_required="Monitor soil moisture after rainfall. Reassess irrigation needs in 24-48 hours.",
                        recommended_dosage="0 mm (wait for rain)",
                        urgency="low",
                        valid_until=valid_until,
                    )
                elif max_temp > 35:
                    # High temperature - recommend evening irrigation
                    irrigation_rec = Recommendation(
                        user_id=user.id,
                        field_id=field.id,
                        category="irrigation",
                        title=f"Schedule Evening Irrigation - High Temperature Alert",
                        description=f"Soil moisture is low and maximum temperature is expected to reach {max_temp}°C. Irrigate during evening to minimize evaporative loss.",
                        action_required="Apply irrigation after 5:00 PM when temperature drops. Avoid midday watering.",
                        recommended_dosage="35 - 40 mm water depth (approx. 4-5 hours furrow/sprinkler run)",
                        urgency="high",
                        valid_until=valid_until,
                    )
                else:
                    # Normal irrigation
                    irrigation_rec = Recommendation(
                        user_id=user.id,
                        field_id=field.id,
                        category="irrigation",
                        title=f"Schedule Irrigation for {field.name}",
                        description=f"Soil moisture is below target threshold. Weather forecast: {weather_summary.get('condition', 'N/A')}, no rain expected.",
                        action_required="Apply light to moderate irrigation during early morning or late evening hours.",
                        recommended_dosage="35 - 40 mm water depth (approx. 4-5 hours furrow/sprinkler run)",
                        urgency="high",
                        valid_until=valid_until,
                    )
            else:
                # Adequate moisture
                irrigation_rec = Recommendation(
                    user_id=user.id,
                    field_id=field.id,
                    category="irrigation",
                    title="Moisture Adequate — Delay Irrigation",
                    description=f"Soil moisture reserves are sufficient. Weather: {weather_summary.get('condition', 'N/A')}.",
                    action_required="Keep irrigation pumps off. Monitor soil moisture again in 3-4 days.",
                    recommended_dosage="0 mm (no irrigation needed currently)",
                    urgency="low",
                    valid_until=valid_until,
                )
        else:
            # Fallback to original logic if weather unavailable
            if is_dry:
                irrigation_rec = Recommendation(
                    user_id=user.id,
                    field_id=field.id,
                    category="irrigation",
                    title=f"Schedule Irrigation for {field.name}",
                    description=f"Current root-zone moisture is below target threshold for {stage} stage of {field.crop_name}.",
                    action_required="Apply light to moderate irrigation during early morning or late evening hours to minimize evaporative loss.",
                    recommended_dosage="35 - 40 mm water depth (approx. 4-5 hours furrow/sprinkler run)",
                    urgency="high",
                    valid_until=valid_until,
                )
            else:
                irrigation_rec = Recommendation(
                    user_id=user.id,
                    field_id=field.id,
                    category="irrigation",
                    title="Moisture Adequate — Delay Irrigation",
                    description="Soil moisture reserves are sufficient for current transpiration demand. Avoid waterlogging.",
                    action_required="Keep irrigation pumps off. Monitor soil moisture again in 3-4 days.",
                    recommended_dosage="0 mm (no irrigation needed currently)",
                    urgency="low",
                    valid_until=valid_until,
                )
        generated.append(irrigation_rec)

        # 2. Weather-Enhanced Fertilizer Recommendation
        if "wheat" in crop:
            if stage in ("Vegetative", "Tillering"):
                fert_title = "First Top Dressing of Nitrogen for Wheat"
                fert_desc = "Tillering stage requires nitrogen boost to maximize productive spikes per square meter."
                fert_action = "Apply Neem-coated Urea as top dressing immediately following irrigation."
                fert_dosage = "25-30 kg Urea per acre"
                fert_urgency = "medium"
                
                # Check weather for application timing
                if weather_summary:
                    rain_prob = weather_summary.get("rain_probability_24h", 0)
                    wind_speed = weather_summary.get("avg_wind_speed", 0)
                    
                    if rain_prob > 50:
                        fert_desc += f" However, rain is expected ({rain_prob}% probability) in next 24h."
                        fert_action = "DELAY fertilizer application by 24-48 hours to avoid nutrient runoff from rainfall."
                        fert_urgency = "low"
                    elif wind_speed > 15:
                        fert_desc += f" Wind speed is currently high ({wind_speed:.1f} km/h)."
                        fert_action = "Wait for wind to subside below 12 km/h before spraying to prevent drift."
                
                fert_rec = Recommendation(
                    user_id=user.id,
                    field_id=field.id,
                    category="fertilizer",
                    title=fert_title,
                    description=fert_desc,
                    action_required=fert_action,
                    recommended_dosage=fert_dosage,
                    urgency=fert_urgency,
                    valid_until=valid_until,
                )
            else:
                fert_rec = Recommendation(
                    user_id=user.id,
                    field_id=field.id,
                    category="fertilizer",
                    title="Foliar Micronutrient Application (0:52:34)",
                    description="Boost grain development and flag leaf photosynthetic efficiency.",
                    action_required="Spray Mono Potassium Phosphate (0:52:34) in 150 liters of water per acre.",
                    recommended_dosage="1 kg NPK 0:52:34 per acre",
                    urgency="medium",
                    valid_until=valid_until,
                )
        elif "rice" in crop or "paddy" in crop:
            fert_rec = Recommendation(
                user_id=user.id,
                field_id=field.id,
                category="fertilizer",
                title="Panicle Initiation Nutrient Boost for Paddy",
                description="Crucial stage for spikelet count and grain size filling.",
                action_required="Broadcast Muriate of Potash (MOP) alongside Urea in standing water (2 cm).",
                recommended_dosage="15 kg MOP + 20 kg Urea per acre",
                urgency="medium",
                valid_until=valid_until,
            )
        else:
            fert_rec = Recommendation(
                user_id=user.id,
                field_id=field.id,
                category="fertilizer",
                title=f"Balanced Nutrient Maintenance for {field.crop_name}",
                description="Maintain balanced vegetative growth and root stability.",
                action_required="Apply well-decomposed Farmyard Manure (FYM) or balanced NPK 19:19:19 foliar spray.",
                recommended_dosage="500 g NPK 19:19:19 in 100 L water per acre",
                urgency="medium",
                valid_until=valid_until,
            )
        generated.append(fert_rec)

        # 3. Soil Health & Disease Management if score is degraded
        if field.health_score < 75 or request.observed_stress:
            health_rec = Recommendation(
                user_id=user.id,
                field_id=field.id,
                category="disease_management",
                title="Crop Canopy Health Inspection",
                description=f"Field health score is currently {field.health_score}/100 indicating possible abiotic or biotic stress.",
                action_required="Inspect underside of leaves in 5 random spots across the field. Use Crop Scanner for leaf spot analysis.",
                recommended_dosage="Prophylactic spray of Trichoderma viride bio-agent @ 2.5 kg/acre with organic compost.",
                urgency="high",
                valid_until=valid_until,
            )
            generated.append(health_rec)

        for rec in generated:
            db.add(rec)
        await db.commit()
        for rec in generated:
            await db.refresh(rec)

        return generated


recommendation_service = RecommendationService()
