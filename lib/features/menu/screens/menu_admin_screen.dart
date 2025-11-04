import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';

class MenuAdminScreen extends StatefulWidget {
  @override
  _MenuAdminScreenState createState() => _MenuAdminScreenState();
}

class _MenuAdminScreenState extends State<MenuAdminScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final List<String> _categories = [
    'Todos',
    'entradas',
    'principales',
    'postres',
    'bebidas',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _supabaseService.getMenuItems(
        category: _selectedCategory == 'Todos' ? null : _selectedCategory,
        showAll:
            true, // Admin ve todos los items (disponibles y no disponibles)
      );
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar items: $e')));
    }
  }

  Future<void> _deleteItem(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar item?'),
        content: Text('¿Estás seguro de eliminar "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabaseService.deleteMenuItem(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "$name" eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMenuItems();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al eliminar: $e')));
      }
    }
  }

  void _showCreateEditDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final descController = TextEditingController(
      text: item?['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: item?['price']?.toString() ?? '',
    );
    final prepTimeController = TextEditingController(
      text: item?['preparation_time']?.toString() ?? '15',
    );
    final caloriesController = TextEditingController(
      text: item?['calories']?.toString() ?? '',
    );
    String selectedCategory = item?['category'] ?? 'principales';
    bool isAvailable = item?['is_available'] ?? true;
    bool isVegetarian = item?['is_vegetarian'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? '✏️ Editar Item' : '➕ Crear Nuevo Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Descripción *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Precio (\$) *',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['entradas', 'principales', 'postres', 'bebidas']
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value!);
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: prepTimeController,
                        decoration: InputDecoration(
                          labelText: 'Tiempo (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: caloriesController,
                        decoration: InputDecoration(
                          labelText: 'Calorías',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Disponible'),
                  value: isAvailable,
                  onChanged: (value) {
                    setDialogState(() => isAvailable = value);
                  },
                ),
                SwitchListTile(
                  title: Text('Vegetariano'),
                  value: isVegetarian,
                  onChanged: (value) {
                    setDialogState(() => isVegetarian = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⚠️ Completa los campos obligatorios (*)'),
                    ),
                  );
                  return;
                }

                final data = {
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'category': selectedCategory,
                  'preparation_time':
                      int.tryParse(prepTimeController.text) ?? 15,
                  'calories': int.tryParse(caloriesController.text),
                  'is_available': isAvailable,
                  'is_vegetarian': isVegetarian,
                };

                try {
                  if (isEdit) {
                    await _supabaseService.updateMenuItem(item['id'], data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Item actualizado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    await _supabaseService.createMenuItem(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Item creado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pop(context);
                  _loadMenuItems();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
                }
              },
              child: Text(isEdit ? 'Guardar Cambios' : 'Crear Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🍽️ Administrar Menú'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMenuItems,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por categoría
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected =
                      _selectedCategory == cat ||
                      (_selectedCategory == null && cat == 'Todos');
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat == 'Todos' ? null : cat;
                        });
                        _loadMenuItems();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Lista de items
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _menuItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay items en el menú',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Presiona + para agregar el primero',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item['is_available']
                                ? Colors.green
                                : Colors.red,
                            child: Icon(Icons.restaurant, color: Colors.white),
                          ),
                          title: Text(
                            item['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      item['category'].toString().toUpperCase(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    padding: EdgeInsets.all(4),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  SizedBox(width: 8),
                                  if (item['is_vegetarian'])
                                    Icon(
                                      Icons.eco,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${item['price'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCreateEditDialog(item: item);
                                  } else if (value == 'delete') {
                                    _deleteItem(item['id'], item['name']);
                                  }
                                },
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditDialog(),
        icon: Icon(Icons.add),
        label: Text('Nuevo Item'),
      ),
    );
  }
}
