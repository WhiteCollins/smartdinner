import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/reservations/screens/reservations_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/menu/screens/menu_admin_screen.dart';
import '../features/admin/screens/dashboard_screen.dart';
import '../utils/supabase_test_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String reservations = '/reservations';
  static const String orders = '/orders';
  static const String menu = '/menu';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReservations = '/admin/reservations';
  static const String adminOrders = '/admin/orders';
  static const String adminMenu = '/admin/menu';
  static const String adminPredictions = '/admin/predictions';
  static const String test = '/test'; // Ruta temporal para diagnóstico

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => SplashScreen(),
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      home: (context) => HomeScreen(),
      reservations: (context) => ReservationsScreen(),
      orders: (context) => OrdersScreen(),
      menu: (context) => MenuScreen(),
      adminMenu: (context) => MenuAdminScreen(),
      adminDashboard: (context) => DashboardScreen(),
      test: (context) => const SupabaseTestScreen(), // Pantalla de diagnóstico
    };
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'SmartDinner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sistema Inteligente para Restaurantes',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Comenzar'),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.test);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: Icon(Icons.bug_report, size: 18),
              label: Text('🔧 Diagnóstico'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ReservationsScreen(),
    MenuScreen(),
    OrdersScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Reservas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
        ],
      ),
    );
  }
}
