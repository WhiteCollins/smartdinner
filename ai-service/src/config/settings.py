"""Configuración centralizada usando Pydantic Settings"""
from pydantic_settings import BaseSettings
from functools import lru_cache
import os

class Settings(BaseSettings):
    # API Configuration
    app_name: str = "SmartDinner AI Service"
    version: str = "1.0.0"
    port: int = 8000
    environment: str = "development"
    
    # Supabase
    supabase_url: str = ""
    supabase_service_key: str = ""
    
    # Model Configuration
    model_path: str = "./models"
    data_path: str = "./data"
    prediction_batch_size: int = 100
    model_retrain_interval: int = 86400  # 24 hours
    
    # Cache
    cache_ttl: int = 3600
    
    # Logging
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = False

@lru_cache()
def get_settings() -> Settings:
    return Settings()
