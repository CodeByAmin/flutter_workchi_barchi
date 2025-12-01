# app/api/v1_convos.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..core.deps import get_current_user_id
from ..db.base import get_db
from ..db import crud

router = APIRouter()

@router.post("/conversations")
def create_conversation(members: list[str], is_group: bool = False, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    conv = crud.create_conversation(db, is_group=is_group)
    # add requesting user if not present
    if str(user_id) not in members:
        members.append(str(user_id))
    for m in members:
        crud.add_member_to_conversation(db, conv.id, m)
    return {"id": str(conv.id)}
    
@router.get("/conversations")
def list_conversations(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    convs = crud.list_conversations_for_user(db, user_id)
    return [{"id": str(c.id), "is_group": c.is_group, "created_at": c.created_at} for c in convs]
