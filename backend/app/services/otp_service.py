# OTP_SERVICE.PY
import json
from datetime import datetime
from typing import Optional
import redis.asyncio as redis

MAX_OTP_ATTEMPTS = 3

async def send_otp(redis_client: redis.Redis, phone: str, otp: str) -> bool:
    """Store OTP in Redis with metadata"""
    otp_data = {
        "code": otp,
        "attempts": 0,
        "created_at": datetime.utcnow().isoformat()
    }
    
    await redis_client.setex(f"otp:{phone}", 120, json.dumps(otp_data))
    return True

async def verify_otp_code(redis_client: redis.Redis, phone: str, otp: str) -> bool:
    """Verify OTP from Redis"""
    otp_key = f"otp:{phone}"
    otp_data_str = await redis_client.get(otp_key)
    
    if not otp_data_str:
        return False
    
    try:
        otp_data = json.loads(otp_data_str)
    except json.JSONDecodeError:
        return False
    
    # Check attempts
    if otp_data.get("attempts", 0) >= MAX_OTP_ATTEMPTS:
        await redis_client.delete(otp_key)
        return False
    
    # Verify code
    if otp_data.get("code") != otp:
        # Increment attempts
        otp_data["attempts"] = otp_data.get("attempts", 0) + 1
        await redis_client.setex(otp_key, 120, json.dumps(otp_data))
        return False
    
    # OTP is valid, delete it
    await redis_client.delete(otp_key)
    return True