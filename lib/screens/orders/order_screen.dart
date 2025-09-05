import 'package:cbc_vegitable_order/bloc/order/order_bloc.dart';
import 'package:cbc_vegitable_order/bloc/order/order_event.dart';
import 'package:cbc_vegitable_order/bloc/order/order_state.dart';
import 'package:cbc_vegitable_order/config/app_colors.dart';
import 'package:cbc_vegitable_order/models/order_item.dart';
import 'package:cbc_vegitable_order/screens/orders/order_item_form_modal.dart';
import 'package:cbc_vegitable_order/widgets/customer_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Add a flag to track if we're currently placing an order
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    // Only load if the current state is OrderInitial
    final currentState = context.read<OrderBloc>().state;
    if (currentState is OrderInitial) {
      context.read<OrderBloc>().add(LoadOrders());
    }
  }

  @override
  void dispose() {
    print('OrderScreen disposing...');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Order',
            onPressed: () => _showClearOrderDialog(context),
          ),
        ],
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          print('=== BlocListener received state: ${state.runtimeType} ===');

          // Check if widget is still mounted before handling state changes
          if (!mounted) {
            print('Widget not mounted, ignoring state change');
            return;
          }

          if (state is OrderPlaced) {
            print('=== Order placed successfully ===');
            _isPlacingOrder = false; // Reset flag

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${state.orderData['id']} placed successfully!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'VIEW',
                    textColor: Colors.white,
                    onPressed: () {
                      print('Order ID: ${state.orderData['id']}');
                    },
                  ),
                ),
              );
              // Show success dialog
              _showOrderSuccessDialog(context, state.orderData);
            }
          } else if (state is OrderPlacementFailed) {
            print('=== Order placement failed ===');
            print('Error: ${state.error}');
            _isPlacingOrder = false; // Reset flag

            if (mounted) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to place order: ${state.error.replaceAll('Exception: Error creating order: ', '')}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
              // Show error dialog
              _showOrderErrorDialog(context, state.error);
            }
          } else if (state is OrderPlacing) {
            _isPlacingOrder = true; // Set flag
          }
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderInitial || state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderPlacing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Placing your order...'),
                  ],
                ),
              );
            } else if (state is OrderLoaded) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        Text(
                          'Items in your order: ${state.orderItems.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (state.orderItems.isNotEmpty)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.clear),
                            label: const Text('CLEAR ALL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _showClearOrderDialog(context),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildOrderTable(context, state.orderItems),
                  ),
                  if (state.orderItems.isNotEmpty) ...[
                    _buildOrderSummary(context, state),
                    _buildOrderButton(context, state.orderItems),
                  ],
                ],
              );
            } else if (state is OrderError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrderTable(BuildContext context, List<OrderItem> orderItems) {
    if (orderItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Your order is empty',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add products from the Products screen',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: orderItems.length,
      itemBuilder: (context, index) {
        final item = orderItems[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content: Text(
                      "Are you sure you want to remove ${item.productName} from your order?"
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "REMOVE",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            if (mounted) {
              final orderBloc = context.read<OrderBloc>();
              orderBloc.add(RemoveOrderItem(item.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.productName} removed from order'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      if (mounted) {
                        orderBloc.add(AddOrderItem(item));
                      }
                    },
                  ),
                ),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('€${item.price.toStringAsFixed(2).replaceAll('.', ',')} per ${item.unit}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.quantity}${item.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '€${(item.price * item.quantity).toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditOrderItemModal(context, item),
                  ),
                ],
              ),
              onTap: () => _showEditOrderItemModal(context, item),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context, OrderLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items: ${state.totalItems}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Total: €${state.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton(BuildContext context, List<OrderItem> orderItems) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final isPlacing = state is OrderPlacing || _isPlacingOrder;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: (orderItems.isEmpty || isPlacing)
                ? null
                : () => _showCustomerInfoDialog(context, orderItems),
            child: isPlacing
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text('PLACING ORDER...'),
              ],
            )
                : Text(
              orderItems.isEmpty ? 'NO ITEMS TO ORDER' : 'PLACE ORDER (${orderItems.length} items)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _showEditOrderItemModal(BuildContext context, OrderItem item) {
    if (!mounted) return;

    final orderBloc = context.read<OrderBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => OrderItemFormModal(
        productName: item.productName,
        initialPrice: item.price,
        initialQuantity: item.quantity,
        unit: item.unit,
        onSave: (price, quantity) {
          if (mounted) {
            final updatedItem = item.copyWith(
              price: price,
              quantity: quantity,
            );
            orderBloc.add(UpdateOrderItem(updatedItem));
          }
        },
      ),
    );
  }

  void _showClearOrderDialog(BuildContext context) {
    if (!mounted) return;

    final orderBloc = context.read<OrderBloc>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear Order"),
          content: const Text("Are you sure you want to clear all items from your order?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  orderBloc.add(ClearOrder());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cleared'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text("CLEAR ALL"),
            ),
          ],
        );
      },
    );
  }
  void _showCustomerInfoDialog(BuildContext context, List<OrderItem> orderItems) {
    if (!mounted || _isPlacingOrder) return;

    print('=== Showing customer info dialog ===');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CustomerInfoDialog(
          onSubmit: (name, email, phone, address, notes) {
            print('=== CustomerInfoDialog onSubmit called ===');
            print('Customer: $name, Email: $email');

            // Close the customer info dialog
            Navigator.of(dialogContext).pop();

            // Proceed directly to place order without confirmation dialog
            _placeOrderDirectly(orderItems, name, email, phone, address, notes);
          },
        );
      },
    );
  }

  void _placeOrderDirectly(
      List<OrderItem> orderItems,
      String customerName,
      String customerEmail,
      String customerPhone,
      String customerAddress,
      String notes,
      ) {
    print('=== _placeOrderDirectly called ===');

    // Check if widget is still mounted and not already placing an order
    if (!mounted || _isPlacingOrder) {
      print('Widget not mounted or already placing order');
      return;
    }

    // Set the flag to prevent multiple submissions
    setState(() {
      _isPlacingOrder = true;
    });

    // Use a small delay to ensure the dialog is fully closed
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isPlacingOrder) {
        print('Widget unmounted during delay, aborting order placement');
        return;
      }

      if (mounted) {
        print('=== Dispatching PlaceOrder event ===');
        try {
          context.read<OrderBloc>().add(PlaceOrder(
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            customerAddress: customerAddress,
            notes: notes,
            items: orderItems,
          ));
          print('=== PlaceOrder event dispatched successfully ===');
        } catch (e) {
          print('Error dispatching PlaceOrder event: $e');
          setState(() {
            _isPlacingOrder = false;
          });
        }
      } else {
        print('ERROR: Widget not mounted, cannot dispatch BLoC event');
        _isPlacingOrder = false;
      }
    });
  }

  // Alternative method with confirmation dialog (if you want to keep it)
  void _showPlaceOrderConfirmation(
      BuildContext context,
      List<OrderItem> orderItems,
      String customerName,
      String customerEmail,
      String customerPhone,
      String customerAddress,
      String notes,
      ) {
    print('=== _showPlaceOrderConfirmation called ===');

    if (!mounted || _isPlacingOrder) {
      print('Widget not mounted or already placing order');
      return;
    }

    // Use WidgetsBinding to ensure we're in the right frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        print('Widget not mounted in PostFrameCallback');
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm Order"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer: $customerName",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (customerEmail.isNotEmpty)
                    Text("Email: $customerEmail"),
                  if (customerPhone.isNotEmpty)
                    Text("Phone: $customerPhone"),
                  if (customerAddress.isNotEmpty)
                    Text("Address: $customerAddress"),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text("Notes: $notes"),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    "Order Items:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...orderItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "• ${item.productName}: ${item.quantity}${item.unit} - €${(item.price * item.quantity).toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  )).toList(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Total: €${orderItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _placeOrderDirectly(orderItems, customerName, customerEmail, customerPhone, customerAddress, notes);
                },
                child: const Text(
                  "CONFIRM ORDER",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _showOrderSuccessDialog(BuildContext context, Map<String, dynamic> orderData) {
    if (!mounted) {
      print('Widget not mounted, cannot show success dialog');
      return;
    }

    // Use WidgetsBinding to ensure safe dialog showing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text("Order Placed!"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your order has been placed successfully!",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text("Order ID: #${orderData['id']}"),
                if (orderData['customer_name'] != null)
                  Text("Customer: ${orderData['customer_name']}"),
                if (orderData['total_amount'] != null)
                  Text(
                    "Total: €${double.parse(orderData['total_amount'].toString()).toStringAsFixed(2).replaceAll('.', ',')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }

  void _showOrderErrorDialog(BuildContext context, String error) {
    if (!mounted) {
      print('Widget not mounted, cannot show error dialog');
      return;
    }

    // Use WidgetsBinding to ensure safe dialog showing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text("Order Failed"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Failed to place your order:"),
                const SizedBox(height: 8),
                Text(
                  error.replaceAll('Exception: Error creating order: ', ''),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Please check your internet connection and try again.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }
}
