# app/api/v1_users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db.base import get_db
from ..db import crud
from ..schemas.user import UserProfileUpdate, UserProfileOut

router = APIRouter()

@router.get("/me", response_model=UserProfileOut)
def get_my_profile(user_id: str = Depends(...), db: Session = Depends(get_db)):
    # TODO: replace user_id dependency with real auth dependency
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    return {
        "id": str(user.id),
        "phone": user.phone,
        "name": user.name,
        "avatar_url": user.avatar_url,
        "role": user.role,
        "rating_avg": user.rating_avg,
        "last_seen": user.last_seen
    }

@router.put("/me", response_model=UserProfileOut)
def update_profile(payload: UserProfileUpdate, user_id: str = Depends(...), db: Session = Depends(get_db)):
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    if payload.name:
        user.name = payload.name
    if payload.avatar_url:
        user.avatar_url = payload.avatar_url
    db.commit()
    db.refresh(user)
    return {
        "id": str(user.id),
        "phone": user.phone,
        "name": user.name,
        "avatar_url": user.avatar_url,
        "role": user.role,
        "rating_avg": user.rating_avg,
        "last_seen": user.last_seen
    }
