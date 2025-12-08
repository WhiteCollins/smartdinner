"""Schemas de Pydantic para validación de datos"""
from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, List
from datetime import datetime

class PredictionRequest(BaseModel):
    item_id: str
    item_name: str
    date: str
    historical_data: Optional[Dict] = {}
    
    @validator('date')
    def validate_date(cls, v):
        try:
            datetime.fromisoformat(v.replace('Z', '+00:00'))
            return v
        except ValueError:
            raise ValueError('Invalid date format. Use ISO format (YYYY-MM-DD)')

class PredictionResponse(BaseModel):
    item_id: str
    item_name: str
    prediction_date: str
    predicted_demand: int = Field(ge=0)
    confidence: float = Field(ge=0.0, le=1.0)
    level: str = Field(pattern='^(low|medium|high)$')
    factors: Optional[Dict] = None
    recommendations: Optional[List[str]] = None

class BatchPredictionRequest(BaseModel):
    items: List[PredictionRequest]
    date: Optional[str] = None

class TrainingRequest(BaseModel):
    days_of_history: int = Field(default=90, ge=30, le=365)
    force_retrain: bool = False

class TrainingResponse(BaseModel):
    status: str
    message: str
    samples: Optional[int] = None
    mae: Optional[float] = None
    r2: Optional[float] = None
    trained_at: Optional[str] = None

class ModelStatus(BaseModel):
    model_name: str
    status: str
    version: str
    last_training: Optional[str]
    accuracy: Optional[float]
    samples_trained: Optional[int]
