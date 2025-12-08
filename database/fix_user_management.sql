-- ============================================
-- FIX: Gestión de Usuarios - SmartDinner
-- Ejecutar en SQL Editor de Supabase
-- ============================================
-- Problemas a resolver:
-- 1. La columna 'status' no existe (solo is_active)
-- 2. Las políticas RLS no permiten a admin editar otros usuarios
-- 3. Los usuarios necesitan email_verified para confirmar acceso
-- ============================================

-- 1. AGREGAR COLUMNA STATUS SI NO EXISTE
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';

-- 2. AGREGAR COLUMNA created_by_admin SI NO EXISTE
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS created_by_admin BOOLEAN DEFAULT false;

-- 3. SINCRONIZAR status CON is_active EXISTENTE
UPDATE public.users 
SET status = CASE 
    WHEN is_active = true THEN 'active' 
    ELSE 'inactive' 
END
WHERE status IS NULL OR status = '';

-- 4. ELIMINAR CONSTRAINT ANTIGUO DE ROLE SI EXISTE
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_role;

-- 5. AGREGAR CONSTRAINT ACTUALIZADO PARA ROLES
DO $$
BEGIN
    ALTER TABLE public.users 
    ADD CONSTRAINT users_role_check 
    CHECK (role IN ('admin', 'customer', 'waiter', 'cook', 'cashier', 'staff'));
EXCEPTION
    WHEN duplicate_object THEN 
        NULL; -- El constraint ya existe
END;
$$;

-- 6. AGREGAR CONSTRAINT PARA STATUS
DO $$
BEGIN
    ALTER TABLE public.users 
    ADD CONSTRAINT users_status_check 
    CHECK (status IN ('active', 'inactive', 'suspended'));
EXCEPTION
    WHEN duplicate_object THEN 
        NULL;
END;
$$;

-- 7. ELIMINAR POLÍTICAS RLS ANTIGUAS
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Anyone can create account" ON public.users;
DROP POLICY IF EXISTS "Admin can view all users" ON public.users;
DROP POLICY IF EXISTS "Admin can update all users" ON public.users;
DROP POLICY IF EXISTS "Admin full access" ON public.users;

-- 8. CREAR POLÍTICAS RLS CORRECTAS

-- 8.1 SELECT: Usuarios ven su perfil, Admin ve todos
CREATE POLICY "Users can view their own profile" 
ON public.users
FOR SELECT 
TO authenticated
USING (
    auth.uid() = id 
    OR 
    EXISTS (
        SELECT 1 FROM public.users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
);

-- 8.2 INSERT: Permitir creación de cuentas
CREATE POLICY "Anyone can create account" 
ON public.users
FOR INSERT 
TO public
WITH CHECK (true);

-- 8.3 UPDATE: Usuario edita su perfil, Admin edita cualquiera
CREATE POLICY "Users can update their own profile" 
ON public.users
FOR UPDATE 
TO authenticated
USING (
    auth.uid() = id 
    OR 
    EXISTS (
        SELECT 1 FROM public.users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
)
WITH CHECK (
    auth.uid() = id 
    OR 
    EXISTS (
        SELECT 1 FROM public.users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
);

-- 8.4 DELETE: Solo Admin puede eliminar
CREATE POLICY "Admin can delete users" 
ON public.users
FOR DELETE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
);

-- 9. CREAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(status);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- 10. ACTUALIZAR ADMIN SI EXISTE
UPDATE public.users 
SET 
    role = 'admin',
    status = 'active',
    is_active = true,
    email_verified = true
WHERE email = 'admin@smartdinner.com';

-- 11. VERIFICAR ESTRUCTURA FINAL
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- 12. VERIFICAR USUARIOS EXISTENTES
SELECT 
    id,
    email, 
    name,
    role, 
    status,
    is_active,
    email_verified,
    created_at
FROM public.users
ORDER BY created_at DESC;

-- ============================================
-- IMPORTANTE: CONFIGURACIÓN EN SUPABASE DASHBOARD
-- ============================================
-- Para que los usuarios creados por admin puedan iniciar sesión 
-- sin confirmación de email:
--
-- 1. Ir a Authentication > Providers > Email
-- 2. Desactivar "Confirm email" 
--    O mantenerlo activo y usar la función admin para confirmar
--
-- 3. Agregar URL de redirección en Authentication > URL Configuration:
--    - Site URL: http://localhost:8080 (o tu dominio de producción)
--    - Redirect URLs: 
--      - http://localhost:8080/#/reset-password
--      - http://localhost:8080/#/login
--      - https://tu-dominio.com/#/reset-password (producción)
-- ============================================

-- 13. MARCAR TODOS LOS USUARIOS EXISTENTES COMO VERIFICADOS
-- (Útil para usuarios que ya fueron creados antes del fix)
UPDATE public.users 
SET email_verified = true 
WHERE email_verified = false OR email_verified IS NULL;
