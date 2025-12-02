# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import redis.asyncio as redis
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from .core.config import settings
import logging


from .db.base import engine, Base
from .api import v1_auth, v1_users, v1_convos, v1_messages, v1_market
logger = logging.getLogger("uvicorn.error")
logger.setLevel(logging.INFO)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Starting up...")
    
    # Create database tables
    # Base.metadata.create_all(bind=engine)
    
    # Test Redis connection
    try:
        redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
        await redis_client.ping()
        print("Redis connection successful")
        await redis_client.close()
    except Exception as e:
        print(f"Redis connection failed: {e}")
    
    yield
    
    # Shutdown
    print("Shutting down...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS middleware
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.BACKEND_CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Include routers
app.include_router(v1_auth.router, prefix=settings.API_V1_STR)
app.include_router(v1_users.router, prefix=settings.API_V1_STR + "/users")
app.include_router(v1_convos.router, prefix=settings.API_V1_STR)
app.include_router(v1_messages.router, prefix=settings.API_V1_STR)
app.include_router(v1_market.router, prefix=settings.API_V1_STR)
@app.get("/")
async def root():
    return {"message": "JobConnect API", "version": settings.VERSION}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "backend"}