-- Script SQL adicional para Inventario
-- Ejecutar esto después del schema principal en Supabase

-- Tabla de inventario
CREATE TABLE IF NOT EXISTS inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  menu_item_id UUID REFERENCES menu_items(id) ON DELETE SET NULL,
  quantity DECIMAL(10,2) DEFAULT 0,
  unit TEXT DEFAULT 'unidad',
  min_quantity DECIMAL(10,2) DEFAULT 10,
  cost_per_unit DECIMAL(10,2) DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Tabla de movimientos de inventario
CREATE TABLE IF NOT EXISTS inventory_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID REFERENCES inventory(id) ON DELETE CASCADE,
  quantity DECIMAL(10,2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('in', 'out', 'adjustment')),
  reason TEXT,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_inventory_menu_item ON inventory(menu_item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_quantity ON inventory(quantity);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_item ON inventory_movements(item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_date ON inventory_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_type ON inventory_movements(type);

-- Trigger para actualizar updated_at en inventory
CREATE OR REPLACE FUNCTION update_inventory_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_inventory_updated_at
  BEFORE UPDATE ON inventory
  FOR EACH ROW
  EXECUTE FUNCTION update_inventory_updated_at();

-- Trigger para actualizar last_updated cuando cambia la cantidad
CREATE OR REPLACE FUNCTION update_inventory_last_updated()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.quantity != OLD.quantity THEN
    NEW.last_updated = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_inventory_last_updated
  BEFORE UPDATE ON inventory
  FOR EACH ROW
  EXECUTE FUNCTION update_inventory_last_updated();

-- Habilitar Row Level Security
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para inventory
CREATE POLICY "Anyone can view inventory" 
  ON inventory FOR SELECT 
  USING (true);

CREATE POLICY "Authenticated users can create inventory" 
  ON inventory FOR INSERT 
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update inventory" 
  ON inventory FOR UPDATE 
  USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can delete inventory" 
  ON inventory FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Políticas RLS para inventory_movements
CREATE POLICY "Anyone can view movements" 
  ON inventory_movements FOR SELECT 
  USING (true);

CREATE POLICY "Authenticated users can create movements" 
  ON inventory_movements FOR INSERT 
  WITH CHECK (auth.role() = 'authenticated');

-- Función para obtener items con stock bajo
CREATE OR REPLACE FUNCTION get_low_stock_items(threshold INTEGER DEFAULT 10)
RETURNS TABLE (
  id UUID,
  name TEXT,
  quantity DECIMAL,
  min_quantity DECIMAL,
  unit TEXT,
  cost_per_unit DECIMAL,
  last_updated TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.id,
    i.name,
    i.quantity,
    i.min_quantity,
    i.unit,
    i.cost_per_unit,
    i.last_updated
  FROM inventory i
  WHERE i.quantity <= threshold
    AND i.deleted_at IS NULL
  ORDER BY i.quantity ASC;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener valor total del inventario
CREATE OR REPLACE FUNCTION get_inventory_total_value()
RETURNS DECIMAL AS $$
DECLARE
  total_value DECIMAL;
BEGIN
  SELECT COALESCE(SUM(quantity * cost_per_unit), 0)
  INTO total_value
  FROM inventory
  WHERE deleted_at IS NULL;
  
  RETURN total_value;
END;
$$ LANGUAGE plpgsql;

-- Insertar datos de ejemplo (opcional)
INSERT INTO inventory (name, quantity, unit, min_quantity, cost_per_unit) VALUES
  ('Tomates', 50, 'kg', 20, 2.50),
  ('Lechuga', 30, 'unidades', 15, 1.80),
  ('Pollo', 40, 'kg', 25, 8.50),
  ('Arroz', 100, 'kg', 50, 1.20),
  ('Aceite de Oliva', 20, 'litros', 10, 12.00),
  ('Sal', 50, 'kg', 20, 0.50),
  ('Pasta', 80, 'kg', 40, 1.50),
  ('Queso', 25, 'kg', 15, 15.00),
  ('Carne de Res', 30, 'kg', 20, 12.00),
  ('Papas', 60, 'kg', 30, 1.80)
ON CONFLICT DO NOTHING;

-- Comentarios para documentación
COMMENT ON TABLE inventory IS 'Tabla para gestión de inventario del restaurante';
COMMENT ON TABLE inventory_movements IS 'Registro de movimientos de inventario (entradas/salidas)';
COMMENT ON COLUMN inventory.quantity IS 'Cantidad actual en stock';
COMMENT ON COLUMN inventory.min_quantity IS 'Cantidad mínima requerida (alerta de stock bajo)';
COMMENT ON COLUMN inventory.cost_per_unit IS 'Costo por unidad para cálculo de valor de inventario';
COMMENT ON COLUMN inventory_movements.type IS 'Tipo de movimiento: in (entrada), out (salida), adjustment (ajuste)';
