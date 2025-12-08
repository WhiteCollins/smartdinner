from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import uvicorn
import os

from .models.schemas import (
    PredictionRequest, 
    PredictionResponse,
    BatchPredictionRequest,
    TrainingRequest,
    TrainingResponse,
    ModelStatus
)
from .services.prediction_service import DemandPredictionService
from .config.settings import get_settings

settings = get_settings()
app = FastAPI(
    title=settings.app_name,
    description="Servicio de Inteligencia Artificial para predicción de demanda y análisis",
    version=settings.version
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Singleton del servicio de predicción
prediction_service = DemandPredictionService()

@app.get("/")
async def root():
    """Endpoint raíz con información del servicio"""
    model_info = prediction_service.get_model_info()
    return {
        "service": settings.app_name,
        "version": settings.version,
        "status": "running",
        "model_loaded": model_info["model_loaded"],
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
def health():
    """Health check endpoint"""
    model_loaded = prediction_service.model is not None
    return {
        "status": "healthy" if model_loaded else "degraded",
        "model_loaded": model_loaded,
        "timestamp": datetime.now().isoformat()
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict_demand(request: PredictionRequest):
    """
    Predice la demanda de un platillo específico para una fecha determinada.
    
    - **item_id**: ID único del platillo
    - **item_name**: Nombre del platillo
    - **date**: Fecha de predicción (formato ISO)
    - **historical_data**: Datos históricos opcionales
    """
    try:
        prediction = prediction_service.predict(
            request.item_id,
            request.date
        )
        
        return PredictionResponse(
            item_id=request.item_id,
            item_name=request.item_name,
            prediction_date=request.date,
            **prediction
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en predicción: {str(e)}")

@app.post("/batch-predict")
async def batch_predict(request: BatchPredictionRequest):
    """
    Predice la demanda para múltiples platillos de forma eficiente.
    
    - **items**: Lista de items a predecir
    - **date**: Fecha de predicción (opcional, usa fecha actual si no se proporciona)
    """
    try:
        date_str = request.date or datetime.now().isoformat()
        
        predictions = prediction_service.batch_predict(
            [item.dict() for item in request.items],
            date_str
        )
        
        return {
            "predictions": predictions,
            "total_items": len(predictions),
            "prediction_date": date_str,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en batch prediction: {str(e)}")
@app.post("/train", response_model=TrainingResponse)
async def train_model(
    request: TrainingRequest,
    background_tasks: BackgroundTasks
):
    """
    Entrena o re-entrena el modelo de predicción de demanda.
    
    El entrenamiento se ejecuta en segundo plano para no bloquear el API.
    
    - **days_of_history**: Cantidad de días históricos a usar (30-365)
    - **force_retrain**: Forzar re-entrenamiento aunque ya exista modelo
    """
    def train_task():
        try:
            result = prediction_service.train_model(request.days_of_history)
            print(f"✅ Entrenamiento completado: {result}")
        except Exception as e:
            print(f"❌ Error en entrenamiento: {e}")
    
    # Ejecutar entrenamiento en background
    background_tasks.add_task(train_task)
    
    return TrainingResponse(
        status="training_started",
        message=f"El modelo está siendo entrenado en segundo plano con {request.days_of_history} días de historia",
        samples=None,
        mae=None,
        r2=None,
        trained_at=None
    )

@app.get("/models/status", response_model=ModelStatus)
async def get_model_status():
    """
    Obtiene el estado actual del modelo de predicción.
    
    Incluye información sobre:
    - Estado de carga del modelo
    - Última fecha de entrenamiento
    - Métricas de precisión
    - Número de muestras usadas
    """
    model_info = prediction_service.get_model_info()
    metadata = model_info.get("metadata") or {}
    
    return ModelStatus(
        model_name="demand_prediction_model",
        status="loaded" if model_info["model_loaded"] else "not_trained",
        version=settings.version,
        last_training=metadata.get("trained_at") if metadata else None,
        accuracy=metadata.get("r2") if metadata else None,
        samples_trained=metadata.get("samples") if metadata else None
    )

@app.get("/models/info")
async def get_model_info():
    """
    Obtiene información detallada sobre el modelo actual.
    
    Retorna:
    - Estado de carga del modelo
    - Metadata del último entrenamiento
    - Columnas de features utilizadas
    """
    return prediction_service.get_model_info()

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)