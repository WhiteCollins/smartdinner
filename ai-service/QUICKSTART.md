# 🚀 Guía de Inicio Rápido - SmartDinner AI Service

Esta guía te llevará de 0 a 100 en menos de 10 minutos.

---

## ⚡ Inicio Rápido (5 minutos)

### 1️⃣ Instalar Dependencias

```powershell
cd ai-service
pip install -r requirements.txt
```

### 2️⃣ Configurar Variables de Entorno

```powershell
# Copiar template
cp env.example .env

# Editar .env con tus credenciales
notepad .env
```

**Variables mínimas requeridas:**
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_SERVICE_KEY=tu_service_role_key
```

### 3️⃣ Validar Instalación

```powershell
python scripts/validate_setup.py
```

Este script verifica:
- ✅ Dependencias instaladas
- ✅ Configuración válida
- ✅ Conexión a Supabase
- ✅ Estructura de directorios

### 4️⃣ Entrenar Modelo

```powershell
python scripts/train.py --days 90
```

Esto puede tomar 1-3 minutos dependiendo de los datos.

### 5️⃣ Iniciar Servicio

```powershell
python scripts/run.py
```

¡Listo! El servicio estará corriendo en `http://localhost:8000`

---

## 📖 Documentación Interactiva

Una vez iniciado el servicio, visita:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

---

## 🧪 Probar Endpoints

### Con curl:

```powershell
# Health check
curl http://localhost:8000/health

# Predicción individual
curl -X POST "http://localhost:8000/predict" `
  -H "Content-Type: application/json" `
  -d '{
    "item_id": "tu-item-id",
    "item_name": "Pizza Margherita",
    "date": "2024-12-01T12:00:00"
  }'
```

### Con Python:

```python
import requests

# Predicción
response = requests.post('http://localhost:8000/predict', json={
    'item_id': 'item-123',
    'item_name': 'Pizza Margherita',
    'date': '2024-12-01T12:00:00'
})

print(response.json())
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Model not trained"

```powershell
python scripts/train.py --days 90
```

### Error: "Supabase connection failed"

1. Verifica que `.env` tenga las credenciales correctas
2. Verifica conectividad: `curl https://tu-proyecto.supabase.co`
3. Verifica que el service key sea válido

### Error: "Insufficient data"

Necesitas al menos 30 días de órdenes históricas. Opciones:

1. Usar menos días: `--days 30`
2. Poblar datos de prueba en Supabase
3. Esperar a tener más datos reales

### Error: "Port already in use"

```powershell
# Cambiar puerto en .env
PORT=8001

# O matar proceso en puerto 8000
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

---

## 📊 Flujo de Trabajo Típico

### Desarrollo Diario:

```powershell
# 1. Activar entorno virtual (si usas uno)
.\venv\Scripts\Activate.ps1

# 2. Actualizar código (git pull, etc.)
git pull origin dev

# 3. Instalar nuevas dependencias (si hay)
pip install -r requirements.txt

# 4. Iniciar con hot reload
python scripts/run.py
```

### Re-entrenar Modelo (Semanal/Mensual):

```powershell
# Con más historia
python scripts/train.py --days 180 --force

# Ver información del modelo
python scripts/train.py --info
```

### Ejecutar Tests:

```powershell
# Todos los tests
pytest

# Solo tests de API
pytest tests/test_api.py -v

# Con cobertura
pytest --cov=src tests/
```

---

## 🐳 Docker (Opcional)

### Build:

```powershell
docker build -t smartdinner-ai:latest .
```

### Run:

```powershell
docker run -p 8000:8000 `
  --env-file .env `
  smartdinner-ai:latest
```

### Con docker-compose:

```yaml
# docker-compose.yml
version: '3.8'
services:
  ai-service:
    build: ./ai-service
    ports:
      - "8000:8000"
    env_file:
      - ./ai-service/.env
    volumes:
      - ./ai-service/models:/app/models
```

```powershell
docker-compose up -d
```

---

## 📚 Recursos Adicionales

- **README completo**: [README.md](README.md)
- **Documentación API**: http://localhost:8000/docs
- **Código fuente**: `src/`
- **Tests**: `tests/`
- **Notebooks**: `notebooks/exploratory_analysis.py`

---

## 🎯 Siguientes Pasos

1. ✅ Servicio funcionando
2. 🔗 Integrar con backend Node.js
3. 📊 Configurar monitoreo y logging
4. 🔄 Automatizar re-entrenamiento
5. 📈 Optimizar modelo según métricas

---

## 💡 Tips

- **Logging**: Los logs aparecen en la consola
- **Modelo**: Se guarda en `models/demand_prediction_model.pkl`
- **Hot Reload**: Cambios en código se aplican automáticamente en desarrollo
- **Datos**: El modelo necesita datos históricos reales para funcionar bien

---

## 🆘 Ayuda

Si encuentras problemas:

1. Ejecuta: `python scripts/validate_setup.py`
2. Revisa logs del servicio
3. Verifica que Supabase tenga datos
4. Consulta la documentación completa

---

¡Disfruta construyendo con SmartDinner AI! 🎉
