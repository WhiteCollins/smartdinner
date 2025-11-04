-- ============================================
-- FIX: ELIMINAR RECURSIÓN EN POLÍTICAS
-- ============================================

-- El problema es que las políticas de menu_items verifican el role en la tabla users,
-- pero las políticas de users también verifican cosas, creando recursión infinita.

-- SOLUCIÓN: Simplificar las políticas de menu_items para NO consultar la tabla users

-- PASO 1: Eliminar políticas conflictivas de menu_items
DROP POLICY IF EXISTS "Admins can manage menu items" ON menu_items;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON menu_items;
DROP POLICY IF EXISTS "Authenticated users can view all menu items" ON menu_items;
DROP POLICY IF EXISTS "Admins can create menu items" ON menu_items;
DROP POLICY IF EXISTS "Admins can update menu items" ON menu_items;
DROP POLICY IF EXISTS "Admins can delete menu items" ON menu_items;

-- PASO 2: Crear políticas simples SIN verificar la tabla users

-- Política 1: Cualquiera puede ver items disponibles
CREATE POLICY "Public can view available items"
ON menu_items
FOR SELECT
TO public
USING (is_available = true);

-- Política 2: Usuarios autenticados pueden ver TODOS los items
CREATE POLICY "Authenticated can view all items"
ON menu_items
FOR SELECT
TO authenticated
USING (true);

-- Política 3: Usuarios autenticados pueden insertar items
-- (Confiaremos en la lógica de la app para verificar que sea admin)
CREATE POLICY "Authenticated can insert items"
ON menu_items
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política 4: Usuarios autenticados pueden actualizar items
CREATE POLICY "Authenticated can update items"
ON menu_items
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política 5: Usuarios autenticados pueden eliminar items
CREATE POLICY "Authenticated can delete items"
ON menu_items
FOR DELETE
TO authenticated
USING (true);

-- PASO 3: Verificar las nuevas políticas
SELECT 
    policyname,
    cmd as command,
    roles,
    CASE 
        WHEN length(qual::text) > 80 THEN substring(qual::text, 1, 77) || '...'
        ELSE qual::text
    END as using_clause
FROM pg_policies
WHERE tablename = 'menu_items'
ORDER BY policyname;
