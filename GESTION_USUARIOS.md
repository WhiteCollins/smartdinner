# 🔐 Sistema de Gestión de Usuarios - SmartDinner

## 📋 Resumen de Cambios Implementados

Este documento describe las modificaciones realizadas al sistema de autenticación y gestión de usuarios de SmartDinner, eliminando el registro público y centralizando la creación de usuarios en el panel de administración.

---

## ✅ Cambios Implementados

### 1. **Eliminación del Registro Público**

#### Archivos Modificados:
- `lib/features/auth/screens/login_screen.dart`
  - ❌ Removido botón "Regístrate"
  - ✅ Agregado enlace "¿Olvidaste tu contraseña?"

- `lib/config/routes.dart`
  - ❌ Comentada ruta `/register`
  - ❌ Comentado import de `register_screen.dart`

#### Resultado:
- Los usuarios **NO pueden auto-registrarse**
- Solo el **login** está disponible públicamente

---

### 2. **Recuperación de Contraseña**

#### Archivos Creados:
- `lib/features/auth/screens/forgot_password_screen.dart`
  - Formulario para solicitar reset de contraseña
  - Envía email de recuperación vía Supabase
  - Interfaz responsive (web, tablet, móvil)

#### Archivos Modificados:
- `lib/core/services/supabase_service.dart`
  - Agregado método `resetPassword(String email)`

- `lib/config/routes.dart`
  - Agregada ruta `/forgot-password`

#### Funcionalidad:
1. Usuario hace click en "¿Olvidaste tu contraseña?"
2. Ingresa su email
3. Recibe enlace de reset por correo
4. Puede restablecer su contraseña

---

### 3. **Sistema de Roles de Usuario**

#### Archivo Creado:
- `lib/core/models/user_roles.dart`

#### Roles Disponibles:
```dart
enum UserRole {
  admin          // Administrador
  waiter         // Mesero
  cashier        // Cajero
  cook           // Cocinero
  deliveryPerson // Repartidor
  vipCustomer    // Cliente VIP
  customer       // Cliente
}
```

#### Estados de Usuario:
```dart
enum UserStatus {
  active      // Activo
  inactive    // Inactivo
  suspended   // Suspendido
}
```

#### Propiedades:
- `displayName`: Nombre legible del rol/estado
- `value`: Valor almacenado en base de datos
- `isAdmin`, `isStaff`, `isCustomer`: Helpers de verificación

---

### 4. **Administración de Usuarios (Panel Admin)**

#### Archivos Creados:

**Pantalla Principal:**
- `lib/features/admin/screens/user_management_screen.dart`
  - Lista de todos los usuarios
  - Filtros por rol y estado
  - Opciones de editar, cambiar estado, reset password, eliminar

**Diálogos:**
- `lib/features/admin/widgets/create_user_dialog.dart`
  - Formulario completo para crear usuarios
  - Campos: nombre, email, teléfono, rol, estado, contraseña

- `lib/features/admin/widgets/edit_user_dialog.dart`
  - Formulario para editar usuarios existentes
  - Permite cambiar: nombre, teléfono, rol, estado

#### Funcionalidades:

**Crear Usuario:**
- Nombre completo (requerido)
- Email (requerido, único)
- Teléfono (opcional)
- Rol (selección de dropdown)
- Estado (Activo/Inactivo/Suspendido)
- Contraseña inicial (requerido, mín 6 caracteres)

**Editar Usuario:**
- Cambiar nombre, teléfono
- Modificar rol
- Cambiar estado

**Acciones Adicionales:**
- Restablecer contraseña (admin asigna nueva)
- Activar/Desactivar usuario
- Eliminar usuario (soft delete)

---

### 5. **Actualización del SupabaseService**

#### Archivo Modificado:
- `lib/core/services/supabase_service.dart`

#### Nuevos Métodos:

```dart
// Obtener todos los usuarios
Future<List<Map<String, dynamic>>> getAllUsers()

// Crear usuario (solo admin)
Future<Map<String, dynamic>> createUserByAdmin({
  required String email,
  required String password,
  required String name,
  required String role,
  String? phone,
  String status = 'active',
})

// Actualizar rol
Future<Map<String, dynamic>> updateUserRole({
  required String userId,
  required String role,
})

// Cambiar estado
Future<Map<String, dynamic>> toggleUserStatus({
  required String userId,
  required String status,
})

// Eliminar usuario (soft delete)
Future<void> deleteUser(String userId)

// Restablecer contraseña (admin)
Future<void> adminResetUserPassword({
  required String userId,
  required String newPassword,
})

// Recuperación de contraseña pública
Future<void> resetPassword(String email)
```

