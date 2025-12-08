import 'package:flutter/material.dart';

/// Roles disponibles en el sistema SmartDinner
/// IMPORTANTE: Deben coincidir con el CHECK constraint en la tabla users de Supabase
/// Roles: admin, customer, waiter, cook, cashier
enum UserRole {
  admin('admin', 'Administrador', Icons.admin_panel_settings),
  waiter('waiter', 'Mesero', Icons.restaurant),
  cook('cook', 'Cocinero', Icons.soup_kitchen),
  cashier('cashier', 'Cajero', Icons.point_of_sale),
  customer('customer', 'Cliente', Icons.person);

  const UserRole(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final IconData icon;

  /// Obtener rol desde un string
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }

  /// Verificar si el rol tiene permisos de administrador
  bool get isAdmin => this == UserRole.admin;

  /// Verificar si el rol tiene permisos de staff (empleados)
  bool get isStaff =>
      this == UserRole.admin ||
      this == UserRole.waiter ||
      this == UserRole.cook ||
      this == UserRole.cashier;

  /// Verificar si el rol es un cliente
  bool get isCustomer => this == UserRole.customer;

  /// Verificar si puede ver mesas y tomar pedidos
  bool get canManageTables => this == UserRole.admin || this == UserRole.waiter;

  /// Verificar si puede ver la cocina (KDS)
  bool get canViewKitchen => this == UserRole.admin || this == UserRole.cook;

  /// Verificar si puede manejar caja y pagos
  bool get canManageCash => this == UserRole.admin || this == UserRole.cashier;

  /// Verificar si puede ver reportes
  bool get canViewReports => this == UserRole.admin || this == UserRole.cashier;

  /// Verificar si puede gestionar inventario
  bool get canManageInventory =>
      this == UserRole.admin || this == UserRole.cook;
}

/// Estado del usuario en el sistema
enum UserStatus {
  active('active', 'Activo'),
  inactive('inactive', 'Inactivo'),
  suspended('suspended', 'Suspendido');

  const UserStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Obtener estado desde un string
  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.active,
    );
  }

  /// Verificar si el usuario está activo
  bool get isActive => this == UserStatus.active;
}
