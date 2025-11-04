const BaseService = require('./baseService');
const { v4: uuidv4 } = require('uuid');

class ReservationService extends BaseService {
  constructor() {
    super('reservations');
  }

  /**
   * Obtener reservaciones de un usuario
   */
  async findByUser(userId, includeHistory = false) {
    try {
      const filters = { user_id: userId };
      
      if (!includeHistory) {
        // Solo reservaciones futuras o pendientes
        const { data, error } = await this.supabase
          .from('reservations')
          .select('*')
          .eq('user_id', userId)
          .in('status', ['pending', 'confirmed'])
          .gte('date', new Date().toISOString().split('T')[0])
          .order('date', { ascending: true });

        if (error) throw error;
        return data;
      }

      return await this.findAll(filters, { orderBy: 'date', ascending: false });
    } catch (error) {
      console.error('Error finding user reservations:', error);
      throw error;
    }
  }

  /**
   * Obtener reservaciones por fecha
   */
  async findByDate(date) {
    try {
      const { data, error } = await this.supabase
        .from('reservations')
        .select(`
          *,
          users(name, email, phone)
        `)
        .eq('date', date)
        .in('status', ['pending', 'confirmed'])
        .order('time', { ascending: true });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error finding reservations by date:', error);
      throw error;
    }
  }

  /**
   * Obtener reservaciones por estado
   */
  async findByStatus(status) {
    try {
      const { data, error } = await this.supabase
        .from('reservations')
        .select(`
          *,
          users(name, email, phone)
        `)
        .eq('status', status)
        .order('date', { ascending: true })
        .order('time', { ascending: true });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error finding reservations by status:', error);
      throw error;
    }
  }

  /**
   * Crear nueva reservación con validaciones
   */
  async createReservation(reservationData) {
    try {
      // Validar datos requeridos
      const requiredFields = ['user_id', 'date', 'time', 'guests'];
      for (const field of requiredFields) {
        if (!reservationData[field]) {
          throw new Error(`Campo requerido: ${field}`);
        }
      }

      // Validar que la fecha no sea pasada
      const reservationDate = new Date(reservationData.date);
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      if (reservationDate < today) {
        throw new Error('No se pueden hacer reservaciones para fechas pasadas');
      }

      // Validar número de invitados
      if (reservationData.guests < 1) {
        throw new Error('Debe haber al menos 1 invitado');
      }

      if (reservationData.guests > 20) {
        throw new Error('Para grupos mayores a 20 personas, contacte al restaurante');
      }

      // Verificar disponibilidad
      const existingReservations = await this.findByDate(reservationData.date);
      const sameTimeReservations = existingReservations.filter(
        r => r.time === reservationData.time
      );

      if (sameTimeReservations.length >= 10) {
        throw new Error('No hay disponibilidad para esa hora');
      }

      // Crear reservación con estado pendiente
      const newReservation = {
        id: uuidv4(),
        ...reservationData,
        status: 'pending',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      return await this.create(newReservation);
    } catch (error) {
      console.error('Error creating reservation:', error);
      throw error;
    }
  }

  /**
   * Actualizar estado de reservación
   */
  async updateStatus(reservationId, status, notes = null) {
    try {
      const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed', 'no-show'];
      
      if (!validStatuses.includes(status)) {
        throw new Error('Estado inválido');
      }

      const updateData = { status };
      if (notes) {
        updateData.notes = notes;
      }

      return await this.update(reservationId, updateData);
    } catch (error) {
      console.error('Error updating reservation status:', error);
      throw error;
    }
  }

  /**
   * Cancelar reservación
   */
  async cancelReservation(reservationId, userId = null) {
    try {
      const reservation = await this.findById(reservationId);

      if (!reservation) {
        throw new Error('Reservación no encontrada');
      }

      // Si se proporciona userId, verificar que sea del usuario
      if (userId && reservation.user_id !== userId) {
        throw new Error('No tienes permiso para cancelar esta reservación');
      }

      // Verificar que no esté ya cancelada
      if (reservation.status === 'cancelled') {
        throw new Error('La reservación ya está cancelada');
      }

      // Verificar que no sea una reservación pasada
      const reservationDate = new Date(`${reservation.date}T${reservation.time}`);
      if (reservationDate < new Date()) {
        throw new Error('No se pueden cancelar reservaciones pasadas');
      }

      return await this.updateStatus(reservationId, 'cancelled');
    } catch (error) {
      console.error('Error cancelling reservation:', error);
      throw error;
    }
  }

  /**
   * Confirmar reservación
   */
  async confirmReservation(reservationId) {
    try {
      return await this.updateStatus(reservationId, 'confirmed');
    } catch (error) {
      console.error('Error confirming reservation:', error);
      throw error;
    }
  }

  /**
   * Obtener estadísticas de reservaciones
   */
  async getStats(startDate, endDate) {
    try {
      const { data, error } = await this.supabase
        .from('reservations')
        .select('*')
        .gte('date', startDate)
        .lte('date', endDate);

      if (error) throw error;

      const stats = {
        total: data.length,
        pending: data.filter(r => r.status === 'pending').length,
        confirmed: data.filter(r => r.status === 'confirmed').length,
        cancelled: data.filter(r => r.status === 'cancelled').length,
        completed: data.filter(r => r.status === 'completed').length,
        noShow: data.filter(r => r.status === 'no-show').length,
        totalGuests: data.reduce((sum, r) => sum + r.guests, 0)
      };

      return stats;
    } catch (error) {
      console.error('Error getting reservation stats:', error);
      throw error;
    }
  }
}

module.exports = new ReservationService();
