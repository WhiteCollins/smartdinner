-- ============================================
-- VERIFICAR POLÍTICAS DE LA TABLA users
-- ============================================

-- Ver todas las políticas de la tabla users
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as command,
    roles,
    qual as using_expression,
    with_check
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

-- Verificar si RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'users';
