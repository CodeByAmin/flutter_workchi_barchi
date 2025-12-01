# app/api/v1_messages.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..core.deps import get_current_user_id
from ..db.base import get_db
from ..db import crud
from ..schemas.message import SendMessageRequest, MessageOut
from fastapi import WebSocket, WebSocketDisconnect
from ..services.websocket_manager import ws_manager
router = APIRouter()

@router.post("/conversations/{conversation_id}/messages", response_model=MessageOut)
def send_message(conversation_id: str, payload: SendMessageRequest, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    # Check membership (simple)
    # TODO: improve: check conversation membership
    msg = crud.create_message(db, conversation_id=conversation_id, sender_id=user_id, message_text=payload.text)
    return {"id": str(msg.id), "conversation_id": str(msg.conversation_id), "sender_id": str(msg.sender_id), "message": msg.message, "created_at": msg.created_at}

@router.get("/conversations/{conversation_id}/messages")
def list_messages(conversation_id: str, limit: int = 100, offset: int = 0, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    msgs = crud.list_messages(db, conversation_id, limit=limit, offset=offset)
    return [{"id": str(m.id), "sender_id": str(m.sender_id), "message": m.message, "created_at": m.created_at} for m in msgs]

@router.websocket("/ws/conversations/{conversation_id}")
async def convo_ws(websocket: WebSocket, conversation_id: str):
    await ws_manager.connect(conversation_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            # save to DB
            # broadcast to members
            await ws_manager.broadcast(conversation_id, data)
    except WebSocketDisconnect:
        ws_manager.disconnect(conversation_id, websocket)