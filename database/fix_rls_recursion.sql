-- ============================================
-- FIX: Recursión Infinita en Políticas RLS
-- Ejecutar en SQL Editor de Supabase
-- ============================================
-- Problema: Las políticas consultan la misma tabla users
-- causando recursión infinita al verificar roles
-- Solución: Usar auth.uid() directamente sin subqueries
-- ============================================

-- 1. ELIMINAR TODAS LAS POLÍTICAS ANTIGUAS
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Anyone can create account" ON public.users;
DROP POLICY IF EXISTS "Admin can delete users" ON public.users;
DROP POLICY IF EXISTS "Admin can view all users" ON public.users;
DROP POLICY IF EXISTS "Admin can update all users" ON public.users;
DROP POLICY IF EXISTS "Admin full access" ON public.users;
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;
DROP POLICY IF EXISTS "admins_select_all" ON public.users;
DROP POLICY IF EXISTS "Admin can manage all users" ON public.users;
DROP POLICY IF EXISTS "users_select_policy" ON public.users;
DROP POLICY IF EXISTS "users_insert_policy" ON public.users;
DROP POLICY IF EXISTS "users_update_policy" ON public.users;
DROP POLICY IF EXISTS "users_delete_policy" ON public.users;

-- 2. DESHABILITAR RLS TEMPORALMENTE (solo para arreglar)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 3. CREAR FUNCIÓN HELPER PARA VERIFICAR SI ES ADMIN
-- Esta función evita la recursión al usar una tabla temporal
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    user_role TEXT;
BEGIN
    -- Obtener rol directamente sin causar recursión
    SELECT role INTO user_role
    FROM public.users
    WHERE id = auth.uid()
    LIMIT 1;
    
    RETURN COALESCE(user_role = 'admin', false);
END;
$$;

-- 4. HABILITAR RLS DE NUEVO
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 5. CREAR POLÍTICAS SIMPLES SIN RECURSIÓN

-- 5.1 SELECT: Ver propio perfil O si eres admin (usando función)
CREATE POLICY "users_select_policy" 
ON public.users
FOR SELECT 
TO authenticated
USING (
    auth.uid() = id 
    OR 
    public.is_admin()
);

-- 5.2 INSERT: Permitir creación de cuentas
CREATE POLICY "users_insert_policy" 
ON public.users
FOR INSERT 
TO authenticated
WITH CHECK (true);

-- 5.3 UPDATE: Actualizar propio perfil O si eres admin
CREATE POLICY "users_update_policy" 
ON public.users
FOR UPDATE 
TO authenticated
USING (
    auth.uid() = id 
    OR 
    public.is_admin()
)
WITH CHECK (
    auth.uid() = id 
    OR 
    public.is_admin()
);

-- 5.4 DELETE: Solo admin puede eliminar
CREATE POLICY "users_delete_policy" 
ON public.users
FOR DELETE 
TO authenticated
USING (public.is_admin());

-- 6. OTORGAR PERMISOS A LA FUNCIÓN
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon;

-- 7. VERIFICAR POLÍTICAS CREADAS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

-- 8. PROBAR QUE FUNCIONA
-- Ejecuta esto como usuario autenticado:
/*
SELECT id, email, name, role 
FROM public.users 
WHERE id = auth.uid();
*/

-- 9. VERIFICAR QUE NO HAY RECURSIÓN
-- Si este query funciona, las políticas están bien:
/*
SELECT 
    u.id,
    u.email,
    u.name,
    u.role
FROM public.users u
WHERE u.id = auth.uid();
*/
