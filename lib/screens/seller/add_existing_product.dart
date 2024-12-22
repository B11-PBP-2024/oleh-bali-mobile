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
      'https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/products/seller/show-all-products/json/',
    );
    setState(() {
      _products = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Existing Product',
            style: TextStyle(
              color: Colors.white,
              fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24),
                vertical: isVerySmallScreen ? 16 : 24,
              ),
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 8 : 12,
                          vertical: isVerySmallScreen ? 12 : 16,
                        ),
                      ),
                      value: _selectedProductId,
                      items: _products.map<DropdownMenuItem<String>>((product) {
                        return DropdownMenuItem<String>(
                          value: product['id'].toString(),
                          child: Text(
                            product['name'],
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                            ),
                          ),
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
                      // style: TextStyle(
                      //   fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                      // ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: isVerySmallScreen ? 20 : 24,
                      ),
                      isExpanded: true,
                    ),
                    SizedBox(height: isVerySmallScreen ? 12 : 16),

                    // Price Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 8 : 12,
                          vertical: isVerySmallScreen ? 12 : 16,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
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
                    SizedBox(height: isVerySmallScreen ? 20 : 24),

                    SizedBox(
                      height: isVerySmallScreen ? 40 : (isSmallScreen ? 44 : 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isVerySmallScreen ? 8 : 12,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final response = await request.post(
                              'https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/products/seller/create/json/',
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
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context, true);
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response['message'] ?? 'Failed to add product'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}