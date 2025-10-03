import 'package:flutter/material.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showNewReservationDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quick reservation card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hacer una reserva',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text('Reserva tu mesa de forma rápida y sencilla'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showNewReservationDialog,
                      child: Text('Nueva Reserva'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // My reservations section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mis Reservas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 8),
            
            // Reservations list
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Placeholder count
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.event, color: Colors.white),
                      ),
                      title: Text('Reserva #${index + 1}'),
                      subtitle: Text('12 de Octubre, 7:00 PM - 4 personas'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          // TODO: Handle reservation actions
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Acción: $value')),
                          );
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Modificar'),
                          ),
                          PopupMenuItem(
                            value: 'cancel',
                            child: Text('Cancelar'),
                          ),
                        ],
                      ),
                      onTap: () {
                        // TODO: Show reservation details
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Reserva'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número de personas',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  // TODO: Show date picker
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Hora',
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  // TODO: Show time picker
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reserva creada (funcionalidad por implementar)')),
              );
            },
            child: Text('Reservar'),
          ),
        ],
      ),
    );
  }
}
