-- ============================================
-- ESQUEMA DE TABLA MESAS (Tables) - SMARTDINNER
-- Ejecutar en SQL Editor de Supabase
-- ============================================

-- 1. CREAR TABLA MESAS
CREATE TABLE IF NOT EXISTS public.mesas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero INTEGER UNIQUE NOT NULL,
    capacidad INTEGER NOT NULL DEFAULT 4 CHECK (capacidad > 0 AND capacidad <= 20),
    estado TEXT NOT NULL DEFAULT 'disponible' CHECK (estado IN ('disponible', 'ocupada', 'reservada', 'mantenimiento')),
    ubicacion TEXT DEFAULT 'Interior' CHECK (ubicacion IN ('Interior', 'Terraza', 'Bar', 'VIP', 'Privado')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. HABILITAR RLS
ALTER TABLE public.mesas ENABLE ROW LEVEL SECURITY;

-- 3. ELIMINAR POLÍTICAS ANTIGUAS
DROP POLICY IF EXISTS "Allow read access to all users" ON public.mesas;
DROP POLICY IF EXISTS "Allow all access to admin" ON public.mesas;
DROP POLICY IF EXISTS "Allow staff to update status" ON public.mesas;

-- 4. CREAR POLÍTICAS RLS

-- Todos los usuarios autenticados pueden ver las mesas
CREATE POLICY "Allow read access to all users" 
ON public.mesas
FOR SELECT 
TO authenticated
USING (true);

-- Admin puede hacer cualquier operación
CREATE POLICY "Allow all access to admin" 
ON public.mesas
FOR ALL 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
    )
);

-- Staff puede actualizar el estado de las mesas
CREATE POLICY "Allow staff to update status" 
ON public.mesas
FOR UPDATE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() 
        AND users.role IN ('admin', 'staff')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() 
        AND users.role IN ('admin', 'staff')
    )
);

-- 5. TRIGGER PARA UPDATED_AT
DROP TRIGGER IF EXISTS set_mesas_updated_at ON public.mesas;
CREATE TRIGGER set_mesas_updated_at
    BEFORE UPDATE ON public.mesas
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 6. INSERTAR DATOS DE EJEMPLO
INSERT INTO public.mesas (numero, capacidad, estado, ubicacion) VALUES
    (1, 2, 'disponible', 'Interior'),
    (2, 2, 'ocupada', 'Interior'),
    (3, 4, 'disponible', 'Interior'),
    (4, 4, 'reservada', 'Interior'),
    (5, 6, 'ocupada', 'Interior'),
    (6, 6, 'disponible', 'Terraza'),
    (7, 4, 'disponible', 'Terraza'),
    (8, 8, 'disponible', 'Terraza'),
    (9, 10, 'reservada', 'VIP'),
    (10, 4, 'mantenimiento', 'Interior'),
    (11, 2, 'disponible', 'Bar'),
    (12, 2, 'disponible', 'Bar')
ON CONFLICT (numero) DO NOTHING;

-- 7. CREAR ÍNDICES PARA OPTIMIZACIÓN
CREATE INDEX IF NOT EXISTS idx_mesas_estado ON public.mesas(estado);
CREATE INDEX IF NOT EXISTS idx_mesas_ubicacion ON public.mesas(ubicacion);
CREATE INDEX IF NOT EXISTS idx_mesas_numero ON public.mesas(numero);

-- 8. VERIFICAR CREACIÓN
SELECT 
    numero, 
    capacidad, 
    estado, 
    ubicacion 
FROM public.mesas 
ORDER BY numero;
