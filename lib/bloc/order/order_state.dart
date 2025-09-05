import 'package:equatable/equatable.dart';
import 'package:cbc_vegitable_order/models/order_item.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderItem> orderItems;

  const OrderLoaded({required this.orderItems});

  @override
  List<Object> get props => [orderItems];

  double get totalAmount {
    return orderItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get totalItems {
    return orderItems.length;
  }
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object> get props => [message];
}

// Add these new states for order placement
class OrderPlacing extends OrderState {}

class OrderPlaced extends OrderState {
  final Map<String, dynamic> orderData;

  const OrderPlaced(this.orderData);

  @override
  List<Object> get props => [orderData];
}

class OrderPlacementFailed extends OrderState {
  final String error;

  const OrderPlacementFailed(this.error);

  @override
  List<Object> get props => [error];
}
