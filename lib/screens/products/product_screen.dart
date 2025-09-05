import 'package:cbc_vegitable_order/bloc/order/order_bloc.dart';
import 'package:cbc_vegitable_order/bloc/order/order_event.dart';
import 'package:cbc_vegitable_order/bloc/product/product_bloc.dart';
import 'package:cbc_vegitable_order/bloc/product/product_event.dart';
import 'package:cbc_vegitable_order/bloc/product/product_state.dart';
import 'package:cbc_vegitable_order/config/app_colors.dart';
import 'package:cbc_vegitable_order/models/order_item.dart';
import 'package:cbc_vegitable_order/models/product.dart';
import 'package:cbc_vegitable_order/screens/orders/order_screen.dart';
import 'package:cbc_vegitable_order/screens/products/product_form_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => _showAddProductModal(context),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductLoaded) {
                print("Loaded");
                _handleProductUpdates(context, state.products);
              }
            },
          ),
        ],
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductInitial || state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: _buildProductTable(context, state.products),
                  ),
                  _buildOrderButton(context, state.products),
                ],
              );
            } else if (state is ProductError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }

  void _handleProductUpdates(BuildContext context, List<Product> products) {
    final orderBloc = context.read<OrderBloc>();

    // Check for products with needToOrder = 0 and remove them from order
    for (final product in products) {
      if (product.needToOrder == 0) {
        orderBloc.add(RemoveOrderItemByProductId(product.id));
      } else if (product.needToOrder > 0) {
        // Update existing order item quantity if it exists
        orderBloc.add(UpdateOrderItemQuantityByProductId(
          product.id,
          product.needToOrder.toDouble(),
          product.name,
          product.price,
          product.unit,
        ));
      }
    }
    print(products);
  }

  Widget _buildProductTable(BuildContext context, List<Product> products) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    defaultColumnWidth: FixedColumnWidth(constraints.maxWidth / 5),
                    columnWidths: {
                      0: FlexColumnWidth(2),  // Name (wider)
                      1: FlexColumnWidth(1),  // Price
                      2: FlexColumnWidth(1),  // Stock
                      3: FlexColumnWidth(1),  // Used
                      4: FlexColumnWidth(1),  // Need to Order
                    },
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Price',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Stock',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Used',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Need to Order',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...products.map((product) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          children: [
                            InkWell(
                              onTap: () => _showEditProductModal(context, product),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  product.name,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditProductModal(context, product),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  '€${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditProductModal(context, product),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  product.stockDisplay, // This now shows "10kg" or "5pc"
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: product.stock > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditProductModal(context, product),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  product.used.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditProductModal(context, product),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  product.needToOrder.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: product.needToOrder > 0 ? Colors.orange : Colors.black,
                                    fontWeight: product.needToOrder > 0 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildOrderButton(BuildContext context, List<Product> products) {
    // Filter products that need to be ordered
    final productsToOrder = products.where((product) => product.needToOrder > 0).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: productsToOrder.isEmpty ? null : () => _createOrderFromProducts(context, productsToOrder),
        child: Text(
          productsToOrder.isEmpty
              ? 'NO ITEMS TO ORDER'
              : 'CREATE ORDER (${productsToOrder.length} items)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _createOrderFromProducts(BuildContext context, List<Product> productsToOrder) {
    final orderBloc = context.read<OrderBloc>();
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create Order"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create order for the following items?"),
              const SizedBox(height: 10),
              ...productsToOrder.map((product) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "• ${product.name}: ${product.needToOrder}${product.unit}",
                  style: const TextStyle(fontSize: 14),
                ),
              )).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Create order items for each product that needs to be ordered
                for (final product in productsToOrder) {
                  final orderItem = OrderItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString() + product.id,
                    productId: int.parse(product.id),
                    productName: product.name,
                    price: product.price,
                    quantity: product.needToOrder,
                    unit: product.unit,
                  );
                  orderBloc.add(AddOrderItem(orderItem));
                }
                // Navigate to order screen with OrderBloc provided
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: orderBloc,
                      child: const OrderScreen(),
                    ),
                  ),
                );
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${productsToOrder.length} items added to order'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("CREATE ORDER"),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductModal(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => ProductFormModal(
        onSave: (name, price, stock, unit, used, needToOrder) {
          final newProduct = Product(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            price: price,
            stock: stock,
            unit: unit,
            used: used,
            needToOrder: needToOrder,
          );
          productBloc.add(AddProduct(newProduct));
        },
      ),
    );
  }

  void _showEditProductModal(BuildContext context, Product product) {
    final productBloc = context.read<ProductBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => ProductFormModal(
        initialName: product.name,
        initialPrice: product.price,
        initialStock: product.stock,
        initialUnit: product.unit,
        initialUsed: product.used,
        initialNeedToOrder: product.needToOrder,
        onSave: (name, price, stock, unit, used, needToOrder) {
          final updatedProduct = product.copyWith(
            name: name,
            price: price,
            stock: stock,
            unit: unit,
            used: used,
            needToOrder: needToOrder,
          );
          productBloc.add(UpdateProduct(updatedProduct));
        },
        onDelete: () {
          productBloc.add(DeleteProduct(product.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
