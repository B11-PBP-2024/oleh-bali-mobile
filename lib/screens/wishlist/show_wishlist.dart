import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/models/wishlist_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  WishlistEntry? wishlist = null;
  late Future<void> _fetchWishlistFuture;
  late String? total;

  @override
  void initState() {
    super.initState();
    _fetchWishlistFuture = fetchWishlists(context.read<CookieRequest>());
  }

  Future<void> fetchWishlists(CookieRequest request) async {
    final response = await request.get("https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/wishlist/json/");
    var data = response;
    WishlistEntry fetchedWishlist = WishlistEntry.fromJson(data);
    setState(() {
      wishlist = fetchedWishlist;
      total = wishlist == null
          ? "TOTAL: Price not available"
          : wishlist!.totalMin == 0 && wishlist!.totalMax == 0
              ? "TOTAL: Price not available"
              : wishlist!.totalMin == wishlist!.totalMax
                  ? "TOTAL: Rp${wishlist!.totalMin}"
                  : "TOTAL: Rp${wishlist!.totalMin} - Rp${wishlist!.totalMax}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return BaseBuyer(
      appBar: AppBar(
        title: Text("Wishlist"),
      ),
      currentIndex: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder(
                    future: _fetchWishlistFuture,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (wishlist == null || wishlist!.wishlists.isEmpty) {
                        return const Center(
                          child: Text(
                            "No items in your wishlist!.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: wishlist!.wishlists.length,
                          itemBuilder: (context, index) {
                            return WishlistItemCard(
                              wishlist: wishlist!.wishlists[index],
                              onDelete: () async {
                                final response = await request.postJson(
                                  "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/wishlist/delete/",
                                  jsonEncode(<String, String>{
                                    'product_id': wishlist!
                                        .wishlists[index].products.first.pk,
                                  }),
                                );
                                if (response['success'] == true) {
                                  if (mounted) {
                                    setState(() {
                                      wishlist!.totalMin -=
                                          wishlist!.wishlists[index].minPrice;
                                      wishlist!.totalMax -=
                                          wishlist!.wishlists[index].maxPrice;
                                      wishlist!.totalMin =
                                          wishlist!.totalMin < 0
                                              ? 0
                                              : wishlist!.totalMin;
                                      wishlist!.totalMax =
                                          wishlist!.totalMax < 0
                                              ? 0
                                              : wishlist!.totalMax;
                                      wishlist!.wishlists.removeAt(index);
                                    });
                                  }
                                } else {
                                  // Handle error
                                  print(response['error']);
                                }
                              },
                            );
                          },
                        );
                      }
                    })),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red background
                foregroundColor: Colors.white, // White text
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Handle total price button press
              },
              child: Text(
                wishlist == null
                    ? "TOTAL: Price not available"
                    : wishlist!.totalMin == 0 && wishlist!.totalMax == 0
                        ? "TOTAL: Price not available"
                        : wishlist!.totalMin == wishlist!.totalMax
                            ? "TOTAL: Rp${wishlist!.totalMin}"
                            : "TOTAL: Rp${wishlist!.totalMin} - Rp${wishlist!.totalMax}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final Wishlist wishlist;
  final VoidCallback onDelete;

  const WishlistItemCard({
    Key? key,
    required this.wishlist,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = wishlist!.products.first;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.fields.productImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.fields.productName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wishlist!.minPrice == 0 && wishlist!.maxPrice == 0
                        ? "Price not available"
                        : wishlist!.minPrice == wishlist!.maxPrice
                            ? "Rp${wishlist!.minPrice}"
                            : "Rp${wishlist!.minPrice} - Rp${wishlist!.maxPrice}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(product.fields.description),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
