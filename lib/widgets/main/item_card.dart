// lib/widgets/main/item_card.dart

import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/screens/article/show_article.dart';
import 'package:oleh_bali_mobile/screens/auth/login_buyer.dart';
import 'package:oleh_bali_mobile/screens/seller/show_products_seller.dart'; // Corrected import
import 'package:oleh_bali_mobile/screens/catalog/show_catalog.dart';
import 'package:oleh_bali_mobile/screens/store/show_store.dart';
import 'package:oleh_bali_mobile/screens/user_profile/profile_detail.dart';
import 'package:oleh_bali_mobile/screens/wishlist/show_wishlist.dart';
import 'package:oleh_bali_mobile/widgets/main/item_homepage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  // Menampilkan kartu dengan ikon dan nama.

  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return InkWell(
      onTap: () async {
          // Menampilkan pesan SnackBar saat kartu ditekan.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!")));

          if (item.name == "Logout") {
            final response = await request.logout(
                // Tambahkan trailing slash
                "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/auth/logout");

            String message = response["message"];
            if (context.mounted) {
              if (response['status']) {
                String uname = response["username"];
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("$message Sampai jumpa, $uname."),
                ));
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginBuyer()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              }
            }
          } else if (item.name == "Articles") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowArticle()),
            );
          } else if (item.name == "Catalog") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowCatalog()),
            );
          } else if (item.name == "My Products") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowProductsPage()), // Gunakan ShowProductsPage
            );
          } else if (item.name == "Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileDetail()),
            );
          } else if (item.name == "See Stores") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowStore()),
            );
          } else if (item.name == "Wishlist") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistPage()),
            );
          }
        },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          ),
          Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    ),
                ),
        ],
      )
    );
    
  }
}
