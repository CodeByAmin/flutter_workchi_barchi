# app/api/v1_users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db.base import get_db
from ..db import crud
from ..schemas.user import UserProfileUpdate, UserProfileOut
from ..core.deps import get_current_user_id   # این خط رو اضافه کن

router = APIRouter()

@router.get("/me", response_model=UserProfileOut)
def get_my_profile(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404, "User not found")

    return UserProfileOut(
        id=str(user.id),
        phone=user.phone,
        name=user.name,
        avatar_url=user.avatar_url,
        role=user.role,
        has_selected_role=user.role is not None,
        rating_avg=user.rating_avg or 0.0,
        last_seen=user.last_seen.isoformat() if user.last_seen else None
    )

@router.api_route("/me", methods=["PATCH", "PUT"], response_model=UserProfileOut)
def update_profile(
    payload: UserProfileUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404, "User not found")

    if payload.name is not None:
        user.name = payload.name
    if payload.avatar_url is not None:
        user.avatar_url = payload.avatar_url

    db.commit()
    db.refresh(user)

    return UserProfileOut(
        id=str(user.id),
        phone=user.phone,
        name=user.name,
        avatar_url=user.avatar_url,
        role=user.role,
        has_selected_role=user.role is not None,
        rating_avg=user.rating_avg or 0.0,
        last_seen=user.last_seen.isoformat() if user.last_seen else None
    )
@router.post("/me/select-role")
def select_role(
    role: str,  # "worker" یا "employer"
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    if role not in ["worker", "employer"]:
        raise HTTPException(400, "نقش نامعتبر است")

    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404)

    if user.role is not None:
        raise HTTPException(400, "نقش قبلاً انتخاب شده")

    user.role = role
    db.commit()

    return {"message": "نقش با موفقیت انتخاب شد", "role": role}