"""
Ejemplo de notebook Jupyter para análisis exploratorio.

Este notebook muestra cómo analizar los datos del servicio de IA.
"""

# %% [markdown]
# # SmartDinner AI Service - Análisis Exploratorio
# 
# Este notebook permite analizar datos históricos y validar predicciones.

# %% Imports
import sys
from pathlib import Path

# Agregar src al path
sys.path.insert(0, str(Path.cwd().parent / 'src'))

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta

from src.config.database import get_historical_orders, get_menu_items
from src.services.prediction_service import DemandPredictionService

# Configuración de visualización
sns.set_style('whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)

# %% [markdown]
# ## 1. Cargar Datos Históricos

# %% Cargar datos
print("📥 Cargando datos históricos...")

orders = get_historical_orders(days=90)
menu_items = get_menu_items()

df_orders = pd.DataFrame(orders)
df_menu = pd.DataFrame(menu_items)

print(f"✅ Órdenes cargadas: {len(df_orders)}")
print(f"✅ Items del menú: {len(df_menu)}")

# %% Vista previa
df_orders.head()

# %% [markdown]
# ## 2. Análisis Exploratorio

# %% Estadísticas básicas
print("📊 Estadísticas básicas:")
print(df_orders.describe())

# %% Distribución de cantidad
plt.figure()
df_orders['quantity'].hist(bins=30)
plt.title('Distribución de Cantidades Ordenadas')
plt.xlabel('Cantidad')
plt.ylabel('Frecuencia')
plt.show()

# %% Top items más vendidos
top_items = df_orders.groupby('item_id')['quantity'].sum().sort_values(ascending=False).head(10)
print("\n🏆 Top 10 items más vendidos:")
print(top_items)

# %% [markdown]
# ## 3. Análisis Temporal

# %% Convertir fechas
df_orders['created_at'] = pd.to_datetime(df_orders['created_at'])
df_orders['date'] = df_orders['created_at'].dt.date
df_orders['day_of_week'] = df_orders['created_at'].dt.dayofweek
df_orders['hour'] = df_orders['created_at'].dt.hour

# %% Demanda por día de la semana
demand_by_dow = df_orders.groupby('day_of_week')['quantity'].sum()
days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']

plt.figure()
demand_by_dow.plot(kind='bar')
plt.title('Demanda por Día de la Semana')
plt.xlabel('Día')
plt.ylabel('Cantidad Total')
plt.xticks(range(7), days, rotation=45)
plt.tight_layout()
plt.show()

# %% Demanda por hora del día
demand_by_hour = df_orders.groupby('hour')['quantity'].sum()

plt.figure()
demand_by_hour.plot(kind='line', marker='o')
plt.title('Demanda por Hora del Día')
plt.xlabel('Hora')
plt.ylabel('Cantidad Total')
plt.grid(True)
plt.show()

# %% [markdown]
# ## 4. Predicciones del Modelo

# %% Cargar modelo
service = DemandPredictionService()
model_info = service.get_model_info()

print("\n🤖 Información del modelo:")
print(f"Modelo cargado: {model_info['model_loaded']}")

if model_info['model_loaded']:
    metadata = model_info.get('metadata', {})
    print(f"Entrenado: {metadata.get('trained_at', 'N/A')}")
    print(f"MAE: {metadata.get('mae', 'N/A'):.2f}")
    print(f"R²: {metadata.get('r2', 'N/A'):.4f}")

# %% Hacer predicciones de ejemplo
if model_info['model_loaded'] and len(df_menu) > 0:
    print("\n🔮 Predicciones para mañana:")
    
    tomorrow = (datetime.now() + timedelta(days=1)).isoformat()
    
    for _, item in df_menu.head(5).iterrows():
        try:
            pred = service.predict(item['id'], tomorrow)
            print(f"  • {item['name']}: {pred['predicted_demand']} unidades (confianza: {pred['confidence']:.2%})")
        except Exception as e:
            print(f"  • {item['name']}: Error - {e}")

# %% [markdown]
# ## 5. Validación del Modelo

# %% Comparar predicciones vs reales (últimos 7 días)
if model_info['model_loaded']:
    print("\n📈 Validación con datos recientes...")
    
    # Tomar últimos 7 días
    recent_data = df_orders[df_orders['created_at'] >= datetime.now() - timedelta(days=7)]
    
    # Agrupar por item y fecha
    actual_demand = recent_data.groupby(['item_id', 'date'])['quantity'].sum().reset_index()
    
    # Hacer predicciones para esas fechas
    predictions = []
    for _, row in actual_demand.iterrows():
        try:
            pred = service.predict(row['item_id'], str(row['date']))
            predictions.append({
                'item_id': row['item_id'],
                'date': row['date'],
                'actual': row['quantity'],
                'predicted': pred['predicted_demand']
            })
        except:
            pass
    
    if predictions:
        df_val = pd.DataFrame(predictions)
        
        # Calcular error
        df_val['error'] = df_val['predicted'] - df_val['actual']
        df_val['abs_error'] = df_val['error'].abs()
        
        print(f"\nMAE en validación: {df_val['abs_error'].mean():.2f}")
        print(f"Error promedio: {df_val['error'].mean():.2f}")
        
        # Gráfico de predicho vs real
        plt.figure()
        plt.scatter(df_val['actual'], df_val['predicted'], alpha=0.6)
        plt.plot([0, df_val['actual'].max()], [0, df_val['actual'].max()], 'r--', label='Perfect Prediction')
        plt.xlabel('Demanda Real')
        plt.ylabel('Demanda Predicha')
        plt.title('Predicciones vs Demanda Real')
        plt.legend()
        plt.grid(True)
        plt.show()

# %% [markdown]
# ## 6. Conclusiones
# 
# - Analiza los patrones encontrados
# - Evalúa la precisión del modelo
# - Identifica oportunidades de mejora

print("\n✅ Análisis completado!")
