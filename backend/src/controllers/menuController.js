const menuService = require('../services/menuService');

class MenuController {
  /**
   * GET /api/menu
   * Obtener todos los items del menú
   */
  async getAll(req, res) {
    try {
      const { category, available } = req.query;
      
      const filters = {};
      if (category) filters.category = category;
      if (available !== undefined) filters.available = available === 'true';

      const items = await menuService.findAll(filters, { orderBy: 'name' });
      
      res.json({
        success: true,
        data: items,
        count: items.length
      });
    } catch (error) {
      console.error('Error in getAll menu items:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/menu/:id
   * Obtener item por ID
   */
  async getById(req, res) {
    try {
      const { id } = req.params;
      const item = await menuService.findById(id);

      if (!item) {
        return res.status(404).json({
          success: false,
          error: 'Item no encontrado'
        });
      }

      res.json({
        success: true,
        data: item
      });
    } catch (error) {
      console.error('Error in getById menu item:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/menu/category/:category
   * Obtener items por categoría
   */
  async getByCategory(req, res) {
    try {
      const { category } = req.params;
      const items = await menuService.findByCategory(category);

      res.json({
        success: true,
        data: items,
        count: items.length
      });
    } catch (error) {
      console.error('Error in getByCategory:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/menu/search/:term
   * Buscar items por nombre
   */
  async search(req, res) {
    try {
      const { term } = req.params;
      const items = await menuService.searchByName(term);

      res.json({
        success: true,
        data: items,
        count: items.length
      });
    } catch (error) {
      console.error('Error in search menu items:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/menu/categories
   * Obtener todas las categorías
   */
  async getCategories(req, res) {
    try {
      const categories = await menuService.getCategories();

      res.json({
        success: true,
        data: categories
      });
    } catch (error) {
      console.error('Error in getCategories:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/menu/popular
   * Obtener items populares
   */
  async getPopular(req, res) {
    try {
      const { limit = 10 } = req.query;
      const items = await menuService.getPopularItems(parseInt(limit));

      res.json({
        success: true,
        data: items
      });
    } catch (error) {
      console.error('Error in getPopular:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * POST /api/menu
   * Crear nuevo item
   */
  async create(req, res) {
    try {
      const itemData = req.body;
      const newItem = await menuService.createMenuItem(itemData);

      res.status(201).json({
        success: true,
        data: newItem,
        message: 'Item creado exitosamente'
      });
    } catch (error) {
      console.error('Error in create menu item:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PUT /api/menu/:id
   * Actualizar item
   */
  async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const updatedItem = await menuService.update(id, updateData);

      res.json({
        success: true,
        data: updatedItem,
        message: 'Item actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error in update menu item:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PATCH /api/menu/:id/availability
   * Actualizar disponibilidad
   */
  async updateAvailability(req, res) {
    try {
      const { id } = req.params;
      const { available } = req.body;

      if (available === undefined) {
        return res.status(400).json({
          success: false,
          error: 'Campo "available" es requerido'
        });
      }

      const updatedItem = await menuService.updateAvailability(id, available);

      res.json({
        success: true,
        data: updatedItem,
        message: 'Disponibilidad actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error in updateAvailability:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PATCH /api/menu/:id/price
   * Actualizar precio
   */
  async updatePrice(req, res) {
    try {
      const { id } = req.params;
      const { price } = req.body;

      if (!price) {
        return res.status(400).json({
          success: false,
          error: 'Campo "price" es requerido'
        });
      }

      const updatedItem = await menuService.updatePrice(id, price);

      res.json({
        success: true,
        data: updatedItem,
        message: 'Precio actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error in updatePrice:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/menu/:id
   * Eliminar item
   */
  async delete(req, res) {
    try {
      const { id } = req.params;
      const { soft = true } = req.query;

      await menuService.delete(id, soft === 'true');

      res.json({
        success: true,
        message: 'Item eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error in delete menu item:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = new MenuController();
