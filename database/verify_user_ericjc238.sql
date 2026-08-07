-- ============================================
-- VERIFICAR ESTADO DEL USUARIO ericjc238@gmail.com
-- Ejecutar en SQL Editor de Supabase
-- ============================================

-- 1. VERIFICAR SI EL USUARIO EXISTE EN auth.users
SELECT 
    id,
    email,
    email_confirmed_at,
    confirmed_at,
    created_at,
    updated_at,
    last_sign_in_at,
    raw_user_meta_data
FROM auth.users
WHERE email = 'ericjc238@gmail.com';

-- 2. VERIFICAR SI EXISTE EN public.users
SELECT 
    id,
    email,
    name,
    role,
    status,
    is_active,
    email_verified,
    created_by_admin,
    created_at,
    updated_at
FROM public.users
WHERE email = 'ericjc238@gmail.com';

-- ============================================
-- SI EL USUARIO EXISTE PERO NO ESTÁ CONFIRMADO
-- Puedes confirmarlo manualmente con este comando:
-- ============================================

-- OPCIÓN A: Confirmar email manualmente (ejecutar solo si existe)
/*
UPDATE auth.users
SET 
    email_confirmed_at = NOW(),
    confirmed_at = NOW(),
    updated_at = NOW()
WHERE email = 'ericjc238@gmail.com';

UPDATE public.users
SET 
    email_verified = true,
    updated_at = NOW()
WHERE email = 'ericjc238@gmail.com';
*/

-- ============================================
-- OPCIÓN B: Eliminar usuario y volver a crear
-- Útil si hay problemas con el registro
-- ============================================

/*
-- Primero eliminar de public.users
DELETE FROM public.users WHERE email = 'ericjc238@gmail.com';

-- Luego eliminar de auth.users (requiere privilegios de admin)
-- Esto se debe hacer desde el Dashboard de Supabase:
-- Authentication > Users > Buscar usuario > Delete
*/

-- ============================================
-- VERIFICAR CONFIGURACIÓN DE EMAIL EN SUPABASE
-- ============================================

-- Esta query muestra la configuración de auth
-- (Solo lectura, para verificar)
SELECT 
    name,
    value
FROM pg_catalog.pg_settings
WHERE name LIKE '%smtp%' OR name LIKE '%email%';
