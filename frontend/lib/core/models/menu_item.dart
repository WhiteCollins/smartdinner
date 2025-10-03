class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> allergens;
  final bool isAvailable;
  final int preparationTimeMinutes;
  final double calories;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.ingredients,
    required this.allergens,
    required this.isAvailable,
    required this.preparationTimeMinutes,
    required this.calories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      imageUrl: json['image_url'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      isAvailable: json['is_available'] ?? true,
      preparationTimeMinutes: json['preparation_time_minutes'] ?? 0,
      calories: json['calories']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'allergens': allergens,
      'is_available': isAvailable,
      'preparation_time_minutes': preparationTimeMinutes,
      'calories': calories,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? allergens,
    bool? isAvailable,
    int? preparationTimeMinutes,
    double? calories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      calories: calories ?? this.calories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool hasAllergen(String allergen) {
    return allergens.contains(allergen.toLowerCase());
  }

  bool containsIngredient(String ingredient) {
    return ingredients.any((ing) => ing.toLowerCase().contains(ingredient.toLowerCase()));
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
