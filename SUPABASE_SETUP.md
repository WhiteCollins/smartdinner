# Guía de Configuración de Supabase para SmartDinner

## Pasos para conectar tu base de datos Supabase:

### 1. Crear cuenta en Supabase
- Ve a https://app.supabase.com
- Crea una cuenta o inicia sesión
- Crea un nuevo proyecto

### 2. Ejecutar el Script SQL
- Ve a la sección "SQL Editor" en tu proyecto Supabase
- Copia todo el contenido del archivo `database/supabase_schema.sql` (que ya creé previamente)
- Pégalo en el editor SQL de Supabase
- Haz click en "Run" para crear todas las tablas, triggers y políticas RLS

### 3. Obtener las credenciales
- Ve a "Project Settings" > "API"
- Copia los siguientes valores:
  - **Project URL**: Tu URL del proyecto (ej: https://xyzcompany.supabase.co)
  - **anon public key**: La llave pública (anon key)

### 4. Configurar el proyecto Flutter
- Copia el archivo `.env.example` como `.env`:
  ```powershell
  Copy-Item .env.example .env
  ```
- Abre el archivo `.env` y reemplaza los valores:
  ```
  SUPABASE_URL=https://tu-proyecto.supabase.co
  SUPABASE_ANON_KEY=tu-anon-key-aqui
  ```

### 5. Actualizar el código (TEMPORAL)
Dado que Flutter no lee archivos .env directamente sin un paquete adicional, 
por ahora debes actualizar manualmente el archivo `lib/config/supabase_config.dart`:

Reemplaza estas líneas:
```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

Con tus valores reales de Supabase.

### 6. Verificar la instalación
Las dependencias ya están instaladas. Puedes verificar ejecutando:
```powershell
flutter pub get
```

### 7. Ejecutar el proyecto
```powershell
flutter run
```

## Crear usuarios de prueba

Ahora el login usa Supabase real, así que necesitas crear usuarios:

### Opción 1: Registrarse desde la app
- Ejecuta la app
- Ve a "Crear cuenta"
- Llena el formulario
- El usuario se creará en Supabase

### Opción 2: Crear desde el panel de Supabase
- Ve a "Authentication" > "Users" en Supabase
- Click en "Add user"
- Crea un usuario de prueba

### Opción 3: Insertar directamente en la base de datos
Ejecuta este SQL en Supabase para crear un usuario administrador:

```sql
-- Primero crea el usuario de autenticación en Authentication
-- Desde el panel: Authentication > Users > Add user
-- Email: admin@smartdinner.com
-- Password: 123456

-- Luego obtén el UUID del usuario creado y ejecuta:
INSERT INTO users (id, email, name, role, phone)
VALUES (
  'uuid-del-usuario-creado',
  'admin@smartdinner.com',
  'Administrador',
  'admin',
  '1234567890'
);
```

## Arquitectura de la Integración

### Archivos creados/modificados:

1. **pubspec.yaml** - Dependencias añadidas:
   - supabase_flutter
   - provider
   - http
   - shared_preferences
   - flutter_secure_storage
   - cached_network_image
   - intl
   - uuid

2. **lib/config/supabase_config.dart** - Configuración centralizada de Supabase

3. **lib/core/services/supabase_service.dart** - Servicio completo con:
   - Autenticación (login, register, logout)
   - Gestión de usuarios
   - Reservaciones
   - Menú
   - Órdenes
   - Predicciones
   - Reseñas
   - Notificaciones
   - Suscripciones en tiempo real

4. **lib/main.dart** - Inicialización de Supabase al arrancar la app

5. **lib/features/auth/screens/login_screen.dart** - Login con Supabase

6. **lib/features/auth/screens/register_screen.dart** - Registro con Supabase

## Próximos pasos para completar la integración:

### Pantallas pendientes de actualizar:
- [ ] Reservaciones (usar `getUserReservations()`, `createReservation()`)
- [ ] Menú (usar `getMenuItems()`)
- [ ] Órdenes (usar `createOrder()`, `getUserOrders()`)
- [ ] Perfil de usuario (usar `getUserProfile()`, `updateUserProfile()`)
- [ ] Notificaciones (usar `getUserNotifications()`)

### Funcionalidades avanzadas:
- [ ] Implementar suscripciones en tiempo real para órdenes
- [ ] Implementar suscripciones en tiempo real para notificaciones
- [ ] Agregar manejo de imágenes con Supabase Storage
- [ ] Implementar paginación en listados largos

## Solución de problemas

### Error de conexión
- Verifica que la URL de Supabase sea correcta
- Verifica que el anon key sea correcto
- Verifica tu conexión a internet

### Error de autenticación
- Verifica que las políticas RLS estén activas
- Verifica que el usuario exista en Supabase

### Error en queries
- Revisa los logs de Supabase en el panel
- Verifica que las tablas existan
- Verifica los permisos RLS

## Recursos adicionales
- [Documentación de Supabase](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Guía de Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
