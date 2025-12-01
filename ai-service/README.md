# 🤖 SmartDinner AI Service

Servicio de Inteligencia Artificial para predicción de demanda y análisis de datos del sistema SmartDinner.

## 📋 Descripción

Este módulo proporciona predicciones de demanda de platillos usando **Machine Learning** (RandomForest) basándose en datos históricos de órdenes. El servicio expone una API REST construida con **FastAPI**.

## 🚀 Características

- ✅ **Predicción de demanda** individual y por lotes
- 📊 **Entrenamiento de modelos** con datos históricos
- 🔄 **Integración con Supabase** para obtener datos
- 🎯 **Métricas de precisión** (MAE, R²)
- 🔧 **API RESTful** completa con FastAPI
- 📦 **Persistencia de modelos** entrenados

## 📦 Instalación

### 1. Requisitos previos

- Python 3.9 o superior
- Acceso a la base de datos Supabase de SmartDinner

### 2. Instalar dependencias

```bash
cd ai-service
pip install -r requirements.txt
```

### 3. Configuración

Copia el archivo de ejemplo y configura tus variables:

```bash
cp env.example .env
```

Edita `.env` con tus credenciales:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_SERVICE_KEY=tu_service_role_key
MODEL_PATH=./models/demand_prediction_model.pkl
```

## 🎯 Uso

### Entrenar el modelo

**Primera vez (entrenar modelo):**

```bash
python scripts/train.py --days 90
```

Opciones:
- `--days N`: Usar N días de historia (30-365)
- `--force`: Forzar re-entrenamiento
- `--info`: Ver información del modelo actual

### Iniciar el servicio

```bash
# Desarrollo
cd src
uvicorn main:app --reload --port 8000

# Producción
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

## 📡 Endpoints de la API

### 🏠 Información del servicio

```http
GET /
```

Retorna información general y estado del modelo.

### 💊 Health check

```http
GET /health
```

Verifica que el servicio esté funcionando.

### 🔮 Predicción individual

```http
POST /predict
Content-Type: application/json

{
  "item_id": "123e4567-e89b-12d3-a456-426614174000",
  "item_name": "Pizza Margherita",
  "date": "2024-01-15T12:00:00"
}
```

**Respuesta:**
```json
{
  "item_id": "123e4567-e89b-12d3-a456-426614174000",
  "item_name": "Pizza Margherita",
  "prediction_date": "2024-01-15T12:00:00",
  "predicted_demand": 45,
  "confidence": 0.87,
  "level": "medium"
}
```

### 📦 Predicción por lotes

```http
POST /batch-predict
Content-Type: application/json

{
  "items": [
    {"item_id": "uuid1", "item_name": "Pizza"},
    {"item_id": "uuid2", "item_name": "Pasta"}
  ],
  "date": "2024-01-15T12:00:00"
}
```

### 🧠 Entrenar modelo

```http
POST /train
Content-Type: application/json

{
  "days_of_history": 90,
  "force_retrain": false
}
```

Entrena el modelo en segundo plano.

### 📊 Estado del modelo

```http
GET /models/status
```

Retorna el estado actual del modelo (cargado, última fecha de entrenamiento, métricas).

### 📋 Información detallada del modelo

```http
GET /models/info
```

Retorna información completa: metadata, features, precisión.

## 🏗️ Estructura del proyecto

```
ai-service/
├── src/
│   ├── main.py                 # Aplicación FastAPI
│   ├── config/
│   │   ├── settings.py         # Configuración con Pydantic
│   │   └── database.py         # Cliente Supabase
│   ├── models/
│   │   └── schemas.py          # Modelos Pydantic para API
│   └── services/
│       └── prediction_service.py  # Lógica de ML
├── scripts/
│   └── train.py                # Script de entrenamiento CLI
├── models/                     # Modelos entrenados (.pkl)
├── requirements.txt
└── README.md
```

## 🧪 Testing

El proyecto incluye una suite completa de tests:

```bash
# Ejecutar todos los tests
pytest

# Tests específicos
pytest tests/test_api.py          # Tests de API
pytest tests/test_predictions.py  # Tests de ML
pytest tests/test_validators.py   # Tests de validación

# Con cobertura
pytest --cov=src tests/ --cov-report=html

# Ver reporte de cobertura
# Abrir: htmlcov/index.html

# Tests con marcadores
pytest -m unit           # Solo tests unitarios
pytest -m integration    # Solo tests de integración
pytest -m "not slow"     # Excluir tests lentos
```

### Estructura de tests:
- `test_api.py` - Tests de endpoints FastAPI
- `test_predictions.py` - Tests de lógica ML
- `test_validators.py` - Tests de validación de datos
- `conftest.py` - Fixtures compartidos

## 🔧 Modelo de Machine Learning

### Algoritmo

**RandomForestRegressor** de scikit-learn con:
- 100 árboles de decisión
- Profundidad máxima: 10
- Random state: 42 (reproducibilidad)

### Features utilizadas

- `day_of_week` (0-6: Lunes a Domingo)
- `day_of_month` (1-31)
- `month` (1-12)
- `is_weekend` (0 o 1)
- `week_of_year` (1-52)

### Métricas

- **MAE** (Mean Absolute Error): Error promedio en unidades
- **R²** (Coeficiente de determinación): Calidad del ajuste (0-1)

**Interpretación de R²:**
- ≥ 0.7: Excelente
- 0.5-0.7: Bueno
- 0.3-0.5: Moderado
- < 0.3: Necesita mejoras

## 🐳 Docker

```bash
# Construir imagen
docker build -t smartdinner-ai .

# Ejecutar contenedor
docker run -p 8000:8000 --env-file .env smartdinner-ai
```

## 📝 Notas importantes

1. **Primer uso**: Debes entrenar el modelo antes de hacer predicciones
2. **Datos mínimos**: Se requieren al menos 30 días de datos históricos
3. **Re-entrenamiento**: Recomienda re-entrenar mensualmente para mantener precisión
4. **Background training**: El entrenamiento se ejecuta en segundo plano para no bloquear el API

## 🤝 Integración con Backend

El backend Node.js debe llamar a estos endpoints:

```javascript
// Predicción diaria automática
const response = await fetch('http://localhost:8000/batch-predict', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    items: menuItems.map(item => ({
      item_id: item.id,
      item_name: item.name
    })),
    date: new Date().toISOString()
  })
});
```

## 📚 Tecnologías

- **FastAPI**: Framework web moderno y rápido
- **scikit-learn**: Biblioteca de Machine Learning
- **Pydantic**: Validación de datos
- **Supabase**: Cliente para PostgreSQL
- **pandas/numpy**: Procesamiento de datos
- **uvicorn**: Servidor ASGI

## 🐛 Troubleshooting

### Error: "Model not trained"
- Ejecuta `python scripts/train.py` primero

### Error: "Insufficient data"
- Verifica que haya suficientes órdenes históricas en Supabase
- Usa menos días de historia (--days 30)

### Error de conexión a Supabase
- Verifica SUPABASE_URL y SUPABASE_SERVICE_KEY en .env
- Confirma acceso de red a Supabase

## 📄 Licencia

MIT License - Ver LICENSE en el directorio raíz del proyecto.

## 👥 Autor

Desarrollado para SmartDinner - Sistema de gestión de restaurantes
