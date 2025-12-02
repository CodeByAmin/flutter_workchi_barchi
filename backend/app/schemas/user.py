from pydantic import BaseModel
from typing import Optional

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    avatar_url: Optional[str] = None

    class Config:
        extra = "ignore"

class UserProfileOut(BaseModel):
    id: str
    phone: str
    name: Optional[str] = None
    avatar_url: Optional[str] = None
    role: Optional[str] = None        # ← Optional کن!
    has_selected_role: bool           # ← اینو اضافه کن
    rating_avg: float = 0.0
    last_seen: Optional[str] = None