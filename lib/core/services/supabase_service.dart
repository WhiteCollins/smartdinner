import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // ==================== AUTENTICACIÓN ====================

  /// Iniciar sesión con email y contraseña
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Registrar nuevo usuario
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      // Crear registro en tabla users
      if (response.user != null) {
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'phone': phone,
          'role': 'customer',
        });
      }

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener usuario actual
  User? get currentUser => _client.auth.currentUser;

  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  // ==================== USUARIOS ====================

  /// Obtener perfil de usuario
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar perfil de usuario
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;

      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== RESERVAS ====================

  /// Obtener reservas del usuario
  Future<List<Map<String, dynamic>>> getUserReservations(String userId) async {
    try {
      final response = await _client
          .from('reservations')
          .select()
          .eq('user_id', userId)
          .order('reservation_date', ascending: false)
          .order('reservation_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Crear nueva reserva
  Future<Map<String, dynamic>> createReservation({
    required String userId,
    required DateTime date,
    required String time,
    required int partySize,
    String? specialRequests,
  }) async {
    try {
      final response = await _client
          .from('reservations')
          .insert({
            'user_id': userId,
            'reservation_date': date.toIso8601String().split('T')[0],
            'reservation_time': time,
            'party_size': partySize,
            'special_requests': specialRequests,
            'status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancelar reserva
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _client
          .from('reservations')
          .update({'status': 'cancelled'})
          .eq('id', reservationId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== MENÚ ====================

  /// Obtener todos los items del menú
  /// [category] - Filtrar por categoría específica
  /// [showAll] - Si es true, muestra todos los items (disponibles y no disponibles)
  ///             Si es false, solo muestra items disponibles. Default: false
  Future<List<Map<String, dynamic>>> getMenuItems({
    String? category,
    bool showAll = false,
  }) async {
    try {
      var query = _client.from('menu_items').select();

      // Solo filtrar por disponibilidad si showAll es false
      if (!showAll) {
        query = query.eq('is_available', true);
      }

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener item del menú por ID
  Future<Map<String, dynamic>> getMenuItem(String itemId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('id', itemId)
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Crear nuevo item del menú
  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('menu_items')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar item del menú
  Future<Map<String, dynamic>> updateMenuItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('menu_items')
          .update(data)
          .eq('id', itemId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar item del menú
  Future<void> deleteMenuItem(String itemId) async {
    try {
      await _client.from('menu_items').delete().eq('id', itemId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PEDIDOS ====================

  /// Crear nuevo pedido
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String orderType,
    required List<Map<String, dynamic>> items,
    String? reservationId,
    String? deliveryAddress,
    String? specialInstructions,
    double tip = 0,
  }) async {
    try {
      // Crear orden
      final orderResponse = await _client
          .from('orders')
          .insert({
            'user_id': userId,
            'order_type': orderType,
            'reservation_id': reservationId,
            'delivery_address': deliveryAddress,
            'special_instructions': specialInstructions,
            'tip': tip,
            'status': 'pending',
            'payment_status': 'pending',
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Agregar items del pedido
      final orderItems = items
          .map(
            (item) => {
              'order_id': orderId,
              'menu_item_id': item['menu_item_id'],
              'quantity': item['quantity'],
              'unit_price': item['unit_price'],
              'subtotal': item['unit_price'] * item['quantity'],
              'special_instructions': item['special_instructions'],
            },
          )
          .toList();

      await _client.from('order_items').insert(orderItems);

      // Obtener orden completa con items
      final completeOrder = await getOrder(orderId);
      return completeOrder;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener orden por ID
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              menu_items (*)
            )
          ''')
          .eq('id', orderId)
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener órdenes del usuario
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              menu_items (*)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PREDICCIONES IA ====================

  /// Obtener predicciones
  Future<List<Map<String, dynamic>>> getPredictions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('predictions').select('''
            *,
            menu_items (*)
          ''');

      if (startDate != null) {
        query = query.gte(
          'prediction_date',
          startDate.toIso8601String().split('T')[0],
        );
      }

      if (endDate != null) {
        query = query.lte(
          'prediction_date',
          endDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query.order('prediction_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== RESEÑAS ====================

  /// Crear reseña
  Future<Map<String, dynamic>> createReview({
    required String userId,
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .insert({
            'user_id': userId,
            'order_id': orderId,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener reseñas
  Future<List<Map<String, dynamic>>> getReviews({int limit = 10}) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            users (name, email)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== NOTIFICACIONES ====================

  /// Obtener notificaciones del usuario
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Marcar notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== REAL-TIME ====================

  /// Suscribirse a cambios en órdenes
  RealtimeChannel subscribeToOrders(
    String userId,
    Function(Map<String, dynamic>) onOrderUpdate,
  ) {
    return _client
        .channel('orders:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onOrderUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Suscribirse a notificaciones en tiempo real
  RealtimeChannel subscribeToNotifications(
    String userId,
    Function(Map<String, dynamic>) onNotification,
  ) {
    return _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  // ==================== UTILIDADES ====================

  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      return Exception('Database error: ${error.message}');
    } else if (error is AuthException) {
      return Exception('Auth error: ${error.message}');
    } else if (error is StorageException) {
      return Exception('Storage error: ${error.message}');
    }
    return Exception('Unknown error: $error');
  }
}
