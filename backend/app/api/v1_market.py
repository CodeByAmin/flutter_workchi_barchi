# app/api/v1_market.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.deps import get_current_user_id
from ..db.base import get_db
from ..db import crud

router = APIRouter()

@router.get("/market/items")
def list_items(limit:int=50, offset:int=0, db: Session = Depends(get_db)):
    items = crud.list_market_items(db, limit=limit, offset=offset)
    return [{"id": str(i.id), "title": i.title, "price": float(i.price) if i.price else None, "available": i.available} for i in items]
