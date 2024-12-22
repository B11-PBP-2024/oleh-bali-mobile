import 'package:flutter/material.dart';
import '../../models/products_seller_entry.dart';

class ProductCard extends StatelessWidget {
  final ProductSellerEntry product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  String formatRupiah(double number) {
    if (number == 0) return 'Rp 0';
    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120, 
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              image: product.image.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(product.image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.image.isEmpty
                ? const Icon(Icons.image, size: 50)
                : null,
          ),
          const SizedBox(height: 4),

          // Product Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),

                // Product Price
                Text(
                  formatRupiah(product.price),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 1),

                // Product Category
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(), 

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit Button
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.blue,
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.blue,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}