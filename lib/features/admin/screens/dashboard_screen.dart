import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/routes.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/state/theme_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabaseService = SupabaseService();
  final _supabase = Supabase.instance.client;

  // Statistics data
  int _todayReservations = 0;
  int _todayOrders = 0;
  double _todayRevenue = 0.0;
  int _occupiedTables = 0;
  int _totalTables = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final today = DateTime.now();
      final todayStart =
          DateTime(today.year, today.month, today.day).toIso8601String();
      final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();

      // Fetch today's reservations count
      final reservationsResponse = await _supabase
          .from('reservations')
          .select('id')
          .gte('created_at', todayStart)
          .lte('created_at', todayEnd);

      // Fetch today's orders with total
      final ordersResponse = await _supabase
          .from('orders')
          .select('id, total')
          .gte('created_at', todayStart)
          .lte('created_at', todayEnd);

      // Calculate revenue from orders
      double revenue = 0.0;
      for (var order in ordersResponse) {
        revenue += (order['total'] ?? 0).toDouble();
      }

      // Fetch tables status
      final tablesResponse = await _supabase.from('mesas').select('id, estado');

      int occupied = 0;
      for (var table in tablesResponse) {
        if (table['estado'] == 'ocupada' || table['estado'] == 'reservada') {
          occupied++;
        }
      }

      // Fetch recent activity (last 10 events)
      final recentOrders = await _supabase
          .from('orders')
          .select('id, status, created_at')
          .order('created_at', ascending: false)
          .limit(3);

      final recentReservations = await _supabase
          .from('reservations')
          .select('id, party_size, created_at')
          .order('created_at', ascending: false)
          .limit(3);

      // Build activity list
      List<Map<String, dynamic>> activities = [];

      for (var reservation in recentReservations) {
        activities.add({
          'title': 'Nueva reserva para ${reservation['party_size']} personas',
          'time': _formatTimeAgo(DateTime.parse(reservation['created_at'])),
          'icon': Icons.event,
          'timestamp': DateTime.parse(reservation['created_at']),
        });
      }

      for (var order in recentOrders) {
        activities.add({
          'title':
              'Pedido #${order['id'].toString().substring(0, 4)} - ${order['status']}',
          'time': _formatTimeAgo(DateTime.parse(order['created_at'])),
          'icon': Icons.receipt_long,
          'timestamp': DateTime.parse(order['created_at']),
        });
      }

      // Sort by timestamp
      activities.sort((a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      setState(() {
        _todayReservations = reservationsResponse.length;
        _todayOrders = ordersResponse.length;
        _todayRevenue = revenue;
        _occupiedTables = occupied;
        _totalTables = tablesResponse.length;
        _recentActivity = activities.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrativo'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              } else if (value == 'theme_light') {
                context.read<ThemeNotifier>().setMode(ThemeMode.light);
              } else if (value == 'theme_dark') {
                context.read<ThemeNotifier>().setMode(ThemeMode.dark);
              } else if (value == 'theme_system') {
                context.read<ThemeNotifier>().setMode(ThemeMode.system);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Text('Perfil'),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text('Configuración'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child:
                    Text('Tema', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: 'theme_light',
                child: Text('Claro'),
              ),
              PopupMenuItem(
                value: 'theme_dark',
                child: Text('Oscuro'),
              ),
              PopupMenuItem(
                value: 'theme_system',
                child: Text('Sistema'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar Sesión'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics cards
                    _buildStatsSection(),
                    SizedBox(height: 24),

                    // Quick actions
                    _buildQuickActions(),
                    SizedBox(height: 24),

                    // Recent activity
                    _buildRecentActivity(),
                    SizedBox(height: 24),

                    // AI Predictions
                    _buildPredictionsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas de Hoy',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Reservas', '$_todayReservations',
                    Icons.event, Colors.blue)),
            SizedBox(width: 12),
            Expanded(
                child: _buildStatCard('Pedidos', '$_todayOrders',
                    Icons.shopping_cart, Colors.green)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Ingresos',
                    '\$${_todayRevenue.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.orange)),
            SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Mesas Ocupadas',
                    '$_occupiedTables/$_totalTables',
                    Icons.table_restaurant,
                    Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionCard(
              'Cocina',
              Icons.soup_kitchen,
              Colors.red,
              () {
                Navigator.pushNamed(context, AppRoutes.kitchen);
              },
            ),
            _buildActionCard(
              'Reportes',
              Icons.bar_chart,
              Colors.cyan,
              () {
                Navigator.pushNamed(context, AppRoutes.reports);
              },
            ),
            _buildActionCard(
              'Usuarios',
              Icons.people_outline,
              Colors.purple,
              () {
                Navigator.pushNamed(context, AppRoutes.adminUsers);
              },
            ),
            _buildActionCard(
              'Mesas',
              Icons.table_restaurant,
              Colors.teal,
              () {
                Navigator.pushNamed(context, AppRoutes.tablesManagement);
              },
            ),
            _buildActionCard(
              'Inventario',
              Icons.inventory_2,
              Colors.indigo,
              () {
                Navigator.pushNamed(context, AppRoutes.inventory);
              },
            ),
            _buildActionCard(
              'Reservas',
              Icons.event_note,
              Colors.blue,
              () {
                Navigator.pushNamed(context, AppRoutes.reservations);
              },
            ),
            _buildActionCard(
              'Pedidos',
              Icons.receipt_long,
              Colors.green,
              () {
                Navigator.pushNamed(context, AppRoutes.orders);
              },
            ),
            _buildActionCard(
              'Menú',
              Icons.restaurant_menu,
              Colors.orange,
              () {
                Navigator.pushNamed(context, '/admin/menu');
              },
            ),
            _buildActionCard(
              'IA',
              Icons.auto_awesome,
              Colors.deepPurple,
              () {
                Navigator.pushNamed(context, AppRoutes.aiPredictions);
              },
            ),
            _buildActionCard(
              'Pruebas',
              Icons.science,
              Colors.pink,
              () {
                Navigator.pushNamed(context, AppRoutes.integrationTests);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Card(
          child: _recentActivity.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No hay actividad reciente'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _recentActivity.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final activity = _recentActivity[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Icon(activity['icon'] as IconData,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      title: Text(activity['title'] as String),
                      subtitle: Text(activity['time'] as String),
                      dense: true,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPredictionsSection() {
    // Datos de ejemplo para demostración
    final samplePredictions = [
      {'level': 'high'},
      {'level': 'high'},
      {'level': 'high'},
      {'level': 'medium'},
      {'level': 'low'},
    ];

    final highDemand =
        samplePredictions.where((p) => p['level'] == 'high').length;

    return Card(
      child: ListTile(
        leading: Icon(Icons.trending_up, color: Colors.red),
        title: Text('$highDemand items de alta demanda'),
        subtitle: const Text('Predicción para mañana (Demo)'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.aiPredictions);
        },
      ),
    );
  }

  Widget _buildPredictionItem(String item, int percentage, String level) {
    Color levelColor;
    switch (level) {
      case 'Alto':
        levelColor = Colors.red;
        break;
      case 'Medio':
        levelColor = Colors.orange;
        break;
      default:
        levelColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item, style: TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: levelColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
