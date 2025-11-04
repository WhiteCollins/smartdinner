# 🚀 SmartDinner Backend API - Documentación Completa

## ✅ Backend Completo con Supabase + Node.js

El backend de SmartDinner está completamente implementado con **CRUDs completos**, **integración real con Supabase** y **gestión de inventario**.

---

## 📦 Instalación

### 1. Instalar dependencias

```powershell
cd backend
npm install
```

### 2. Configurar variables de entorno

Copia el archivo `.env.example` a `.env`:

```powershell
Copy-Item .env.example .env
```

Edita el archivo `.env` con tus credenciales de Supabase:

```env
NODE_ENV=development
PORT=3000

# Supabase Configuration
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
SUPABASE_SERVICE_KEY=tu-service-role-key-aqui

CORS_ORIGIN=http://localhost:8080
```

> **Nota**: El `SUPABASE_SERVICE_KEY` (service_role key) lo encuentras en Supabase > Settings > API > service_role key (secret)

### 3. Crear tablas de inventario en Supabase

Ejecuta el script SQL ubicado en `database/inventory_schema.sql` en el SQL Editor de Supabase.

### 4. Iniciar el servidor

```powershell
# Modo desarrollo (con auto-reload)
npm run dev

# Modo producción
npm start
```

El servidor estará disponible en: `http://localhost:3000`

---

## 📋 API Endpoints Disponibles

### 🏠 Base

- `GET /` - Información de la API
- `GET /health` - Health check del servidor

### 👤 Usuarios (Users)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/users` | Obtener todos los usuarios |
| `GET` | `/api/users/:id` | Obtener usuario por ID |
| `GET` | `/api/users/:id/profile` | Obtener perfil completo |
| `GET` | `/api/users/email/:email` | Obtener usuario por email |
| `PUT` | `/api/users/:id` | Actualizar usuario |
| `DELETE` | `/api/users/:id` | Eliminar usuario |

**Ejemplo de uso:**
```bash
GET http://localhost:3000/api/users
GET http://localhost:3000/api/users/:userId/profile
PUT http://localhost:3000/api/users/:userId
```

---

### 🍽️ Menú (Menu Items)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/menu` | Obtener todos los items |
| `GET` | `/api/menu/:id` | Obtener item por ID |
| `GET` | `/api/menu/category/:category` | Obtener items por categoría |
| `GET` | `/api/menu/search/:term` | Buscar items |
| `GET` | `/api/menu/categories` | Obtener todas las categorías |
| `GET` | `/api/menu/popular` | Obtener items populares |
| `POST` | `/api/menu` | Crear nuevo item |
| `PUT` | `/api/menu/:id` | Actualizar item |
| `PATCH` | `/api/menu/:id/availability` | Actualizar disponibilidad |
| `PATCH` | `/api/menu/:id/price` | Actualizar precio |
| `DELETE` | `/api/menu/:id` | Eliminar item |

**Ejemplo de creación:**
```json
POST http://localhost:3000/api/menu
{
  "name": "Pizza Margherita",
  "description": "Pizza clásica italiana",
  "category": "Pizzas",
  "price": 12.99,
  "available": true,
  "preparation_time": 20
}
```

---

### 📅 Reservaciones (Reservations)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/reservations` | Obtener todas las reservaciones |
| `GET` | `/api/reservations/:id` | Obtener reservación por ID |
| `GET` | `/api/reservations/user/:userId` | Obtener reservaciones de usuario |
| `GET` | `/api/reservations/date/:date` | Obtener reservaciones por fecha |
| `GET` | `/api/reservations/status/:status` | Obtener reservaciones por estado |
| `GET` | `/api/reservations/stats?startDate=&endDate=` | Estadísticas |
| `POST` | `/api/reservations` | Crear reservación |
| `PUT` | `/api/reservations/:id` | Actualizar reservación |
| `PATCH` | `/api/reservations/:id/status` | Actualizar estado |
| `POST` | `/api/reservations/:id/confirm` | Confirmar reservación |
| `POST` | `/api/reservations/:id/cancel` | Cancelar reservación |
| `DELETE` | `/api/reservations/:id` | Eliminar reservación |

**Ejemplo de creación:**
```json
POST http://localhost:3000/api/reservations
{
  "user_id": "uuid-del-usuario",
  "date": "2025-11-15",
  "time": "19:30",
  "guests": 4,
  "special_requests": "Mesa cerca de la ventana"
}
```

**Estados válidos:** `pending`, `confirmed`, `cancelled`, `completed`, `no-show`

---

