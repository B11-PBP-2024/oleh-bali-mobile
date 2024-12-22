import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/models/product_entry.dart';
import 'package:oleh_bali_mobile/screens/see_stores/see_stores.dart';
import 'package:oleh_bali_mobile/screens/review/see_review.dart';
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
    return BaseBuyer(
      appBar: AppBar(
        title: Text(widget.product.fields.productName),
      ),
      currentIndex: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: SingleChildScrollView(
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
                  border: Border.all(color: Color.fromARGB(255, 161, 44, 44)),
                  borderRadius: BorderRadius.circular(12.0), // Circular border
                ),
                child: Text(
                  widget.product.fields.productCategory,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 161, 44, 44), // Red text color
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.product.fields.price!,
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red background
                        foregroundColor: Colors.white, // White text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: () {
                        // Handle "See Stores" button press
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SeeStores(productId: widget.product.pk)));
                      },
                      child: const Center(
                        child: Text('See Stores',
                        textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red), // Red border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: () {
                        // Handle "See Reviews" button press
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SeeReview(productId: widget.product.pk, productName: widget.product.fields.productName,)));
                      },
                      child: const Center(
                        child: Text(
                          'See Reviews',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center, // Center-align the text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      )
    ,);
  }
}