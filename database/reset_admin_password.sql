-- ============================================
-- RESETEAR CONTRASEÑA DEL ADMIN
-- Ejecuta esto si el login sigue fallando
-- ============================================

-- OPCIÓN 1: Ver si existe un mecanismo de reset
-- (No se puede cambiar password directamente desde SQL en Supabase)

-- SOLUCIÓN MANUAL:
-- 1. Ve a Supabase Dashboard > Authentication > Users
-- 2. Busca admin@smartdinner.com
-- 3. Click en los 3 puntos (...) > "Send magic link" o "Reset password"
-- 4. O elimina el usuario y créalo de nuevo:
--    - Email: admin@smartdinner.com
--    - Password: 123456
--    - ✅ Auto Confirm User (MUY IMPORTANTE)

-- Después de crear/resetear, ejecuta esto para sincronizar:
INSERT INTO public.users (id, email, name, phone, role, is_active, email_verified, password_hash)
SELECT 
    id,
    email,
    'Admin SmartDinner',
    '809-555-0001',
    'admin',
    true,
    true,
    NULL
FROM auth.users
WHERE email = 'admin@smartdinner.com'
ON CONFLICT (email) DO UPDATE SET
    id = EXCLUDED.id,
    role = 'admin',
    email_verified = true,
    is_active = true,
    name = 'Admin SmartDinner',
    phone = '809-555-0001',
    password_hash = NULL,
    updated_at = now();

-- Verificar
SELECT 
    u.id as public_id,
    a.id as auth_id,
    u.email,
    u.role,
    a.email_confirmed_at,
    CASE 
        WHEN u.id = a.id THEN '✅ IDs coinciden'
        ELSE '❌ IDs NO coinciden'
    END as sincronizacion
FROM public.users u
JOIN auth.users a ON u.email = a.email
WHERE u.email = 'admin@smartdinner.com';
