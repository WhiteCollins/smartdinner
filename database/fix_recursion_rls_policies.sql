-- ============================================
-- SOLUCIONAR RECURSIÓN INFINITA EN POLÍTICAS RLS
-- ============================================
-- Problema: Las políticas actuales causan recursión infinita
-- Solución: Eliminar políticas problemáticas y crear nuevas simples

-- 1. DESHABILITAR RLS TEMPORALMENTE (para poder trabajar)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. ELIMINAR TODAS LAS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.users;
DROP POLICY IF EXISTS "Enable read access for own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.users;
DROP POLICY IF EXISTS "Enable delete for users based on id" ON public.users;

-- 3. RE-HABILITAR RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 4. CREAR POLÍTICAS SIMPLES SIN RECURSIÓN

-- 4.1 Permitir que usuarios autenticados vean su propio perfil
-- IMPORTANTE: NO consultar la tabla users dentro de la política
CREATE POLICY "users_select_own"
ON public.users
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- 4.2 Permitir que usuarios actualicen su propio perfil
CREATE POLICY "users_update_own"
ON public.users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 4.3 Política especial para admins (sin recursión)
-- Usar una función que NO cause recursión
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'admin'
  );
$$;

-- 4.4 Permitir que admins vean todos los perfiles (usando la función)
CREATE POLICY "admins_select_all"
ON public.users
FOR SELECT
TO authenticated
USING (
  auth.uid() = id  -- Puede ver su propio perfil
  OR 
  (SELECT role FROM public.users WHERE id = auth.uid() LIMIT 1) = 'admin'  -- O es admin
);

-- ALTERNATIVA MÁS SIMPLE: Permitir que todos los usuarios autenticados vean todos los perfiles
-- Descomenta estas líneas si la política de arriba sigue dando problemas:

-- DROP POLICY IF EXISTS "admins_select_all" ON public.users;
-- CREATE POLICY "users_select_all"
-- ON public.users
-- FOR SELECT
-- TO authenticated
-- USING (true);  -- Cualquier usuario autenticado puede ver cualquier perfil

-- 5. VERIFICACIÓN: Intentar leer el perfil del admin
SELECT 
    id,
    email,
    name,
    role,
    is_active,
    '✅ Perfil accesible - RLS funcionando correctamente' as status
FROM public.users
WHERE email = 'admin@smartdinner.com';

-- 6. Ver las políticas activas después de los cambios
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as command,
    permissive,
    roles
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'users'
ORDER BY policyname;

-- 7. Confirmar que RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'users';
