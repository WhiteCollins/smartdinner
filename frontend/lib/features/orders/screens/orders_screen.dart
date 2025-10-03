import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pedidos Actuales'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentOrders(),
          _buildOrderHistory(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/menu');
        },
        child: Icon(Icons.add_shopping_cart),
        tooltip: 'Hacer nuevo pedido',
      ),
    );
  }

  Widget _buildCurrentOrders() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Active orders
          Expanded(
            child: ListView.builder(
              itemCount: 2, // Placeholder count
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pedido #${1001 + index}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(index == 0 ? 'Preparando' : 'En camino'),
                              backgroundColor: index == 0 ? Colors.orange[100] : Colors.blue[100],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Pizza Margherita x1'),
                        Text('Coca-Cola x2'),
                        Text('Ensalada César x1'),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${(25.99 + index * 5).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tiempo estimado: ${15 + index * 10} min',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: index == 0 ? 0.6 : 0.8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: Text('Pedido #${1000 - index}'),
              subtitle: Text('${15 + index} de Octubre, 2024 - \$${(20 + index * 3).toStringAsFixed(2)}'),
              trailing: TextButton(
                onPressed: () {
                  // TODO: Show order details or reorder
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ver detalles del pedido')),
                  );
                },
                child: Text('Ver detalles'),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
