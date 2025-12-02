# app/api/v1_users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db.base import get_db
from ..db import crud
from ..schemas.user import UserProfileUpdate, UserProfileOut
from ..core.deps import get_current_user_id   # این خط رو اضافه کن

router = APIRouter()

@router.get("/me", response_model=UserProfileOut)
def get_my_profile(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
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
        "last_seen": user.last_seen.isoformat() if user.last_seen else None
    }

@router.put("/me", response_model=UserProfileOut)
def update_profile(payload: UserProfileUpdate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    if payload.name is not None:
        user.name = payload.name
    if payload.avatar_url is not None:
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
        "last_seen": user.last_seen.isoformat() if user.last_seen else None
    }