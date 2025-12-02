# services/sms_probiders/KAVEHNEGAR.PY
import requests
from ...core.config import settings

def send_otp_kavenegar(phone: str, otp: str) -> dict | None:
    api_key = settings.KAVENEGAR_API_KEY.strip()
    if not api_key or api_key == "your-kavenegar-api-key-here":
        print("Kavenegar API key not set")
        return None

    url = f"https://api.kavenegar.com/v1/{api_key}/sms/send.json"
    payload = {
        "receptor": phone.replace("+98", "0"),  # کاوِنگر با 09 کار می‌کنه
        "message": f"کد ورود JobConnect: {otp}\nاین کد ۲ دقیقه معتبر است.",
        "sender": "10004346"
    }

    try:
        response = requests.post(url, data=payload, timeout=12)
        response.raise_for_status()
        print(f"پیامک با موفقیت ارسال شد: {response.json()}")
        return response.json()
    except Exception as e:
        print(f"خطای کاوِنگر: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"پاسخ سرور: {e.response.text}")
        return None