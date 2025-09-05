import 'package:cbc_vegitable_order/config/app_colors.dart';
import 'package:flutter/material.dart';

class OrderItemFormModal extends StatefulWidget {
  final String productName;
  final double initialPrice;
  final int initialQuantity;
  final String unit; // Add unit parameter
  final Function(double price, int quantity) onSave;

  const OrderItemFormModal({
    Key? key,
    required this.productName,
    required this.initialPrice,
    required this.initialQuantity,
    required this.unit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<OrderItemFormModal> createState() => _OrderItemFormModalState();
}

class _OrderItemFormModalState extends State<OrderItemFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
        text: widget.initialPrice.toStringAsFixed(2).replaceAll('.', ','));
    _quantityController = TextEditingController(
        text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.productName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price per ${widget.unit}',
                border: const OutlineInputBorder(),
                prefixText: '€',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                String normalizedValue = value.replaceAll(',', '.');
                if (double.tryParse(normalizedValue) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (${widget.unit})',
                border: const OutlineInputBorder(),
                suffixText: widget.unit,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                final quantity = int.tryParse(value);
                if (quantity == null) {
                  return 'Please enter a valid number';
                }
                if (quantity <= 0) {
                  return 'Quantity must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '€${_calculateTotal().toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              String normalizedPrice = _priceController.text.replaceAll(',', '.');
              widget.onSave(
                double.parse(normalizedPrice),
                int.parse(_quantityController.text),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  double _calculateTotal() {
    try {
      String normalizedPrice = _priceController.text.replaceAll(',', '.');
      double price = double.tryParse(normalizedPrice) ?? 0;
      int quantity = int.tryParse(_quantityController.text) ?? 0;
      return price * quantity;
    } catch (e) {
      return 0;
    }
  }
}
