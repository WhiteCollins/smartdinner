-- ============================================
-- FUNCIONES: Administración de Usuarios - SmartDinner
-- Ejecutar en SQL Editor de Supabase
-- ============================================
-- NOTA: Los usuarios se crean desde Flutter con signUp()
-- Esta función solo se usa para ELIMINAR usuarios
-- ============================================

-- 1. ELIMINAR FUNCIÓN ANTIGUA SI EXISTE (ya no se usa)
DROP FUNCTION IF EXISTS public.admin_create_user(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);

-- ============================================
-- CREAR FUNCIÓN PARA ELIMINAR USUARIO COMPLETAMENTE
-- ============================================
CREATE OR REPLACE FUNCTION public.admin_delete_user(
    user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar que el usuario que ejecuta es admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Solo administradores pueden eliminar usuarios';
    END IF;

    -- Verificar que el usuario existe
    IF NOT EXISTS (
        SELECT 1 FROM public.users WHERE id = user_id
    ) THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- No permitir eliminar al admin principal
    IF EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = user_id 
        AND email = 'admin@smartdinner.com'
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar el usuario administrador principal';
    END IF;

    -- Eliminar de public.users (esto también eliminará de auth.users por CASCADE)
    DELETE FROM public.users WHERE id = user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Usuario eliminado correctamente',
        'user_id', user_id
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al eliminar usuario: %', SQLERRM;
END;
$$;

-- 4. OTORGAR PERMISOS
GRANT EXECUTE ON FUNCTION public.admin_delete_user TO authenticated;

-- 5. TESTING - Comentar después de probar
/*
-- Crear usuario de prueba
SELECT public.admin_create_user(
    'test@example.com',
    'password123',
    'Usuario Prueba',
    'customer',
    NULL,
    'active'
);

-- Ver usuarios
SELECT id, email, name, role, email_verified, created_by_admin 
FROM public.users 
ORDER BY created_at DESC;

-- Ver en auth.users
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email = 'test@example.com';
*/
