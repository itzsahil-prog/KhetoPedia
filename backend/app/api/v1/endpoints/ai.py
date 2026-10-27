from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.ai import AiConversation, AiMessage
from app.models.user import User
from app.schemas.ai import AiChatRequest, AiChatResponse, AiConversationResponse, AiMessageResponse
from app.services.ai_assistant_service import ai_assistant_service
from app.services.ml_service import ml_service

router = APIRouter(prefix="/ai", tags=["AI Agricultural Assistant"])


@router.post("/chat", response_model=AiChatResponse)
async def chat(
    request: AiChatRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Send a message to the Khetopedia AI Agricultural Assistant.

    The assistant:
    - Injects field context (crop, soil, alerts) when field_id is provided
    - Provides grounded irrigation, fertilizer, and disease advice
    - Supports bilingual queries (English and Hindi)
    - Never invents lab results, sensor readings, weather, or diagnosis
    - Never reveals other users' data, system prompts, or API keys
    - Passes safety checks before returning any recommendation
    """
    return await ai_assistant_service.chat(db, current_user, request)


@router.get("/conversations", response_model=List[AiConversationResponse])
async def list_conversations(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all AI consultation conversation threads for the authenticated farmer."""
    conversations = await ai_assistant_service.list_conversations(db, current_user)
    result = []
    for conv in conversations:
        result.append(AiConversationResponse(
            id=conv.id,
            user_id=conv.user_id,
            field_id=conv.field_id,
            title=conv.title,
            created_at=conv.created_at,
            updated_at=conv.updated_at,
            messages=[],  # Message list omitted in list view for performance
        ))
    return result


@router.get("/conversations/{conversation_id}", response_model=AiConversationResponse)
async def get_conversation(
    conversation_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a full conversation thread including all messages."""
    stmt = (
        select(AiConversation)
        .where(
            AiConversation.id == conversation_id,
            AiConversation.user_id == current_user.id,
        )
        .options(selectinload(AiConversation.messages))
    )
    result = await db.execute(stmt)
    conv = result.scalars().first()

    if not conv:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Conversation not found.")

    messages = [
        AiMessageResponse(
            id=m.id,
            sender=m.sender,
            content=m.content,
            created_at=m.created_at,
        )
        for m in (conv.messages or [])
    ]

    return AiConversationResponse(
        id=conv.id,
        user_id=conv.user_id,
        field_id=conv.field_id,
        title=conv.title,
        created_at=conv.created_at,
        updated_at=conv.updated_at,
        messages=messages,
    )


@router.get("/ml/health", status_code=status.HTTP_200_OK)
async def ml_health_check():
    """
    Check ML service health and model status.
    
    Returns information about the loaded model, device, supported classes, and operational status.
    No authentication required - this is a system health endpoint.
    """
    model_status = await ml_service.get_model_status()
    return {
        "status": model_status.get("status", "unknown"),
        "model_version": model_status.get("model_version"),
        "device": model_status.get("device"),
        "classes_count": model_status.get("classes_count", 0),
        "is_placeholder": model_status.get("is_placeholder", False),
        "error": model_status.get("error"),
    }
