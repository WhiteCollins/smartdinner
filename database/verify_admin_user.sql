-- ============================================
-- VERIFICAR USUARIO ADMIN
-- ============================================

-- 1. Ver tu usuario en la tabla users
SELECT 
    id,
    email,
    role,
    created_at
FROM users
WHERE email = 'admin@smartdinner.com';

-- 2. Ver el usuario en auth.users (debe coincidir el UUID)
SELECT 
    id,
    email,
    email_confirmed_at,
    created_at
FROM auth.users
WHERE email = 'admin@smartdinner.com';

-- 3. Verificar que ambos IDs coinciden
SELECT 
    'auth.users' as source, id::text as user_id, email
FROM auth.users
WHERE email = 'admin@smartdinner.com'
UNION ALL
SELECT 
    'public.users' as source, id::text as user_id, email
FROM users
WHERE email = 'admin@smartdinner.com';
