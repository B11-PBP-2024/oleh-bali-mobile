import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/product_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntry product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late bool isLiked;
  late int likeCount;
  late bool isWishlist;

  @override
  void initState() {
    super.initState();
    isLiked = widget.product.fields.isLike;
    likeCount = widget.product.fields.likeCount;
    isWishlist = widget.product.fields.isWishlist;
  }

  Future<void> _handleWishlistButton(CookieRequest request) async {
    if (!isWishlist) {
      final response = await request.postJson(
        "http://localhost:8000/wishlist/add/",
        jsonEncode(<String, String>{
          'product_id': widget.product.pk,
        }),
      );
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            isWishlist = !isWishlist;
            widget.product.fields.isWishlist = isWishlist;
          });
        }
      } else {
        // Handle error
        print(response['error']);
      }
    } else {
      final response = await request.postJson(
        "http://localhost:8000/wishlist/delete/",
        jsonEncode(<String, String>{
          'product_id': widget.product.pk,
        }),
      );
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            isWishlist = !isWishlist;
            widget.product.fields.isWishlist = isWishlist;
          });
        }
      } else {
        // Handle error
        print(response['error']);
      }
    }
  }

  Future<void> _handleLikeButtonPress(CookieRequest request) async {
    if (!isLiked) {
      final response = await request.postJson(
        "http://localhost:8000/like/add/",
        jsonEncode(<String, String>{
          'product_id': widget.product.pk,
        }),
      );

      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            isLiked = !isLiked;
            likeCount += isLiked ? 1 : -1;
            widget.product.fields.likeCount = likeCount;
            widget.product.fields.isLike = isLiked;
          });
        }
      } else {
        // Handle error
        print(response['error']);
      }
    } else {
      final response = await request.postJson(
        "http://localhost:8000/like/delete/",
        jsonEncode(<String, String>{
          'product_id': widget.product.pk,
        }),
      );
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            isLiked = !isLiked;
            likeCount += isLiked ? 1 : -1;
            widget.product.fields.likeCount = likeCount;
            widget.product.fields.isLike = isLiked;
          });
        }
      } else {
        // Handle error
        print(response['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.fields.productName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.product.fields.productImage,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product.fields.productName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Background color inside the border
                  border: Border.all(color: Color.fromARGB(255, 161,44,44,)),
                  borderRadius: BorderRadius.circular(12.0), // Circular border
                ),
                child: Text(
                  widget.product.fields.productCategory,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 161,44,44,), // Red text color
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 10),
            Text(
              priceValues.reverse[widget.product.fields.price]!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product.fields.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Likes: $likeCount',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_rounded,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),
                  iconSize: 30.0, // Set the desired icon size
                  onPressed: () async {
                    await _handleLikeButtonPress(request);
                  },
                ),
                IconButton(
                  icon: Icon(
                    isWishlist ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isWishlist ? const Color.fromARGB(255, 235, 179, 5) : Colors.grey,
                  ),
                  iconSize: 30.0, // Set the desired icon size
                  onPressed: () async {
                    await _handleWishlistButton(request);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}