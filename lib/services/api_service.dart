import 'dart:convert';
import 'package:cbc_vegitable_order/models/product.dart';
import 'package:cbc_vegitable_order/models/order_item.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://cbc-app.duckdns.org:3000/api/v1'; // Replace with your API URL

  // Get all products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? [];
        print(productsJson);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Create product
  static Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Update product
  static Future<Product> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Delete product
  static Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Create order
  static Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String notes,
    required List<OrderItem> items,
  }) async {
    try {
      print("hello");
      // Calculate total amount
      double totalAmount = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      // Prepare order data
      final orderData = {
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'notes': notes,
        'items': items.map((item) => {
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit': item.unit,
          'price': item.price
        }).toList(),
      };

      print('Sending order data: ${json.encode(orderData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(orderData),
      );

      print('Order response status: ${response.statusCode}');
      print('Order response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error occurred';
          throw Exception('Failed to create order: $errorMessage');
        } catch (e) {
          throw Exception('Failed to create order: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Error creating order: $e');
    }
  }

  // Get all orders (optional - for future use)
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> ordersJson = data['data'] ?? [];
        return ordersJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order by ID (optional - for future use)
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Update order status (optional - for future use)
  static Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Cancel order (optional - for future use)
  static Future<void> cancelOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error canceling order: $e');
    }
  }
}
