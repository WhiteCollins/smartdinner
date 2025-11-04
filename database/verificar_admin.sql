-- ============================================
-- VERIFICAR USUARIO ADMIN
-- Ejecuta esto después de setup_complete.sql
-- ============================================

-- 1. Ver usuario admin en auth.users
SELECT 
    id,
    email,
    email_confirmed_at,
    created_at,
    CASE 
        WHEN email_confirmed_at IS NOT NULL THEN '✅ Confirmado'
        ELSE '❌ Sin confirmar'
    END as estado
FROM auth.users 
WHERE email = 'admin@smartdinner.com';

-- 2. Ver usuario admin en public.users
SELECT 
    id,
    email,
    name,
    role,
    is_active,
    email_verified,
    password_hash,
    created_at
FROM public.users 
WHERE email = 'admin@smartdinner.com';

-- 3. Ver TODAS las columnas de public.users
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'users'
ORDER BY ordinal_position;
