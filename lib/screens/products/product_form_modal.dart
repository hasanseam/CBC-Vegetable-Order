import 'package:cbc_vegitable_order/config/app_colors.dart';
import 'package:flutter/material.dart';

class ProductFormModal extends StatefulWidget {
  final String? initialName;
  final double? initialPrice;
  final int? initialStock;
  final String? initialUnit;
  final int? initialUsed;
  final int? initialNeedToOrder;
  final Function(String name, double price, int stock, String unit, int used, int needToOrder) onSave;
  final VoidCallback? onDelete;

  const ProductFormModal({
    Key? key,
    this.initialName,
    this.initialPrice,
    this.initialStock,
    this.initialUnit,
    this.initialUsed,
    this.initialNeedToOrder,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _usedController;
  late TextEditingController _needToOrderController;
  String _selectedUnit = 'kg';
  final List<String> _units = ['kg', 'pc', 'liter', 'gram', 'box', 'pack'];

  // Store original total stock (stock + used)
  late int _originalTotalStock;

  bool get isEditMode => widget.initialName != null;

  @override
  void initState() {
    super.initState();

    // Calculate original total stock
    _originalTotalStock = (widget.initialStock ?? 0) + (widget.initialUsed ?? 0);

    _nameController = TextEditingController(text: widget.initialName ?? '');
    _priceController = TextEditingController(
        text: widget.initialPrice?.toStringAsFixed(2).replaceAll('.', ',') ?? '');
    _stockController = TextEditingController(
        text: widget.initialStock?.toString() ?? '');
    _usedController = TextEditingController(
        text: widget.initialUsed?.toString() ?? '0');
    _needToOrderController = TextEditingController(
        text: widget.initialNeedToOrder?.toString() ?? '0');
    _selectedUnit = widget.initialUnit ?? 'kg';

    // Add listener to used field to update stock automatically
    _usedController.addListener(_updateStockFromUsed);
  }

  void _updateStockFromUsed() {
    final used = int.tryParse(_usedController.text) ?? 0;
    final newStock = _originalTotalStock - used;

    // Update stock field if the calculation is valid
    if (newStock >= 0) {
      _stockController.text = newStock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _usedController.dispose();
    _needToOrderController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${widget.initialName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                widget.onDelete?.call();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditMode ? 'Edit Product' : 'Add Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
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
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Available Stock',
                  border: OutlineInputBorder(),
                  helperText: 'Auto-calculated: Total - Used',
                ),
                keyboardType: TextInputType.number,
                readOnly: false, // Make it read-only since it's auto-calculated
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stock value is required';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null) {
                    return 'Invalid stock value';
                  }
                  if (stock < 0) {
                    return 'Stock cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                items: _units.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedUnit = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usedController,
                decoration: InputDecoration(
                  labelText: 'Used Quantity',
                  border: const OutlineInputBorder(),
                  helperText: 'Total stock: $_originalTotalStock$_selectedUnit',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter used quantity';
                  }
                  final used = int.tryParse(value);
                  if (used == null) {
                    return 'Please enter a valid number';
                  }
                  if (used < 0) {
                    return 'Used quantity cannot be negative';
                  }
                  if (used > _originalTotalStock) {
                    return 'Used cannot exceed total stock ($_originalTotalStock)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _needToOrderController,
                decoration: const InputDecoration(
                  labelText: 'Need to Order',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter need to order quantity';
                  }
                  final needToOrder = int.tryParse(value);
                  if (needToOrder == null) {
                    return 'Please enter a valid number';
                  }
                  if (needToOrder < 0) {
                    return 'Need to order cannot be negative';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isEditMode && widget.onDelete != null)
          TextButton(
            onPressed: _showDeleteConfirmation,
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
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
                _nameController.text,
                double.parse(normalizedPrice),
                int.parse(_stockController.text),
                _selectedUnit,
                int.parse(_usedController.text),
                int.parse(_needToOrderController.text),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
