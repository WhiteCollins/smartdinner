-- ============================================
-- CONFIGURACIÓN COMPLETA DE SMARTDINNER
-- Ejecuta este script en SQL Editor de Supabase
-- ============================================

-- 1. CREAR TABLA USERS SI NO EXISTE
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('admin', 'customer', 'staff')),
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. HABILITAR RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. ELIMINAR POLÍTICAS ANTIGUAS SI EXISTEN
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Anyone can create account" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;

-- 4. CREAR POLÍTICAS RLS CORRECTAS

-- Política para SELECT: Los usuarios pueden ver su propio perfil
CREATE POLICY "Users can view their own profile" 
ON public.users
FOR SELECT 
TO authenticated
USING (auth.uid() = id OR role = 'admin');

-- Política para INSERT: Permitir registro público
CREATE POLICY "Anyone can create account" 
ON public.users
FOR INSERT 
TO public
WITH CHECK (true);

-- Política para UPDATE: Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update their own profile" 
ON public.users
FOR UPDATE 
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 5. CREAR FUNCIÓN Y TRIGGER PARA UPDATED_AT
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON public.users;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 6. VERIFICAR COLUMNAS EXISTENTES Y AJUSTAR
DO $$
DECLARE
    has_password_hash BOOLEAN;
BEGIN
    -- Verificar si la columna password_hash existe
    SELECT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'password_hash'
    ) INTO has_password_hash;
    
    IF has_password_hash THEN
        RAISE NOTICE 'Tabla users tiene columna password_hash';
        
        -- Hacer password_hash nullable si no lo es
        ALTER TABLE public.users ALTER COLUMN password_hash DROP NOT NULL;
        RAISE NOTICE 'Columna password_hash ahora permite NULL';
    END IF;
END;
$$;

-- 7. SINCRONIZAR USUARIO ADMIN
DO $$
DECLARE
    admin_exists BOOLEAN;
    has_password_hash BOOLEAN;
BEGIN
    -- Verificar si admin existe en auth.users
    SELECT EXISTS (
        SELECT 1 FROM auth.users WHERE email = 'admin@smartdinner.com'
    ) INTO admin_exists;
    
    -- Verificar si password_hash existe
    SELECT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'password_hash'
    ) INTO has_password_hash;
    
    IF NOT admin_exists THEN
        RAISE NOTICE 'Usuario admin NO existe en auth.users';
        RAISE NOTICE 'Debes crearlo manualmente en Authentication > Users';
    ELSE
        RAISE NOTICE 'Usuario admin YA existe en auth.users';
        
        -- Actualizar o insertar usuario admin (UPSERT por email)
        IF has_password_hash THEN
            -- Con password_hash
            INSERT INTO public.users (id, email, name, phone, role, is_active, email_verified, password_hash)
            VALUES (
                (SELECT id FROM auth.users WHERE email = 'admin@smartdinner.com'),
                'admin@smartdinner.com',
                'Admin SmartDinner',
                '809-555-0001',
                'admin',
                true,
                true,
                NULL
            )
            ON CONFLICT (email) DO UPDATE SET
                role = 'admin',
                email_verified = true,
                is_active = true,
                name = 'Admin SmartDinner',
                phone = '809-555-0001',
                password_hash = NULL,
                updated_at = now();
        ELSE
            -- Sin password_hash
            INSERT INTO public.users (id, email, name, phone, role, is_active, email_verified)
            VALUES (
                (SELECT id FROM auth.users WHERE email = 'admin@smartdinner.com'),
                'admin@smartdinner.com',
                'Admin SmartDinner',
                '809-555-0001',
                'admin',
                true,
                true
            )
            ON CONFLICT (email) DO UPDATE SET
                role = 'admin',
                email_verified = true,
                is_active = true,
                name = 'Admin SmartDinner',
                phone = '809-555-0001',
                updated_at = now();
        END IF;
            
        RAISE NOTICE 'Usuario admin sincronizado en public.users';
    END IF;
END;
$$;

-- 8. VERIFICAR CONFIGURACIÓN FINAL
SELECT 
    'Tabla users' as item,
    COUNT(*) as total
FROM public.users
UNION ALL
SELECT 
    'Usuarios admin',
    COUNT(*)
FROM public.users
WHERE role = 'admin';

-- 9. MOSTRAR POLÍTICAS ACTIVAS
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'users';

-- ============================================
-- INSTRUCCIONES ADICIONALES
-- ============================================
-- 
-- Si el usuario admin NO existe, créalo así:
-- 
-- 1. Ve a Authentication > Users en Supabase Dashboard
-- 2. Click en "Add user"
-- 3. Completa:
--    - Email: admin@smartdinner.com
--    - Password: 123456
--    - Auto Confirm User: ✓ ACTIVADO
-- 4. Click "Create User"
-- 5. Vuelve a ejecutar este script para sincronizar
--
-- ============================================
