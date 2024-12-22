import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../models/products_seller_entry.dart';

class ProductCard extends StatefulWidget {
  final ProductSellerEntry product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  bool isPriceHovered = false;
  bool isEditHovered = false;
  bool isDeleteHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatRupiah(double number) {
    if (number == 0) return 'Rp 0';
    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<void> handlePriceChange(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final formKey = GlobalKey<FormState>();
    String price = widget.product.price.toString();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Edit Price',
              style: TextStyle(
                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: price,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                      fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                      color: Colors.grey[600],
                    ),
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 8 : 12,
                      vertical: isVerySmallScreen ? 12 : 16,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                    color: Colors.grey[800],
                  ),
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price cannot be empty';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    price = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final response = await request.post(
                      'http://localhost:8000/products/seller/edit/${widget.product.id}/json/',
                      {
                        'price': price,
                      },
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext); // Close the dialog first
                      
                      if (response['status'] == true) {
                        widget.onEdit(); // Refresh the product list
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Price updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update price'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    Navigator.pop(dialogContext); // Close dialog on error
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isHovered 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.red.withOpacity(0.1),
                  blurRadius: isHovered ? 12 : 8,
                  offset: Offset(0, isHovered ? 4 : 2),
                  spreadRadius: isHovered ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'product-${widget.product.id}',
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.jpg',
                        image: widget.product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MouseRegion(
                          onEnter: (_) => setState(() => isPriceHovered = true),
                          onExit: (_) => setState(() => isPriceHovered = false),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: isPriceHovered ? 1.1 : 1.0,
                            child: Text(
                              formatRupiah(widget.product.price),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 24,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MouseRegion(
                                    onEnter: (_) => setState(() => isEditHovered = true),
                                    onExit: (_) => setState(() => isEditHovered = false),
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => handlePriceChange(context),
                                      child: AnimatedScale(
                                        duration: const Duration(milliseconds: 200),
                                        scale: isEditHovered ? 1.2 : 1.0,
                                        child: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  MouseRegion(
                                    onEnter: (_) => setState(() => isDeleteHovered = true),
                                    onExit: (_) => setState(() => isDeleteHovered = false),
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: widget.onDelete,
                                      child: AnimatedScale(
                                        duration: const Duration(milliseconds: 200),
                                        scale: isDeleteHovered ? 1.2 : 1.0,
                                        child: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}