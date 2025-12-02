#config.py
from enum import Enum
from typing import Optional
from pydantic_settings import BaseSettings
from enum import Enum
from typing import Optional

class SmsProvider(str, Enum):
    MOCK = "mock"
    DOCKER = "docker"
    KAVENEGAR = "kavenegar"

class Settings(BaseSettings):
    PROJECT_NAME: str = "JobConnect API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database
    DATABASE_URL: str
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # SMS Provider
    KAVENEGAR_API_KEY: Optional[str] = None
    SMS_PROVIDER: SmsProvider = SmsProvider.MOCK  # default
    
    # Environment
    ENVIRONMENT: str = "development"
    
    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
