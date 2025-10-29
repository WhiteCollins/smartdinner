const BaseService = require('./baseService');
const { v4: uuidv4 } = require('uuid');

class InventoryService extends BaseService {
  constructor() {
    super('inventory');
  }

  /**
   * Obtener inventario completo
   */
  async getAllInventory() {
    try {
      const { data, error } = await this.supabase
        .from('inventory')
        .select(`
          *,
          menu_items(name, category)
        `)
        .order('name', { ascending: true });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting all inventory:', error);
      throw error;
    }
  }

  /**
   * Obtener items con stock bajo
   */
  async getLowStockItems(threshold = 10) {
    try {
      const { data, error } = await this.supabase
        .from('inventory')
        .select(`
          *,
          menu_items(name, category)
        `)
        .lte('quantity', threshold)
        .order('quantity', { ascending: true });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting low stock items:', error);
      throw error;
    }
  }

  /**
   * Obtener items fuera de stock
   */
  async getOutOfStockItems() {
    try {
      const { data, error } = await this.supabase
        .from('inventory')
        .select(`
          *,
          menu_items(name, category)
        `)
        .eq('quantity', 0)
        .order('name', { ascending: true });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting out of stock items:', error);
      throw error;
    }
  }

  /**
   * Actualizar cantidad de inventario
   */
  async updateQuantity(itemId, quantity, type = 'set') {
    try {
      let newQuantity = quantity;

      if (type === 'add') {
        const currentItem = await this.findById(itemId);
        newQuantity = currentItem.quantity + quantity;
      } else if (type === 'subtract') {
        const currentItem = await this.findById(itemId);
        newQuantity = currentItem.quantity - quantity;
        if (newQuantity < 0) newQuantity = 0;
      }

      return await this.update(itemId, {
        quantity: newQuantity,
        last_updated: new Date().toISOString()
      });
    } catch (error) {
      console.error('Error updating inventory quantity:', error);
      throw error;
    }
  }

  /**
   * Registrar movimiento de inventario
   */
  async recordMovement(movementData) {
    try {
      const { item_id, quantity, type, reason, user_id } = movementData;

      // Validar datos requeridos
      if (!item_id || !quantity || !type) {
        throw new Error('item_id, quantity y type son requeridos');
      }

      // Crear registro de movimiento
      const movement = {
        id: uuidv4(),
        item_id,
        quantity,
        type, // 'in' (entrada) o 'out' (salida)
        reason: reason || null,
        user_id: user_id || null,
        created_at: new Date().toISOString()
      };

      const { data, error } = await this.supabase
        .from('inventory_movements')
        .insert(movement)
        .select()
        .single();

      if (error) throw error;

      // Actualizar inventario según el tipo de movimiento
      if (type === 'in') {
        await this.updateQuantity(item_id, quantity, 'add');
      } else if (type === 'out') {
        await this.updateQuantity(item_id, quantity, 'subtract');
      }

      return data;
    } catch (error) {
      console.error('Error recording inventory movement:', error);
      throw error;
    }
  }

  /**
   * Obtener historial de movimientos de un item
   */
  async getMovementHistory(itemId, limit = 50) {
    try {
      const { data, error } = await this.supabase
        .from('inventory_movements')
        .select(`
          *,
          users(name, email)
        `)
        .eq('item_id', itemId)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting movement history:', error);
      throw error;
    }
  }

  /**
   * Crear item de inventario
   */
  async createInventoryItem(itemData) {
    try {
      const { name, menu_item_id, quantity, unit, min_quantity, cost_per_unit } = itemData;

      if (!name) {
        throw new Error('Campo "name" es requerido');
      }

      const newItem = {
        id: uuidv4(),
        name,
        menu_item_id: menu_item_id || null,
        quantity: quantity || 0,
        unit: unit || 'unidad',
        min_quantity: min_quantity || 10,
        cost_per_unit: cost_per_unit || 0,
        last_updated: new Date().toISOString(),
        created_at: new Date().toISOString()
      };

      return await this.create(newItem);
    } catch (error) {
      console.error('Error creating inventory item:', error);
      throw error;
    }
  }

  /**
   * Generar orden de compra para items con stock bajo
   */
  async generatePurchaseOrder(threshold = 10) {
    try {
      const lowStockItems = await this.getLowStockItems(threshold);

      const purchaseOrder = {
        id: uuidv4(),
        items: lowStockItems.map(item => ({
          item_id: item.id,
          name: item.name,
          current_quantity: item.quantity,
          min_quantity: item.min_quantity,
          suggested_order: Math.max(item.min_quantity * 2 - item.quantity, 0),
          cost_per_unit: item.cost_per_unit,
          unit: item.unit
        })),
        total_items: lowStockItems.length,
        estimated_cost: lowStockItems.reduce(
          (sum, item) => sum + (item.cost_per_unit * Math.max(item.min_quantity * 2 - item.quantity, 0)),
          0
        ),
        created_at: new Date().toISOString()
      };

      return purchaseOrder;
    } catch (error) {
      console.error('Error generating purchase order:', error);
      throw error;
    }
  }

  /**
   * Obtener estadísticas de inventario
   */
  async getInventoryStats() {
    try {
      const allItems = await this.getAllInventory();

      const stats = {
        totalItems: allItems.length,
        lowStockItems: allItems.filter(item => item.quantity <= item.min_quantity).length,
        outOfStockItems: allItems.filter(item => item.quantity === 0).length,
        totalValue: allItems.reduce((sum, item) => sum + (item.quantity * item.cost_per_unit), 0),
        itemsByCategory: {}
      };

      // Agrupar por categoría si hay menu_items asociados
      allItems.forEach(item => {
        if (item.menu_items && item.menu_items.category) {
          const category = item.menu_items.category;
          if (!stats.itemsByCategory[category]) {
            stats.itemsByCategory[category] = 0;
          }
          stats.itemsByCategory[category]++;
        }
      });

      return stats;
    } catch (error) {
      console.error('Error getting inventory stats:', error);
      throw error;
    }
  }
}

module.exports = new InventoryService();
