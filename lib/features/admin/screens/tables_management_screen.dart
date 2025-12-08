import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TablesManagementScreen extends StatefulWidget {
  const TablesManagementScreen({super.key});

  @override
  State<TablesManagementScreen> createState() => _TablesManagementScreenState();
}

class _TablesManagementScreenState extends State<TablesManagementScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tables = [];
  bool _isLoading = true;
  bool _usingRealData = false; // Se actualiza según la conexión

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoading = true);

    try {
      // Intentar cargar datos reales de Supabase
      final response = await _supabase
          .from('mesas')
          .select()
          .order('numero', ascending: true);

      if (response != null && (response as List).isNotEmpty) {
        setState(() {
          _tables = List<Map<String, dynamic>>.from(response);
          _usingRealData = true;
          _isLoading = false;
        });
        // Suscribirse a cambios en tiempo real
        _subscribeToChanges();
      } else {
        // Tabla vacía, usar datos de ejemplo
        setState(() {
          _tables = _getSampleTables();
          _usingRealData = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Error de conexión, usar datos de ejemplo
      debugPrint('Error cargando mesas de Supabase: $e');
      setState(() {
        _tables = _getSampleTables();
        _usingRealData = false;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usando datos de demostración'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getSampleTables() {
    return [
      {
        'id': '1',
        'numero': 1,
        'capacidad': 2,
        'estado': 'disponible',
        'ubicacion': 'Interior'
      },
      {
        'id': '2',
        'numero': 2,
        'capacidad': 2,
        'estado': 'ocupada',
        'ubicacion': 'Interior'
      },
      {
        'id': '3',
        'numero': 3,
        'capacidad': 4,
        'estado': 'disponible',
        'ubicacion': 'Interior'
      },
      {
        'id': '4',
        'numero': 4,
        'capacidad': 4,
        'estado': 'reservada',
        'ubicacion': 'Interior'
      },
      {
        'id': '5',
        'numero': 5,
        'capacidad': 6,
        'estado': 'ocupada',
        'ubicacion': 'Interior'
      },
      {
        'id': '6',
        'numero': 6,
        'capacidad': 6,
        'estado': 'disponible',
        'ubicacion': 'Interior'
      },
      {
        'id': '7',
        'numero': 7,
        'capacidad': 8,
        'estado': 'disponible',
        'ubicacion': 'Terraza'
      },
      {
        'id': '8',
        'numero': 8,
        'capacidad': 4,
        'estado': 'reservada',
        'ubicacion': 'Terraza'
      },
      {
        'id': '9',
        'numero': 9,
        'capacidad': 2,
        'estado': 'ocupada',
        'ubicacion': 'Terraza'
      },
      {
        'id': '10',
        'numero': 10,
        'capacidad': 10,
        'estado': 'disponible',
        'ubicacion': 'Salón Privado'
      },
      {
        'id': '11',
        'numero': 11,
        'capacidad': 4,
        'estado': 'limpieza',
        'ubicacion': 'Interior'
      },
      {
        'id': '12',
        'numero': 12,
        'capacidad': 2,
        'estado': 'disponible',
        'ubicacion': 'Barra'
      },
    ];
  }

  void _subscribeToChanges() {
    _supabase
        .channel('mesas_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mesas',
          callback: (payload) {
            _loadTables();
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar Mesa',
            onPressed: _showAddTableDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _loadTables,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner de demo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Datos de demostración - Toca una mesa para cambiar su estado',
                          style: TextStyle(
                              color: Colors.blue.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // Resumen de estado
                _buildStatusSummary(),
                const Divider(height: 1),

                // Filtros por ubicación
                _buildLocationFilter(),

                // Grid de mesas
                Expanded(
                  child:
                      _tables.isEmpty ? _buildEmptyState() : _buildTablesGrid(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTableDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Mesa'),
      ),
    );
  }

  String _selectedLocation = 'Todas';

  Widget _buildLocationFilter() {
    final locations = [
      'Todas',
      'Interior',
      'Terraza',
      'Salón Privado',
      'Barra'
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isSelected = location == _selectedLocation;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(location),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedLocation = location);
              },
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredTables {
    if (_selectedLocation == 'Todas') return _tables;
    return _tables.where((t) => t['ubicacion'] == _selectedLocation).toList();
  }

  Widget _buildTablesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _filteredTables.length,
      itemBuilder: (context, index) {
        final table = _filteredTables[index];
        return _buildTableCard(table);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_restaurant, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay mesas configuradas',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showAddTableDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Primera Mesa'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    final available = _tables.where((t) => t['estado'] == 'disponible').length;
    final occupied = _tables.where((t) => t['estado'] == 'ocupada').length;
    final reserved = _tables.where((t) => t['estado'] == 'reservada').length;
    final cleaning = _tables.where((t) => t['estado'] == 'limpieza').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
              child: _buildStatusChip(
                  'Disponibles', available, Colors.green, Icons.check_circle)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatusChip(
                  'Ocupadas', occupied, Colors.orange, Icons.people)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatusChip(
                  'Reservadas', reserved, Colors.blue, Icons.event)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatusChip('Limpieza', cleaning, Colors.purple,
                  Icons.cleaning_services)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildTableCard(Map<String, dynamic> table) {
    final estado = table['estado'] as String;
    Color statusColor;
    IconData statusIcon;

    switch (estado) {
      case 'disponible':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'ocupada':
        statusColor = Colors.orange;
        statusIcon = Icons.people;
        break;
      case 'reservada':
        statusColor = Colors.blue;
        statusIcon = Icons.event;
        break;
      case 'limpieza':
        statusColor = Colors.purple;
        statusIcon = Icons.cleaning_services;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.block;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 2),
      ),
      child: InkWell(
        onTap: () => _showTableActions(table),
        onLongPress: () => _showEditTableDialog(table),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.table_restaurant, size: 36, color: statusColor),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Mesa ${table['numero']}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                '${table['capacidad']} personas',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                table['ubicacion'] ?? 'Interior',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusName(estado),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusName(String estado) {
    switch (estado) {
      case 'disponible':
        return 'DISPONIBLE';
      case 'ocupada':
        return 'OCUPADA';
      case 'reservada':
        return 'RESERVADA';
      case 'limpieza':
        return 'EN LIMPIEZA';
      default:
        return estado.toUpperCase();
    }
  }

  void _showTableActions(Map<String, dynamic> table) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_restaurant,
                    size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${table['numero']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${table['capacidad']} personas • ${table['ubicacion'] ?? 'Interior'}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            Text('Cambiar Estado:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatusButton(
                        'disponible', Colors.green, Icons.check_circle, table)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildStatusButton(
                        'ocupada', Colors.orange, Icons.people, table)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildStatusButton(
                        'reservada', Colors.blue, Icons.event, table)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildStatusButton('limpieza', Colors.purple,
                        Icons.cleaning_services, table)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar Mesa'),
              onTap: () {
                Navigator.pop(context);
                _showEditTableDialog(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar Mesa'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTable(table);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
      String status, Color color, IconData icon, Map<String, dynamic> table) {
    final isCurrentStatus = table['estado'] == status;

    return ElevatedButton.icon(
      onPressed: isCurrentStatus
          ? null
          : () {
              _updateTableStatus(table, status);
              Navigator.pop(context);
            },
      icon: Icon(icon, size: 18),
      label: Text(_getStatusName(status), style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? color : color.withOpacity(0.1),
        foregroundColor: isCurrentStatus ? Colors.white : color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _updateTableStatus(Map<String, dynamic> table, String newStatus) {
    setState(() {
      final index = _tables.indexWhere((t) => t['id'] == table['id']);
      if (index != -1) {
        _tables[index]['estado'] = newStatus;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mesa ${table['numero']} → ${_getStatusName(newStatus)}'),
        backgroundColor: _getStatusColor(newStatus),
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Si usas datos reales, actualiza en Supabase
    // if (_useRealData) {
    //   _supabase.from('mesas').update({'estado': newStatus}).eq('id', table['id']);
    // }
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'disponible':
        return Colors.green;
      case 'ocupada':
        return Colors.orange;
      case 'reservada':
        return Colors.blue;
      case 'limpieza':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAddTableDialog() {
    final numeroController = TextEditingController();
    final capacidadController = TextEditingController();
    String ubicacion = 'Interior';
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Nueva Mesa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número de Mesa',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacidadController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (personas)',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: ubicacion,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                items: ['Interior', 'Terraza', 'Bar', 'VIP', 'Privado']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => ubicacion = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add),
              label: Text(_isSaving ? 'Guardando...' : 'Agregar'),
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (numeroController.text.isEmpty ||
                          capacidadController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Complete todos los campos')),
                        );
                        return;
                      }

                      setDialogState(() => _isSaving = true);

                      try {
                        // Guardar en Supabase
                        final response = await _supabase
                            .from('mesas')
                            .insert({
                              'numero': int.parse(numeroController.text),
                              'capacidad': int.parse(capacidadController.text),
                              'estado': 'disponible',
                              'ubicacion': ubicacion,
                            })
                            .select()
                            .single();

                        setState(() {
                          _tables.add(response);
                          _tables.sort((a, b) => (a['numero'] as int)
                              .compareTo(b['numero'] as int));
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Mesa ${response['numero']} agregada ✓'),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTableDialog(Map<String, dynamic> table) {
    final numeroController =
        TextEditingController(text: table['numero'].toString());
    final capacidadController =
        TextEditingController(text: table['capacidad'].toString());
    String ubicacion = table['ubicacion'] ?? 'Interior';
    // Validar que ubicación sea válida
    if (!['Interior', 'Terraza', 'Bar', 'VIP', 'Privado'].contains(ubicacion)) {
      ubicacion = 'Interior';
    }
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar Mesa ${table['numero']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número de Mesa',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacidadController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (personas)',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: ubicacion,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                items: ['Interior', 'Terraza', 'Bar', 'VIP', 'Privado']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => ubicacion = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
              onPressed: _isSaving
                  ? null
                  : () async {
                      setDialogState(() => _isSaving = true);

                      try {
                        // Actualizar en Supabase
                        await _supabase.from('mesas').update({
                          'numero': int.parse(numeroController.text),
                          'capacidad': int.parse(capacidadController.text),
                          'ubicacion': ubicacion,
                        }).eq('id', table['id']);

                        setState(() {
                          final index =
                              _tables.indexWhere((t) => t['id'] == table['id']);
                          if (index != -1) {
                            _tables[index]['numero'] =
                                int.parse(numeroController.text);
                            _tables[index]['capacidad'] =
                                int.parse(capacidadController.text);
                            _tables[index]['ubicacion'] = ubicacion;
                          }
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mesa actualizada ✓'),
                            backgroundColor: Colors.green,
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
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTable(Map<String, dynamic> table) {
    bool _isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Eliminar Mesa'),
          content: Text(
              '¿Estás seguro de eliminar la Mesa ${table['numero']}?\n\nEsta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _isDeleting
                  ? null
                  : () async {
                      setDialogState(() => _isDeleting = true);

                      try {
                        // Eliminar de Supabase
                        await _supabase
                            .from('mesas')
                            .delete()
                            .eq('id', table['id']);

                        setState(() {
                          _tables.removeWhere((t) => t['id'] == table['id']);
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Mesa ${table['numero']} eliminada ✓'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => _isDeleting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al eliminar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_usingRealData) {
      _supabase.channel('mesas_changes').unsubscribe();
    }
    super.dispose();
  }
}
