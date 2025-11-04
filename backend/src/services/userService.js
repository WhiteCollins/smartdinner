const BaseService = require('./baseService');

class UserService extends BaseService {
  constructor() {
    super('users');
  }

  /**
   * Obtener usuario por email
   */
  async findByEmail(email) {
    try {
      return await this.findOne({ email });
    } catch (error) {
      console.error('Error finding user by email:', error);
      throw error;
    }
  }

  /**
   * Obtener perfil completo del usuario con relaciones
   */
  async getUserProfile(userId) {
    try {
      const { data, error } = await this.supabase
        .from('users')
        .select(`
          *,
          reservations:reservations(count),
          orders:orders(count)
        `)
        .eq('id', userId)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error getting user profile:', error);
      throw error;
    }
  }

  /**
   * Actualizar perfil de usuario
   */
  async updateProfile(userId, profileData) {
    try {
      const allowedFields = ['name', 'phone', 'avatar_url'];
      const updateData = {};

      allowedFields.forEach(field => {
        if (profileData[field] !== undefined) {
          updateData[field] = profileData[field];
        }
      });

      return await this.update(userId, updateData);
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  }

  /**
   * Obtener usuarios por rol
   */
  async findByRole(role) {
    try {
      return await this.findAll({ role });
    } catch (error) {
      console.error('Error finding users by role:', error);
      throw error;
    }
  }

  /**
   * Actualizar último acceso del usuario
   */
  async updateLastAccess(userId) {
    try {
      return await this.update(userId, {
        last_access: new Date().toISOString()
      });
    } catch (error) {
      console.error('Error updating last access:', error);
      throw error;
    }
  }
}

module.exports = new UserService();