---

### 6. **Actualización de Base de Datos**

#### Archivo Creado:
- `database/migrations/001_add_user_roles_and_status.sql`

#### Cambios en la Tabla `users`:

**Nuevas Columnas:**
```sql
ALTER TABLE users 
ADD COLUMN role TEXT DEFAULT 'customer',
ADD COLUMN status TEXT DEFAULT 'active',
ADD COLUMN created_by_admin BOOLEAN DEFAULT FALSE;
```

**Constraints:**
- `role` debe ser uno de: admin, waiter, cashier, cook, delivery, vip_customer, customer
- `status` debe ser uno de: active, inactive, suspended

**Índices (Performance):**
```sql
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_by_admin ON users(created_by_admin);
```

---

### 7. **Integración con Panel Administrativo**

#### Archivos Modificados:
- `lib/features/admin/screens/dashboard_screen.dart`
  - Agregada tarjeta "Gestionar Usuarios" en acciones rápidas
  - Navegación a `/admin/users`

- `lib/config/routes.dart`
  - Agregada ruta `AppRoutes.adminUsers = '/admin/users'`
  - Enlazada con `UserManagementScreen()`

---

## 🚀 Cómo Usar el Sistema

### Para Administradores:

1. **Acceder al Panel Admin:**
   - Login con cuenta de administrador
   - Navegar a "Panel Administrativo"

2. **Gestionar Usuarios:**
   - Click en "Gestionar Usuarios"
   - Ver lista completa de usuarios
   - Filtrar por rol o estado

3. **Crear Nuevo Usuario:**
   - Click en botón "Nuevo Usuario" (flotante)
   - Completar formulario:
     - Nombre completo
     - Email
     - Teléfono (opcional)
     - Seleccionar rol
     - Seleccionar estado
     - Asignar contraseña inicial
   - Click en "Crear Usuario"

4. **Editar Usuario Existente:**
   - Click en menú (⋮) del usuario
   - Seleccionar "Editar"
   - Modificar datos necesarios
   - "Guardar Cambios"

5. **Cambiar Estado:**
   - Menú del usuario → "Cambiar Estado"
   - Alterna entre Activo/Inactivo

6. **Restablecer Contraseña:**
   - Menú del usuario → "Restablecer Contraseña"
   - Ingresar nueva contraseña
   - Confirmar contraseña
   - Usuario puede usar la nueva contraseña inmediatamente

### Para Usuarios:

1. **Iniciar Sesión:**
   - Ingresar email y contraseña proporcionados por admin
   - Click en "Iniciar Sesión"

2. **Olvidé mi Contraseña:**
   - Click en "¿Olvidaste tu contraseña?"
   - Ingresar email
   - Revisar correo electrónico
   - Seguir enlace para restablecer

---

## 📦 Pasos de Instalación

### 1. Actualizar Base de Datos en Supabase

1. Ir a tu proyecto en Supabase
2. Navegar a **SQL Editor**
3. Ejecutar el script:
   ```bash
   database/migrations/001_add_user_roles_and_status.sql
   ```
4. Verificar que las columnas fueron creadas correctamente

### 2. Configurar Permisos en Supabase

**Row Level Security (RLS):**

```sql
-- Permitir que admins vean todos los usuarios
CREATE POLICY "Admins can view all users"
ON users FOR SELECT
TO authenticated
USING (
  auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  )
  OR auth.uid() = id
);

-- Permitir que admins actualicen usuarios
CREATE POLICY "Admins can update users"
ON users FOR UPDATE
TO authenticated
USING (
  auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  )
);
```

### 3. Habilitar Admin API en Supabase

1. Ir a **Settings** → **API**
2. Copiar el **service_role key** (secret)
3. **⚠️ IMPORTANTE:** Este key debe usarse SOLO en backend/servidor
4. Para crear usuarios desde Flutter:
   - Usar Cloud Functions o Backend API
   - NO exponer service_role key en cliente

### 4. Instalar Dependencias

```bash
flutter pub get
```

### 5. Probar el Sistema

```bash
flutter run -d chrome
```

---

## 🔒 Seguridad

### Mejores Prácticas Implementadas:

✅ **Validación de Formularios:**
- Email con regex validation
- Contraseñas mínimo 6 caracteres
- Confirmación de contraseña

✅ **Control de Acceso:**
- Solo administradores pueden crear usuarios
- Solo administradores ven gestión de usuarios
- Verificación de roles en cada acción

