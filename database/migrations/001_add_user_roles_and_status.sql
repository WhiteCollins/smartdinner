-- ========================================
-- Script: Actualización de tabla users para administración
-- Descripción: Agrega columnas para roles, estado y seguimiento de usuarios creados por admin
-- Fecha: 2025-11-06
-- ========================================

-- 1. Agregar columnas nuevas a la tabla users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'customer',
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active',
ADD COLUMN IF NOT EXISTS created_by_admin BOOLEAN DEFAULT FALSE;

-- 2. Crear tipo enum para roles (opcional, mejor validación)
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM (
        'admin',
        'waiter',
        'cashier',
        'cook',
        'delivery',
        'vip_customer',
        'customer'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Crear tipo enum para estados (opcional, mejor validación)
DO $$ BEGIN
    CREATE TYPE user_status AS ENUM (
        'active',
        'inactive',
        'suspended'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 4. Agregar índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_by_admin ON users(created_by_admin);

-- 5. Actualizar usuarios existentes con valores por defecto
UPDATE users 
SET 
    role = COALESCE(role, 'customer'),
    status = COALESCE(status, 'active'),
    created_by_admin = COALESCE(created_by_admin, FALSE)
WHERE role IS NULL OR status IS NULL OR created_by_admin IS NULL;

-- 6. Asegurar que el usuario admin tenga el rol correcto
UPDATE users 
SET role = 'admin', status = 'active'
WHERE email = 'admin@smartdinner.com';

-- 7. Agregar restricciones (constraints)
ALTER TABLE users
ADD CONSTRAINT check_role CHECK (role IN ('admin', 'waiter', 'cashier', 'cook', 'delivery', 'vip_customer', 'customer')),
ADD CONSTRAINT check_status CHECK (status IN ('active', 'inactive', 'suspended'));

-- 8. Crear función para validar creación de usuarios por admin
CREATE OR REPLACE FUNCTION check_admin_user_creation()
RETURNS TRIGGER AS $$
BEGIN
    -- Si created_by_admin es true, verificar que el usuario actual sea admin
    IF NEW.created_by_admin = TRUE THEN
        -- Aquí podrías agregar lógica adicional de validación
        NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Crear trigger para validación
DROP TRIGGER IF EXISTS trigger_check_admin_user_creation ON users;
CREATE TRIGGER trigger_check_admin_user_creation
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION check_admin_user_creation();

-- 10. Comentarios en las columnas para documentación
COMMENT ON COLUMN users.role IS 'Rol del usuario en el sistema: admin, waiter, cashier, cook, delivery, vip_customer, customer';
COMMENT ON COLUMN users.status IS 'Estado del usuario: active, inactive, suspended';
COMMENT ON COLUMN users.created_by_admin IS 'Indica si el usuario fue creado por un administrador (no por registro público)';

-- 11. Verificar la estructura actualizada
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- ========================================
-- RESULTADO ESPERADO:
-- ========================================
-- La tabla users ahora tiene:
-- - role: Define el rol del usuario en el sistema
-- - status: Define si el usuario está activo, inactivo o suspendido
-- - created_by_admin: Marca si fue creado por admin o auto-registro
--
-- Todos los usuarios existentes mantienen sus datos
-- El usuario admin@smartdinner.com tiene rol 'admin'
-- ========================================
