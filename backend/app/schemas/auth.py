#AUTH.PY 
from pydantic import BaseModel, validator
import re
from typing import Optional

class SendOTPRequest(BaseModel):
    phone: str
    
    @validator('phone')
    def validate_phone(cls, v):
        # Simple validation for Iranian phone numbers
        if not re.match(r'^\+98[0-9]{10}$', v):
            raise ValueError('Phone must be in format +989121234567')
        return v

class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str
    device_id: str

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: dict

class OTPResponse(BaseModel):
    ok: bool
    ttl: int