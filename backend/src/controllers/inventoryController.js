const inventoryService = require('../services/inventoryService');

class InventoryController {
  /**
   * GET /api/inventory
   * Obtener todo el inventario
   */
  async getAll(req, res) {
    try {
      const inventory = await inventoryService.getAllInventory();
      
      res.json({
        success: true,
        data: inventory,
        count: inventory.length
      });
    } catch (error) {
      console.error('Error in getAll inventory:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/inventory/:id
   * Obtener item por ID
   */
  async getById(req, res) {
    try {
      const { id } = req.params;
      const item = await inventoryService.findById(id);

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
      console.error('Error in getById inventory:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/inventory/low-stock
   * Obtener items con stock bajo
   */
  async getLowStock(req, res) {
    try {
      const { threshold = 10 } = req.query;
      const items = await inventoryService.getLowStockItems(parseInt(threshold));

      res.json({
        success: true,
        data: items,
        count: items.length
      });
    } catch (error) {
      console.error('Error in getLowStock:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/inventory/out-of-stock
   * Obtener items fuera de stock
   */
  async getOutOfStock(req, res) {
    try {
      const items = await inventoryService.getOutOfStockItems();

      res.json({
        success: true,
        data: items,
        count: items.length
      });
    } catch (error) {
      console.error('Error in getOutOfStock:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * POST /api/inventory
   * Crear nuevo item de inventario
   */
  async create(req, res) {
    try {
      const itemData = req.body;
      const newItem = await inventoryService.createInventoryItem(itemData);

      res.status(201).json({
        success: true,
        data: newItem,
        message: 'Item de inventario creado exitosamente'
      });
    } catch (error) {
      console.error('Error in create inventory item:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PUT /api/inventory/:id
   * Actualizar item
   */
  async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const updatedItem = await inventoryService.update(id, updateData);

      res.json({
        success: true,
        data: updatedItem,
        message: 'Item actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error in update inventory item:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PATCH /api/inventory/:id/quantity
   * Actualizar cantidad
   */
  async updateQuantity(req, res) {
    try {
      const { id } = req.params;
      const { quantity, type = 'set' } = req.body;

      if (quantity === undefined) {
        return res.status(400).json({
          success: false,
          error: 'Campo "quantity" es requerido'
        });
      }

      const updatedItem = await inventoryService.updateQuantity(id, quantity, type);

      res.json({
        success: true,
        data: updatedItem,
        message: 'Cantidad actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error in updateQuantity:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * POST /api/inventory/movement
   * Registrar movimiento de inventario
   */
  async recordMovement(req, res) {
    try {
      const movementData = req.body;
      const movement = await inventoryService.recordMovement(movementData);

      res.status(201).json({
        success: true,
        data: movement,
        message: 'Movimiento registrado exitosamente'
      });
    } catch (error) {
      console.error('Error in recordMovement:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/inventory/:id/history
   * Obtener historial de movimientos
   */
  async getHistory(req, res) {
    try {
      const { id } = req.params;
      const { limit = 50 } = req.query;
      
      const history = await inventoryService.getMovementHistory(id, parseInt(limit));

      res.json({
        success: true,
        data: history,
        count: history.length
      });
    } catch (error) {
      console.error('Error in getHistory:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/inventory/purchase-order
   * Generar orden de compra
   */
  async generatePurchaseOrder(req, res) {
    try {
      const { threshold = 10 } = req.query;
      const purchaseOrder = await inventoryService.generatePurchaseOrder(parseInt(threshold));

      res.json({
        success: true,
        data: purchaseOrder
      });
    } catch (error) {
      console.error('Error in generatePurchaseOrder:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/inventory/stats
   * Obtener estadísticas
   */
  async getStats(req, res) {
    try {
      const stats = await inventoryService.getInventoryStats();

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Error in getStats:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/inventory/:id
   * Eliminar item
   */
  async delete(req, res) {
    try {
      const { id } = req.params;
      const { soft = true } = req.query;

      await inventoryService.delete(id, soft === 'true');

      res.json({
        success: true,
        message: 'Item eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error in delete inventory item:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = new InventoryController();
