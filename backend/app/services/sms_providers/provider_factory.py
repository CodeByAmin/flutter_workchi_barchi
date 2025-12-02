import logging
from app.services.sms_providers.provider_enum import SmsProvider
from app.services.sms_providers.kavenegar import send_otp_kavenegar
from app.core.config import settings

logger = logging.getLogger("uvicorn.error")

async def send_sms(phone: str, otp: str):
    provider = settings.SMS_PROVIDER  # از .env گرفته میشه

    if provider == SmsProvider.KAVENEGAR:
        return await send_otp_kavenegar(phone, otp)

    elif provider == SmsProvider.DOCKER:
        logger.info(f"[DOCKER LOG SMS] OTP={otp} -> {phone}")
        return {"status": "docker-ok"}

    elif provider == SmsProvider.MOCK:
        logger.info(f"[MOCK SMS] OTP={otp} -> {phone}")
        return {"status": "mock-ok"}

    else:
        logger.error("Provider not supported")
        return None
