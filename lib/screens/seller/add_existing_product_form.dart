import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddExistingProductForm extends StatefulWidget {
  const AddExistingProductForm({super.key});

  @override
  State<AddExistingProductForm> createState() => _AddExistingProductFormState();
}

class _AddExistingProductFormState extends State<AddExistingProductForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String _price = '';
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'http://localhost:8000/products/seller/show-all-products/json/',
    );
    setState(() {
      _products = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Product Seller',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                value: _selectedProductId,
                items: _products.map<DropdownMenuItem<String>>((product) {
                  return DropdownMenuItem<String>(
                    value: product['id'].toString(),
                    child: Text(product['name']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedProductId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a product';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _price = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await request.post(
                      'http://localhost:8000/products/seller/create/json/',
                      {
                        'product': _selectedProductId,
                        'price': _price,
                      },
                    );

                    if (response['status'] == true) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product added successfully!'),
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'Failed to add product'),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 