const userService = require('../services/userService');

class UserController {
  /**
   * GET /api/users
   * Obtener todos los usuarios
   */
  async getAll(req, res) {
    try {
      const { role, limit, offset } = req.query;
      
      const filters = {};
      if (role) filters.role = role;

      const options = {};
      if (limit) options.limit = parseInt(limit);
      if (offset) options.offset = parseInt(offset);

      const users = await userService.findAll(filters, options);
      
      res.json({
        success: true,
        data: users,
        count: users.length
      });
    } catch (error) {
      console.error('Error in getAll users:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/users/:id
   * Obtener usuario por ID
   */
  async getById(req, res) {
    try {
      const { id } = req.params;
      const user = await userService.findById(id);

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Usuario no encontrado'
        });
      }

      res.json({
        success: true,
        data: user
      });
    } catch (error) {
      console.error('Error in getById user:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/users/:id/profile
   * Obtener perfil completo del usuario
   */
  async getProfile(req, res) {
    try {
      const { id } = req.params;
      const profile = await userService.getUserProfile(id);

      if (!profile) {
        return res.status(404).json({
          success: false,
          error: 'Usuario no encontrado'
        });
      }

      res.json({
        success: true,
        data: profile
      });
    } catch (error) {
      console.error('Error in getProfile:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * PUT /api/users/:id
   * Actualizar usuario
   */
  async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const updatedUser = await userService.updateProfile(id, updateData);

      res.json({
        success: true,
        data: updatedUser,
        message: 'Usuario actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error in update user:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/users/:id
   * Eliminar usuario
   */
  async delete(req, res) {
    try {
      const { id } = req.params;
      const { soft = true } = req.query;

      await userService.delete(id, soft === 'true');

      res.json({
        success: true,
        message: 'Usuario eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error in delete user:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/users/email/:email
   * Obtener usuario por email
   */
  async getByEmail(req, res) {
    try {
      const { email } = req.params;
      const user = await userService.findByEmail(email);

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Usuario no encontrado'
        });
      }

      res.json({
        success: true,
        data: user
      });
    } catch (error) {
      console.error('Error in getByEmail:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = new UserController();
