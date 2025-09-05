class OrderItem {
  final String id;
  final int productId; // Make sure this field exists
  final String productName;
  final double price;
  final int quantity;
  final String unit;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  OrderItem copyWith({
    String? id,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    String? unit,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }
}
