# SmartDinner - Sistema Inteligente para la Gestión de Restaurantes

## Descripción

SmartDinner es una solución tecnológica integral diseñada para revolucionar la gestión operativa de los restaurantes. Mediante una aplicación web y móvil, el sistema centraliza tres procesos críticos: reservas de mesas, pedidos digitales y predicción de demanda de insumos a través de Inteligencia Artificial.

## Equipo de Desarrollo

- **Eric A. Jiménez Collins** - 2023-0966
- **Alexander Matos De La Cruz** - 2023-0951  
- **Kelobel Tapia** - 2023-0596

**Materia:** Proyecto Final  



## Arquitectura del Sistema

### Tecnologías Utilizadas

- **Frontend:** Flutter (Web, iOS, Android)
- **Backend:** Node.js con Express
- **Base de Datos:** PostgreSQL
- **Inteligencia Artificial:** Python (scikit-learn, Pandas, TensorFlow)
- **Contenerización:** Docker
- **Control de Versiones:** Git/GitHub

### Estructura del Proyecto

```
smartdinner/
├── backend/           # API Node.js + Express
├── ai-service/        # Servicio de IA en Python
├── database/          # Scripts y migraciones de BD
├── docs/              # Documentación
├── scripts/           # Scripts de utilidad
└── .github/           # CI/CD workflows
```

## Funcionalidades

### Módulo de Clientes
- ✅ Creación de perfiles de usuario
- ✅ Sistema de reservas de mesas
- ✅ Menú digital interactivo
- ✅ Gestión de pedidos (mesa y delivery)

### Módulo de Administración
- ✅ Panel de control en tiempo real
- ✅ Dashboard con reportes y análisis de IA
- ✅ Gestión del menú
- ✅ Gestión de reservas y pedidos

### Módulo de Inteligencia Artificial
- ✅ Predicción de demanda de platillos
- ✅ Análisis de patrones de consumo
- ✅ Optimización de inventario

## Instalación y Configuración

### Prerequisitos
- Docker y Docker Compose
- Flutter SDK (para desarrollo móvil)
- Node.js 18+
- Python 3.9+

### Configuración Rápida con Docker

1. Clonar el repositorio:
```bash
git clone [repository-url]
cd smartdinner
```

2. Iniciar todos los servicios:
```bash
docker-compose up -d
```

3. Acceder a las aplicaciones:
- Backend API: http://localhost:3000
- AI Service: http://localhost:8000
- Base de Datos: localhost:5432
  
	Para el frontend Flutter, ejecútalo localmente durante el desarrollo:
	- flutter pub get
	- flutter run -d chrome (o el dispositivo que prefieras)

### Desarrollo Local

Ver los README específicos en cada directorio:
- Frontend (en la raíz del repositorio): usar los comandos de Flutter
- [Backend README](./backend/README.md)
- [AI Service README](./ai-service/README.md)

## Cronograma de Desarrollo (16 Semanas)

### Fase 1: Configuración e Infraestructura (Semanas 1-2)
- Configuración del entorno de desarrollo
- Estructura base del proyecto
- Configuración de CI/CD

### Fase 2: Backend y Base de Datos (Semanas 3-6)
- Desarrollo de la API REST
- Modelos de datos
- Autenticación y autorización
- Testing unitario

### Fase 3: Frontend (Semanas 7-10)
- Desarrollo de la aplicación Flutter
- Integración con el backend
- Diseño de interfaces
- Testing de UI

### Fase 4: Inteligencia Artificial (Semanas 11-13)
- Desarrollo del modelo predictivo
- Integración con el sistema principal
- Entrenamiento y optimización

### Fase 5: Testing y Deployment (Semanas 14-16)
- Testing integral del sistema
- Deployment en producción
- Documentación final
- Presentación del proyecto

## Métricas de Éxito (KPIs)

- ✅ Precisión del modelo de IA > 75%
- ✅ Tiempo de respuesta de API < 200ms
- ✅ Cobertura de tests > 80%
- ✅ Disponibilidad del sistema > 99%

## Contribuir

1. Fork del proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit de cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## Licencia

Este proyecto es desarrollado como parte del Proyecto Final de la materia.

## Contacto

Para más información sobre el proyecto, contactar a cualquier miembro del equipo de desarrollo.
