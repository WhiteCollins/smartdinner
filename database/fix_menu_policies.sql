-- ============================================
-- LIMPIAR Y RECREAR POLÍTICAS DE menu_items
-- ============================================

-- PASO 1: Eliminar políticas existentes que pueden estar causando conflicto
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON menu_items;
DROP POLICY IF EXISTS "Authenticated users can view all menu items" ON menu_items;
DROP POLICY IF EXISTS "Admins can create menu items" ON menu_items;
DROP POLICY IF EXISTS "Admins can update menu items" ON menu_items;
DROP POLICY IF EXISTS "Admins can delete menu items" ON menu_items;

-- PASO 2: Mantener solo las políticas necesarias

-- Política 1: Todos pueden ver items disponibles (YA EXISTE, NO TOCAR)
-- "Anyone can view available menu items" - SELECT para public

-- Política 2: Admins/Staff pueden hacer TODO (YA EXISTE, VERIFICAR)
-- "Admins can manage menu items" - ALL para admin/staff

-- PASO 3: Verificar políticas finales
SELECT 
    policyname,
    cmd as command,
    roles,
    CASE 
        WHEN qual IS NOT NULL THEN 'USING: ' || qual
        ELSE 'No USING clause'
    END as using_clause,
    CASE 
        WHEN with_check IS NOT NULL THEN 'WITH CHECK: ' || with_check
        ELSE 'No WITH CHECK clause'
    END as check_clause
FROM pg_policies
WHERE tablename = 'menu_items'
ORDER BY policyname;
