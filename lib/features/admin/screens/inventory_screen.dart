import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = true;
  String _filterCategory = 'Todos';
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _usingRealData = false;

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      // Cargar inventario desde Supabase (campos en español)
      final inventoryResponse = await _supabase
          .from('inventory')
          .select()
          .eq('is_active', true)
          .order('nombre');

      if ((inventoryResponse as List).isNotEmpty) {
        setState(() {
          _items = inventoryResponse
              .map((item) => {
                    'id': item['id'],
                    'nombre': item['nombre'] ?? 'Sin nombre',
                    'categoria': item['categoria'] ?? 'General',
                    'cantidad': (item['cantidad'] as num?)?.toDouble() ?? 0,
                    'unidad': item['unidad'] ?? 'unidad',
                    'minimo': (item['stock_minimo'] as num?)?.toDouble() ?? 10,
                    'precio_unitario':
                        (item['precio_unitario'] as num?)?.toDouble() ?? 0,
                    'proveedor': item['proveedor'] ?? 'Sin asignar',
                    'ultima_actualizacion': item['updated_at'] != null
                        ? DateTime.parse(item['updated_at'])
                        : DateTime.now(),
                    'fecha_vencimiento': item['fecha_vencimiento'] != null
                        ? DateTime.parse(item['fecha_vencimiento'])
                        : DateTime.now().add(const Duration(days: 30)),
                  })
              .toList();

          _suppliers = _getSampleSuppliers();
          _isLoading = false;
          _usingRealData = true;
        });
        debugPrint(
            '✅ Inventario cargado: ${_items.length} items desde Supabase');
      } else {
        debugPrint('⚠️ Tabla inventory vacía');
        _loadSampleData();
      }
    } catch (e) {
      // Si falla, usar datos de ejemplo
      debugPrint('⚠️ Error cargando inventario: $e');
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    setState(() {
      _items = _getSampleItems();
      _suppliers = _getSampleSuppliers();
      _isLoading = false;
      _usingRealData = false;
    });
  }

  String _getCategoryFromName(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('tomate') ||
        nameLower.contains('cebolla') ||
        nameLower.contains('lechuga') ||
        nameLower.contains('zanahoria')) {
      return 'Vegetales';
    } else if (nameLower.contains('pollo') ||
        nameLower.contains('carne') ||
        nameLower.contains('res') ||
        nameLower.contains('cerdo')) {
      return 'Carnes';
    } else if (nameLower.contains('queso') ||
        nameLower.contains('leche') ||
        nameLower.contains('crema')) {
      return 'Lácteos';
    } else if (nameLower.contains('aceite') ||
        nameLower.contains('sal') ||
        nameLower.contains('pimienta')) {
      return 'Condimentos';
    } else if (nameLower.contains('pasta') ||
        nameLower.contains('arroz') ||
        nameLower.contains('harina')) {
      return 'Granos';
    } else if (nameLower.contains('vino') ||
        nameLower.contains('cerveza') ||
        nameLower.contains('agua') ||
        nameLower.contains('refresco')) {
      return 'Bebidas';
    }
    return 'Otros';
  }

  List<Map<String, dynamic>> _getSampleItems() {
    return [
      {
        'id': '1',
        'nombre': 'Tomates',
        'categoria': 'Vegetales',
        'cantidad': 50,
        'unidad': 'kg',
        'minimo': 20,
        'precio_unitario': 2.5,
        'proveedor': 'Frutas y Verduras SA',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(hours: 2)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 5)),
      },
      {
        'id': '2',
        'nombre': 'Pollo',
        'categoria': 'Carnes',
        'cantidad': 15,
        'unidad': 'kg',
        'minimo': 25,
        'precio_unitario': 8.5,
        'proveedor': 'Carnes Premium',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(hours: 5)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 3)),
      },
      {
        'id': '3',
        'nombre': 'Pasta Spaghetti',
        'categoria': 'Granos',
        'cantidad': 80,
        'unidad': 'kg',
        'minimo': 30,
        'precio_unitario': 1.8,
        'proveedor': 'Distribuidora Central',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(days: 1)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 180)),
      },
      {
        'id': '4',
        'nombre': 'Aceite de Oliva',
        'categoria': 'Condimentos',
        'cantidad': 12,
        'unidad': 'L',
        'minimo': 10,
        'precio_unitario': 12.0,
        'proveedor': 'Importadora Gourmet',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(days: 3)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 365)),
      },
      {
        'id': '5',
        'nombre': 'Queso Mozzarella',
        'categoria': 'Lácteos',
        'cantidad': 8,
        'unidad': 'kg',
        'minimo': 15,
        'precio_unitario': 6.5,
        'proveedor': 'Lácteos del Valle',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(hours: 8)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 14)),
      },
      {
        'id': '6',
        'nombre': 'Cebolla',
        'categoria': 'Vegetales',
        'cantidad': 30,
        'unidad': 'kg',
        'minimo': 15,
        'precio_unitario': 1.2,
        'proveedor': 'Frutas y Verduras SA',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(hours: 12)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 30)),
      },
      {
        'id': '7',
        'nombre': 'Carne de Res',
        'categoria': 'Carnes',
        'cantidad': 20,
        'unidad': 'kg',
        'minimo': 15,
        'precio_unitario': 12.0,
        'proveedor': 'Carnes Premium',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(hours: 3)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 4)),
      },
      {
        'id': '8',
        'nombre': 'Vino Tinto',
        'categoria': 'Bebidas',
        'cantidad': 24,
        'unidad': 'botellas',
        'minimo': 12,
        'precio_unitario': 15.0,
        'proveedor': 'Distribuidora de Vinos',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(days: 7)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 730)),
      },
      {
        'id': '9',
        'nombre': 'Lechuga',
        'categoria': 'Vegetales',
        'cantidad': 5,
        'unidad': 'kg',
        'minimo': 10,
        'precio_unitario': 1.5,
        'proveedor': 'Frutas y Verduras SA',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(hours: 1)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 2)),
      },
      {
        'id': '10',
        'nombre': 'Sal',
        'categoria': 'Condimentos',
        'cantidad': 50,
        'unidad': 'kg',
        'minimo': 10,
        'precio_unitario': 0.5,
        'proveedor': 'Distribuidora Central',
        'ultima_actualizacion':
            DateTime.now().subtract(const Duration(days: 14)),
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 1095)),
      },
    ];
  }

  List<Map<String, dynamic>> _getSampleSuppliers() {
    return [
      {
        'id': '1',
        'nombre': 'Frutas y Verduras SA',
        'contacto': 'Juan Pérez',
        'telefono': '+1 809-555-0101',
        'email': 'contacto@frutasyverduras.com',
        'direccion': 'Calle Principal #123',
        'categoria': 'Vegetales',
        'activo': true,
      },
      {
        'id': '2',
        'nombre': 'Carnes Premium',
        'contacto': 'María García',
        'telefono': '+1 809-555-0102',
        'email': 'ventas@carnespremium.com',
        'direccion': 'Av. Industrial #456',
        'categoria': 'Carnes',
        'activo': true,
      },
      {
        'id': '3',
        'nombre': 'Distribuidora Central',
        'contacto': 'Carlos Rodríguez',
        'telefono': '+1 809-555-0103',
        'email': 'pedidos@distcentral.com',
        'direccion': 'Zona Industrial Norte',
        'categoria': 'General',
        'activo': true,
      },
      {
        'id': '4',
        'nombre': 'Lácteos del Valle',
        'contacto': 'Ana Martínez',
        'telefono': '+1 809-555-0104',
        'email': 'ventas@lacteosvalle.com',
        'direccion': 'Carretera del Valle km 5',
        'categoria': 'Lácteos',
        'activo': true,
      },
      {
        'id': '5',
        'nombre': 'Importadora Gourmet',
        'contacto': 'Roberto Sánchez',
        'telefono': '+1 809-555-0105',
        'email': 'info@gourmetimport.com',
        'direccion': 'Centro Comercial Plaza',
        'categoria': 'Especialidades',
        'activo': false,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredItems {
    var items = _items;

    if (_filterCategory != 'Todos') {
      items =
          items.where((item) => item['categoria'] == _filterCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              (item['nombre'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (item['proveedor'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  List<Map<String, dynamic>> get _lowStockItems {
    return _items
        .where((item) => (item['cantidad'] as num) < (item['minimo'] as num))
        .toList();
  }

  List<Map<String, dynamic>> get _expiringItems {
    final now = DateTime.now();
    return _items.where((item) {
      final expiry = item['fecha_vencimiento'] as DateTime;
      return expiry.difference(now).inDays <= 7;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Stock'),
            Tab(icon: Icon(Icons.warning), text: 'Alertas'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Proveedores'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStockTab(),
                _buildAlertsTab(),
                _buildSuppliersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Item'),
      ),
    );
  }

  // ==================== TAB DE STOCK ====================
  Widget _buildStockTab() {
    return Column(
      children: [
        // Banner de demo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Datos de demostración',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
              ),
            ],
          ),
        ),

        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o proveedor...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Filtros
        _buildCategoryFilter(),

        // Resumen rápido
        _buildQuickSummary(),

        // Lista de items
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return _buildInventoryCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickSummary() {
    final totalItems = _items.length;
    final lowStock = _lowStockItems.length;
    final expiring = _expiringItems.length;
    final totalValue = _items.fold<double>(
        0,
        (sum, item) =>
            sum + (item['cantidad'] as num) * (item['precio_unitario'] as num));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard('Total Items', totalItems.toString(),
                Colors.blue, Icons.inventory),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard('Stock Bajo', lowStock.toString(),
                Colors.orange, Icons.warning),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
                'Por Vencer', expiring.toString(), Colors.red, Icons.schedule),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
                'Valor',
                '\$${totalValue.toStringAsFixed(0)}',
                Colors.green,
                Icons.attach_money),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'Todos',
      'Vegetales',
      'Carnes',
      'Granos',
      'Condimentos',
      'Lácteos',
      'Bebidas'
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _filterCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _filterCategory = category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No se encontraron items',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final cantidad = item['cantidad'] as num;
    final minimo = item['minimo'] as num;
    final isLowStock = cantidad < minimo;
    final expiry = item['fecha_vencimiento'] as DateTime;
    final isExpiringSoon = expiry.difference(DateTime.now()).inDays <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isLowStock ? Colors.orange.withOpacity(0.5) : Colors.transparent,
          width: isLowStock ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono de categoría
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isLowStock ? Colors.orange : Colors.green)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(item['categoria'] as String),
                  color: isLowStock ? Colors.orange : Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Información del item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['nombre'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BAJO',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (isExpiringSoon)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VENCE',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['categoria']} • ${item['proveedor']}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Cantidad actual
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isLowStock ? Colors.orange : Colors.green)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$cantidad ${item['unidad']}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isLowStock ? Colors.orange : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mín: $minimo',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        Text(
                          '\$${item['precio_unitario']}/${item['unidad']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de acciones
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Agregar Stock'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle,
                            color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('Retirar Stock'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'add':
                      _showStockDialog(item, true);
                      break;
                    case 'remove':
                      _showStockDialog(item, false);
                      break;
                    case 'edit':
                      _showEditItemDialog(item);
                      break;
                    case 'delete':
                      _confirmDeleteItem(item);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB DE ALERTAS ====================
  Widget _buildAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sección de Stock Bajo
        _buildAlertSection(
          'Stock Bajo',
          Icons.warning,
          Colors.orange,
          _lowStockItems,
          (item) =>
              'Quedan ${item['cantidad']} ${item['unidad']} (mín: ${item['minimo']})',
        ),

        const SizedBox(height: 24),

        // Sección de Por Vencer
        _buildAlertSection(
          'Por Vencer',
          Icons.schedule,
          Colors.red,
          _expiringItems,
          (item) {
            final expiry = item['fecha_vencimiento'] as DateTime;
            final days = expiry.difference(DateTime.now()).inDays;
            return days <= 0 ? '¡VENCIDO!' : 'Vence en $days días';
          },
        ),
      ],
    );
  }

  Widget _buildAlertSection(
    String title,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) getSubtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                items.length.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle,
                        size: 48, color: Colors.green.shade300),
                    const SizedBox(height: 8),
                    Text('Sin alertas',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          )
        else
          ...items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child:
                        Icon(_getCategoryIcon(item['categoria']), color: color),
                  ),
                  title: Text(item['nombre']),
                  subtitle: Text(getSubtitle(item)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _showStockDialog(item, true),
                        tooltip: 'Agregar Stock',
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.shopping_cart, color: Colors.blue),
                        onPressed: () => _showOrderDialog(item),
                        tooltip: 'Hacer Pedido',
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ==================== TAB DE PROVEEDORES ====================
  Widget _buildSuppliersTab() {
    return Column(
      children: [
        // Botón para agregar proveedor
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddSupplierDialog,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Proveedor'),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suppliers.length,
            itemBuilder: (context, index) {
              final supplier = _suppliers[index];
              return _buildSupplierCard(supplier);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> supplier) {
    final isActive = supplier['activo'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            Icons.local_shipping,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(supplier['nombre'],
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            if (!isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('INACTIVO',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
          ],
        ),
        subtitle: Text(supplier['categoria']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person, 'Contacto', supplier['contacto']),
                _buildInfoRow(Icons.phone, 'Teléfono', supplier['telefono']),
                _buildInfoRow(Icons.email, 'Email', supplier['email']),
                _buildInfoRow(
                    Icons.location_on, 'Dirección', supplier['direccion']),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Llamar al proveedor
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Llamando a ${supplier['telefono']}')),
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Llamar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showOrderDialog({'proveedor': supplier['nombre']}),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Hacer Pedido'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ==================== UTILIDADES ====================
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vegetales':
        return Icons.eco;
      case 'Carnes':
        return Icons.set_meal;
      case 'Granos':
        return Icons.grain;
      case 'Condimentos':
        return Icons.coffee;
      case 'Lácteos':
        return Icons.water_drop;
      case 'Bebidas':
        return Icons.local_bar;
      default:
        return Icons.inventory;
    }
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getCategoryIcon(item['categoria']),
                        size: 40, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nombre'],
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text(item['categoria'],
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow(
                  'Stock Actual', '${item['cantidad']} ${item['unidad']}'),
              _buildDetailRow(
                  'Stock Mínimo', '${item['minimo']} ${item['unidad']}'),
              _buildDetailRow(
                  'Precio Unitario', '\$${item['precio_unitario']}'),
              _buildDetailRow('Valor en Stock',
                  '\$${((item['cantidad'] as num) * (item['precio_unitario'] as num)).toStringAsFixed(2)}'),
              _buildDetailRow('Proveedor', item['proveedor']),
              _buildDetailRow(
                  'Vencimiento', _formatDate(item['fecha_vencimiento'])),
              _buildDetailRow('Última Actualización',
                  _formatDateTime(item['ultima_actualizacion'])),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showStockDialog(item, true);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showStockDialog(item, false);
                      },
                      icon: const Icon(Icons.remove),
                      label: const Text('Retirar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showStockDialog(Map<String, dynamic> item, bool isAdding) {
    final cantidadController = TextEditingController();
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isAdding ? Icons.add_circle : Icons.remove_circle,
                color: isAdding ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(isAdding ? 'Agregar Stock' : 'Retirar Stock'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nombre'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Stock actual: ${item['cantidad']} ${item['unidad']}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (${item['unidad']})',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(isAdding ? Icons.add : Icons.remove),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdding ? Colors.green : Colors.orange,
              ),
              onPressed: _isSaving
                  ? null
                  : () async {
                      final cantidad =
                          double.tryParse(cantidadController.text) ?? 0;
                      if (cantidad <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Ingrese una cantidad válida')),
                        );
                        return;
                      }

                      setDialogState(() => _isSaving = true);

                      final currentStock = (item['cantidad'] as num).toDouble();
                      final newStock = isAdding
                          ? currentStock + cantidad
                          : (currentStock - cantidad).clamp(0, double.infinity);

                      try {
                        // Actualizar en Supabase
                        await _supabase.from('inventory').update({
                          'cantidad': newStock,
                        }).eq('id', item['id']);

                        setState(() {
                          final index =
                              _items.indexWhere((i) => i['id'] == item['id']);
                          if (index != -1) {
                            _items[index]['cantidad'] = newStock;
                            _items[index]['ultima_actualizacion'] =
                                DateTime.now();
                          }
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isAdding
                                ? '✅ Se agregaron $cantidad ${item['unidad']} de ${item['nombre']}'
                                : '✅ Se retiraron $cantidad ${item['unidad']} de ${item['nombre']}'),
                            backgroundColor:
                                isAdding ? Colors.green : Colors.orange,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => _isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isAdding ? 'Agregar' : 'Retirar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    final minimoController = TextEditingController();
    final precioController = TextEditingController();
    String categoria = 'Vegetales';
    String unidad = 'kg';
    String proveedor = _suppliers.isNotEmpty ? _suppliers.first['nombre'] : '';
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                      labelText: 'Nombre', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: const InputDecoration(
                      labelText: 'Categoría', border: OutlineInputBorder()),
                  items: [
                    'Vegetales',
                    'Carnes',
                    'Granos',
                    'Condimentos',
                    'Lácteos',
                    'Bebidas',
                    'Limpieza',
                    'General'
                  ]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => categoria = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: cantidadController,
                        decoration: const InputDecoration(
                            labelText: 'Cantidad',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: unidad,
                        decoration: const InputDecoration(
                            labelText: 'Unidad', border: OutlineInputBorder()),
                        items: [
                          'kg',
                          'g',
                          'L',
                          'ml',
                          'unidad',
                          'docena',
                          'caja',
                          'bolsa'
                        ]
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => unidad = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minimoController,
                        decoration: const InputDecoration(
                            labelText: 'Stock Mínimo',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: precioController,
                        decoration: const InputDecoration(
                            labelText: 'Precio Unit.',
                            border: OutlineInputBorder(),
                            prefixText: '\$'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: proveedor.isNotEmpty ? proveedor : null,
                  decoration: const InputDecoration(
                      labelText: 'Proveedor', border: OutlineInputBorder()),
                  items: _suppliers
                      .map((s) => DropdownMenuItem(
                          value: s['nombre'] as String,
                          child: Text(s['nombre'])))
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => proveedor = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (nombreController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ingrese un nombre')),
                        );
                        return;
                      }

                      setDialogState(() => _isSaving = true);

                      try {
                        // Guardar en Supabase
                        final response = await _supabase
                            .from('inventory')
                            .insert({
                              'nombre': nombreController.text,
                              'categoria': categoria,
                              'cantidad':
                                  double.tryParse(cantidadController.text) ?? 0,
                              'unidad': unidad,
                              'stock_minimo':
                                  double.tryParse(minimoController.text) ?? 0,
                              'precio_unitario':
                                  double.tryParse(precioController.text) ?? 0,
                              'proveedor':
                                  proveedor.isNotEmpty ? proveedor : null,
                              'is_active': true,
                            })
                            .select()
                            .single();

                        setState(() {
                          _items.add({
                            'id': response['id'],
                            'nombre': response['nombre'],
                            'categoria': response['categoria'],
                            'cantidad':
                                (response['cantidad'] as num).toDouble(),
                            'unidad': response['unidad'],
                            'minimo':
                                (response['stock_minimo'] as num).toDouble(),
                            'precio_unitario':
                                (response['precio_unitario'] as num?)
                                        ?.toDouble() ??
                                    0,
                            'proveedor': response['proveedor'] ?? 'Sin asignar',
                            'ultima_actualizacion': DateTime.now(),
                            'fecha_vencimiento':
                                DateTime.now().add(const Duration(days: 30)),
                          });
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item agregado exitosamente ✓'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => _isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item) {
    // Similar a _showAddItemDialog pero con valores pre-llenados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Funcionalidad de edición disponible desde el menú del item')),
    );
  }

  void _confirmDeleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Item'),
        content: Text('¿Eliminar "${item['nombre']}" del inventario?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _items.removeWhere((i) => i['id'] == item['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item eliminado')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Preparando pedido para ${item['proveedor'] ?? 'proveedor'}')),
    );
  }

  void _showAddSupplierDialog() {
    final nombreController = TextEditingController();
    final contactoController = TextEditingController();
    final telefonoController = TextEditingController();
    final emailController = TextEditingController();
    final direccionController = TextEditingController();
    String categoria = 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Proveedor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                      labelText: 'Nombre de la Empresa',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactoController,
                  decoration: const InputDecoration(
                      labelText: 'Persona de Contacto',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                      labelText: 'Teléfono', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                      labelText: 'Dirección', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: const InputDecoration(
                      labelText: 'Categoría', border: OutlineInputBorder()),
                  items: [
                    'General',
                    'Vegetales',
                    'Carnes',
                    'Lácteos',
                    'Bebidas',
                    'Especialidades'
                  ]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => categoria = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingrese el nombre de la empresa')),
                  );
                  return;
                }

                setState(() {
                  _suppliers.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'nombre': nombreController.text,
                    'contacto': contactoController.text,
                    'telefono': telefonoController.text,
                    'email': emailController.text,
                    'direccion': direccionController.text,
                    'categoria': categoria,
                    'activo': true,
                  });
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Proveedor agregado exitosamente')),
                );
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}
