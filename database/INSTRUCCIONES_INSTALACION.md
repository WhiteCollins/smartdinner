# 🔧 Instrucciones de Instalación - Fix Gestión de Usuarios

## Problema Solucionado
1. ✅ Políticas RLS no permitían a admin editar otros usuarios
2. ✅ Los usuarios necesitan confirmar email antes de iniciar sesión
3. ✅ Eliminar usuarios solo los marcaba como inactivos (ahora se eliminan permanentemente)

## 📋 Pasos de Instalación

### 1. Ejecutar SQL en Supabase (ORDEN IMPORTANTE)

Ve a **Supabase Dashboard > SQL Editor** y ejecuta EN ESTE ORDEN:

#### A. Primero: `fix_user_management.sql`
Este script:
- Agrega columnas `status` y `created_by_admin`
- Actualiza constraints de roles
- Corrige políticas RLS para que admin pueda editar usuarios
- Marca usuarios existentes como verificados

#### B. Segundo: `admin_user_functions.sql`
Este script:
- Elimina función antigua `admin_create_user()` (ya no se usa)
- Crea función `admin_delete_user()` que elimina usuarios permanentemente

### 2. Configurar Supabase Dashboard

#### ✅ Configuración de Email (IMPORTANTE)
**Authentication > Providers > Email:**
- ✅ **MANTENER ACTIVADO** "Confirm email"
- Todos los usuarios (incluyendo los creados por admin) recibirán correo de confirmación
- Deben hacer clic en el link del correo antes de poder iniciar sesión

#### Configurar URLs
**Authentication > URL Configuration:**
- **Site URL**: `http://localhost:8080` (desarrollo)
- **Redirect URLs** (agregar):
  - `http://localhost:8080/#/reset-password`
  - `http://localhost:8080/#/login`

### 3. Verificar Instalación

Después de ejecutar los scripts SQL, verifica:

```sql
-- Ver funciones creadas
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE 'admin_%';

-- Debería mostrar:
-- admin_delete_user
```

### 4. Probar Funcionalidades

#### Crear Usuario
1. En la app, ir a **Gestión de Usuarios**
2. Clic en **+ Nuevo Usuario**
3. Llenar formulario y guardar
4. **El usuario recibirá un correo de confirmación**
5. Debe hacer clic en el link del correo para confirmar
6. Después de confirmar, podrá iniciar sesión

#### Eliminar Usuario
1. En lista de usuarios, clic en menú (⋮)
2. Seleccionar **Eliminar**
3. Confirmar en el diálogo de advertencia
4. El usuario se elimina PERMANENTEMENTE de la base de datos

## 🔍 Verificación de Usuarios Creados

```sql
-- Ver usuarios en public.users
SELECT 
    email, 
    name, 
    role, 
    email_verified, 
    created_by_admin
FROM public.users 
ORDER BY created_at DESC;

-- Ver usuarios en auth.users (tabla de Supabase)
SELECT 
    email, 
    email_confirmed_at,
    created_at
FROM auth.users 
ORDER BY created_at DESC;
```

## ⚠️ Notas Importantes

### Sobre Crear Usuarios
- Usa `signUp()` de Supabase Auth que:
  - Crea usuario en `auth.users` SIN confirmar
  - Envía correo de confirmación automáticamente
  - Crea perfil en `public.users` con `email_verified = false`
  - Usuario **DEBE** confirmar email antes de iniciar sesión

### Sobre Eliminar Usuarios
- **PERMANENTE**: No se puede deshacer
- Elimina de `auth.users` Y `public.users`
- No se puede eliminar el admin principal (`admin@smartdinner.com`)
- Si quieres solo desactivar, usa el toggle de estado en su lugar

### Sobre Reset de Contraseña
- Admin puede resetear contraseña de otros usuarios (requiere Service Role Key)
- Usuarios pueden resetear su propia contraseña por email
- El link de reset redirige a `/reset-password` en la app

## 🐛 Solución de Problemas

### "Credenciales inválidas" después de crear usuario
✅ **Es normal**: El usuario debe confirmar su email primero
- Revisa la bandeja de entrada del email ingresado
- Haz clic en el link de confirmación
- Después podrás iniciar sesión

### Usuario no recibe email de confirmación
- Verifica configuración SMTP en Supabase (Authentication > Email Templates)
- En desarrollo, revisa los logs en Supabase Dashboard > Authentication > Users
- Puedes confirmar manualmente en el dashboard: Users > [usuario] > Confirm email

### No puedo eliminar usuario
- Verifica que ejecutaste `admin_user_functions.sql`
- Verifica que eres admin
- No puedes eliminar `admin@smartdinner.com`

## 📁 Archivos Modificados

### SQL
- `database/fix_user_management.sql` - Estructura y políticas
- `database/admin_user_functions.sql` - Funciones de creación/eliminación

### Dart/Flutter
- `lib/core/services/supabase_service.dart`:
  - `createUserByAdmin()` - Usa función SQL
  - `deleteUser()` - Elimina permanentemente
  - `deactivateUser()` - Soft delete (nuevo)
  - `updatePassword()` - Para reset password
  
- `lib/features/auth/screens/reset_password_screen.dart` - Nueva pantalla

- `lib/features/admin/screens/user_management_screen.dart`:
  - Diálogo de eliminación mejorado con advertencia

- `lib/config/routes.dart`:
  - Agregada ruta `/reset-password`

## ✅ Checklist Final

- [ ] Ejecutar `fix_user_management.sql` en Supabase
- [ ] Ejecutar `admin_user_functions.sql` en Supabase
- [ ] Configurar Authentication > Email en Dashboard
- [ ] Configurar URL Configuration en Dashboard
- [ ] Probar crear usuario y login inmediato
- [ ] Probar eliminar usuario
- [ ] Probar reset de contraseña
- [ ] Probar editar usuario (cambiar rol, estado)

## 🎯 Próximos Pasos

Una vez verificado todo:
1. Crear usuarios de prueba para cada rol (waiter, cook, cashier)
2. Implementar navegación basada en roles
3. Configurar vistas específicas por rol
