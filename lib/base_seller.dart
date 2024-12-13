import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/profile_buyer_entry.dart';
import 'package:oleh_bali_mobile/screens/article/show_article.dart';
import 'package:oleh_bali_mobile/screens/auth/login_buyer.dart';
import 'package:oleh_bali_mobile/screens/catalog/show_catalog.dart';
import 'package:oleh_bali_mobile/screens/main/buyer_homepage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:oleh_bali_mobile/screens/user_profile/profile_detail.dart';
import 'package:oleh_bali_mobile/models/profile_seller_entry.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseSeller extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final PreferredSizeWidget appBar;
  final Color? backgroundColor;

  const BaseSeller({
    super.key,
    required this.appBar,
    required this.child,
    required this.currentIndex,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: appBar,
      body: child,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'My Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.5),
        onTap: (index) async {
          if (index == currentIndex) {
            return;
          }
          Widget nextPage;
          if (index == 0) {
            nextPage = BuyerHomepage();
          } else if (index == 1) {
            nextPage = const ShowArticle();
          } else if (index == 2) {
            var profile =
                await fetchProfile('http://localhost:8000/profile/api/seller/');
            nextPage = ProfileDetail(profile: profile);
          } else if (index == 3) {
            final response =
                await request.logout("http://localhost:8000/auth/logout/");
            String message = response["message"];
            if (context.mounted) {
              if (response['status']) {
                String uname = response["username"];
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("$message Sampai jumpa, $uname."),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              }
            }
            nextPage = const LoginBuyer();
          } else {
            return;
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => nextPage,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        },
      ),
    );
  }
}

Future<dynamic> fetchProfile(String url) async {
  var response = await http.get(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data['profile_type'] == 'buyer') {
      return ProfileBuyer.fromJson(data['profile']);
    } else if (data['profile_type'] == 'seller') {
      return ProfileSeller.fromJson(data['profile']);
    }
  } else {
    throw Exception('Failed to load profile');
  }
}
