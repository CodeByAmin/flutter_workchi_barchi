# v1_auth.py
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
import redis.asyncio as redis
import random
from datetime import datetime
import asyncio
from ..core.config import settings
from ..core.security import create_access_token, create_refresh_token, verify_token
from ..db.base import get_db
from ..db import crud
from ..schemas.auth import SendOTPRequest, VerifyOTPRequest, RefreshTokenRequest, TokenResponse, OTPResponse
from ..services.otp_service import send_otp, verify_otp_code
from ..services.sms_providers.kavenegar import send_otp_kavenegar
from ..services.auth_service import send_otp_service, verify_otp_service, refresh_token_service
router = APIRouter()
security = HTTPBearer()

@router.post("/send-otp", response_model=OTPResponse)
async def send_otp_endpoint(
    request: SendOTPRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Send OTP to phone number"""
    # Rate limiting check (simplified)
    # In production, use proper rate limiting middleware
    
    otp_code = str(random.randint(100000, 999999))
    
    # Store OTP in Redis with TTL
    redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
    otp_key = f"otp:{request.phone}"
    
    # Store OTP with metadata
    otp_data = {
        "code": otp_code,
        "attempts": 0,
        "created_at": datetime.utcnow().isoformat()
    }
    
    # Use pipeline for atomic operations
    async with redis_client.pipeline() as pipe:
        await pipe.setex(otp_key, 120, str(otp_data))
        await pipe.incr(f"rate:otp:{request.phone}")
        await pipe.expire(f"rate:otp:{request.phone}", 3600)
        await pipe.execute()
    
    # Send OTP via SMS in background
    if settings.SMS_PROVIDER == "kavenegar" and settings.KAVENEGAR_API_KEY:
        background_tasks.add_task(
            send_otp_kavenegar,
            phone=request.phone,
            otp=otp_code
        )
    else:
        # Mock for development
        print(f"Mock OTP for {request.phone}: {otp_code}")
    
    return OTPResponse(ok=True, ttl=120)

@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp_endpoint(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db)
):
    """Verify OTP and return tokens"""
    redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
    
    # Verify OTP
    is_valid = await verify_otp_code(
        redis_client=redis_client,
        phone=request.phone,
        otp=request.otp
    )
    
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid OTP or OTP expired"
        )
    
    # Get or create user
    user = crud.get_or_create_user_by_phone(db, request.phone)
    
    # Create tokens
    access_token = create_access_token({"sub": str(user.id), "role": user.role})
    refresh_token, refresh_id = create_refresh_token({"sub": str(user.id)})
    
    # Store refresh token in Redis
    refresh_key = f"refresh_token:{user.id}:{refresh_id}"
    await redis_client.setex(refresh_key, settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 3600, "1")
    
    # Store device session
    device_key = f"session_device:{user.id}:{request.device_id}"
    device_data = {
        "last_login": datetime.utcnow().isoformat(),
        "token_id": refresh_id
    }
    await redis_client.setex(device_key, 30 * 24 * 3600, str(device_data))
    
    # Update user last seen
    user.last_seen = datetime.utcnow()
    db.commit()
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user={
            "id": str(user.id),
            "phone": user.phone,
            "role": user.role,
            "name": user.name
        }
    )

@router.post("/refresh", response_model=dict)
async def refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """Refresh access token using refresh token"""
    # Verify refresh token
    payload = verify_token(request.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    user_id = payload.get("sub")
    token_id = payload.get("jti")
    
    if not user_id or not token_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload"
        )
    
    # Check if refresh token exists in Redis
    redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
    refresh_key = f"refresh_token:{user_id}:{token_id}"
    exists = await redis_client.exists(refresh_key)
    
    if not exists:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token revoked"
        )
    
    # Get user
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Create new access token
    access_token = create_access_token({"sub": str(user.id), "role": user.role})
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/logout")
async def logout(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Logout user by invalidating refresh token"""
    token = credentials.credentials
    payload = verify_token(token)
    
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
    
    user_id = payload.get("sub")
    token_id = payload.get("jti")
    
    if user_id and token_id:
        # Invalidate refresh token
        redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
        refresh_key = f"refresh_token:{user_id}:{token_id}"
        await redis_client.delete(refresh_key)
    
    return {"ok": True}