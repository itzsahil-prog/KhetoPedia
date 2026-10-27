from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class AiChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    field_id: Optional[str] = None
    conversation_id: Optional[str] = None
    preferred_language: Optional[str] = "en"  # "en", "hi", etc.


class AiMessageResponse(BaseModel):
    id: str
    sender: str  # user, assistant
    content: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class AiConversationResponse(BaseModel):
    id: str
    user_id: str
    field_id: Optional[str] = None
    title: str
    created_at: datetime
    updated_at: datetime
    messages: List[AiMessageResponse] = []

    model_config = ConfigDict(from_attributes=True)


class AiChatResponse(BaseModel):
    conversation_id: str
    reply: str
    suggested_actions: List[str] = []
    field_context_applied: bool = False
