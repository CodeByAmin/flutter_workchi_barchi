# app/schemas/user.py
from pydantic import BaseModel
from typing import Optional

class UserProfileUpdate(BaseModel):
    name: Optional[str]
    avatar_url: Optional[str]

class UserProfileOut(BaseModel):
    id: str
    phone: str
    name: Optional[str]
    avatar_url: Optional[str]
    role: str
    rating_avg: float
    last_seen: Optional[str]
