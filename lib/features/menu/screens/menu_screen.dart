import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<int, int> cart = {}; // item_id -> quantity

  final List<String> categories = [
    'Entradas',
    'Platos Principales',
    'Bebidas',
    'Postres'
  ];

  final Map<String, List<Map<String, dynamic>>> menuItems = {
    'Entradas': [
      {
        'id': 1,
        'name': 'Ensalada César',
        'description': 'Lechuga romana, crutones, parmesano y aderezo césar',
        'price': 8.99,
        'image': 'assets/images/caesar_salad.jpg',
      },
      {
        'id': 2,
        'name': 'Bruschetta',
        'description': 'Pan tostado con tomate, albahaca y mozzarella',
        'price': 6.99,
        'image': 'assets/images/bruschetta.jpg',
      },
    ],
    'Platos Principales': [
      {
        'id': 3,
        'name': 'Pizza Margherita',
        'description': 'Salsa de tomate, mozzarella fresca y albahaca',
        'price': 14.99,
        'image': 'assets/images/margherita.jpg',
      },
      {
        'id': 4,
        'name': 'Pasta Carbonara',
        'description': 'Espaguetis con panceta, huevo, parmesano y pimienta negra',
        'price': 12.99,
        'image': 'assets/images/carbonara.jpg',
      },
    ],
    'Bebidas': [
      {
        'id': 5,
        'name': 'Coca-Cola',
        'description': 'Refrescante bebida cola (355ml)',
        'price': 2.50,
        'image': 'assets/images/coca_cola.jpg',
      },
      {
        'id': 6,
        'name': 'Agua Natural',
        'description': 'Agua purificada (500ml)',
        'price': 1.50,
        'image': 'assets/images/water.jpg',
      },
    ],
    'Postres': [
      {
        'id': 7,
        'name': 'Tiramisu',
        'description': 'Clásico postre italiano con mascarpone y café',
        'price': 7.99,
        'image': 'assets/images/tiramisu.jpg',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _showCart,
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.values.fold(0, (sum, qty) => sum + qty)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) => _buildCategoryItems(category)).toList(),
      ),
    );
  }

  Widget _buildCategoryItems(String category) {
    final items = menuItems[category] ?? [];
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16),
                
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${item['price'].toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Add to cart button
                Column(
                  children: [
                    if (cart.containsKey(item['id']))
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _removeFromCart(item['id']),
                            icon: Icon(Icons.remove_circle_outline),
                            iconSize: 20,
                          ),
                          Text('${cart[item['id']]}'),
                          IconButton(
                            onPressed: () => _addToCart(item['id']),
                            icon: Icon(Icons.add_circle_outline),
                            iconSize: 20,
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _addToCart(item['id']),
                        child: Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, 36),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCart(int itemId) {
    setState(() {
      cart[itemId] = (cart[itemId] ?? 0) + 1;
    });
  }

  void _removeFromCart(int itemId) {
    setState(() {
      if (cart[itemId] != null) {
        if (cart[itemId]! > 1) {
          cart[itemId] = cart[itemId]! - 1;
        } else {
          cart.remove(itemId);
        }
      }
    });
  }

  void _showCart() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carrito de Compras',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            ...cart.entries.map((entry) {
              final itemId = entry.key;
              final quantity = entry.value;
              // Find item details (simplified for demo)
              return ListTile(
                title: Text('Item #$itemId'),
                subtitle: Text('Cantidad: $quantity'),
                trailing: Text('\$${(10.99 * quantity).toStringAsFixed(2)}'),
              );
            }).toList(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '\$${_calculateTotal().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido realizado (funcionalidad por implementar)')),
                );
                setState(() {
                  cart.clear();
                });
              },
              child: Text('Realizar Pedido'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    // Simplified calculation for demo
    return cart.values.fold(0.0, (sum, qty) => sum + (qty * 10.99));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}