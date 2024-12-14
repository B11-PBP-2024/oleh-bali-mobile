import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/models/store_product.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SeeStores extends StatefulWidget {
  final String productId;

  const SeeStores({super.key, required this.productId});

  @override
  _SeeStoresPageState createState() => _SeeStoresPageState();
}

class _SeeStoresPageState extends State<SeeStores> {
  StoresProduct? storesProduct;
  late Future<void> _fetchStoresProductFuture;

  Future<void> _fetchStoresProduct(CookieRequest request) async {
    final response = await request.get(
        "http://localhost:8000/see_stores/${widget.productId}/stores/json/");
    var data = response;
    StoresProduct fetchedStoresProduct = StoresProduct.fromJson(data);
    setState(() {
      storesProduct = fetchedStoresProduct;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoresProductFuture =
        _fetchStoresProduct(context.read<CookieRequest>());
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder<void>(
      future: _fetchStoresProductFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (storesProduct == null ||
            storesProduct!.sellersWithPrices.isEmpty) {
          return BaseBuyer(
            appBar: AppBar(
              title: Text("See Stores"),
            ),
            currentIndex: 2,
            child: const Center(
              child: Text(
                "No Stores Available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        } else {
          return BaseBuyer(
            appBar: AppBar(
              title: Text("See ${storesProduct!.product.productName} Stores"),
            ),
            currentIndex: 3,
            child: ListView.builder(
              itemCount: storesProduct!.sellersWithPrices.length,
              itemBuilder: (context, index) {
                return StoreCard(
                    sellerWithPrice: storesProduct!.sellersWithPrices[index]);
              },
            ),
          );
        }
      },
    );
  }
}

class StoreCard extends StatelessWidget {
  final SellersWithPrice sellerWithPrice;

  const StoreCard({super.key, required this.sellerWithPrice});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                sellerWithPrice.seller.profilePicture,
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
                    sellerWithPrice.seller.storeName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: Rp.${sellerWithPrice.price}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sellerWithPrice.seller.address}, ${sellerWithPrice.seller.village}, ${sellerWithPrice.seller.subdistrict}, ${sellerWithPrice.seller.city}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.red),
              onPressed: () async {
                final url = Uri.parse(sellerWithPrice.seller.maps);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
