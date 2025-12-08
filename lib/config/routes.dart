import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
// import '../features/auth/screens/register_screen.dart'; // ❌ Registro público deshabilitado
import '../features/reservations/screens/reservations_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/menu/screens/menu_admin_screen.dart';
import '../features/admin/screens/dashboard_screen.dart';
import '../features/admin/screens/user_management_screen.dart';
import '../utils/supabase_test_screen.dart';
import '../core/services/supabase_service.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String home = '/home';
  static const String reservations = '/reservations';
  static const String orders = '/orders';
  static const String menu = '/menu';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReservations = '/admin/reservations';
  static const String adminOrders = '/admin/orders';
  static const String adminMenu = '/admin/menu';
  static const String adminUsers = '/admin/users';
  static const String adminPredictions = '/admin/predictions';
  static const String test = '/test'; // Ruta temporal para diagnóstico

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => SplashScreen(),
      login: (context) => LoginScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      // register: (context) => RegisterScreen(), // ❌ Registro público deshabilitado
      home: (context) => HomeScreen(),
      reservations: (context) => ReservationsScreen(),
      orders: (context) => OrdersScreen(),
      menu: (context) => MenuScreen(),
      adminMenu: (context) => AdminRoute(child: MenuAdminScreen()),
      adminDashboard: (context) => AdminRoute(child: DashboardScreen()),
      adminUsers: (context) => const AdminRoute(child: UserManagementScreen()),
      test: (context) => const SupabaseTestScreen(), // Pantalla de diagnóstico
    };
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser != null) {
        final userProfile = await _supabaseService.getUserProfile(currentUser.id);
        setState(() {
          _isAdmin = userProfile['role'] == 'admin';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error al verificar rol: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Widget> get _screens {
    if (_isAdmin) {
      return [
        ReservationsScreen(),
        MenuScreen(),
        OrdersScreen(),
        DashboardScreen(),
      ];
    } else {
      return [
        ReservationsScreen(),
        MenuScreen(),
        OrdersScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    final items = [
      BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Reservas'),
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu),
        label: 'Menú',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Pedidos',
      ),
    ];

    if (_isAdmin) {
      items.add(
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        items: _navItems,
      ),
    );
  }
}

// Widget de protección para rutas administrativas
class AdminRoute extends StatefulWidget {
  final Widget child;

  const AdminRoute({super.key, required this.child});

  @override
  _AdminRouteState createState() => _AdminRouteState();
}

class _AdminRouteState extends State<AdminRoute> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser != null) {
        final userProfile = await _supabaseService.getUserProfile(currentUser.id);
        setState(() {
          _isAdmin = userProfile['role'] == 'admin';
          _isLoading = false;
        });

        // Si no es admin, redirigir al home
        if (!_isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ No tienes permisos para acceder a esta sección'),
                backgroundColor: Colors.orange,
              ),
            );
          });
        }
      } else {
        // Si no hay usuario, redirigir al login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verificando acceso...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso Denegado')),
        body: const Center(
          child: Text('Acceso Denegado'),
        ),
      );
    }

    return widget.child;
  }
}
