-- ============================================
-- POLÍTICAS RLS PARA menu_items
-- ============================================

-- 1. Habilitar RLS en la tabla
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;

-- 2. Permitir a TODOS ver items disponibles (para clientes)
CREATE POLICY "Anyone can view available menu items"
ON menu_items
FOR SELECT
TO public
USING (is_available = true);

-- 3. Permitir a usuarios autenticados ver todos los items
CREATE POLICY "Authenticated users can view all menu items"
ON menu_items
FOR SELECT
TO authenticated
USING (true);

-- 4. Permitir a ADMINS crear items
CREATE POLICY "Admins can create menu items"
ON menu_items
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- 5. Permitir a ADMINS actualizar items
CREATE POLICY "Admins can update menu items"
ON menu_items
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- 6. Permitir a ADMINS eliminar items
CREATE POLICY "Admins can delete menu items"
ON menu_items
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- ============================================
-- VERIFICACIÓN
-- ============================================
-- Ejecuta esto para verificar las políticas creadas:
SELECT schemaname, tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'menu_items';
