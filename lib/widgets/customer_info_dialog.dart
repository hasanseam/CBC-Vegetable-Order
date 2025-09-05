import 'package:flutter/material.dart';
import 'package:cbc_vegitable_order/config/app_colors.dart';

class CustomerInfoDialog extends StatefulWidget {
  final Function(String name, String email, String phone, String address, String notes) onSubmit;

  const CustomerInfoDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<CustomerInfoDialog> createState() => _CustomerInfoDialogState();
}

class _CustomerInfoDialogState extends State<CustomerInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    print('Submit button pressed'); // Debug print

    if (_isSubmitting) {
      print('Already submitting, ignoring'); // Debug print
      return;
    }

    if (_formKey.currentState == null) {
      print('Form key current state is null'); // Debug print
      return;
    }

    print('Validating form...'); // Debug print

    if (_formKey.currentState!.validate()) {
      print('Form is valid, proceeding...'); // Debug print

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Call the onSubmit callback
        await widget.onSubmit(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _addressController.text.trim(),
          _notesController.text.trim(),
        );

        print('onSubmit completed successfully'); // Debug print

        // Close the dialog only if still mounted
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error in onSubmit: $e'); // Debug print

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } else {
      print('Form validation failed'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Customer Information',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please provide your information to complete the order',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: 'e.g., +32 123 456 789',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    // Optional field, but if provided, should be valid
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 8) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    hintText: 'Street, City, Postal Code',
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    // Optional field, but if provided, should be meaningful
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 10) {
                        return 'Please enter a complete address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Special Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Any special instructions...',
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            print('Cancel button pressed'); // Debug print
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'CONTINUE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}