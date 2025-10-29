# 🚀 Inicio Rápido - SmartDinner con Supabase

## ✅ Ya está instalado todo!

Las dependencias ya fueron instaladas. Ahora solo necesitas **3 pasos**:

---

## 📋 PASO 1: Crear proyecto en Supabase (5 minutos)

1. Ve a: https://app.supabase.com
2. Crea una cuenta (gratis)
3. Click en "New Project"
4. Dale un nombre: "SmartDinner"
5. Crea una contraseña para la base de datos
6. Selecciona una región cercana
7. Click en "Create new project"
8. Espera 2 minutos a que se cree

---

## 📋 PASO 2: Copiar las credenciales (2 minutos)

1. En tu proyecto de Supabase, ve a: **Settings** (⚙️) > **API**
2. Copia estos dos valores:

   - **Project URL** (ejemplo: `https://abcdefgh.supabase.co`)
   - **anon public key** (es una llave larga)

3. Abre el archivo: `lib/config/supabase_config.dart`

4. Reemplaza estas líneas (líneas 5-12):

```dart
// ANTES (líneas 5-7):
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://tu-proyecto.supabase.co', // ← CAMBIAR ESTO

// DESPUÉS:
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://abcdefgh.supabase.co', // ← TU URL AQUÍ
```

```dart
// ANTES (líneas 10-12):
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'tu-anon-key-aqui', // ← CAMBIAR ESTO

// DESPUÉS:
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // ← TU KEY AQUÍ
```

---

## 📋 PASO 3: Crear las tablas (3 minutos)

1. En Supabase, ve a: **SQL Editor** (📝)
2. Click en "New query"
3. Ve al archivo donde guardé el SQL anteriormente o copia esto:

```sql
-- COPIA ESTE SQL Y PÉGALO EN SUPABASE SQL EDITOR:

-- Crear tabla de usuarios
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  role TEXT DEFAULT 'customer',
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de items del menú
CREATE TABLE menu_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  available BOOLEAN DEFAULT true,
  preparation_time INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de reservaciones
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL,
  time TIME NOT NULL,
  guests INTEGER NOT NULL,
  status TEXT DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de órdenes
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  total DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de items de órdenes
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id UUID REFERENCES menu_items(id),
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad (los usuarios solo ven sus propios datos)
CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Anyone can view menu" ON menu_items FOR SELECT USING (true);

CREATE POLICY "Users can view own reservations" ON reservations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create reservations" ON reservations FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own order items" ON order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);
```

4. Click en **"Run"** (▶️)
5. Deberías ver: "Success. No rows returned"

---

## 🎉 ¡LISTO! Ahora ejecuta la app:

```powershell
flutter run
```

---

## 👤 Crear tu primer usuario:

**Opción 1 - Desde la app (RECOMENDADO):**
1. Ejecuta la app
2. Click en "¿No tienes cuenta? Regístrate"
3. Llena el formulario
4. ¡Listo!

**Opción 2 - Desde Supabase:**
1. Ve a: **Authentication** > **Users**
2. Click en "Add user"
3. Email: admin@smartdinner.com
4. Password: 123456
5. Click en "Create user"

---

## ✅ Verificar que todo funciona:

1. Abre la app
2. Ingresa tu email y contraseña
3. Click en "Iniciar Sesión"
4. Deberías ver: "¡Bienvenido a SmartDinner!"
5. Deberías navegar a la pantalla principal

---

## ❌ Si hay problemas:

### Error: "Invalid project URL"
- ✅ Verifica que copiaste bien la URL en `supabase_config.dart`
- ✅ La URL debe empezar con `https://`

### Error: "Invalid API key"
- ✅ Verifica que copiaste bien el anon key
- ✅ El anon key es una llave MUY larga

### Error: "Email not confirmed"
- ✅ Ve a Supabase > Authentication > Settings
- ✅ Desactiva "Enable email confirmations"

### Error: "relation does not exist"
- ✅ Verifica que ejecutaste el SQL en Supabase
- ✅ Ve a Database > Tables y verifica que existan las tablas

---

## 📚 Documentación completa:

Lee los archivos:
- `SUPABASE_SETUP.md` - Guía detallada completa
- `IMPLEMENTACION_SUPABASE.md` - Resumen técnico de lo implementado

---

## 🎯 ¿Qué funciona ahora?

✅ Registro de usuarios
✅ Login con email/password
✅ Logout
✅ Validación de formularios
✅ Indicadores de carga
✅ Manejo de errores
✅ Base de datos PostgreSQL
✅ Seguridad con Row Level Security

---

## 📞 Contacto:

Si tienes dudas, revisa la documentación o contacta al desarrollador.

¡Disfruta de SmartDinner! 🍽️
