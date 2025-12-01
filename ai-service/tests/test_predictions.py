"""
Tests para el servicio de predicciones.

Verifica la lógica de ML y transformación de datos.
"""

import pytest
from datetime import datetime
import pandas as pd
import numpy as np


class TestFeatureEngineering:
    """Tests para extracción de features."""
    
    def test_prepare_features(self, sample_orders_data):
        """Verifica extracción de features temporales."""
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        features_df = service.prepare_features(sample_orders_data)
        
        # Verificar columnas esperadas
        expected_columns = ['day_of_week', 'day_of_month', 'month', 'is_weekend', 'week_of_year']
        for col in expected_columns:
            assert col in features_df.columns
        
        # Verificar rangos de valores
        assert features_df['day_of_week'].min() >= 0
        assert features_df['day_of_week'].max() <= 6
        assert features_df['month'].min() >= 1
        assert features_df['month'].max() <= 12
        assert features_df['is_weekend'].isin([0, 1]).all()
    
    def test_prepare_features_empty_data(self):
        """Test con datos vacíos."""
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        
        with pytest.raises(ValueError):
            service.prepare_features([])


class TestModelTraining:
    """Tests para entrenamiento del modelo."""
    
    def test_train_model_insufficient_data(self):
        """Verifica error con datos insuficientes."""
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        
        # Con días muy altos y sin datos reales
        with pytest.raises(ValueError):
            service.train_model(days_of_history=365)


class TestPredictionLogic:
    """Tests para lógica de predicción."""
    
    def test_prediction_output_structure(self):
        """Verifica estructura de salida de predicciones."""
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        
        # Si no hay modelo, debe lanzar excepción
        if service.model is None:
            with pytest.raises(ValueError, match="modelo no ha sido entrenado"):
                service.predict("item-1", datetime.now().isoformat())
    
    def test_batch_prediction_consistency(self):
        """Verifica consistencia en batch predictions."""
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        
        items = [
            {'item_id': 'item-1', 'item_name': 'Pizza'},
            {'item_id': 'item-2', 'item_name': 'Pasta'}
        ]
        
        if service.model is None:
            # Sin modelo, debe retornar predicciones dummy
            predictions = service.batch_predict(items, datetime.now().isoformat())
            assert len(predictions) == len(items)
        else:
            predictions = service.batch_predict(items, datetime.now().isoformat())
            assert len(predictions) == len(items)
            
            for pred in predictions:
                assert 'item_id' in pred
                assert 'predicted_demand' in pred
                assert 'confidence' in pred


class TestModelInfo:
    """Tests para información del modelo."""
    
    def test_get_model_info_structure(self):
        """Verifica estructura de información del modelo."""
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        info = service.get_model_info()
        
        assert 'model_loaded' in info
        assert 'model_path' in info
        assert isinstance(info['model_loaded'], bool)
        
        if info['model_loaded']:
            assert 'metadata' in info
            assert 'feature_columns' in info
