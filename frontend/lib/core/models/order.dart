class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderType type;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? tableNumber;
  final String? specialInstructions;
  final DateTime estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.type,
    required this.status,
    this.deliveryAddress,
    this.tableNumber,
    this.specialInstructions,
    required this.estimatedDeliveryTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['total_amount'].toDouble(),
      type: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => OrderType.dineIn,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['delivery_address'],
      tableNumber: json['table_number'],
      specialInstructions: json['special_instructions'],
      estimatedDeliveryTime: DateTime.parse(json['estimated_delivery_time']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'delivery_address': deliveryAddress,
      'table_number': tableNumber,
      'special_instructions': specialInstructions,
      'estimated_delivery_time': estimatedDeliveryTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderType? type,
    OrderStatus? status,
    String? deliveryAddress,
    String? tableNumber,
    String? specialInstructions,
    DateTime? estimatedDeliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      type: type ?? this.type,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      tableNumber: tableNumber ?? this.tableNumber,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? customizations;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.customizations,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      menuItemId: json['menu_item_id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      customizations: json['customizations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'customizations': customizations,
    };
  }

  double get totalPrice => price * quantity;

  OrderItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? customizations,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
    );
  }
}

enum OrderType {
  dineIn,
  takeaway,
  delivery,
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  completed,
  cancelled,
}
