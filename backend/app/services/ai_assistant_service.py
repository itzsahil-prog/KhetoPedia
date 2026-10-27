import re
from typing import List, Optional, Tuple
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.ai import AiConversation, AiMessage
from app.models.dashboard import Field, Alert
from app.models.soil import SoilTest
from app.models.user import User
from app.schemas.ai import AiChatRequest, AiChatResponse


class AiAssistantService:
    @staticmethod
    async def get_or_create_conversation(
        db: AsyncSession, user: User, conversation_id: Optional[str] = None, field_id: Optional[str] = None
    ) -> AiConversation:
        if conversation_id:
            stmt = select(AiConversation).where(
                AiConversation.id == conversation_id, AiConversation.user_id == user.id
            )
            conv = (await db.execute(stmt)).scalars().first()
            if conv:
                return conv

        conv = AiConversation(
            user_id=user.id,
            field_id=field_id,
            title="Field Consultation" if field_id else "General Agricultural Consultation",
        )
        db.add(conv)
        await db.commit()
        await db.refresh(conv)
        return conv

    @staticmethod
    def _generate_grounded_response(
        query: str,
        user_name: str,
        field: Optional[Field],
        soil: Optional[SoilTest],
        alerts: List[Alert],
        language: str = "en",
    ) -> Tuple[str, List[str]]:
        """Synthesizes grounded agrarian advice strictly adhering to safety rules (§22, §23)."""
        q_lower = query.lower()
        is_hindi = language.startswith("hi") or any("\u0900" <= c <= "\u097f" for c in query)

        context_info = []
        if field:
            context_info.append(f"Field: {field.name} (Crop: {field.crop_name or 'Not specified'}, Health: {field.health_score}/100, Water: {field.water_status})")
        if soil:
            context_info.append(f"Soil Status: pH {soil.ph}, Condition {soil.soil_condition}, Toxicity: {soil.toxicity_level}")
        if alerts:
            alert_titles = ", ".join(a.title for a in alerts[:2])
            context_info.append(f"Active Advisories: {alert_titles}")

        # Domain knowledge routing
        if any(w in q_lower for w in ["water", "irrigation", "irrigat", "pani", "paani", "sinchai", "सिंचाई", "पानी"]):
            if field and field.water_status == "Needs Irrigation":
                if is_hindi:
                    reply = (
                        f"नमस्ते {user_name}! आपके खेत '{field.name}' के वर्तमान आंकड़ों के अनुसार मिट्टी में नमी कम है "
                        f"और इसे सिंचाई की आवश्यकता है। सिफारिश: वाष्पीकरण से बचने के लिए सुबह या शाम के समय हल्की सिंचाई करें।"
                    )
                    actions = ["सुबह हल्की सिंचाई करें", "ड्रिप या स्प्रिंकलर लाइन चेक करें", "3 दिन बाद मिट्टी की नमी मापें"]
                else:
                    reply = (
                        f"Hello {user_name}! According to the telemetry for '{field.name}', soil moisture is currently low "
                        f"and irrigation is needed. Recommended: Provide a scheduled light irrigation during early morning or evening hours."
                    )
                    actions = ["Schedule morning irrigation", "Inspect irrigation valves/drippers", "Check moisture again in 3 days"]
            else:
                if is_hindi:
                    reply = (
                        f"आपके खेत '{field.name if field else 'वर्तमान प्लॉट'}' में पानी का स्तर पर्याप्त है। "
                        f"अत्यधिक पानी देने से जड़ों में सड़न हो सकती है। फिलहाल सिंचाई रोकें।"
                    )
                    actions = ["सिंचाई रोके रखें", "जल निकासी की व्यवस्था देखें", "मौसम पूर्वानुमान चेक करें"]
                else:
                    reply = (
                        f"For '{field.name if field else 'your field'}', soil moisture is currently adequate. "
                        f"Excess irrigation could lead to root hypoxia or fungal spread. Delay watering for now."
                    )
                    actions = ["Hold off on irrigation", "Monitor upcoming rain forecast", "Check field drainage"]

        elif any(w in q_lower for w in ["fertilizer", "urea", "dap", "npk", "khad", "खाद", "यूरिया"]):
            crop = (field.crop_name if field else "Wheat").title()
            if is_hindi:
                reply = (
                    f"{crop} की अच्छी पैदावार के लिए संतुलित खाद जरूरी है। "
                    f"मिट्टी परीक्षण के आधार पर यूरिया (नाइट्रोजन) को 2-3 खुराकों में बांटकर दें। "
                    f"फॉस्फोरस (DAP/SSP) और पोटाश (MOP) की पूरी मात्रा बुवाई के समय ही दें। हमेशा यूरिया के साथ नीम कोटिंग का उपयोग करें।"
                )
                actions = ["नीम लेपित यूरिया का प्रयोग करें", "मिट्टी परीक्षण कार्ड देखें", "सिंचाई के तुरंत बाद यूरिया न डालें"]
            else:
                reply = (
                    f"For healthy development in {crop}, apply balanced NPK nutrients based on your soil test. "
                    f"Split nitrogen (Neem-coated Urea) into 2-3 top dressings at tillering and jointing stages. "
                    f"Apply basal phosphorus and potassium during sowing. Never apply excess nitrogen during humid weather."
                )
                actions = ["Review Soil NPK card", "Apply Neem-coated Urea split dose", "Incorporate organic FYM compost"]

        elif any(w in q_lower for w in ["disease", "pest", "leaf", "blight", "yellow", "keeda", "rog", "रोग", "कीट", "पीला"]):
            if is_hindi:
                reply = (
                    f"पत्तियों पर किसी भी प्रकार के धब्बे, पीलापन या कीट के लक्षण दिखने पर खेत के विभिन्न हिस्सों से प्रभावित पत्तियों की "
                    f"साफ फोटो खींचकर हमारे 'Crop Scanner' में स्कैन करें। हमारा AI मॉडल रोग की पहचान करके सटीक फफूंदनाशी या कीटनाशक खुराक बताएगा।"
                )
                actions = ["फसल स्कैनर से फोटो लें", "खेत के 5 कोनों में निरीक्षण करें", "सुबह के समय पत्तियों की जांच करें"]
            else:
                reply = (
                    f"For symptoms like yellowing, leaf spots, or suspected pest infestation, take a well-lit photo of the affected leaves "
                    f"using our 'Scan Crop' tool. The diagnostic engine will pinpoint the exact pathogen (such as rust, blight, or nutrient deficiency) "
                    f"and provide approved dosage treatments."
                )
                actions = ["Open Crop Scanner", "Inspect underside of leaves", "Avoid overhead spraying during noon"]

        else:
            field_mention = f" on your field '{field.name}' ({field.crop_name})" if field else ""
            if is_hindi:
                reply = (
                    f"नमस्ते {user_name}! मैं खेतोपीडिया का कृषि सहायक हूँ। मैं आपकी फसल प्रबंधन{field_mention}, "
                    f"सिंचाई नियोजन, खाद खुराक, और कीट-रोग निदान में सहायता कर सकता हूँ। आप किस विषय में जानकारी चाहते हैं?"
                )
                actions = ["सिंचाई की सलाह पूछें", "खाद खुराक चेक करें", "रोग निदान के लिए पत्ती स्कैन करें"]
            else:
                reply = (
                    f"Hello {user_name}! I am your Khetopedia Agricultural Assistant. I can assist with crop growth{field_mention}, "
                    f"irrigation scheduling, balanced fertilization, weather advisories, and pest management. How can I help you today?"
                )
                actions = ["Check irrigation needs", "View fertilizer advice", "Scan crop for diseases"]

        return reply, actions

    @staticmethod
    async def chat(
        db: AsyncSession, user: User, request: AiChatRequest
    ) -> AiChatResponse:
        conversation = await AiAssistantService.get_or_create_conversation(
            db, user, request.conversation_id, request.field_id
        )

        # Retrieve field context if applicable
        target_field = None
        target_soil = None
        target_alerts: List[Alert] = []

        field_id = request.field_id or conversation.field_id
        if field_id:
            stmt = select(Field).where(Field.id == field_id, Field.user_id == user.id)
            target_field = (await db.execute(stmt)).scalars().first()
            if target_field:
                soil_stmt = select(SoilTest).where(SoilTest.field_id == field_id).order_by(desc(SoilTest.test_date)).limit(1)
                target_soil = (await db.execute(soil_stmt)).scalars().first()

                alert_stmt = select(Alert).where(Alert.field_id == field_id, Alert.is_read == False).limit(3)
                target_alerts = list((await db.execute(alert_stmt)).scalars().all())

        # Save user message
        user_msg = AiMessage(
            conversation_id=conversation.id,
            sender="user",
            content=request.message.strip(),
        )
        db.add(user_msg)

        # Generate response
        reply_text, actions = AiAssistantService._generate_grounded_response(
            query=request.message,
            user_name=user.name,
            field=target_field,
            soil=target_soil,
            alerts=target_alerts,
            language=request.preferred_language or user.preferred_locale or "en",
        )

        # Save assistant message
        asst_msg = AiMessage(
            conversation_id=conversation.id,
            sender="assistant",
            content=reply_text,
        )
        db.add(asst_msg)

        await db.commit()

        return AiChatResponse(
            conversation_id=conversation.id,
            reply=reply_text,
            suggested_actions=actions,
            field_context_applied=target_field is not None,
        )

    @staticmethod
    async def list_conversations(
        db: AsyncSession, user: User
    ) -> List[AiConversation]:
        stmt = (
            select(AiConversation)
            .where(AiConversation.user_id == user.id)
            .order_by(desc(AiConversation.updated_at))
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_conversation(
        db: AsyncSession, user: User, conversation_id: str
    ) -> AiConversation:
        stmt = select(AiConversation).where(
            AiConversation.id == conversation_id, AiConversation.user_id == user.id
        )
        conv = (await db.execute(stmt)).scalars().first()
        if not conv:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversation not found.")
        return conv


ai_assistant_service = AiAssistantService()
