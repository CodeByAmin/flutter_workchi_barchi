# app/schemas/message.py
from pydantic import BaseModel

class SendMessageRequest(BaseModel):
    text: str

class MessageOut(BaseModel):
    id: str
    conversation_id: str
    sender_id: str
    message: str
    created_at: str
