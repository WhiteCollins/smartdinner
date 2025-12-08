-- ============================================
-- VERIFICAR Y CONFIRMAR USUARIOS - SmartDinner
-- Ejecutar en SQL Editor de Supabase
-- ============================================
-- Usa este script para:
-- 1. Ver el estado de confirmación de usuarios
-- 2. Confirmar manualmente usuarios para desarrollo/testing
-- ============================================

-- 1. VER TODOS LOS USUARIOS Y SU ESTADO DE CONFIRMACIÓN
SELECT 
    u.id,
    u.email,
    u.name,
    u.role,
    u.is_active,
    pu.email_verified as public_email_verified,
    u.email_confirmed_at,
    u.created_at,
    CASE 
        WHEN u.email_confirmed_at IS NOT NULL THEN '✅ Confirmado'
        ELSE '❌ Pendiente de confirmar'
    END as estado_confirmacion
FROM auth.users u
LEFT JOIN public.users pu ON pu.id = u.id
ORDER BY u.created_at DESC;

-- 2. VER SOLO USUARIOS NO CONFIRMADOS
SELECT 
    u.id,
    u.email,
    u.name,
    u.created_at,
    NOW() - u.created_at as tiempo_desde_creacion
FROM auth.users u
WHERE u.email_confirmed_at IS NULL
ORDER BY u.created_at DESC;

-- ============================================
-- CONFIRMAR USUARIO MANUALMENTE (PARA DESARROLLO)
-- ============================================
-- ⚠️ IMPORTANTE: Esto es solo para desarrollo/testing
-- En producción, los usuarios deben confirmar por email
-- ============================================

-- 3. CONFIRMAR UN USUARIO ESPECÍFICO POR EMAIL
-- Reemplaza 'usuario@ejemplo.com' con el email del usuario
/*
UPDATE auth.users 
SET 
    email_confirmed_at = NOW(),
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com' 
  AND email_confirmed_at IS NULL;

-- Actualizar también en public.users
UPDATE public.users 
SET email_verified = true
WHERE email = 'usuario@ejemplo.com';

-- Verificar que se actualizó
SELECT 
    u.email, 
    u.email_confirmed_at,
    pu.email_verified
FROM auth.users u
LEFT JOIN public.users pu ON pu.id = u.id
WHERE u.email = 'usuario@ejemplo.com';
*/

-- 4. CONFIRMAR TODOS LOS USUARIOS NO CONFIRMADOS (SOLO DESARROLLO)
/*
⚠️ CUIDADO: Esto confirmará TODOS los usuarios pendientes
Solo usar en desarrollo, nunca en producción
*/
/*
UPDATE auth.users 
SET 
    email_confirmed_at = NOW(),
    updated_at = NOW()
WHERE email_confirmed_at IS NULL;

UPDATE public.users 
SET email_verified = true
WHERE email_verified = false OR email_verified IS NULL;

-- Ver resultado
SELECT COUNT(*) as usuarios_confirmados
FROM auth.users 
WHERE email_confirmed_at IS NOT NULL;
*/

-- 5. VERIFICAR USUARIO ESPECÍFICO ANTES DE CONFIRMAR
-- Usa esto para asegurarte de que el usuario existe
-- Reemplaza 'usuario@ejemplo.com' con el email
/*
SELECT 
    u.id,
    u.email,
    u.raw_user_meta_data->>'name' as nombre,
    u.email_confirmed_at,
    u.confirmation_sent_at,
    u.created_at,
    pu.role,
    pu.email_verified
FROM auth.users u
LEFT JOIN public.users pu ON pu.id = u.id
WHERE u.email = 'usuario@ejemplo.com';
*/

-- ============================================
-- EJEMPLO DE USO COMÚN
-- ============================================
-- Si creaste un usuario con email: test@example.com
-- y quieres confirmarlo manualmente:

/*
-- Paso 1: Verificar que existe
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email = 'test@example.com';

-- Paso 2: Confirmar
UPDATE auth.users 
SET email_confirmed_at = NOW(), updated_at = NOW()
WHERE email = 'test@example.com';

UPDATE public.users 
SET email_verified = true
WHERE email = 'test@example.com';

-- Paso 3: Verificar confirmación
SELECT 
    u.email,
    u.email_confirmed_at as confirmado_en_auth,
    pu.email_verified as confirmado_en_public
FROM auth.users u
JOIN public.users pu ON pu.id = u.id
WHERE u.email = 'test@example.com';
*/

-- ============================================
-- REENVIAR EMAIL DE CONFIRMACIÓN (DESDE LA APP)
-- ============================================
-- Nota: Esto se hace desde Flutter con:
-- await _supabaseService.resendEmailConfirmation(email);
-- No desde SQL
-- ============================================
