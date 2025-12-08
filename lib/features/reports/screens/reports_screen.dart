import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/services/export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  bool _isLoading = true;

  // Período seleccionado
  String _selectedPeriod = 'today';
  DateTimeRange? _customDateRange;

  // Datos de reportes
  Map<String, dynamic> _salesData = {};
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _hourlyData = [];
  Map<String, dynamic> _summaryData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      // Calcular rango de fechas según el período seleccionado
      final dateRange = _getDateRange();
      final startDate = dateRange.start.toIso8601String();
      final endDate = dateRange.end.toIso8601String();

      // Obtener pedidos del período
      final ordersResponse = await _supabase
          .from('orders')
          .select('''
            id, total, status, created_at,
            order_items (quantity, menu_items (nombre, precio, categoria))
          ''')
          .gte('created_at', startDate)
          .lte('created_at', endDate)
          .order('created_at', ascending: false);

      if (ordersResponse != null && (ordersResponse as List).isNotEmpty) {
        // Procesar datos reales
        _processRealData(ordersResponse);
      } else {
        // Sin datos, mostrar ejemplos
        setState(() {
          _salesData = _getSampleSalesData();
          _topProducts = _getSampleTopProducts();
          _hourlyData = _getSampleHourlyData();
          _summaryData = _getSampleSummary();
        });
      }
    } catch (e) {
      debugPrint('Error cargando reportes: $e');
      // Fallback a datos de ejemplo
      setState(() {
        _salesData = _getSampleSalesData();
        _topProducts = _getSampleTopProducts();
        _hourlyData = _getSampleHourlyData();
        _summaryData = _getSampleSummary();
      });
    }

    setState(() => _isLoading = false);
  }

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case 'today':
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case 'yesterday':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 1)),
          end: today,
        );
      case 'week':
        return DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1)),
          end: today.add(const Duration(days: 1)),
        );
      case 'month':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: today.add(const Duration(days: 1)),
        );
      case 'custom':
        return _customDateRange ??
            DateTimeRange(
                start: today, end: today.add(const Duration(days: 1)));
      default:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
    }
  }

  void _processRealData(List<dynamic> orders) {
    // Calcular totales de ventas
    double totalVentas = 0;
    int totalPedidos = orders.length;
    Map<String, Map<String, dynamic>> productStats = {};
    Map<String, Map<String, dynamic>> hourlyStats = {};
    Map<String, double> dailyStats = {};
    int totalItems = 0;

    for (var order in orders) {
      final total = (order['total'] ?? 0).toDouble();
      totalVentas += total;

      // Procesar fecha para estadísticas por hora y día
      final createdAt = DateTime.parse(order['created_at']);
      final hourKey = '${createdAt.hour.toString().padLeft(2, '0')}:00';
      final dayKey = DateFormat('E').format(createdAt);

      // Estadísticas por hora
      if (!hourlyStats.containsKey(hourKey)) {
        hourlyStats[hourKey] = {'hora': hourKey, 'pedidos': 0, 'ventas': 0.0};
      }
      hourlyStats[hourKey]!['pedidos'] =
          (hourlyStats[hourKey]!['pedidos'] as int) + 1;
      hourlyStats[hourKey]!['ventas'] =
          (hourlyStats[hourKey]!['ventas'] as double) + total;

      // Estadísticas por día
      dailyStats[dayKey] = (dailyStats[dayKey] ?? 0) + total;

      // Procesar items del pedido
      final orderItems = order['order_items'] as List? ?? [];
      for (var item in orderItems) {
        totalItems += (item['quantity'] as int? ?? 1);
        final menuItem = item['menu_items'];
        if (menuItem != null) {
          final nombre = menuItem['nombre'] ?? 'Desconocido';
          final precio = (menuItem['precio'] ?? 0).toDouble();
          final cantidad = item['quantity'] ?? 1;

          if (!productStats.containsKey(nombre)) {
            productStats[nombre] = {
              'nombre': nombre,
              'cantidad': 0,
              'ingresos': 0.0,
            };
          }
          productStats[nombre]!['cantidad'] += cantidad;
          productStats[nombre]!['ingresos'] += precio * cantidad;
        }
      }
    }

    // Calcular porcentajes de productos
    final productList = productStats.values.toList();
    productList
        .sort((a, b) => (b['cantidad'] as int).compareTo(a['cantidad'] as int));
    for (var product in productList) {
      product['porcentaje'] = totalItems > 0
          ? ((product['cantidad'] as int) / totalItems * 100).toStringAsFixed(1)
          : '0';
    }

    // Ordenar datos por hora
    final hourlyList = hourlyStats.values.toList();
    hourlyList
        .sort((a, b) => (a['hora'] as String).compareTo(b['hora'] as String));

    // Crear lista de ventas por día
    final diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayMapping = {
      'Mon': 'Lun',
      'Tue': 'Mar',
      'Wed': 'Mié',
      'Thu': 'Jue',
      'Fri': 'Vie',
      'Sat': 'Sáb',
      'Sun': 'Dom'
    };
    final ventasPorDia = diasSemana.map((dia) {
      double ventas = 0;
      dailyStats.forEach((key, value) {
        if (dayMapping[key] == dia) ventas = value;
      });
      return {'dia': dia, 'ventas': ventas};
    }).toList();

    setState(() {
      _salesData = {
        'total_ventas': totalVentas,
        'total_pedidos': totalPedidos,
        'ticket_promedio': totalPedidos > 0 ? totalVentas / totalPedidos : 0.0,
        'crecimiento': 0.0, // Requiere datos históricos para calcular
        'ventas_por_dia': ventasPorDia,
      };
      _topProducts = productList.take(10).toList().cast<Map<String, dynamic>>();
      _hourlyData = hourlyList.cast<Map<String, dynamic>>();
      _summaryData = {
        'total_clientes': totalPedidos, // Aproximación
        'mesas_atendidas': totalPedidos,
        'tiempo_promedio': 35,
        'reservas_cumplidas': 0,
        'reservas_canceladas': 0,
        'items_vendidos': totalItems,
        'propinas': 0.0,
        'descuentos': 0.0,
      };
    });
  }

  Map<String, dynamic> _getSampleSalesData() {
    return {
      'total_ventas': 15750.50,
      'total_pedidos': 127,
      'ticket_promedio': 124.02,
      'crecimiento': 12.5,
      'ventas_por_dia': [
        {'dia': 'Lun', 'ventas': 2150.0},
        {'dia': 'Mar', 'ventas': 1890.0},
        {'dia': 'Mié', 'ventas': 2340.0},
        {'dia': 'Jue', 'ventas': 2780.0},
        {'dia': 'Vie', 'ventas': 3250.0},
        {'dia': 'Sáb', 'ventas': 3340.0},
        {'dia': 'Dom', 'ventas': 0.0},
      ],
    };
  }

  List<Map<String, dynamic>> _getSampleTopProducts() {
    return [
      {
        'nombre': 'Hamburguesa Clásica',
        'cantidad': 45,
        'ingresos': 675.0,
        'porcentaje': 18.2
      },
      {
        'nombre': 'Pizza Margherita',
        'cantidad': 38,
        'ingresos': 570.0,
        'porcentaje': 15.4
      },
      {
        'nombre': 'Pasta Alfredo',
        'cantidad': 32,
        'ingresos': 448.0,
        'porcentaje': 12.9
      },
      {
        'nombre': 'Tacos al Pastor',
        'cantidad': 28,
        'ingresos': 336.0,
        'porcentaje': 11.3
      },
      {
        'nombre': 'Ensalada César',
        'cantidad': 25,
        'ingresos': 275.0,
        'porcentaje': 10.1
      },
      {
        'nombre': 'Filete Mignon',
        'cantidad': 18,
        'ingresos': 450.0,
        'porcentaje': 7.3
      },
      {
        'nombre': 'Pollo a la Parrilla',
        'cantidad': 22,
        'ingresos': 330.0,
        'porcentaje': 8.9
      },
      {
        'nombre': 'Limonada',
        'cantidad': 65,
        'ingresos': 195.0,
        'porcentaje': 26.3
      },
      {
        'nombre': 'Cerveza',
        'cantidad': 52,
        'ingresos': 260.0,
        'porcentaje': 21.0
      },
      {
        'nombre': 'Postre del Día',
        'cantidad': 15,
        'ingresos': 120.0,
        'porcentaje': 6.1
      },
    ];
  }

  List<Map<String, dynamic>> _getSampleHourlyData() {
    return [
      {'hora': '11:00', 'pedidos': 5, 'ventas': 420.0},
      {'hora': '12:00', 'pedidos': 12, 'ventas': 980.0},
      {'hora': '13:00', 'pedidos': 18, 'ventas': 1560.0},
      {'hora': '14:00', 'pedidos': 15, 'ventas': 1280.0},
      {'hora': '15:00', 'pedidos': 8, 'ventas': 640.0},
      {'hora': '16:00', 'pedidos': 4, 'ventas': 320.0},
      {'hora': '17:00', 'pedidos': 6, 'ventas': 480.0},
      {'hora': '18:00', 'pedidos': 10, 'ventas': 850.0},
      {'hora': '19:00', 'pedidos': 22, 'ventas': 1980.0},
      {'hora': '20:00', 'pedidos': 25, 'ventas': 2250.0},
      {'hora': '21:00', 'pedidos': 20, 'ventas': 1720.0},
      {'hora': '22:00', 'pedidos': 12, 'ventas': 980.0},
    ];
  }

  Map<String, dynamic> _getSampleSummary() {
    return {
      'total_clientes': 89,
      'mesas_atendidas': 45,
      'tiempo_promedio': 42, // minutos
      'reservas_cumplidas': 12,
      'reservas_canceladas': 2,
      'items_vendidos': 247,
      'propinas': 1250.0,
      'descuentos': 350.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Reportes'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Ventas'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Productos'),
            Tab(icon: Icon(Icons.schedule), text: 'Horarios'),
            Tab(icon: Icon(Icons.summarize), text: 'Resumen'),
          ],
        ),
        actions: [
          // Selector de período
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Período',
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadReportData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Hoy')),
              const PopupMenuItem(value: 'yesterday', child: Text('Ayer')),
              const PopupMenuItem(value: 'week', child: Text('Esta semana')),
              const PopupMenuItem(value: 'month', child: Text('Este mes')),
              const PopupMenuItem(
                  value: 'custom', child: Text('Personalizado...')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: 'Exportar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de período y demo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Datos de demostración • Período: ${_getPeriodLabel()}',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSalesTab(),
                      _buildProductsTab(),
                      _buildHoursTab(),
                      _buildSummaryTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Hoy';
      case 'yesterday':
        return 'Ayer';
      case 'week':
        return 'Esta semana';
      case 'month':
        return 'Este mes';
      case 'custom':
        return 'Personalizado';
      default:
        return 'Hoy';
    }
  }

  // ==================== TAB DE VENTAS ====================
  Widget _buildSalesTab() {
    final ventas = _salesData['total_ventas'] ?? 0.0;
    final pedidos = _salesData['total_pedidos'] ?? 0;
    final ticketPromedio = _salesData['ticket_promedio'] ?? 0.0;
    final crecimiento = _salesData['crecimiento'] ?? 0.0;
    final ventasPorDia = _salesData['ventas_por_dia'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Ventas',
                  '\$${ventas.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                  subtitle:
                      '${crecimiento >= 0 ? '+' : ''}${crecimiento.toStringAsFixed(1)}% vs período anterior',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Pedidos',
                  pedidos.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Ticket Promedio',
                  '\$${ticketPromedio.toStringAsFixed(2)}',
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Tasa de Ocupación',
                  '78%',
                  Icons.table_restaurant,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Gráfico de ventas por día
          Text('Ventas por Día', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: _buildBarChart(ventasPorDia),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Desglose de métodos de pago
          Text('Métodos de Pago',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildPaymentMethodsCard(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitle.startsWith('+') ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List ventasPorDia) {
    if (ventasPorDia.isEmpty) return const Center(child: Text('Sin datos'));

    final maxVenta = ventasPorDia
        .map((d) => (d['ventas'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: ventasPorDia.map((data) {
        final ventas = (data['ventas'] as num).toDouble();
        final altura = maxVenta > 0 ? (ventas / maxVenta) * 150 : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${(ventas / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Container(
                  height: altura,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.blue.shade700, Colors.blue.shade300],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['dia'] as String,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodsCard() {
    final methods = [
      {
        'metodo': 'Efectivo',
        'monto': 6300.0,
        'porcentaje': 40,
        'color': Colors.green
      },
      {
        'metodo': 'Tarjeta Crédito',
        'monto': 5512.50,
        'porcentaje': 35,
        'color': Colors.blue
      },
      {
        'metodo': 'Tarjeta Débito',
        'monto': 3150.0,
        'porcentaje': 20,
        'color': Colors.orange
      },
      {
        'metodo': 'Transferencia',
        'monto': 788.0,
        'porcentaje': 5,
        'color': Colors.purple
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: methods.map((m) {
            final color = m['color'] as Color;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(m['metodo'] as String)),
                  Text('\$${(m['monto'] as double).toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: (m['porcentaje'] as int) / 100,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child:
                        Text('${m['porcentaje']}%', textAlign: TextAlign.end),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==================== TAB DE PRODUCTOS ====================
  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏆 Top 10 Productos Más Vendidos',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _topProducts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = _topProducts[index];
                final isTop3 = index < 3;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTop3
                        ? [
                            Colors.amber,
                            Colors.grey.shade400,
                            Colors.brown.shade300
                          ][index]
                        : Colors.grey.shade200,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isTop3 ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product['nombre'],
                    style: TextStyle(
                        fontWeight:
                            isTop3 ? FontWeight.bold : FontWeight.normal),
                  ),
                  subtitle: Text('${product['cantidad']} unidades vendidas'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product['ingresos'].toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        '${product['porcentaje']}%',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Ventas por categoría
          Text('Ventas por Categoría',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildCategorySalesCard(),
        ],
      ),
    );
  }

  Widget _buildCategorySalesCard() {
    final categories = [
      {'categoria': 'Principales', 'ventas': 8500.0, 'porcentaje': 54},
      {'categoria': 'Bebidas', 'ventas': 3200.0, 'porcentaje': 20},
      {'categoria': 'Entradas', 'ventas': 2100.0, 'porcentaje': 13},
      {'categoria': 'Postres', 'ventas': 1200.0, 'porcentaje': 8},
      {'categoria': 'Acompañamientos', 'ventas': 750.0, 'porcentaje': 5},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categories.map((c) {
            final porcentaje = c['porcentaje'] as int;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['categoria'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('\$${(c['ventas'] as double).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: porcentaje / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==================== TAB DE HORARIOS ====================
  Widget _buildHoursTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⏰ Actividad por Hora',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Identifica las horas pico de tu restaurante',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Gráfico de horas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _hourlyData.map((data) {
                  final hora = data['hora'] as String;
                  final pedidos = data['pedidos'] as int;
                  final ventas = data['ventas'] as double;
                  final maxPedidos = _hourlyData
                      .map((d) => d['pedidos'] as int)
                      .reduce((a, b) => a > b ? a : b);
                  final porcentaje =
                      maxPedidos > 0 ? pedidos / maxPedidos : 0.0;

                  // Determinar si es hora pico
                  final isPeak = pedidos >= maxPedidos * 0.8;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            hora,
                            style: TextStyle(
                              fontWeight:
                                  isPeak ? FontWeight.bold : FontWeight.normal,
                              color: isPeak ? Colors.red : null,
                            ),
                          ),
                        ),
                        if (isPeak)
                          const Icon(Icons.local_fire_department,
                              color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: porcentaje,
                                child: Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPeak
                                          ? [
                                              Colors.red.shade400,
                                              Colors.orange.shade400
                                            ]
                                          : [
                                              Colors.blue.shade400,
                                              Colors.blue.shade200
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    '$pedidos pedidos',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 70,
                          child: Text(
                            '\$${ventas.toStringAsFixed(0)}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Insights
          Text('💡 Insights', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildInsightCard(
            Icons.trending_up,
            'Hora Pico',
            '19:00 - 21:00 es tu horario de mayor actividad',
            Colors.red,
          ),
          _buildInsightCard(
            Icons.trending_down,
            'Hora Valle',
            '15:00 - 17:00 baja actividad, considera promociones',
            Colors.blue,
          ),
          _buildInsightCard(
            Icons.restaurant,
            'Almuerzo',
            '13:00 tiene el pico del almuerzo con 18 pedidos',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      IconData icon, String title, String description, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  // ==================== TAB DE RESUMEN ====================
  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 Resumen del Período',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Grid de métricas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildSummaryCard(
                  'Clientes Atendidos',
                  '${_summaryData['total_clientes']}',
                  Icons.people,
                  Colors.blue),
              _buildSummaryCard(
                  'Mesas Atendidas',
                  '${_summaryData['mesas_atendidas']}',
                  Icons.table_restaurant,
                  Colors.green),
              _buildSummaryCard(
                  'Tiempo Prom. Mesa',
                  '${_summaryData['tiempo_promedio']} min',
                  Icons.timer,
                  Colors.orange),
              _buildSummaryCard(
                  'Items Vendidos',
                  '${_summaryData['items_vendidos']}',
                  Icons.restaurant_menu,
                  Colors.purple),
              _buildSummaryCard(
                  'Reservas Cumplidas',
                  '${_summaryData['reservas_cumplidas']}',
                  Icons.event_available,
                  Colors.teal),
              _buildSummaryCard(
                  'Reservas Canceladas',
                  '${_summaryData['reservas_canceladas']}',
                  Icons.event_busy,
                  Colors.red),
              _buildSummaryCard('Propinas', '\$${_summaryData['propinas']}',
                  Icons.volunteer_activism, Colors.pink),
              _buildSummaryCard('Descuentos', '\$${_summaryData['descuentos']}',
                  Icons.discount, Colors.amber),
            ],
          ),

          const SizedBox(height: 24),

          // Comparativa
          Text('📊 Comparativa', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildComparisonCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    final comparisons = [
      {
        'metrica': 'Ventas',
        'actual': '\$15,750',
        'anterior': '\$14,000',
        'cambio': 12.5,
        'positivo': true
      },
      {
        'metrica': 'Pedidos',
        'actual': '127',
        'anterior': '115',
        'cambio': 10.4,
        'positivo': true
      },
      {
        'metrica': 'Ticket Promedio',
        'actual': '\$124',
        'anterior': '\$122',
        'cambio': 1.6,
        'positivo': true
      },
      {
        'metrica': 'Cancelaciones',
        'actual': '2',
        'anterior': '5',
        'cambio': -60.0,
        'positivo': true
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text('Métrica',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Actual',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Anterior',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Cambio',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            ...comparisons.map((c) {
              final cambio = c['cambio'] as double;
              final positivo = c['positivo'] as bool;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(c['metrica'] as String)),
                    Expanded(
                        child: Text(c['actual'] as String,
                            textAlign: TextAlign.center)),
                    Expanded(
                      child: Text(
                        c['anterior'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            positivo
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 14,
                            color: positivo ? Colors.green : Colors.red,
                          ),
                          Text(
                            '${cambio.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: positivo ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    final exportService = ExportService();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Exportar Reporte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      await _exportToPdf(exportService);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ExportButton(
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green,
                    onTap: () async {
                      Navigator.pop(context);
                      await _exportToExcel(exportService);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToPdf(ExportService exportService) async {
    try {
      _showLoadingDialog('Generando PDF...');

      final file = await exportService.exportSalesReportToPdf(
        salesData: {
          'totalSales': 45750.00,
          'totalOrders': 128,
          'averageTicket': 357.42,
          'weeklyData': [
            {'label': 'Lun', 'value': 5200},
            {'label': 'Mar', 'value': 4800},
            {'label': 'Mié', 'value': 6100},
            {'label': 'Jue', 'value': 5900},
            {'label': 'Vie', 'value': 8200},
            {'label': 'Sáb', 'value': 9500},
            {'label': 'Dom', 'value': 6050},
          ],
          'paymentMethods': [
            {'method': 'Tarjeta', 'amount': 27450, 'percentage': 60},
            {'method': 'Efectivo', 'amount': 13725, 'percentage': 30},
            {'method': 'Transferencia', 'amount': 4575, 'percentage': 10},
          ],
        },
        period: _selectedPeriod,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        await exportService.shareFile(file,
            subject: 'Reporte de Ventas - SmartDinner');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToExcel(ExportService exportService) async {
    try {
      _showLoadingDialog('Generando Excel...');

      final file = await exportService.exportSalesReportToExcel(
        salesData: {
          'totalSales': 45750.00,
          'totalOrders': 128,
          'averageTicket': 357.42,
          'paymentMethods': [
            {'method': 'Tarjeta', 'amount': 27450, 'percentage': 60},
            {'method': 'Efectivo', 'amount': 13725, 'percentage': 30},
            {'method': 'Transferencia', 'amount': 4575, 'percentage': 10},
          ],
        },
        dailyData: [
          {
            'date': '25/11/2024',
            'sales': 5200,
            'orders': 18,
            'averageTicket': 288.89
          },
          {
            'date': '26/11/2024',
            'sales': 4800,
            'orders': 15,
            'averageTicket': 320.00
          },
          {
            'date': '27/11/2024',
            'sales': 6100,
            'orders': 20,
            'averageTicket': 305.00
          },
        ],
        period: _selectedPeriod,
      );

      if (mounted) {
        Navigator.pop(context);

        await exportService.shareFile(file,
            subject: 'Reporte de Ventas - SmartDinner');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Excel generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
