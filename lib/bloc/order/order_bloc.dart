import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cbc_vegitable_order/models/order_item.dart';
import 'package:cbc_vegitable_order/services/api_service.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<AddOrderItem>(_onAddOrderItem);
    on<RemoveOrderItem>(_onRemoveOrderItem);
    on<UpdateOrderItem>(_onUpdateOrderItem);
    on<ClearOrder>(_onClearOrder);
    on<RemoveOrderItemByProductId>(_onRemoveOrderItemByProductId);
    on<UpdateOrderItemQuantityByProductId>(_onUpdateOrderItemQuantityByProductId);
    on<PlaceOrder>(_onPlaceOrder); // Add this line
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) {
    try {
      // Load existing orders or start with empty list
      emit(const OrderLoaded(orderItems: []));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  void _onAddOrderItem(AddOrderItem event, Emitter<OrderState> emit) {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      // Check if item with same productId already exists
      final existingItemIndex = currentState.orderItems
          .indexWhere((item) => item.productId == event.orderItem.productId);

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final updatedItems = List<OrderItem>.from(currentState.orderItems);
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: event.orderItem.quantity,
        );
        emit(OrderLoaded(orderItems: updatedItems));
      } else {
        // Add new item
        final updatedItems = List<OrderItem>.from(currentState.orderItems)
          ..add(event.orderItem);
        emit(OrderLoaded(orderItems: updatedItems));
      }
    } else {
      // If no current state, create new order with this item
      emit(OrderLoaded(orderItems: [event.orderItem]));
    }
  }

  void _onRemoveOrderItem(RemoveOrderItem event, Emitter<OrderState> emit) {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      final updatedItems = currentState.orderItems
          .where((item) => item.id != event.orderItemId)
          .toList();
      emit(OrderLoaded(orderItems: updatedItems));
    }
  }

  void _onUpdateOrderItem(UpdateOrderItem event, Emitter<OrderState> emit) {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      final updatedItems = currentState.orderItems.map((item) {
        if (item.id == event.orderItem.id) {
          return event.orderItem;
        }
        return item;
      }).toList();
      emit(OrderLoaded(orderItems: updatedItems));
    }
  }

  void _onClearOrder(ClearOrder event, Emitter<OrderState> emit) {
    emit(const OrderLoaded(orderItems: []));
  }

  void _onRemoveOrderItemByProductId(RemoveOrderItemByProductId event, Emitter<OrderState> emit) {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      final updatedItems = currentState.orderItems
          .where((item) => item.productId != int.parse(event.productId))
          .toList();
      emit(OrderLoaded(orderItems: updatedItems));
    }
  }

  void _onUpdateOrderItemQuantityByProductId(UpdateOrderItemQuantityByProductId event, Emitter<OrderState> emit) {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      // Find existing item with the same productId
      final existingItemIndex = currentState.orderItems
          .indexWhere((item) => item.productId == int.parse(event.productId));

      if (existingItemIndex != -1) {
        // Update existing item
        final updatedItems = List<OrderItem>.from(currentState.orderItems);
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: event.quantity.toInt(),
          productName: event.productName,
          price: event.price,
          unit: event.unit,
        );
        emit(OrderLoaded(orderItems: updatedItems));
      } else if (event.quantity > 0) {
        // Create new item if quantity > 0 and item doesn't exist
        final newOrderItem = OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + event.productId,
          productId: int.parse(event.productId),
          productName: event.productName,
          price: event.price,
          quantity: event.quantity.toInt(),
          unit: event.unit,
        );
        final updatedItems = List<OrderItem>.from(currentState.orderItems)
          ..add(newOrderItem);
        emit(OrderLoaded(orderItems: updatedItems));
      }
    } else if (event.quantity > 0) {
      // If no current state and quantity > 0, create new order with this item
      final newOrderItem = OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + event.productId,
        productId: int.parse(event.productId),
        productName: event.productName,
        price: event.price,
        quantity: event.quantity.toInt(),
        unit: event.unit,
      );
      emit(OrderLoaded(orderItems: [newOrderItem]));
    }
  }

  // Add this new method for placing orders
// Add this new method for placing orders
  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    print('=== _onPlaceOrder method called ===');

    // Store the current items in case we need to restore them on error
    List<OrderItem> currentItems = [];
    if (state is OrderLoaded) {
      currentItems = (state as OrderLoaded).orderItems;
    }

    emit(OrderPlacing());
    print('=== OrderPlacing state emitted ===');

    try {
      print('=== PLACING ORDER DEBUG ===');
      print('Customer Name: ${event.customerName}');
      print('Customer Email: ${event.customerEmail}');
      print('Customer Phone: ${event.customerPhone}');
      print('Customer Address: ${event.customerAddress}');
      print('Notes: ${event.notes}');
      print('Order Items Count: ${event.items.length}');

      for (int i = 0; i < event.items.length; i++) {
        final item = event.items[i];
        print('Item $i: ${item.productName} - Qty: ${item.quantity} - Price: ${item.price}');
      }
      print('=== END DEBUG ===');

      print('=== Calling ApiService.createOrder ===');
      final response = await ApiService.createOrder(
        customerName: event.customerName,
        customerEmail: event.customerEmail,
        customerPhone: event.customerPhone,
        customerAddress: event.customerAddress,
        notes: event.notes,
        items: event.items,
      );

      print('=== API Response received ===');
      print('API Response: $response');
      print('Response type: ${response.runtimeType}');

      // Check if response has the expected structure
      if (response != null && response['data'] != null) {
        print('=== Emitting OrderPlaced state ===');
        emit(OrderPlaced(response['data']));

        // Add a small delay before clearing the order
        await Future.delayed(const Duration(milliseconds: 500));

        print('=== Clearing order after successful placement ===');
        emit(const OrderLoaded(orderItems: []));
      } else {
        print('=== Invalid API response structure ===');
        throw Exception('Invalid response from server');
      }

    } catch (e, stackTrace) {
      print('=== Order placement error ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');

      emit(OrderPlacementFailed(e.toString()));

      // Add a small delay before restoring the order items
      await Future.delayed(const Duration(milliseconds: 100));

      // Return to the previous loaded state with items intact
      print('=== Restoring order items after error ===');
      emit(OrderLoaded(orderItems: currentItems));
    }
  }

}
