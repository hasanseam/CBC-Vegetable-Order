class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String unit;
  final int used;
  final int needToOrder;
  // Ignore extra API fields for now

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.unit,
    required this.used,
    required this.needToOrder,
  });

  // Create from JSON (API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? 'kg',
      used: json['used'] ?? 0,
      needToOrder: json['need_to_order'] ?? 0,
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'unit': unit,
      'used': used,
      'need_to_order': needToOrder,
    };
  }

  // Your existing methods
  String get stockDisplay => '$stock$unit';

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? unit,
    int? used,
    int? needToOrder,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      used: used ?? this.used,
      needToOrder: needToOrder ?? this.needToOrder,
    );
  }
}
