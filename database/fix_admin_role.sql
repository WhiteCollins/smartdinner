-- ============================================
-- VERIFICAR Y ARREGLAR ROL DE ADMIN
-- ============================================
-- Este script verifica y corrige el rol del usuario admin@smartdinner.com

-- 1. Verificar el usuario actual en auth.users
SELECT 
    id,
    email,
    created_at,
    email_confirmed_at
FROM auth.users
WHERE email = 'admin@smartdinner.com';

-- 2. Verificar el perfil en la tabla users
SELECT 
    id,
    email,
    name,
    role,
    is_active,
    email_verified,
    created_at
FROM public.users
WHERE email = 'admin@smartdinner.com';

-- 3. Si el usuario NO existe en public.users, crearlo:
INSERT INTO public.users (
    id,
    email,
    name,
    phone,
    role,
    is_active,
    email_verified
)
SELECT 
    au.id,
    'admin@smartdinner.com',
    'Admin SmartDinner',
    '809-555-0001',
    'admin',
    true,
    true
FROM auth.users au
WHERE au.email = 'admin@smartdinner.com'
ON CONFLICT (id) DO UPDATE SET
    role = 'admin',
    is_active = true,
    email_verified = true,
    name = 'Admin SmartDinner';

-- 4. Si ya existe pero tiene rol diferente, actualizar:
UPDATE public.users
SET 
    role = 'admin',
    is_active = true,
    email_verified = true
WHERE email = 'admin@smartdinner.com';

-- 5. Verificación final - Debe mostrar role = 'admin'
SELECT 
    u.id,
    u.email,
    u.name,
    u.role,
    u.is_active,
    u.email_verified,
    CASE 
        WHEN u.role = 'admin' THEN '✅ ROL CORRECTO'
        ELSE '❌ ROL INCORRECTO - Ejecuta los UPDATE de arriba'
    END as status
FROM public.users u
WHERE u.email = 'admin@smartdinner.com';

-- 6. Verificar que las políticas RLS permiten el acceso
-- Esto muestra si el usuario puede ver su propio perfil
SELECT 
    *
FROM public.users
WHERE id = (SELECT id FROM auth.users WHERE email = 'admin@smartdinner.com')
LIMIT 1;
