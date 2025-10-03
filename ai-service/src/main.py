from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
import uvicorn
import os

app = FastAPI(
    title="SmartDinner AI Service",
    description="Servicio de Inteligencia Artificial para predicción de demanda",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PredictionRequest(BaseModel):
    item_id: str
    item_name: str
    date: str
    historical_data: dict = {}

class PredictionResponse(BaseModel):
    item_id: str
    item_name: str
    prediction_date: str
    predicted_demand: int
    confidence: float
    level: str

@app.get("/")
async def root():
    return {
        "service": "SmartDinner AI Service",
        "version": "1.0.0",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    return {
        "status": "OK",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict_demand(request: PredictionRequest):
    """
    Predice la demanda de un platillo específico
    """
    try:
        # TODO: Implementar lógica de predicción real
        # Por ahora, retornamos datos de ejemplo
        
        import random
        
        predicted_demand = random.randint(10, 100)
        confidence = random.uniform(0.6, 0.95)
        
        if predicted_demand >= 70:
            level = "high"
        elif predicted_demand >= 40:
            level = "medium"
        else:
            level = "low"
        
        return PredictionResponse(
            item_id=request.item_id,
            item_name=request.item_name,
            prediction_date=request.date,
            predicted_demand=predicted_demand,
            confidence=confidence,
            level=level
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/batch-predict")
async def batch_predict(items: list[PredictionRequest]):
    """
    Predice la demanda para múltiples platillos
    """
    try:
        predictions = []
        for item in items:
            prediction = await predict_demand(item)
            predictions.append(prediction)
        
        return {
            "predictions": predictions,
            "total_items": len(predictions),
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/models/status")
async def get_model_status():
    """
    Obtiene el estado de los modelos de IA
    """
    return {
        "demand_prediction_model": {
            "status": "loaded",
            "version": "1.0.0",
            "last_training": "2024-10-01T00:00:00Z",
            "accuracy": 0.85
        },
        "recommendation_model": {
            "status": "not_implemented",
            "version": None
        }
    }

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)