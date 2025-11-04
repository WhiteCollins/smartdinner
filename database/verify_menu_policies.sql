-- ============================================
-- VERIFICAR POLÍTICAS ACTUALES DE menu_items
-- ============================================

-- 1. Ver todas las políticas existentes
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as command,
    roles,
    qual as using_expression,
    with_check
FROM pg_policies
WHERE tablename = 'menu_items'
ORDER BY policyname;

-- 2. Verificar si RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'menu_items';

-- 3. Probar SELECT como usuario autenticado
-- (Esto debería funcionar si las políticas están bien configuradas)
SELECT COUNT(*) as total_items FROM menu_items;
