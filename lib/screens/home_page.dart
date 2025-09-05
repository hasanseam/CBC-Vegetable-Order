import 'package:cbc_vegitable_order/bloc/order/order_bloc.dart';
import 'package:cbc_vegitable_order/bloc/order/order_event.dart';
import 'package:cbc_vegitable_order/bloc/product/product_bloc.dart';
import 'package:cbc_vegitable_order/bloc/product/product_event.dart';
import 'package:cbc_vegitable_order/config/app_colors.dart';
import 'package:cbc_vegitable_order/screens/dashboard/dashboard_screen.dart';
import 'package:cbc_vegitable_order/screens/orders/order_screen.dart';
import 'package:cbc_vegitable_order/screens/products/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProductBloc _productBloc;
  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    // Create shared instances
    _productBloc = ProductBloc()..add(LoadProducts());
    _orderBloc = OrderBloc()..add(LoadOrders()); // Updated event name
  }

  @override
  void dispose() {
    _productBloc.close();
    _orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _productBloc),
        BlocProvider.value(value: _orderBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: AppColors.background,
          child: GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            crossAxisCount: 2,
            children: [
              _buildTile(
                context,
                'Products',
                Icons.inventory,
                AppColors.primary,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: _productBloc),
                          BlocProvider.value(value: _orderBloc),
                        ],
                        child: const ProductScreen(),
                      ),
                    ),
                  );
                },
              ),
              _buildTile(
                context,
                'My Order',
                Icons.shopping_cart,
                AppColors.primary,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: _orderBloc,
                        child: const OrderScreen(),
                      ),
                    ),
                  );
                },
              ),
              _buildTile(
                context,
                'Reservation',
                Icons.book_online,
                AppColors.primary,
                    () {
                  // Navigate to Reservation page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation selected')),
                  );
                },
              ),
              _buildTile(
                context,
                'Dashboard',
                Icons.dashboard,
                AppColors.primary,
                    () {
                  // Navigate to Dashboard screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: _productBloc),
                          BlocProvider.value(value: _orderBloc),
                        ],
                        child: const DashboardScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
