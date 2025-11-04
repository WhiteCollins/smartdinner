import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrativo'),
        actions: [
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
                value: 'logout',
                child: Text('Cerrar Sesión'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            Expanded(child: _buildStatCard('Reservas', '24', Icons.event, Colors.blue)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Pedidos', '67', Icons.shopping_cart, Colors.green)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Ingresos', '\$1,234', Icons.attach_money, Colors.orange)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Mesas Ocupadas', '18/25', Icons.table_restaurant, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
                color: Colors.grey[600],
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Gestionar Reservas',
              Icons.event_note,
              Colors.blue,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navegando a reservas...')),
                );
              },
            ),
            _buildActionCard(
              'Ver Pedidos',
              Icons.list_alt,
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navegando a pedidos...')),
                );
              },
            ),
            _buildActionCard(
              'Gestionar Menú',
              Icons.restaurant_menu,
              Colors.orange,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navegando a menú...')),
                );
              },
            ),
            _buildActionCard(
              'Predicciones IA',
              Icons.analytics,
              Colors.purple,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navegando a predicciones...')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final activities = [
                {'title': 'Nueva reserva para 4 personas', 'time': 'Hace 5 min', 'icon': Icons.event},
                {'title': 'Pedido #1001 completado', 'time': 'Hace 12 min', 'icon': Icons.check_circle},
                {'title': 'Mesa 7 liberada', 'time': 'Hace 18 min', 'icon': Icons.table_restaurant},
                {'title': 'Nuevo platillo agregado al menú', 'time': 'Hace 1 hora', 'icon': Icons.add_circle},
                {'title': 'Predicción IA actualizada', 'time': 'Hace 2 horas', 'icon': Icons.analytics},
              ];
              
              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(activity['icon'] as IconData, size: 20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Predicciones IA',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Demanda Prevista para Mañana',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildPredictionItem('Pizza Margherita', 85, 'Alto'),
                _buildPredictionItem('Pasta Carbonara', 67, 'Medio'),
                _buildPredictionItem('Ensalada César', 45, 'Medio'),
                _buildPredictionItem('Tiramisu', 23, 'Bajo'),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver predicciones detalladas...')),
                    );
                  },
                  child: Text('Ver Análisis Completo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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