# KAVEHNEGAR.PY
import os
import requests
from typing import Optional
from ...core.config import settings

def send_otp_kavenegar(phone: str, otp: str) -> Optional[dict]:
    """Send OTP via Kavenegar SMS provider"""
    if not settings.KAVENEGAR_API_KEY:
        print("Warning: Kavenegar API key not configured")
        return None
    
    try:
        url = f"https://api.kavenegar.com/v1/{settings.KAVENEGAR_API_KEY}/sms/send.json"
        message = f"کد تایید JobConnect: {otp}"
        
        payload = {
            "receptor": phone,
            "message": message,
            "sender": "10004346"  # Default sender number
        }
        
        response = requests.post(url, data=payload, timeout=10)
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.RequestException as e:
        print(f"Error sending SMS via Kavenegar: {e}")
        return None