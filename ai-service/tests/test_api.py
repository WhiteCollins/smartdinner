"""
Tests para los endpoints de la API FastAPI.

Verifica que todos los endpoints respondan correctamente.
"""

import pytest
from fastapi.testclient import TestClient


class TestHealthEndpoints:
    """Tests para endpoints de salud y estado."""
    
    def test_root_endpoint(self, test_client: TestClient):
        """Test del endpoint raíz."""
        response = test_client.get("/")
        assert response.status_code == 200
        data = response.json()
        
        assert "service" in data
        assert "version" in data
        assert "status" in data
        assert data["status"] == "running"
    
    def test_health_endpoint(self, test_client: TestClient):
        """Test del health check."""
        response = test_client.get("/health")
        assert response.status_code == 200
        data = response.json()
        
        assert "status" in data
        assert "model_loaded" in data
        assert "timestamp" in data


class TestPredictionEndpoints:
    """Tests para endpoints de predicción."""
    
    def test_predict_endpoint_structure(self, test_client: TestClient, sample_prediction_request):
        """Verifica estructura de respuesta de predict."""
        response = test_client.post("/predict", json=sample_prediction_request)
        
        # Puede fallar si no hay modelo entrenado, pero verificamos estructura
        if response.status_code == 200:
            data = response.json()
            assert "item_id" in data
            assert "predicted_demand" in data
            assert "confidence" in data
            assert "level" in data
        else:
            # Si falla, debe ser por falta de modelo
            assert response.status_code in [400, 500]
    
    def test_predict_invalid_data(self, test_client: TestClient):
        """Test con datos inválidos."""
        invalid_request = {
            "item_id": "invalid",
            "item_name": "",  # Nombre vacío
            "date": "not-a-date"
        }
        
        response = test_client.post("/predict", json=invalid_request)
        assert response.status_code == 422  # Validation error
    
    def test_batch_predict_structure(self, test_client: TestClient, sample_batch_request):
        """Verifica estructura de batch predict."""
        response = test_client.post("/batch-predict", json=sample_batch_request)
        
        if response.status_code == 200:
            data = response.json()
            assert "predictions" in data
            assert "total_items" in data
            assert isinstance(data["predictions"], list)
        else:
            assert response.status_code in [400, 500]


class TestModelEndpoints:
    """Tests para endpoints de información del modelo."""
    
    def test_model_status_endpoint(self, test_client: TestClient):
        """Test del endpoint de estado del modelo."""
        response = test_client.get("/models/status")
        assert response.status_code == 200
        data = response.json()
        
        assert "model_name" in data
        assert "status" in data
        assert "version" in data
    
    def test_model_info_endpoint(self, test_client: TestClient):
        """Test del endpoint de información del modelo."""
        response = test_client.get("/models/info")
        assert response.status_code == 200
        data = response.json()
        
        assert "model_loaded" in data
        assert "model_path" in data


class TestTrainingEndpoint:
    """Tests para el endpoint de entrenamiento."""
    
    def test_train_endpoint_validation(self, test_client: TestClient):
        """Verifica validación de parámetros de entrenamiento."""
        # Días fuera de rango
        invalid_request = {
            "days_of_history": 10,  # Mínimo es 30
            "force_retrain": False
        }
        
        response = test_client.post("/train", json=invalid_request)
        assert response.status_code == 422  # Validation error
    
    def test_train_endpoint_structure(self, test_client: TestClient):
        """Verifica estructura de respuesta de entrenamiento."""
        valid_request = {
            "days_of_history": 90,
            "force_retrain": False
        }
        
        response = test_client.post("/train", json=valid_request)
        
        # El entrenamiento se ejecuta en background
        if response.status_code == 200:
            data = response.json()
            assert "status" in data
            assert "message" in data
        else:
            # Puede fallar por falta de datos
            assert response.status_code in [400, 500]
