const orderService = require('../services/orderService');

class OrderController {
  /**
   * GET /api/orders
   * Obtener todas las órdenes
   */
  async getAll(req, res) {
    try {
      const { user_id, status, limit } = req.query;
      
      let orders;

      if (user_id) {
        orders = await orderService.findByUser(user_id, { limit: limit ? parseInt(limit) : 50 });
      } else if (status) {
        orders = await orderService.findByStatus(status);
      } else {
        orders = await orderService.findAll({}, { 
          orderBy: 'created_at', 
          ascending: false,
          limit: limit ? parseInt(limit) : 100
        });
      }
      
      res.json({
        success: true,
        data: orders,
        count: orders.length
      });
    } catch (error) {
      console.error('Error in getAll orders:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/orders/:id
   * Obtener orden por ID con items
   */
  async getById(req, res) {
    try {
      const { id } = req.params;
      const order = await orderService.findByIdWithItems(id);

      if (!order) {
        return res.status(404).json({
          success: false,
          error: 'Orden no encontrada'
        });
      }

      res.json({
        success: true,
        data: order
      });
    } catch (error) {
      console.error('Error in getById order:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/orders/user/:userId
   * Obtener órdenes de un usuario
   */
  async getByUser(req, res) {
    try {
      const { userId } = req.params;
      const { limit } = req.query;
      
      const orders = await orderService.findByUser(userId, { 
        limit: limit ? parseInt(limit) : 50 
      });

      res.json({
        success: true,
        data: orders,
        count: orders.length
      });
    } catch (error) {
      console.error('Error in getByUser orders:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/orders/status/:status
   * Obtener órdenes por estado
   */
  async getByStatus(req, res) {
    try {
      const { status } = req.params;
      const orders = await orderService.findByStatus(status);

      res.json({
        success: true,
        data: orders,
        count: orders.length
      });
    } catch (error) {
      console.error('Error in getByStatus:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/orders/active
   * Obtener órdenes activas
   */
  async getActive(req, res) {
    try {
      const orders = await orderService.getActiveOrders();

      res.json({
        success: true,
        data: orders,
        count: orders.length
      });
    } catch (error) {
      console.error('Error in getActive:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * POST /api/orders
   * Crear nueva orden
   */
  async create(req, res) {
    try {
      const orderData = req.body;
      const newOrder = await orderService.createOrder(orderData);

      res.status(201).json({
        success: true,
        data: newOrder,
        message: 'Orden creada exitosamente'
      });
    } catch (error) {
      console.error('Error in create order:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PUT /api/orders/:id
   * Actualizar orden
   */
  async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const updatedOrder = await orderService.update(id, updateData);

      res.json({
        success: true,
        data: updatedOrder,
        message: 'Orden actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error in update order:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PATCH /api/orders/:id/status
   * Actualizar estado de orden
   */
  async updateStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!status) {
        return res.status(400).json({
          success: false,
          error: 'Campo "status" es requerido'
        });
      }

      const updatedOrder = await orderService.updateStatus(id, status);

      res.json({
        success: true,
        data: updatedOrder,
        message: 'Estado actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error in updateStatus:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * POST /api/orders/:id/cancel
   * Cancelar orden
   */
  async cancel(req, res) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;
      
      const updatedOrder = await orderService.cancelOrder(id, user_id);

      res.json({
        success: true,
        data: updatedOrder,
        message: 'Orden cancelada exitosamente'
      });
    } catch (error) {
      console.error('Error in cancel order:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/orders/:id
   * Eliminar orden
   */
  async delete(req, res) {
    try {
      const { id } = req.params;
      const { soft = true } = req.query;

      await orderService.delete(id, soft === 'true');

      res.json({
        success: true,
        message: 'Orden eliminada exitosamente'
      });
    } catch (error) {
      console.error('Error in delete order:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/orders/stats
   * Obtener estadísticas de órdenes
   */
  async getStats(req, res) {
    try {
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          error: 'startDate y endDate son requeridos'
        });
      }

      const stats = await orderService.getStats(startDate, endDate);

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
   * GET /api/orders/top-selling
   * Obtener items más vendidos
   */
  async getTopSelling(req, res) {
    try {
      const { limit = 10 } = req.query;
      const topItems = await orderService.getTopSellingItems(parseInt(limit));

      res.json({
        success: true,
        data: topItems
      });
    } catch (error) {
      console.error('Error in getTopSelling:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = new OrderController();
