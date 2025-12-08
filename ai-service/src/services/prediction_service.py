"""Servicio de predicción de demanda usando ML"""
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import pickle
import os
import json
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score

from ..config.database import get_historical_orders, get_menu_items
from ..config.settings import get_settings

class DemandPredictionService:
    """Servicio de predicción de demanda usando Random Forest"""
    
    def __init__(self):
        self.settings = get_settings()
        self.model = None
        self.feature_columns = []
        self.metadata = {}
        self.load_or_create_model()
    
    def load_or_create_model(self):
        """Carga modelo existente o crea uno nuevo"""
        model_path = os.path.join(self.settings.model_path, "demand_model.pkl")
        metadata_path = os.path.join(self.settings.model_path, "model_metadata.json")
        
        if os.path.exists(model_path):
            try:
                with open(model_path, 'rb') as f:
                    self.model = pickle.load(f)
                
                if os.path.exists(metadata_path):
                    with open(metadata_path, 'r') as f:
                        self.metadata = json.load(f)
                
                print("✅ Modelo de demanda cargado correctamente")
            except Exception as e:
                print(f"⚠️ Error al cargar modelo: {e}")
                self.model = None
        else:
            print("⚠️ Modelo no encontrado. Usar endpoint /train para entrenar")
    
    def prepare_features(self, orders_data: List[Dict]) -> pd.DataFrame:
        """Prepara features para el modelo desde datos de órdenes"""
        
        if not orders_data:
            return pd.DataFrame()
        
        # Expandir order_items
        records = []
        for order in orders_data:
            created_at = pd.to_datetime(order.get('created_at'))
            order_items = order.get('order_items', [])
            
            for item in order_items:
                if isinstance(item, dict):
                    records.append({
                        'created_at': created_at,
                        'menu_item_id': item.get('menu_item_id'),
                        'quantity': item.get('quantity', 1)
                    })
        
        if not records:
            return pd.DataFrame()
        
        df = pd.DataFrame(records)
        
        # Features temporales
        df['day_of_week'] = df['created_at'].dt.dayofweek
        df['day_of_month'] = df['created_at'].dt.day
        df['month'] = df['created_at'].dt.month
        df['is_weekend'] = df['day_of_week'].isin([5, 6]).astype(int)
        df['hour'] = df['created_at'].dt.hour
        df['week_of_year'] = df['created_at'].dt.isocalendar().week
        
        # Agregar por item y fecha
        daily_demand = df.groupby([
            df['created_at'].dt.date, 
            'menu_item_id'
        ]).agg({
            'quantity': 'sum',
            'day_of_week': 'first',
            'day_of_month': 'first',
            'month': 'first',
            'is_weekend': 'first',
            'week_of_year': 'first'
        }).reset_index()
        
        daily_demand.columns = ['date', 'item_id', 'demand', 'day_of_week', 
                                'day_of_month', 'month', 'is_weekend', 'week_of_year']
        
        return daily_demand
    
    def train_model(self, days_of_history: int = 90) -> Dict:
        """Entrena el modelo con datos históricos"""
        print(f"🔄 Iniciando entrenamiento con {days_of_history} días de historia...")
        
        # Obtener datos
        orders = get_historical_orders(days=days_of_history)
        
        if not orders:
            raise ValueError("No hay datos históricos suficientes para entrenar")
        
        print(f"📊 Obtenidos {len(orders)} pedidos históricos")
        
        # Preparar features
        df = self.prepare_features(orders)
        
        if df.empty or len(df) < 10:
            raise ValueError(f"No se pudieron generar features suficientes (solo {len(df)} muestras)")
        
        print(f"✅ Generadas {len(df)} muestras de entrenamiento")
        
        # Separar features y target
        feature_cols = ['day_of_week', 'day_of_month', 'month', 'is_weekend', 'week_of_year']
        self.feature_columns = feature_cols
        
        X = df[feature_cols]
        y = df['demand']
        
        # Split train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        print(f"📈 Entrenando modelo (train: {len(X_train)}, test: {len(X_test)})...")
        
        # Entrenar modelo
        self.model = RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            n_jobs=-1
        )
        
        self.model.fit(X_train, y_train)
        
        # Evaluar
        y_pred = self.model.predict(X_test)
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        
        # Guardar modelo
        os.makedirs(self.settings.model_path, exist_ok=True)
        model_path = os.path.join(self.settings.model_path, "demand_model.pkl")
        
        with open(model_path, 'wb') as f:
            pickle.dump(self.model, f)
        
        # Guardar metadata
        self.metadata = {
            "trained_at": datetime.now().isoformat(),
            "samples": len(df),
            "mae": float(mae),
            "r2": float(r2),
            "days_of_history": days_of_history,
            "feature_columns": feature_cols
        }
        
        metadata_path = os.path.join(self.settings.model_path, "model_metadata.json")
        with open(metadata_path, 'w') as f:
            json.dump(self.metadata, f, indent=2)
        
        print(f"✅ Modelo entrenado y guardado exitosamente")
        print(f"   📊 MAE: {mae:.2f}")
        print(f"   📊 R²: {r2:.4f}")
        print(f"   💾 Guardado en: {model_path}")
        
        return {
            "status": "success",
            "samples": len(df),
            "mae": float(mae),
            "r2": float(r2),
            "trained_at": self.metadata["trained_at"]
        }
    
    def predict(self, item_id: str, date_str: str) -> Dict:
        """Predice demanda para un item en una fecha específica"""
        
        if self.model is None:
            # Retornar predicción por defecto si no hay modelo
            return {
                "predicted_demand": 15,
                "confidence": 0.5,
                "level": "medium",
                "factors": {"note": "Modelo no entrenado, usando valores por defecto"}
            }
        
        # Parsear fecha
        try:
            target_date = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
        except:
            target_date = datetime.now()
        
        # Crear features
        features = pd.DataFrame([{
            'day_of_week': target_date.weekday(),
            'day_of_month': target_date.day,
            'month': target_date.month,
            'is_weekend': 1 if target_date.weekday() in [5, 6] else 0,
            'week_of_year': target_date.isocalendar()[1]
        }])
        
        # Predecir
        predicted_demand = max(0, int(self.model.predict(features)[0]))
        
        # Calcular confianza basada en varianza de los árboles
        predictions = [estimator.predict(features)[0] 
                      for estimator in self.model.estimators_[:10]]  # Usar solo 10 para velocidad
        std = np.std(predictions)
        confidence = max(0.5, min(0.95, 1 - (std / max(predicted_demand, 1))))
        
        # Determinar nivel
        if predicted_demand >= 50:
            level = "high"
        elif predicted_demand >= 20:
            level = "medium"
        else:
            level = "low"
        
        # Factores que influyen
        factors = {
            "is_weekend": features['is_weekend'].iloc[0] == 1,
            "day_of_week": target_date.strftime('%A'),
            "month": target_date.strftime('%B')
        }
        
        # Recomendaciones
        recommendations = []
        if level == "high":
            recommendations.append(f"Alta demanda esperada. Asegurar stock suficiente de ingredientes.")
        elif level == "low":
            recommendations.append(f"Demanda baja proyectada. Considerar promociones especiales.")
        
        if features['is_weekend'].iloc[0]:
            recommendations.append("Fin de semana: considerar personal adicional.")
        
        return {
            "predicted_demand": predicted_demand,
            "confidence": float(confidence),
            "level": level,
            "factors": factors,
            "recommendations": recommendations
        }
    
    def batch_predict(self, items: List[Dict], date_str: str) -> List[Dict]:
        """Predice demanda para múltiples items"""
        predictions = []
        
        for item in items:
            try:
                pred = self.predict(item['item_id'], date_str)
                predictions.append({
                    "item_id": item['item_id'],
                    "item_name": item.get('item_name', 'Unknown'),
                    "prediction_date": date_str,
                    **pred
                })
            except Exception as e:
                print(f"⚠️ Error predicting {item.get('item_id')}: {e}")
                # Agregar predicción por defecto
                predictions.append({
                    "item_id": item['item_id'],
                    "item_name": item.get('item_name', 'Unknown'),
                    "prediction_date": date_str,
                    "predicted_demand": 10,
                    "confidence": 0.5,
                    "level": "medium",
                    "factors": {"error": str(e)}
                })
        
        return predictions
    
    def get_model_info(self) -> Dict:
        """Retorna información sobre el modelo actual"""
        return {
            "model_loaded": self.model is not None,
            "metadata": self.metadata if self.metadata else None,
            "feature_columns": self.feature_columns
        }