### 🛒 Órdenes (Orders)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/orders` | Obtener todas las órdenes |
| `GET` | `/api/orders/:id` | Obtener orden por ID con items |
| `GET` | `/api/orders/user/:userId` | Obtener órdenes de usuario |
| `GET` | `/api/orders/status/:status` | Obtener órdenes por estado |
| `GET` | `/api/orders/active` | Obtener órdenes activas |
| `GET` | `/api/orders/stats?startDate=&endDate=` | Estadísticas |
| `GET` | `/api/orders/top-selling?limit=10` | Items más vendidos |
| `POST` | `/api/orders` | Crear orden |
| `PUT` | `/api/orders/:id` | Actualizar orden |
| `PATCH` | `/api/orders/:id/status` | Actualizar estado |
| `POST` | `/api/orders/:id/cancel` | Cancelar orden |
| `DELETE` | `/api/orders/:id` | Eliminar orden |

**Ejemplo de creación:**
```json
POST http://localhost:3000/api/orders
{
  "user_id": "uuid-del-usuario",
  "items": [
    {
      "menu_item_id": "uuid-del-item-1",
      "quantity": 2,
      "price": 12.99
    },
    {
      "menu_item_id": "uuid-del-item-2",
      "quantity": 1,
      "price": 8.50
    }
  ],
  "notes": "Sin cebolla",
  "delivery_address": "Calle 123, Ciudad"
}
```

**Estados válidos:** `pending`, `confirmed`, `preparing`, `ready`, `delivered`, `cancelled`

---

### 📦 Inventario (Inventory) - ¡NUEVO!

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/inventory` | Obtener todo el inventario |
| `GET` | `/api/inventory/:id` | Obtener item por ID |
| `GET` | `/api/inventory/low-stock?threshold=10` | Items con stock bajo |
| `GET` | `/api/inventory/out-of-stock` | Items fuera de stock |
| `GET` | `/api/inventory/purchase-order?threshold=10` | Generar orden de compra |
| `GET` | `/api/inventory/stats` | Estadísticas de inventario |
| `GET` | `/api/inventory/:id/history?limit=50` | Historial de movimientos |
| `POST` | `/api/inventory` | Crear item de inventario |
| `POST` | `/api/inventory/movement` | Registrar movimiento |
| `PUT` | `/api/inventory/:id` | Actualizar item |
| `PATCH` | `/api/inventory/:id/quantity` | Actualizar cantidad |
| `DELETE` | `/api/inventory/:id` | Eliminar item |

**Ejemplo de creación de item:**
```json
POST http://localhost:3000/api/inventory
{
  "name": "Tomates",
  "quantity": 50,
  "unit": "kg",
  "min_quantity": 20,
  "cost_per_unit": 2.50,
  "menu_item_id": "uuid-opcional"
}
```

**Ejemplo de registro de movimiento:**
```json
POST http://localhost:3000/api/inventory/movement
{
  "item_id": "uuid-del-item",
  "quantity": 10,
  "type": "in",
  "reason": "Compra semanal",
  "user_id": "uuid-del-usuario"
}
```

**Tipos de movimiento:** `in` (entrada), `out` (salida), `adjustment` (ajuste)

**Actualizar cantidad:**
```json
PATCH http://localhost:3000/api/inventory/:id/quantity
{
  "quantity": 10,
  "type": "add"  // o "subtract" o "set"
}
```

---

## 🏗️ Arquitectura del Backend

### Estructura de Carpetas

```
backend/
├── src/
│   ├── config/
│   │   └── supabase.js          # Configuración de Supabase
│   ├── services/
│   │   ├── baseService.js       # Servicio base con CRUDs genéricos
│   │   ├── userService.js       # Lógica de usuarios
│   │   ├── menuService.js       # Lógica de menú
│   │   ├── reservationService.js # Lógica de reservaciones
│   │   ├── orderService.js      # Lógica de órdenes
│   │   └── inventoryService.js  # Lógica de inventario ✨
│   ├── controllers/
│   │   ├── userController.js
│   │   ├── menuController.js
│   │   ├── reservationController.js
│   │   ├── orderController.js
│   │   └── inventoryController.js ✨
│   ├── routes/
│   │   ├── userRoutes.js
│   │   ├── menuRoutes.js
│   │   ├── reservationRoutes.js
│   │   ├── orderRoutes.js
│   │   └── inventoryRoutes.js   ✨
│   ├── app.js                   # Configuración de Express
│   └── server.js                # Punto de entrada
├── .env                         # Variables de entorno
├── .env.example                 # Plantilla de variables
└── package.json                 # Dependencias
```

### Patrón de Diseño

**Capa de Servicio (Service Layer)**
- `baseService.js`: Operaciones CRUD genéricas reutilizables
- Servicios específicos: Lógica de negocio especializada

**Capa de Controlador (Controller Layer)**
- Maneja peticiones HTTP
- Valida datos de entrada
- Llama a servicios
- Retorna respuestas JSON

**Capa de Rutas (Routes Layer)**
- Define endpoints REST
- Mapea URLs a controladores

---

## ✅ CRUDs Implementados

### ✅ CREATE (Crear)
- ✅ Usuarios (con Supabase Auth)
- ✅ Items del menú
- ✅ Reservaciones
- ✅ Órdenes con items
- ✅ Items de inventario
- ✅ Movimientos de inventario

### ✅ READ (Leer)
- ✅ Todos los registros con filtros
- ✅ Registros por ID
- ✅ Búsquedas específicas (por fecha, estado, categoría, etc.)
- ✅ Estadísticas y reportes
- ✅ Joins con tablas relacionadas

### ✅ UPDATE (Actualizar)
- ✅ Actualización completa de registros
- ✅ Actualización parcial (PATCH)
- ✅ Actualización de estados
- ✅ Actualización de disponibilidad
- ✅ Actualización de precios/cantidades

### ✅ DELETE (Eliminar)
- ✅ Soft delete (marcado como eliminado)
- ✅ Hard delete (eliminación física)
- ✅ Eliminación con validaciones

---

## 🔗 Integración con Supabase

### Conexión Real con PostgreSQL
- ✅ Cliente de Supabase configurado
- ✅ Service Role Key para operaciones de backend
- ✅ Consultas directas a la base de datos
- ✅ Transacciones y rollbacks
- ✅ Row Level Security (RLS) respetado

### Características Implementadas
- ✅ Operaciones CRUD en tiempo real
- ✅ Filtros y búsquedas avanzadas
- ✅ Joins entre tablas
- ✅ Agregaciones y estadísticas
- ✅ Paginación
- ✅ Ordenamiento
- ✅ Conteo de registros

---

## 🧪 Probar la API

### Con Postman o Thunder Client

1. **Health Check**
```
GET http://localhost:3000/health
```

2. **Obtener menú**
```
GET http://localhost:3000/api/menu
```

3. **Crear reservación**
```
POST http://localhost:3000/api/reservations
Content-Type: application/json

