# services/auth_service.py
import json
import random
from datetime import datetime, timedelta
from typing import Optional, Tuple
from jose import jwt

from ..core.config import settings
from ..core.redis import redis_client
from ..core.security import create_access_token, create_refresh_token, verify_token
from ..db import crud

MAX_OTP_ATTEMPTS = 3

async def send_otp_service(phone: str) -> Tuple[bool, str]:
    """Send OTP to user, using Kavenegar or fallback to Firebase or debug mode"""
    otp_code = str(random.randint(100000, 999999))
    otp_data = {
        "code": otp_code,
        "attempts": 0,
        "created_at": datetime.utcnow().isoformat()
    }

    # Save OTP to Redis
    await redis_client.setex(f"otp:{phone}", 120, json.dumps(otp_data))

    # Try Kavenegar
    from .sms_providers.kavenegar import send_otp_kavenegar
    if settings.SMS_PROVIDER.lower() == "kavenegar" and settings.KAVENEGAR_API_KEY:
        result = send_otp_kavenegar(phone, otp_code)
        if result and result.get("return") == 200:
            return True, "OTP sent via Kavenegar"
        else:
            print(f"Debug: Kavenegar failed for {phone}, fallback mode")
    
    # TODO: Add Firebase SMS here if you want
    if settings.SMS_PROVIDER.lower() == "firebase":
        # Placeholder: implement Firebase send
        print(f"Debug: Firebase SMS not implemented, fallback to debug OTP")
    
    # Debug fallback
    print(f"Debug OTP for {phone}: {otp_code}")
    return True, "OTP sent via debug mode"

async def verify_otp_service(phone: str, otp: str, device_id: str, db) -> dict:
    """Verify OTP and return tokens"""
    otp_key = f"otp:{phone}"
    otp_data_str = await redis_client.get(otp_key)
    if not otp_data_str:
        raise ValueError("OTP expired or not found")

    try:
        otp_data = json.loads(otp_data_str)
    except json.JSONDecodeError:
        raise ValueError("OTP data corrupted")

    if otp_data.get("attempts", 0) >= MAX_OTP_ATTEMPTS:
        await redis_client.delete(otp_key)
        raise ValueError("Max OTP attempts reached")

    if otp_data.get("code") != otp:
        otp_data["attempts"] = otp_data.get("attempts", 0) + 1
        await redis_client.setex(otp_key, 120, json.dumps(otp_data))
        raise ValueError("Incorrect OTP")

    # OTP is valid, delete it
    await redis_client.delete(otp_key)

    # Get or create user
    user = crud.get_or_create_user_by_phone(db, phone)

    # Create tokens
    access_token = create_access_token({"sub": str(user.id), "role": user.role})
    refresh_token, refresh_id = create_refresh_token({"sub": str(user.id)})

    # Store refresh token in Redis
    refresh_key = f"refresh_token:{user.id}:{refresh_id}"
    await redis_client.setex(refresh_key, settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 3600, "1")

    # Device session
    device_key = f"session_device:{user.id}:{device_id}"
    device_data = {
        "last_login": datetime.utcnow().isoformat(),
        "token_id": refresh_id
    }
    await redis_client.setex(device_key, 30 * 24 * 3600, json.dumps(device_data))

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": {
            "id": str(user.id),
            "phone": user.phone,
            "role": user.role,
            "name": user.name
        }
    }

async def refresh_token_service(refresh_token: str, db) -> str:
    """Refresh access token"""
    payload = verify_token(refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise ValueError("Invalid refresh token")

    user_id = payload.get("sub")
    token_id = payload.get("jti")
    if not user_id or not token_id:
        raise ValueError("Invalid token payload")

    refresh_key = f"refresh_token:{user_id}:{token_id}"
    exists = await redis_client.exists(refresh_key)
    if not exists:
        raise ValueError("Refresh token revoked")

    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise ValueError("User not found")

    access_token = create_access_token({"sub": str(user.id), "role": user.role})
    return access_token