✅ **Soft Delete:**
- Usuarios no se eliminan permanentemente
- Se marcan como `inactive`
- Mantiene integridad referencial

✅ **Auditoría:**
- Campo `created_by_admin` para tracking
- Timestamps automáticos (created_at, updated_at)

### ⚠️ Consideraciones Importantes:

1. **Service Role Key:**
   - NO incluir en código cliente
   - Usar solo en backend seguro
   - Rotar periódicamente

2. **Contraseñas:**
   - Almacenadas hasheadas por Supabase
   - Nunca se muestran en UI
   - Reset requiere confirmación

3. **Email Confirmation:**
   - Usuarios creados por admin: auto-confirmados
   - Reset password: requiere verificación por email

---

## 🧪 Testing

### Casos de Prueba:

**Login:**
- ✅ Login con credenciales válidas
- ✅ Login con credenciales inválidas
- ✅ Link "Olvidaste contraseña" funcional

**Recuperación de Contraseña:**
- ✅ Envío de email de reset
- ✅ Validación de email format
- ✅ Mensaje de éxito

**Gestión de Usuarios (Admin):**
- ✅ Crear usuario con todos los campos
- ✅ Crear usuario con campos opcionales vacíos
- ✅ Validación de email duplicado
- ✅ Editar usuario existente
- ✅ Cambiar rol de usuario
- ✅ Activar/Desactivar usuario
- ✅ Restablecer contraseña
- ✅ Eliminar usuario

**Filtros:**
- ✅ Filtrar por rol
- ✅ Filtrar por estado
- ✅ Combinación de filtros

---

## 📊 Estructura de Archivos

```
lib/
├── core/
│   ├── models/
│   │   └── user_roles.dart              ✨ NUEVO
│   └── services/
│       └── supabase_service.dart        ✏️ MODIFICADO
├── features/
│   ├── admin/
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart    ✏️ MODIFICADO
│   │   │   └── user_management_screen.dart  ✨ NUEVO
│   │   └── widgets/
│   │       ├── create_user_dialog.dart  ✨ NUEVO
│   │       └── edit_user_dialog.dart    ✨ NUEVO
│   └── auth/
│       └── screens/
│           ├── login_screen.dart        ✏️ MODIFICADO
│           ├── register_screen.dart     ❌ DESHABILITADO
│           └── forgot_password_screen.dart  ✨ NUEVO
├── config/
│   └── routes.dart                      ✏️ MODIFICADO
└── database/
    └── migrations/
        └── 001_add_user_roles_and_status.sql  ✨ NUEVO
```

---

## 📝 Notas Adicionales

### Roles y Permisos Sugeridos:

| Rol | Permisos |
|-----|----------|
| **Admin** | Acceso total al sistema, gestión de usuarios |
| **Waiter** | Ver menú, tomar pedidos, gestionar mesas |
| **Cashier** | Ver pedidos, procesar pagos, reportes de ventas |
| **Cook** | Ver pedidos de cocina, actualizar estado |
| **Delivery** | Ver pedidos delivery, actualizar entregas |
| **VIP Customer** | Reservas prioritarias, descuentos especiales |
| **Customer** | Hacer reservas, ver menú, realizar pedidos |

### Próximas Mejoras:

- [ ] Implementar verificación de dos factores (2FA)
- [ ] Logs de auditoría de acciones admin
- [ ] Exportar lista de usuarios (CSV/PDF)
- [ ] Búsqueda por nombre/email en lista
- [ ] Paginación para listas grandes
- [ ] Roles personalizados dinámicos
- [ ] Permisos granulares por funcionalidad

---

## 🆘 Solución de Problemas

### Error: "Admin API not enabled"
**Solución:** Verificar que estás usando el `service_role` key, no el `anon` key.

### Error: "User already exists"
**Solución:** El email ya está registrado. Usar otro email o editar usuario existente.

### Error: "Insufficient permissions"
**Solución:** Verificar que el usuario actual tenga rol `admin`.

### No recibo email de reset
**Solución:** 
1. Verificar configuración SMTP en Supabase
2. Revisar carpeta spam
3. Verificar que el email esté confirmado

---

## 📞 Contacto y Soporte

Para preguntas o problemas, contactar al equipo de desarrollo:
- Eric A. Jiménez Collins - 2023-0966
- Alexander Matos De La Cruz - 2023-0951
- Kelobel Tapia - 2023-0596

---

**Última Actualización:** 6 de Noviembre, 2025
**Versión:** 1.0.0
