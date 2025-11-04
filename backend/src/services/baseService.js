const { supabase } = require('../config/supabase');

/**
 * Servicio base para operaciones CRUD con Supabase
 */
class BaseService {
  constructor(tableName) {
    this.tableName = tableName;
    this.supabase = supabase;
  }

  /**
   * Obtener todos los registros con filtros opcionales
   */
  async findAll(filters = {}, options = {}) {
    try {
      let query = this.supabase.from(this.tableName).select(options.select || '*');

      // Aplicar filtros
      Object.keys(filters).forEach(key => {
        if (filters[key] !== undefined && filters[key] !== null) {
          query = query.eq(key, filters[key]);
        }
      });

      // Aplicar ordenamiento
      if (options.orderBy) {
        query = query.order(options.orderBy, { ascending: options.ascending !== false });
      }

      // Aplicar límite y offset
      if (options.limit) {
        query = query.limit(options.limit);
      }
      if (options.offset) {
        query = query.range(options.offset, options.offset + (options.limit || 10) - 1);
      }

      const { data, error } = await query;

      if (error) throw error;
      return data;
    } catch (error) {
      console.error(`Error in findAll (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Obtener un registro por ID
   */
  async findById(id) {
    try {
      const { data, error } = await this.supabase
        .from(this.tableName)
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error(`Error in findById (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Obtener un registro por criterio específico
   */
  async findOne(filters) {
    try {
      let query = this.supabase.from(this.tableName).select('*');

      Object.keys(filters).forEach(key => {
        query = query.eq(key, filters[key]);
      });

      const { data, error } = await query.single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error(`Error in findOne (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Crear un nuevo registro
   */
  async create(data) {
    try {
      const { data: result, error } = await this.supabase
        .from(this.tableName)
        .insert(data)
        .select()
        .single();

      if (error) throw error;
      return result;
    } catch (error) {
      console.error(`Error in create (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Crear múltiples registros
   */
  async createMany(dataArray) {
    try {
      const { data, error } = await this.supabase
        .from(this.tableName)
        .insert(dataArray)
        .select();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error(`Error in createMany (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Actualizar un registro por ID
   */
  async update(id, data) {
    try {
      // Agregar updated_at automáticamente
      const updateData = {
        ...data,
        updated_at: new Date().toISOString()
      };

      const { data: result, error } = await this.supabase
        .from(this.tableName)
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return result;
    } catch (error) {
      console.error(`Error in update (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Actualizar múltiples registros
   */
  async updateMany(filters, data) {
    try {
      let query = this.supabase.from(this.tableName).update({
        ...data,
        updated_at: new Date().toISOString()
      });

      Object.keys(filters).forEach(key => {
        query = query.eq(key, filters[key]);
      });

      const { data: result, error } = await query.select();

      if (error) throw error;
      return result;
    } catch (error) {
      console.error(`Error in updateMany (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Eliminar un registro por ID (soft delete si existe deleted_at)
   */
  async delete(id, soft = true) {
    try {
      if (soft) {
        // Soft delete - marcar como eliminado
        const { data, error } = await this.supabase
          .from(this.tableName)
          .update({ deleted_at: new Date().toISOString() })
          .eq('id', id)
          .select()
          .single();

        if (error) throw error;
        return data;
      } else {
        // Hard delete - eliminar físicamente
        const { error } = await this.supabase
          .from(this.tableName)
          .delete()
          .eq('id', id);

        if (error) throw error;
        return { id, deleted: true };
      }
    } catch (error) {
      console.error(`Error in delete (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Eliminar múltiples registros
   */
  async deleteMany(filters, soft = true) {
    try {
      if (soft) {
        let query = this.supabase
          .from(this.tableName)
          .update({ deleted_at: new Date().toISOString() });

        Object.keys(filters).forEach(key => {
          query = query.eq(key, filters[key]);
        });

        const { data, error } = await query.select();
        if (error) throw error;
        return data;
      } else {
        let query = this.supabase.from(this.tableName).delete();

        Object.keys(filters).forEach(key => {
          query = query.eq(key, filters[key]);
        });

        const { error } = await query;
        if (error) throw error;
        return { deleted: true };
      }
    } catch (error) {
      console.error(`Error in deleteMany (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Contar registros
   */
  async count(filters = {}) {
    try {
      let query = this.supabase
        .from(this.tableName)
        .select('*', { count: 'exact', head: true });

      Object.keys(filters).forEach(key => {
        query = query.eq(key, filters[key]);
      });

      const { count, error } = await query;

      if (error) throw error;
      return count;
    } catch (error) {
      console.error(`Error in count (${this.tableName}):`, error);
      throw error;
    }
  }

  /**
   * Verificar si existe un registro
   */
  async exists(filters) {
    try {
      const count = await this.count(filters);
      return count > 0;
    } catch (error) {
      console.error(`Error in exists (${this.tableName}):`, error);
      throw error;
    }
  }
}

module.exports = BaseService;
