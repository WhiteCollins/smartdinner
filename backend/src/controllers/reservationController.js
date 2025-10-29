const reservationService = require('../services/reservationService');

class ReservationController {
  /**
   * GET /api/reservations
   * Obtener todas las reservaciones
   */
  async getAll(req, res) {
    try {
      const { user_id, date, status } = req.query;
      
      let reservations;

      if (user_id) {
        reservations = await reservationService.findByUser(user_id, true);
      } else if (date) {
        reservations = await reservationService.findByDate(date);
      } else if (status) {
        reservations = await reservationService.findByStatus(status);
      } else {
        reservations = await reservationService.findAll({}, { orderBy: 'date', ascending: false });
      }
      
      res.json({
        success: true,
        data: reservations,
        count: reservations.length
      });
    } catch (error) {
      console.error('Error in getAll reservations:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/reservations/:id
   * Obtener reservación por ID
   */
  async getById(req, res) {
    try {
      const { id } = req.params;
      const reservation = await reservationService.findById(id);

      if (!reservation) {
        return res.status(404).json({
          success: false,
          error: 'Reservación no encontrada'
        });
      }

      res.json({
        success: true,
        data: reservation
      });
    } catch (error) {
      console.error('Error in getById reservation:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/reservations/user/:userId
   * Obtener reservaciones de un usuario
   */
  async getByUser(req, res) {
    try {
      const { userId } = req.params;
      const { includeHistory = false } = req.query;
      
      const reservations = await reservationService.findByUser(
        userId, 
        includeHistory === 'true'
      );

      res.json({
        success: true,
        data: reservations,
        count: reservations.length
      });
    } catch (error) {
      console.error('Error in getByUser reservations:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/reservations/date/:date
   * Obtener reservaciones por fecha
   */
  async getByDate(req, res) {
    try {
      const { date } = req.params;
      const reservations = await reservationService.findByDate(date);

      res.json({
        success: true,
        data: reservations,
        count: reservations.length
      });
    } catch (error) {
      console.error('Error in getByDate:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/reservations/status/:status
   * Obtener reservaciones por estado
   */
  async getByStatus(req, res) {
    try {
      const { status } = req.params;
      const reservations = await reservationService.findByStatus(status);

      res.json({
        success: true,
        data: reservations,
        count: reservations.length
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
   * POST /api/reservations
   * Crear nueva reservación
   */
  async create(req, res) {
    try {
      const reservationData = req.body;
      const newReservation = await reservationService.createReservation(reservationData);

      res.status(201).json({
        success: true,
        data: newReservation,
        message: 'Reservación creada exitosamente'
      });
    } catch (error) {
      console.error('Error in create reservation:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PUT /api/reservations/:id
   * Actualizar reservación
   */
  async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const updatedReservation = await reservationService.update(id, updateData);

      res.json({
        success: true,
        data: updatedReservation,
        message: 'Reservación actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error in update reservation:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PATCH /api/reservations/:id/status
   * Actualizar estado de reservación
   */
  async updateStatus(req, res) {
    try {
      const { id } = req.params;
      const { status, notes } = req.body;

      if (!status) {
        return res.status(400).json({
          success: false,
          error: 'Campo "status" es requerido'
        });
      }

      const updatedReservation = await reservationService.updateStatus(id, status, notes);

      res.json({
        success: true,
        data: updatedReservation,
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
   * POST /api/reservations/:id/confirm
   * Confirmar reservación
   */
  async confirm(req, res) {
    try {
      const { id } = req.params;
      const updatedReservation = await reservationService.confirmReservation(id);

      res.json({
        success: true,
        data: updatedReservation,
        message: 'Reservación confirmada exitosamente'
      });
    } catch (error) {
      console.error('Error in confirm reservation:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * POST /api/reservations/:id/cancel
   * Cancelar reservación
   */
  async cancel(req, res) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;
      
      const updatedReservation = await reservationService.cancelReservation(id, user_id);

      res.json({
        success: true,
        data: updatedReservation,
        message: 'Reservación cancelada exitosamente'
      });
    } catch (error) {
      console.error('Error in cancel reservation:', error);
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/reservations/:id
   * Eliminar reservación
   */
  async delete(req, res) {
    try {
      const { id } = req.params;
      const { soft = true } = req.query;

      await reservationService.delete(id, soft === 'true');

      res.json({
        success: true,
        message: 'Reservación eliminada exitosamente'
      });
    } catch (error) {
      console.error('Error in delete reservation:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/reservations/stats
   * Obtener estadísticas de reservaciones
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

      const stats = await reservationService.getStats(startDate, endDate);

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
}

module.exports = new ReservationController();
