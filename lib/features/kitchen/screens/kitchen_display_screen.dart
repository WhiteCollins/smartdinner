import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KitchenDisplayScreen extends StatefulWidget {
  const KitchenDisplayScreen({super.key});

  @override
  State<KitchenDisplayScreen> createState() => _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState extends State<KitchenDisplayScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  RealtimeChannel? _ordersChannel;
  Timer? _refreshTimer;
  String _filterStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupRealtimeSubscription();
    // Actualizar timers cada minuto
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ordersChannel?.unsubscribe();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    _ordersChannel = _supabase
        .channel('kitchen_orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            _loadOrders();
          },
        )
        .subscribe();
  }

  Future<void> _loadOrders() async {
    try {
      // Cargar pedidos activos (no completados ni cancelados)
      final response = await _supabase.from('orders').select('''
            id,
            status,
            notes,
            created_at,
            updated_at,
            mesa_id,
            user_id,
            total,
            mesas (numero, ubicacion),
            order_items (
              id,
              quantity,
              notes,
              menu_items (nombre, categoria)
            )
          ''').inFilter('status', [
        'pending',
        'preparing',
        'ready'
      ]).order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading kitchen orders: $e');
      // Usar datos de ejemplo si hay error
      if (mounted) {
        setState(() {
          _orders = _getSampleOrders();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSampleOrders() {
    final now = DateTime.now();
    return [
      {
        'id': 'ord-001',
        'status': 'pending',
        'notes': 'Sin cebolla',
        'created_at':
            now.subtract(const Duration(minutes: 15)).toIso8601String(),
        'mesas': {'numero': 5, 'ubicacion': 'interior'},
        'order_items': [
          {
            'quantity': 2,
            'notes': '',
            'menu_items': {
              'nombre': 'Hamburguesa Clásica',
              'categoria': 'Principales'
            }
          },
          {
            'quantity': 1,
            'notes': 'Extra queso',
            'menu_items': {
              'nombre': 'Pizza Margherita',
              'categoria': 'Principales'
            }
          },
          {
            'quantity': 3,
            'notes': '',
            'menu_items': {
              'nombre': 'Papas Fritas',
              'categoria': 'Acompañamientos'
            }
          },
        ],
      },
      {
        'id': 'ord-002',
        'status': 'preparing',
        'notes': '',
        'created_at':
            now.subtract(const Duration(minutes: 8)).toIso8601String(),
        'mesas': {'numero': 3, 'ubicacion': 'terraza'},
        'order_items': [
          {
            'quantity': 1,
            'notes': '',
            'menu_items': {
              'nombre': 'Pasta Alfredo',
              'categoria': 'Principales'
            }
          },
          {
            'quantity': 2,
            'notes': '',
            'menu_items': {'nombre': 'Ensalada César', 'categoria': 'Entradas'}
          },
        ],
      },
      {
        'id': 'ord-003',
        'status': 'ready',
        'notes': 'Cliente VIP',
        'created_at':
            now.subtract(const Duration(minutes: 25)).toIso8601String(),
        'mesas': {'numero': 1, 'ubicacion': 'privado'},
        'order_items': [
          {
            'quantity': 1,
            'notes': '',
            'menu_items': {
              'nombre': 'Filete Mignon',
              'categoria': 'Principales'
            }
          },
          {
            'quantity': 1,
            'notes': 'Sin hielo',
            'menu_items': {'nombre': 'Vino Tinto', 'categoria': 'Bebidas'}
          },
        ],
      },
      {
        'id': 'ord-004',
        'status': 'pending',
        'notes': '',
        'created_at':
            now.subtract(const Duration(minutes: 3)).toIso8601String(),
        'mesas': {'numero': 8, 'ubicacion': 'exterior'},
        'order_items': [
          {
            'quantity': 4,
            'notes': '',
            'menu_items': {
              'nombre': 'Tacos al Pastor',
              'categoria': 'Principales'
            }
          },
          {
            'quantity': 2,
            'notes': '',
            'menu_items': {'nombre': 'Guacamole', 'categoria': 'Entradas'}
          },
          {
            'quantity': 4,
            'notes': '',
            'menu_items': {'nombre': 'Limonada', 'categoria': 'Bebidas'}
          },
        ],
      },
      {
        'id': 'ord-005',
        'status': 'preparing',
        'notes': 'Alergia a mariscos',
        'created_at':
            now.subtract(const Duration(minutes: 12)).toIso8601String(),
        'mesas': {'numero': 12, 'ubicacion': 'barra'},
        'order_items': [
          {
            'quantity': 1,
            'notes': '',
            'menu_items': {
              'nombre': 'Pollo a la Parrilla',
              'categoria': 'Principales'
            }
          },
          {
            'quantity': 1,
            'notes': '',
            'menu_items': {'nombre': 'Arroz', 'categoria': 'Acompañamientos'}
          },
        ],
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_filterStatus == 'todos') return _orders;
    return _orders.where((o) => o['status'] == _filterStatus).toList();
  }

  int get _pendingCount =>
      _orders.where((o) => o['status'] == 'pending').length;
  int get _preparingCount =>
      _orders.where((o) => o['status'] == 'preparing').length;
  int get _readyCount => _orders.where((o) => o['status'] == 'ready').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('🍳 Cocina',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Contador de pedidos
          _buildStatusCounter('Pendiente', _pendingCount, Colors.orange),
          _buildStatusCounter('Preparando', _preparingCount, Colors.blue),
          _buildStatusCounter('Listo', _readyCount, Colors.green),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilters(),

          // Banner de datos demo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue.shade800,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Datos de demostración - Conecta con Supabase para datos reales',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          // Grid de pedidos
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCounter(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todos', 'todos', Colors.grey),
            _buildFilterChip('Pendientes', 'pending', Colors.orange),
            _buildFilterChip('Preparando', 'preparing', Colors.blue),
            _buildFilterChip('Listos', 'ready', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status, Color color) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filterStatus = status);
        },
        backgroundColor: Colors.grey.shade800,
        selectedColor: color.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: color,
        side: BorderSide(color: isSelected ? color : Colors.grey.shade700),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos pendientes',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Buen trabajo! 👨‍🍳',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular columnas basado en el ancho
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(_filteredOrders[index]);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final createdAt = DateTime.parse(order['created_at']);
    final elapsedMinutes = DateTime.now().difference(createdAt).inMinutes;
    final mesa = order['mesas'] as Map<String, dynamic>?;
    final items = order['order_items'] as List? ?? [];
    final notes = order['notes'] as String? ?? '';

    // Colores según estado
    Color statusColor;
    Color headerColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        headerColor = Colors.orange.shade800;
        statusText = 'PENDIENTE';
        statusIcon = Icons.schedule;
        break;
      case 'preparing':
        statusColor = Colors.blue;
        headerColor = Colors.blue.shade800;
        statusText = 'PREPARANDO';
        statusIcon = Icons.local_fire_department;
        break;
      case 'ready':
        statusColor = Colors.green;
        headerColor = Colors.green.shade800;
        statusText = 'LISTO';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        headerColor = Colors.grey.shade800;
        statusText = status.toUpperCase();
        statusIcon = Icons.help;
    }

    // Alerta si lleva mucho tiempo
    final isUrgent = status == 'pending' && elapsedMinutes > 10;
    final isVeryUrgent = status == 'pending' && elapsedMinutes > 15;

    return Card(
      color: isVeryUrgent ? Colors.red.shade900 : Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUrgent ? Colors.red : statusColor,
          width: isUrgent ? 3 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mesa
                Row(
                  children: [
                    const Icon(Icons.table_restaurant,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Mesa ${mesa?['numero'] ?? '?'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Timer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red : Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: isUrgent ? Colors.white : Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${elapsedMinutes}m',
                        style: TextStyle(
                          color: isUrgent ? Colors.white : Colors.white70,
                          fontWeight:
                              isUrgent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: statusColor.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Items del pedido
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map<String, dynamic>;
                final menuItem = item['menu_items'] as Map<String, dynamic>?;
                final quantity = item['quantity'] ?? 1;
                final itemNotes = item['notes'] as String? ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cantidad
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${quantity}x',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nombre y notas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menuItem?['nombre'] ?? 'Item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (itemNotes.isNotEmpty)
                              Text(
                                '→ $itemNotes',
                                style: TextStyle(
                                  color: Colors.yellow.shade300,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Notas del pedido
          if (notes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.yellow.shade900.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(Icons.note, color: Colors.yellow.shade300, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                          color: Colors.yellow.shade300, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(8),
            child: _buildActionButtons(order, status),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order['id'], 'preparing'),
          icon: const Icon(Icons.local_fire_department),
          label: const Text('INICIAR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        );
      case 'preparing':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order['id'], 'ready'),
          icon: const Icon(Icons.check_circle),
          label: const Text('LISTO'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        );
      case 'ready':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order['id'], 'delivered'),
          icon: const Icon(Icons.delivery_dining),
          label: const Text('ENTREGADO'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('orders').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', orderId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido actualizado a: $newStatus'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      _loadOrders();
    } catch (e) {
      // Demo mode - actualizar localmente
      setState(() {
        final index = _orders.indexWhere((o) => o['id'] == orderId);
        if (index != -1) {
          if (newStatus == 'delivered') {
            _orders.removeAt(index);
          } else {
            _orders[index]['status'] = newStatus;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Pedido actualizado (Demo)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
