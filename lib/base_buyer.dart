import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/screens/article/show_article.dart';
import 'package:oleh_bali_mobile/screens/main/buyer_homepage.dart';

class BaseBuyer extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final PreferredSizeWidget appBar;
  final Color? backgroundColor;

  const BaseBuyer({
    super.key,
    required this.appBar,
    required this.child,
    required this.currentIndex,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this.appBar,
      body: child,
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor, // Set backgroundColor
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Wishlist',
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
        unselectedItemColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        onTap: (index) {
          if(index == currentIndex) {
            return;
          }
          if(index == 0) {
            Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (context) => BuyerHomepage()));
          }
          if(index == 1) {
            Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (context) => const ShowArticle()));
          }
        },
      ),
    );
  }
}