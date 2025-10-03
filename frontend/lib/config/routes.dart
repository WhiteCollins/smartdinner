import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/reservations/screens/reservations_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/admin/screens/dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String reservations = '/reservations';
  static const String orders = '/orders';
  static const String menu = '/menu';
  static const String adminDashboard = '/admin/dashboard';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => LoginScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    reservations: (context) => ReservationsScreen(),
    orders: (context) => OrdersScreen(),
    menu: (context) => MenuScreen(),
    adminDashboard: (context) => DashboardScreen(),
  };
}
