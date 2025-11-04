-- ============================================
-- DATOS DE PRUEBA SIMPLIFICADOS - SMARTDINNER
-- Ejecuta esto en Supabase SQL Editor
-- ============================================

-- 1. INSERTAR ITEMS DEL MENÚ (20 items)
INSERT INTO menu_items (name, description, price, category, is_available, preparation_time, is_vegetarian, calories) VALUES
    -- Entradas
    ('Ensalada César', 'Lechuga romana, crutones, queso parmesano y aderezo césar', 8.99, 'entradas', true, 10, true, 250),
    ('Alitas Buffalo', '10 piezas de alitas con salsa picante y aderezo ranch', 12.99, 'entradas', true, 15, false, 450),
    ('Nachos Supreme', 'Nachos con queso, guacamole, crema agria y jalapeños', 10.99, 'entradas', true, 12, true, 550),
    ('Sopa del Día', 'Consulta con el mesero por la sopa especial', 6.99, 'entradas', true, 8, true, 180),
    
    -- Platos Principales
    ('Hamburguesa Clásica', 'Carne de res, lechuga, tomate, queso y papas fritas', 14.99, 'principales', true, 20, false, 850),
    ('Pollo a la Parrilla', 'Pechuga de pollo con vegetales asados y arroz', 16.99, 'principales', true, 25, false, 650),
    ('Pasta Alfredo', 'Fettuccine en salsa cremosa de queso parmesano', 13.99, 'principales', true, 18, true, 720),
    ('Churrasco Premium', 'Corte de res premium con chimichurri y papas', 24.99, 'principales', true, 30, false, 950),
    ('Salmón a la Plancha', 'Filete de salmón con vegetales al vapor', 19.99, 'principales', true, 22, false, 580),
    ('Pizza Margarita', 'Salsa de tomate, mozzarella fresca y albahaca', 11.99, 'principales', true, 15, true, 650),
    
    -- Postres
    ('Cheesecake', 'Pastel de queso con topping de fresas', 7.99, 'postres', true, 5, true, 420),
    ('Brownie con Helado', 'Brownie de chocolate caliente con helado de vainilla', 6.99, 'postres', true, 8, true, 550),
    ('Tiramisú', 'Postre italiano con café y mascarpone', 8.99, 'postres', true, 5, true, 380),
    ('Flan de Coco', 'Flan casero con coco rallado', 5.99, 'postres', true, 5, true, 280),
    
    -- Bebidas
    ('Coca Cola', 'Refresco cola 16oz', 2.99, 'bebidas', true, 2, true, 140),
    ('Jugo Natural', 'Jugo de naranja, piña o chinola', 4.99, 'bebidas', true, 3, true, 120),
    ('Agua Mineral', 'Agua embotellada 500ml', 1.99, 'bebidas', true, 1, true, 0),
    ('Café Americano', 'Café recién preparado', 2.99, 'bebidas', true, 5, true, 5),
    ('Té Helado', 'Té negro con limón y hielo', 3.99, 'bebidas', true, 3, true, 90),
    ('Batido de Fresa', 'Batido cremoso de fresa con leche', 5.99, 'bebidas', true, 5, true, 320);

-- 2. VERIFICAR DATOS CREADOS
SELECT 
    category,
    COUNT(*) as total_items,
    ROUND(AVG(price), 2) as precio_promedio
FROM menu_items
GROUP BY category
ORDER BY category;

-- Deberías ver:
-- bebidas      | 6  | ~3.66
-- entradas     | 4  | ~9.74
-- postres      | 4  | ~7.49
-- principales  | 6  | ~17.08
