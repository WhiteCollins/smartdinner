-- ============================================
-- OPCIÓN A: RECREAR TABLA CON FOREIGN KEY
-- ⚠️ ADVERTENCIA: Esto BORRARÁ todos los usuarios
-- ============================================

-- 1. Respaldar datos existentes (opcional)
CREATE TEMP TABLE users_backup AS 
SELECT * FROM public.users;

-- 2. Eliminar tabla existente
DROP TABLE IF EXISTS public.users CASCADE;

-- 3. Crear tabla correctamente con FK a auth.users
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    phone VARCHAR,
    password_hash TEXT,
    role VARCHAR NOT NULL DEFAULT 'customer' CHECK (role IN ('admin', 'customer', 'staff')),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Habilitar RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 5. Crear políticas RLS
CREATE POLICY "Users can view their own profile" 
ON public.users
FOR SELECT 
TO authenticated
USING (auth.uid() = id OR role = 'admin');

CREATE POLICY "Anyone can create account" 
ON public.users
FOR INSERT 
TO public
WITH CHECK (true);

CREATE POLICY "Users can update their own profile" 
ON public.users
FOR UPDATE 
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 6. Crear trigger para updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 7. Insertar usuario admin desde auth.users
INSERT INTO public.users (id, email, name, phone, role, is_active, email_verified)
SELECT 
    id,
    email,
    'Admin SmartDinner',
    '809-555-0001',
    'admin',
    true,
    true
FROM auth.users
WHERE email = 'admin@smartdinner.com';

-- 8. Verificar
SELECT 
    u.id as public_id,
    a.id as auth_id,
    u.email,
    u.role,
    u.is_active,
    CASE 
        WHEN u.id = a.id THEN '✅ IDs coinciden'
        ELSE '❌ IDs NO coinciden'
    END as sincronizacion
FROM public.users u
JOIN auth.users a ON u.email = a.email
WHERE u.email = 'admin@smartdinner.com';
