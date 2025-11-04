const BaseService = require('./baseService');
const { v4: uuidv4 } = require('uuid');

class OrderService extends BaseService {
  constructor() {
    super('orders');
  }

  /**
   * Obtener órdenes de un usuario
   */
  async findByUser(userId, options = {}) {
    try {
      const { data, error } = await this.supabase
        .from('orders')
        .select(`
          *,
          order_items(
            id,
            quantity,
            price,
            menu_items(name, description, category)
          )
        `)
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(options.limit || 50);

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error finding user orders:', error);
      throw error;
    }
  }

  /**
   * Obtener orden por ID con items
   */
  async findByIdWithItems(orderId) {
    try {
      const { data, error } = await this.supabase
        .from('orders')
        .select(`
          *,
          users(name, email, phone),
          order_items(
            id,
            quantity,
            price,
            menu_items(*)
          )
        `)
        .eq('id', orderId)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error finding order with items:', error);
      throw error;
    }
  }

  /**
   * Obtener órdenes por estado
   */
  async findByStatus(status) {
    try {
      const { data, error } = await this.supabase
        .from('orders')
        .select(`
          *,
          users(name, email),
          order_items(count)
        `)
        .eq('status', status)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error finding orders by status:', error);
      throw error;
    }
  }

  /**
   * Crear orden con items
   */
  async createOrder(orderData) {
    try {
      // Validar datos requeridos
      if (!orderData.user_id) {
        throw new Error('user_id es requerido');
      }

      if (!orderData.items || !Array.isArray(orderData.items) || orderData.items.length === 0) {
        throw new Error('La orden debe contener al menos un item');
      }

      // Calcular total
      let total = 0;
      for (const item of orderData.items) {
        if (!item.menu_item_id || !item.quantity || !item.price) {
          throw new Error('Datos de item inválidos');
        }
        total += item.quantity * item.price;
      }

      // Crear la orden
      const orderId = uuidv4();
      const newOrder = {
        id: orderId,
        user_id: orderData.user_id,
        total: total,
        status: 'pending',
        notes: orderData.notes || null,
        delivery_address: orderData.delivery_address || null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      const { data: order, error: orderError } = await this.supabase
        .from('orders')
        .insert(newOrder)
        .select()
        .single();

      if (orderError) throw orderError;

      // Crear los order_items
      const orderItems = orderData.items.map(item => ({
        id: uuidv4(),
        order_id: orderId,
        menu_item_id: item.menu_item_id,
        quantity: item.quantity,
        price: item.price,
        created_at: new Date().toISOString()
      }));

      const { data: items, error: itemsError } = await this.supabase
        .from('order_items')
        .insert(orderItems)
        .select();

      if (itemsError) throw itemsError;

      // Retornar orden completa con items
      return {
        ...order,
        order_items: items
      };
    } catch (error) {
      console.error('Error creating order:', error);
      throw error;
    }
  }

  /**
   * Actualizar estado de orden
   */
  async updateStatus(orderId, status) {
    try {
      const validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'];
      
      if (!validStatuses.includes(status)) {
        throw new Error('Estado inválido');
      }

      return await this.update(orderId, { status });
    } catch (error) {
      console.error('Error updating order status:', error);
      throw error;
    }
  }

  /**
   * Cancelar orden
   */
  async cancelOrder(orderId, userId = null) {
    try {
      const order = await this.findById(orderId);

      if (!order) {
        throw new Error('Orden no encontrada');
      }

      // Si se proporciona userId, verificar que sea del usuario
      if (userId && order.user_id !== userId) {
        throw new Error('No tienes permiso para cancelar esta orden');
      }

      // Verificar que no esté ya cancelada o completada
      if (order.status === 'cancelled') {
        throw new Error('La orden ya está cancelada');
      }

      if (order.status === 'delivered') {
        throw new Error('No se pueden cancelar órdenes ya entregadas');
      }

      return await this.updateStatus(orderId, 'cancelled');
    } catch (error) {
      console.error('Error cancelling order:', error);
      throw error;
    }
  }

  /**
   * Obtener órdenes activas (no completadas ni canceladas)
   */
  async getActiveOrders() {
    try {
      const { data, error } = await this.supabase
        .from('orders')
        .select(`
          *,
          users(name, email),
          order_items(
            quantity,
            menu_items(name)
          )
        `)
        .in('status', ['pending', 'confirmed', 'preparing', 'ready'])
        .order('created_at', { ascending: true });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting active orders:', error);
      throw error;
    }
  }

  /**
   * Obtener estadísticas de órdenes
   */
  async getStats(startDate, endDate) {
    try {
      const { data, error } = await this.supabase
        .from('orders')
        .select('*')
        .gte('created_at', startDate)
        .lte('created_at', endDate);

      if (error) throw error;

      const stats = {
        total: data.length,
        pending: data.filter(o => o.status === 'pending').length,
        confirmed: data.filter(o => o.status === 'confirmed').length,
        preparing: data.filter(o => o.status === 'preparing').length,
        ready: data.filter(o => o.status === 'ready').length,
        delivered: data.filter(o => o.status === 'delivered').length,
        cancelled: data.filter(o => o.status === 'cancelled').length,
        totalRevenue: data
          .filter(o => o.status === 'delivered')
          .reduce((sum, o) => sum + parseFloat(o.total), 0),
        averageOrderValue: data.length > 0 
          ? data.reduce((sum, o) => sum + parseFloat(o.total), 0) / data.length 
          : 0
      };

      return stats;
    } catch (error) {
      console.error('Error getting order stats:', error);
      throw error;
    }
  }

  /**
   * Obtener items más vendidos
   */
  async getTopSellingItems(limit = 10) {
    try {
      const { data, error } = await this.supabase
        .from('order_items')
        .select(`
          menu_item_id,
          quantity,
          menu_items(name, category, price)
        `);

      if (error) throw error;

      // Agrupar por item y sumar cantidades
      const itemsMap = new Map();
      data.forEach(orderItem => {
        const itemId = orderItem.menu_item_id;
        if (itemsMap.has(itemId)) {
          itemsMap.get(itemId).totalQuantity += orderItem.quantity;
        } else {
          itemsMap.set(itemId, {
            menu_item_id: itemId,
            name: orderItem.menu_items.name,
            category: orderItem.menu_items.category,
            price: orderItem.menu_items.price,
            totalQuantity: orderItem.quantity
          });
        }
      });

      // Convertir a array y ordenar
      const topItems = Array.from(itemsMap.values())
        .sort((a, b) => b.totalQuantity - a.totalQuantity)
        .slice(0, limit);

      return topItems;
    } catch (error) {
      console.error('Error getting top selling items:', error);
      throw error;
    }
  }
}

module.exports = new OrderService();
