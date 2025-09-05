import 'package:equatable/equatable.dart';
import 'package:cbc_vegitable_order/models/order_item.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderEvent {}

class AddOrderItem extends OrderEvent {
  final OrderItem orderItem;

  const AddOrderItem(this.orderItem);

  @override
  List<Object> get props => [orderItem];
}

class RemoveOrderItem extends OrderEvent {
  final String orderItemId;

  const RemoveOrderItem(this.orderItemId);

  @override
  List<Object> get props => [orderItemId];
}

class UpdateOrderItem extends OrderEvent {
  final OrderItem orderItem;

  const UpdateOrderItem(this.orderItem);

  @override
  List<Object> get props => [orderItem];
}

class ClearOrder extends OrderEvent {}

class RemoveOrderItemByProductId extends OrderEvent {
  final String productId;

  const RemoveOrderItemByProductId(this.productId);

  @override
  List<Object> get props => [productId];
}

class UpdateOrderItemQuantityByProductId extends OrderEvent {
  final String productId;
  final double quantity;
  final String productName;
  final double price;
  final String unit;

  const UpdateOrderItemQuantityByProductId(
      this.productId,
      this.quantity,
      this.productName,
      this.price,
      this.unit,
      );

  @override
  List<Object> get props => [productId, quantity, productName, price, unit];
}

// Add these new events for order placement
class PlaceOrder extends OrderEvent {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String notes;
  final List<OrderItem> items;

  const PlaceOrder({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.notes,
    required this.items,
  });

  @override
  List<Object> get props => [customerName, customerEmail, customerPhone, customerAddress, notes, items];
}
