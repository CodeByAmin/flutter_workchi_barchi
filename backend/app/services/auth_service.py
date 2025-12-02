# app/services/auth_service.py

import json
import random
import asyncio
import logging
import httpx
from datetime import datetime
from typing import Tuple

from ..core.config import settings
from ..core.redis import redis_client
from ..core.security import create_access_token, create_refresh_token, verify_token
from ..db import crud
from app.services.sms_providers.provider_factory import send_sms
from app.services.sms_providers.provider_enum import SmsProvider
logger = logging.getLogger("uvicorn.error")

MAX_OTP_ATTEMPTS = 3


# ---------------- OTP PROVIDERS ---------------- #

async def send_otp_kavehnegar(phone: str, otp: str):
    """Provider 1: KavehNegar"""
    try:
        url = "https://api.kavenegar.com/v1/YOUR_KAVEHNEGAR_API_KEY/verify/lookup.json"
        params = {"receptor": phone, "token": otp, "template": "otp-template"}

        async with httpx.AsyncClient(timeout=3) as client:
            response = await client.get(url, params=params)
            if response.status_code == 200:
                return True, "KavehNegar"
            return False, response.text
    except Exception as e:
        return False, f"KavehNegar Failed: {e}"


async def send_otp_payamkmeli(phone: str, otp: str):
    """Provider 2: PayamkMeli"""
    try:
        body = {"mobile": phone, "message": f"کد ورود شما: {otp}"}

        async with httpx.AsyncClient(timeout=3) as client:
            response = await client.post(
                "https://console.payamokmeli.ir/api/v1/send-sms",
                json=body,
                headers={"Authorization": "Bearer YOUR_PAYAMKMELI_TOKEN"}
            )
            if response.status_code == 200:
                return True, "PayamkMeli"
            return False, response.text
    except Exception as e:
        return False, f"PayamkMeli Failed: {e}"


async def send_otp_firebase(phone: str, otp: str):
    """Provider 3: Firebase mock"""
    try:
        await asyncio.sleep(0.4)
        return True, "Firebase"
    except Exception as e:
        return False, f"Firebase Failed: {e}"


# ---------------- PROVIDERS RACE MODE ---------------- #

async def send_otp_race(phone: str, otp_code: str) -> Tuple[bool, str]:
    """ Race between 3 providers - fastest wins — max wait time = 3 sec """
    tasks = [
        send_otp_kavehnegar(phone, otp_code),
        send_otp_payamkmeli(phone, otp_code),
        send_otp_firebase(phone, otp_code)
        
        
    ]
    alarm = "\n\n" + "█" * 120 + "\n" \
            + f"█  OTP FAILED ALL PROVIDERS - MANUAL CODE BELOW\n" \
            + f"█  PHONE: {phone}\n" \
            + f"█  OTP:   {otp_code}\n" \
            + "█" * 120 + "\n\n"
    logger.critical(alarm)
    done, pending = await asyncio.wait(tasks, timeout=3, return_when=asyncio.FIRST_COMPLETED)

    for task in pending:
        task.cancel()

    for task in done:
        success, service = await task
        if success:
            return True, f"SENT by {service} in <3s"

    # Strong Docker alarm log
    alarm = "\n\n" + "█" * 120 + "\n" \
            + f"█  OTP FAILED ALL PROVIDERS - MANUAL CODE BELOW\n" \
            + f"█  PHONE: {phone}\n" \
            + f"█  OTP:   {otp_code}\n" \
            + "█" * 120 + "\n\n"
    logger.critical(alarm)

    return False, "All Providers Failed"


# ---------------- SEND OTP SERVICE MAIN ---------------- #

async def send_otp_service(phone: str) -> Tuple[bool, str]:
    otp_code = str(random.randint(100000, 999999))
    otp_data = {"code": otp_code, "attempts": 0, "created_at": datetime.utcnow().isoformat()}

    await redis_client.setex(f"otp:{phone}", 120, json.dumps(otp_data))

    provider = SmsProvider.MOCK  # یا DOCKER یا KAVENEGAR بر اساس .env
    result = await send_sms(provider, phone, otp_code)

    if result:
        return True, f"OTP sent by {provider.name}"
    return False, "Failed to send OTP"

# ---------------- VERIFY OTP AND CREATE TOKENS ---------------- #

async def verify_otp_service(phone: str, otp: str, device_id: str, db) -> dict:
    otp_key = f"otp:{phone}"
    otp_data_str = await redis_client.get(otp_key)

    if not otp_data_str:
        raise ValueError("OTP expired or not found")

    otp_data = json.loads(otp_data_str)

    if otp_data.get("attempts", 0) >= MAX_OTP_ATTEMPTS:
        await redis_client.delete(otp_key)
        raise ValueError("Max OTP attempts reached")

    if otp_data.get("code") != otp:
        otp_data["attempts"] += 1
        await redis_client.setex(otp_key, 120, json.dumps(otp_data))
        raise ValueError("Incorrect OTP")

    await redis_client.delete(otp_key)
    user = crud.get_or_create_user_by_phone(db, phone)

    access_token = create_access_token({"sub": str(user.id), "role": user.role})
    refresh_token, refresh_id = create_refresh_token({"sub": str(user.id)})

    refresh_key = f"refresh_token:{user.id}:{refresh_id}"
    await redis_client.setex(refresh_key, settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 3600, "1")

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
    payload = verify_token(refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise ValueError("Invalid refresh token")

    user_id = payload.get("sub")
    token_id = payload.get("jti")

    refresh_key = f"refresh_token:{user_id}:{token_id}"
    exists = await redis_client.exists(refresh_key)
    if not exists:
        raise ValueError("Refresh token revoked")

    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise ValueError("User not found")

    return create_access_token({"sub": str(user.id), "role": user.role})
