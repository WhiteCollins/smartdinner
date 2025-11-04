const BaseService = require('./baseService');

class MenuService extends BaseService {
  constructor() {
    super('menu_items');
  }

  /**
   * Obtener items del menú por categoría
   */
  async findByCategory(category) {
    try {
      return await this.findAll({ category, available: true });
    } catch (error) {
      console.error('Error finding menu items by category:', error);
      throw error;
    }
  }

  /**
   * Obtener items disponibles
   */
  async findAvailable() {
    try {
      return await this.findAll({ available: true }, { orderBy: 'name' });
    } catch (error) {
      console.error('Error finding available menu items:', error);
      throw error;
    }
  }

  /**
   * Buscar items por nombre
   */
  async searchByName(searchTerm) {
    try {
      const { data, error } = await this.supabase
        .from('menu_items')
        .select('*')
        .ilike('name', `%${searchTerm}%`)
        .eq('available', true);

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error searching menu items:', error);
      throw error;
    }
  }

  /**
   * Actualizar disponibilidad de un item
   */
  async updateAvailability(itemId, available) {
    try {
      return await this.update(itemId, { available });
    } catch (error) {
      console.error('Error updating item availability:', error);
      throw error;
    }
  }

  /**
   * Actualizar precio de un item
   */
  async updatePrice(itemId, price) {
    try {
      return await this.update(itemId, { price });
    } catch (error) {
      console.error('Error updating item price:', error);
      throw error;
    }
  }

  /**
   * Obtener categorías disponibles
   */
  async getCategories() {
    try {
      const { data, error } = await this.supabase
        .from('menu_items')
        .select('category')
        .eq('available', true);

      if (error) throw error;

      // Obtener categorías únicas
      const categories = [...new Set(data.map(item => item.category))];
      return categories;
    } catch (error) {
      console.error('Error getting categories:', error);
      throw error;
    }
  }

  /**
   * Obtener items populares (los más ordenados)
   */
  async getPopularItems(limit = 10) {
    try {
      const { data, error } = await this.supabase
        .from('menu_items')
        .select(`
          *,
          order_items(count)
        `)
        .eq('available', true)
        .order('order_items(count)', { ascending: false })
        .limit(limit);

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting popular items:', error);
      throw error;
    }
  }

  /**
   * Crear item del menú con validación
   */
  async createMenuItem(itemData) {
    try {
      // Validar datos requeridos
      const requiredFields = ['name', 'category', 'price'];
      for (const field of requiredFields) {
        if (!itemData[field]) {
          throw new Error(`Campo requerido: ${field}`);
        }
      }

      // Validar precio
      if (itemData.price <= 0) {
        throw new Error('El precio debe ser mayor a 0');
      }

      return await this.create(itemData);
    } catch (error) {
      console.error('Error creating menu item:', error);
      throw error;
    }
  }
}

module.exports = new MenuService();
