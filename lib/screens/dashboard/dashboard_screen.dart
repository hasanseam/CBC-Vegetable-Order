import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
              'Order by Day',
              Icons.calendar_today,
              AppColors.primary,
                  () {
                // Navigate to Order by Day dashboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order by Day dashboard selected')),
                );
              },
            ),
            _buildTile(
              context,
              'Used Product by Day',
              Icons.analytics,
              AppColors.primary,
                  () {
                // Navigate to Used Product by Day dashboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Used Product by Day dashboard selected')),
                );
              },
            ),
          ],
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
