/// Roles disponibles en el sistema SmartDinner
enum UserRole {
  admin('admin', 'Administrador'),
  waiter('waiter', 'Mesero'),
  cashier('cashier', 'Cajero'),
  cook('cook', 'Cocinero'),
  deliveryPerson('delivery', 'Repartidor'),
  vipCustomer('vip_customer', 'Cliente VIP'),
  customer('customer', 'Cliente');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

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
      this == UserRole.cashier ||
      this == UserRole.cook ||
      this == UserRole.deliveryPerson;

  /// Verificar si el rol es un cliente
  bool get isCustomer =>
      this == UserRole.customer || this == UserRole.vipCustomer;
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
