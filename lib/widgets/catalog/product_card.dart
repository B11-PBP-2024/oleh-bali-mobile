import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/product_entry.dart';
import 'package:oleh_bali_mobile/screens/catalog/product_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  final ProductEntry product;
  final VoidCallback onRefresh;

  const ProductCard({super.key, required this.product, required this.onRefresh});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isLiked;
  late int likeCount;
  late bool isWishlist;
  late ProductDetailPage productPage;

  @override
  void initState() {
    super.initState();
    isLiked = widget.product.fields.isLike;
    likeCount = widget.product.fields.likeCount;
    isWishlist = widget.product.fields.isWishlist;
    productPage = ProductDetailPage(product: widget.product);
  }

  Future<void> _handleWishlistButton(CookieRequest request) async {
    if (!isWishlist) {
      final response = await request.postJson(
        "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/wishlist/add/",
        jsonEncode(<String, String>{
          'product_id': widget.product.pk,
        }),
      );
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            isWishlist = !isWishlist;
            widget.product.fields.isWishlist = isWishlist;
            productPage = ProductDetailPage(product: widget.product);
          });
        }
      } else {
        // Handle error
        print(response['error']);
      }
    } else {
      final response = await request.postJson(
        "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/wishlist/delete/",
        jsonEncode(<String, String>{
          'product_id': widget.product.pk,
        }),
      );
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            isWishlist = !isWishlist;
            widget.product.fields.isWishlist = isWishlist;
            productPage = ProductDetailPage(product: widget.product);
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
        "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/like/add/",
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
            productPage = ProductDetailPage(product: widget.product);
          });
        }
      } else {
        // Handle error
        print(response['error']);
      }
    } else {
      final response = await request.postJson(
        "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/like/delete/",
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
            productPage = ProductDetailPage(product: widget.product);
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
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => productPage,
          ),
        );
        widget.onRefresh();
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.jpg', 
                  image: widget.product.fields.productImage,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.3,
                  fit: BoxFit.cover,)
              ),
              const SizedBox(height: 10),
              Text(
                widget.product.fields.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.product.fields.price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green,
                  overflow: TextOverflow.ellipsis
                ),
                textScaler: MediaQuery.textScalerOf(context),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_rounded,
                          color: isLiked ? const Color.fromARGB(255, 96, 165, 250) : Colors.grey,
                        ),
                        onPressed: () async {
                          await _handleLikeButtonPress(request);
                        },
                      ),
                      Text('$likeCount')
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isWishlist ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isWishlist ? const Color.fromARGB(255, 235, 179, 5) : Colors.grey,
                    ),
                    iconSize: 30.0,
                    onPressed: () async {
                      await _handleWishlistButton(request);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}