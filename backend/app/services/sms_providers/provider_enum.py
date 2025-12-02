#provider_enum.py
from enum import Enum

class SmsProvider(str, Enum):
    KAVENEGAR = "kavenegar"
    DOCKER = "docker"
    MOCK = "mock"
