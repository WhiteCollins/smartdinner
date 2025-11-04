-- ============================================
-- OPCIÓN B: ACTUALIZAR SIN RECREAR LA TABLA
-- ✅ Mantiene datos existentes
-- ============================================

-- 1. Hacer password_hash nullable
ALTER TABLE public.users ALTER COLUMN password_hash DROP NOT NULL;

-- 2. Ver IDs actuales para diagnóstico
SELECT 
    'auth.users' as tabla,
    id,
    email
FROM auth.users
WHERE email = 'admin@smartdinner.com'
UNION ALL
SELECT 
    'public.users' as tabla,
    id,
    email
FROM public.users
WHERE email = 'admin@smartdinner.com';

-- 3. Actualizar el registro existente con el ID correcto
-- (Esto fallará si id no es el mismo, pero al menos vemos el problema)
UPDATE public.users
SET 
    id = (SELECT id FROM auth.users WHERE email = 'admin@smartdinner.com'),
    role = 'admin',
    email_verified = true,
    is_active = true,
    name = 'Admin SmartDinner',
    phone = '809-555-0001',
    password_hash = NULL
WHERE email = 'admin@smartdinner.com';

-- 4. Verificar resultado
SELECT 
    u.id as public_id,
    a.id as auth_id,
    u.email,
    u.role,
    u.is_active,
    u.email_verified,
    CASE 
        WHEN u.id = a.id THEN '✅ IDs coinciden'
        ELSE '❌ IDs diferentes: ' || u.id::text || ' vs ' || a.id::text
    END as sincronizacion
FROM public.users u
CROSS JOIN auth.users a
WHERE u.email = 'admin@smartdinner.com'
AND a.email = 'admin@smartdinner.com';