{
  "user_id": "tu-user-id",
  "date": "2025-11-15",
  "time": "19:30",
  "guests": 4
}
```

4. **Ver inventario con stock bajo**
```
GET http://localhost:3000/api/inventory/low-stock?threshold=15
```

### Con cURL (PowerShell)

```powershell
# Health check
curl http://localhost:3000/health

# Obtener menú
curl http://localhost:3000/api/menu

# Crear item de menú
curl -X POST http://localhost:3000/api/menu `
  -H "Content-Type: application/json" `
  -d '{"name":"Pizza","category":"Comida","price":15.99,"available":true}'
```

---

## 📊 Gestión de Inventario

### Funcionalidades del Sistema de Inventario

1. **Control de Stock**
   - Registro de cantidades actuales
   - Alertas de stock bajo
   - Identificación de items fuera de stock

2. **Movimientos**
   - Entradas (compras)
   - Salidas (uso en cocina)
   - Ajustes (correcciones)
   - Historial completo

3. **Reportes**
   - Valor total del inventario
   - Items más utilizados
   - Orden de compra automática
   - Estadísticas por categoría

4. **Integración**
   - Vinculación con items del menú
   - Cálculo de costos
   - Alertas automáticas

---

## 🔒 Seguridad

### Row Level Security (RLS)
- Políticas configuradas en Supabase
- Usuarios solo acceden a sus datos
- Admins tienen permisos completos

### Variables de Entorno
- Credenciales nunca en el código
- `.env` en `.gitignore`
- Service Role Key solo en backend

### Validaciones
- Validación de datos en servicios
- Sanitización de entradas
- Manejo de errores completo

---

## 🚀 Siguiente Paso

### Ejecutar el Backend

```powershell
cd backend
npm install
# Configurar .env con tus credenciales
npm run dev
```

### Conectar desde Flutter

Actualiza la URL del backend en tu app Flutter:

```dart
// En tu servicio HTTP de Flutter
final baseUrl = 'http://localhost:3000/api';
```

---

## 📝 Resumen

✅ **Backend 100% funcional**
✅ **CRUDs completos** para todas las entidades
✅ **Integración real con Supabase PostgreSQL**
✅ **Sistema de inventario completo**
✅ **APIs REST bien estructuradas**
✅ **Documentación completa**

¡El backend está listo para usar! 🎉
