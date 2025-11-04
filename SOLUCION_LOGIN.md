# 🔧 Solución: Login y Registro no Funcionan

## ✅ Pasos para Solucionar

### **Paso 1: Desactivar Email Confirmation en Supabase**

1. Ve a: https://app.supabase.com/project/dftgnfvzrrhfegrqahyw
2. Click en **Authentication** (menú izquierdo)
3. Click en **Settings** o **Configuration**
4. Busca **"Enable email confirmations"** o **"Confirm email"**
5. **DESACTÍVALO** (toggle OFF)
6. Click **Save**

⚠️ **IMPORTANTE:** Esto permite que los usuarios se registren sin confirmar email

---

### **Paso 2: Ejecutar Script SQL de Configuración**

1. En Supabase, ve a **SQL Editor**
2. Click en **"New query"**
3. Copia todo el contenido del archivo: `database/setup_complete.sql`
4. Pega en el editor
5. Click en **Run** o presiona `Ctrl + Enter`
6. Verifica que aparezcan mensajes como:
   ```
   ✓ Usuario admin YA existe
   ✓ Usuario admin sincronizado
   ```

Si dice "Usuario admin NO existe", continúa al Paso 3.

---

### **Paso 3: Crear Usuario Admin Manualmente (si no existe)**

1. Ve a **Authentication** > **Users**
2. Click en **"Add user"** (botón verde)
3. Completa el formulario:
   ```
   Email: admin@smartdinner.com
   Password: 123456
   ```
4. **MUY IMPORTANTE**: Activa **"Auto Confirm User"** ✓
5. Click **"Create User"**
6. Vuelve al **SQL Editor** y ejecuta nuevamente el script del Paso 2

---

### **Paso 4: Verificar en Supabase**

1. Ve a **Table Editor**
2. Selecciona la tabla **`users`**
3. Deberías ver al menos 1 usuario:
   - Email: `admin@smartdinner.com`
   - Role: `admin`
   - Email verified: `true`

---

### **Paso 5: Probar en la App**

#### **Prueba de Login:**

1. Ejecuta la app:
   ```bash
   flutter run -d chrome
   ```

2. En la pantalla de login:
   - Email: `admin@smartdinner.com`
   - Password: `123456`
   - Click **"Iniciar Sesión"**

3. **Resultado esperado:**
   - ✅ Mensaje: "¡Bienvenido a SmartDinner!"
   - ✅ Redirección al Home
   
4. Si falla, abre **DevTools** (F12) y busca:
   ```
   Console > Mensajes de error
   Network > Verifica llamadas a Supabase
   ```

#### **Prueba de Registro:**

1. En la pantalla de login, click **"Regístrate"**

2. Completa el formulario:
   ```
   Nombre: Juan Pérez
   Email: juan.perez@test.com
   Teléfono: 809-555-1234
   Contraseña: test123456
   Confirmar: test123456
   ```

3. Click **"Crear Cuenta"**

4. **Resultado esperado:**
   - ✅ Mensaje: "¡Cuenta creada exitosamente!"
   - ✅ Redirección al Home
   - ✅ Usuario aparece en **Table Editor > users**

---

## 🐛 Errores Comunes y Soluciones

### Error: "Invalid login credentials"

**Causa:** Usuario no existe o contraseña incorrecta

**Solución:**
1. Verifica que el usuario existe en **Authentication > Users**
2. Intenta reset password o crea el usuario nuevamente

---

### Error: "Email not confirmed"

**Causa:** Email confirmation está habilitado

**Solución:**
1. Ve a **Authentication > Settings**
2. Desactiva **"Enable email confirmations"**
3. O marca **"Auto Confirm User"** al crear usuarios

---

### Error: "new row violates row-level security policy"

**Causa:** Las políticas RLS están bloqueando el insert

**Solución:**
1. Ejecuta el script SQL del Paso 2 nuevamente
2. Verifica que exista la política:
   ```sql
   "Anyone can create account" FOR INSERT TO public
   ```

---

### Error: "duplicate key value violates unique constraint"

**Causa:** El usuario ya existe en la tabla

**Solución:**
1. Ve a **Table Editor > users**
2. Busca el email duplicado
3. Elimínalo o usa otro email

---

### Error: "relation public.users does not exist"

**Causa:** La tabla users no está creada

**Solución:**
1. Ejecuta el script SQL del Paso 2
2. Verifica en **Table Editor** que aparezca la tabla `users`

---

## 📋 Verificación Final

Ejecuta estas consultas en **SQL Editor**:

```sql
-- Ver todos los usuarios
SELECT id, email, name, role, email_verified, created_at
FROM public.users
ORDER BY created_at DESC;

-- Ver políticas RLS
SELECT policyname, cmd, permissive
FROM pg_policies
WHERE tablename = 'users';

-- Ver usuarios en auth
SELECT id, email, email_confirmed_at, created_at
FROM auth.users
ORDER BY created_at DESC;
```

**Resultados esperados:**
- ✅ Al menos 1 usuario en `public.users`
- ✅ 3 políticas RLS activas
- ✅ Usuario admin con `email_confirmed_at` lleno

---

## 🆘 Si Sigue Sin Funcionar

1. **Revisa logs de Supabase:**
   - Ve a **Logs** > **Auth Logs**
   - Busca errores recientes

2. **Verifica credenciales en `.env`:**
   ```bash
   SUPABASE_URL=https://dftgnfvzrrhfegrqahyw.supabase.co
   SUPABASE_ANON_KEY=eyJhbGci...
   ```

3. **Reinicia la app Flutter:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

4. **Comparte el error exacto:**
   - Copia el mensaje de error completo de DevTools
   - Incluye los logs de Auth en Supabase
