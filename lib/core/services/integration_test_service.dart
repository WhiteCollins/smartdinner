import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Servicio para pruebas de integración con Supabase
class IntegrationTestService {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _client = Supabase.instance.client;
  final List<TestResult> _results = [];

  /// Ejecutar todas las pruebas de integración
  Future<IntegrationTestReport> runAllTests() async {
    _results.clear();
    final startTime = DateTime.now();

    developer.log('🧪 Iniciando pruebas de integración...');

    // Pruebas de conexión
    await _testConnection();

    // Pruebas de autenticación
    await _testAuthentication();

    // Pruebas de datos
    await _testMenuItems();
    await _testOrders();
    await _testReservations();
    await _testTables();
    await _testInventory();

    // Pruebas de tiempo real
    await _testRealtimeSubscription();

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    return IntegrationTestReport(
      results: List.from(_results),
      totalTests: _results.length,
      passed: _results.where((r) => r.passed).length,
      failed: _results.where((r) => !r.passed).length,
      duration: duration,
      timestamp: startTime,
    );
  }

  Future<void> _testConnection() async {
    try {
      await _client.from('menu_items').select('id').limit(1);

      _addResult(
        'Conexión a Supabase',
        passed: true,
        message: 'Conexión establecida correctamente',
        category: 'Conexión',
      );
    } catch (e) {
      _addResult(
        'Conexión a Supabase',
        passed: false,
        message: 'Error de conexión: $e',
        category: 'Conexión',
      );
    }
  }

  Future<void> _testAuthentication() async {
    try {
      final currentUser = _supabaseService.currentUser;

      if (currentUser != null) {
        final profile = await _supabaseService.getUserProfile(currentUser.id);
        _addResult(
          'Autenticación de usuario',
          passed: true,
          message: 'Usuario autenticado: ${currentUser.email}',
          category: 'Autenticación',
          data: {'userId': currentUser.id, 'role': profile['role']},
        );
      } else {
        _addResult(
          'Autenticación de usuario',
          passed: true,
          message: 'No hay sesión activa (comportamiento esperado)',
          category: 'Autenticación',
        );
      }
    } catch (e) {
      _addResult(
        'Autenticación de usuario',
        passed: false,
        message: 'Error de autenticación: $e',
        category: 'Autenticación',
      );
    }
  }

  Future<void> _testMenuItems() async {
    try {
      final items = await _client.from('menu_items').select().limit(10);

      _addResult(
        'Consulta de menú',
        passed: true,
        message: 'Se obtuvieron ${(items as List).length} items del menú',
        category: 'Datos',
        data: {'count': items.length},
      );

      // Prueba de estructura de datos
      if (items.isNotEmpty) {
        final item = items.first;
        final hasRequiredFields = item.containsKey('id') &&
            item.containsKey('name') &&
            item.containsKey('price');

        _addResult(
          'Estructura de menu_items',
          passed: hasRequiredFields,
          message: hasRequiredFields
              ? 'Estructura correcta'
              : 'Faltan campos requeridos',
          category: 'Datos',
        );
      }
    } catch (e) {
      _addResult(
        'Consulta de menú',
        passed: false,
        message: 'Error al consultar menú: $e',
        category: 'Datos',
      );
    }
  }

  Future<void> _testOrders() async {
    try {
      final orders =
          await _client.from('orders').select('*, order_items(*)').limit(5);

      _addResult(
        'Consulta de pedidos',
        passed: true,
        message: 'Se obtuvieron ${(orders as List).length} pedidos',
        category: 'Datos',
        data: {'count': orders.length},
      );

      // Verificar relaciones
      if (orders.isNotEmpty) {
        final hasItems = orders.first['order_items'] != null;
        _addResult(
          'Relación orders->order_items',
          passed: hasItems,
          message: hasItems ? 'Relación correcta' : 'Sin items relacionados',
          category: 'Relaciones',
        );
      }
    } catch (e) {
      _addResult(
        'Consulta de pedidos',
        passed: false,
        message: 'Error al consultar pedidos: $e',
        category: 'Datos',
      );
    }
  }

  Future<void> _testReservations() async {
    try {
      final reservations =
          await _client.from('reservations').select('*, tables(*)').limit(5);

      _addResult(
        'Consulta de reservaciones',
        passed: true,
        message: 'Se obtuvieron ${(reservations as List).length} reservaciones',
        category: 'Datos',
        data: {'count': reservations.length},
      );
    } catch (e) {
      _addResult(
        'Consulta de reservaciones',
        passed: false,
        message: 'Error al consultar reservaciones: $e',
        category: 'Datos',
      );
    }
  }

  Future<void> _testTables() async {
    try {
      final tables = await _client.from('mesas').select();

      _addResult(
        'Consulta de mesas',
        passed: true,
        message: 'Se obtuvieron ${(tables as List).length} mesas',
        category: 'Datos',
        data: {'count': tables.length},
      );
    } catch (e) {
      _addResult(
        'Consulta de mesas',
        passed: false,
        message: 'Error al consultar mesas: $e',
        category: 'Datos',
      );
    }
  }

  Future<void> _testInventory() async {
    try {
      final inventory = await _client.from('inventory').select();

      _addResult(
        'Consulta de inventario',
        passed: true,
        message: 'Se obtuvieron ${(inventory as List).length} items',
        category: 'Datos',
        data: {'count': inventory.length},
      );
    } catch (e) {
      _addResult(
        'Consulta de inventario',
        passed: false,
        message: 'Error al consultar inventario: $e',
        category: 'Datos',
      );
    }
  }

  Future<void> _testRealtimeSubscription() async {
    try {
      final channel = _client.channel('test_channel');

      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        callback: (payload) {
          // Solo para verificar que el canal funciona
        },
      );

      await channel.subscribe();

      // Esperar un momento para verificar la suscripción
      await Future.delayed(const Duration(seconds: 2));

      await _client.removeChannel(channel);

      _addResult(
        'Suscripción en tiempo real',
        passed: true,
        message: 'Canal de tiempo real configurado correctamente',
        category: 'Realtime',
      );
    } catch (e) {
      _addResult(
        'Suscripción en tiempo real',
        passed: false,
        message: 'Error en suscripción realtime: $e',
        category: 'Realtime',
      );
    }
  }

  void _addResult(
    String name, {
    required bool passed,
    required String message,
    required String category,
    Map<String, dynamic>? data,
  }) {
    final result = TestResult(
      name: name,
      passed: passed,
      message: message,
      category: category,
      data: data,
      timestamp: DateTime.now(),
    );
    _results.add(result);
    developer.log(
      '${passed ? "✅" : "❌"} $name: $message',
    );
  }
}

class TestResult {
  final String name;
  final bool passed;
  final String message;
  final String category;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  TestResult({
    required this.name,
    required this.passed,
    required this.message,
    required this.category,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'passed': passed,
        'message': message,
        'category': category,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
}

class IntegrationTestReport {
  final List<TestResult> results;
  final int totalTests;
  final int passed;
  final int failed;
  final Duration duration;
  final DateTime timestamp;

  IntegrationTestReport({
    required this.results,
    required this.totalTests,
    required this.passed,
    required this.failed,
    required this.duration,
    required this.timestamp,
  });

  double get passRate => totalTests > 0 ? (passed / totalTests) * 100 : 0;

  Map<String, List<TestResult>> get resultsByCategory {
    final map = <String, List<TestResult>>{};
    for (final result in results) {
      map.putIfAbsent(result.category, () => []).add(result);
    }
    return map;
  }
}
