import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_seller.dart';
import 'package:oleh_bali_mobile/widgets/main/item_card.dart';
import 'package:oleh_bali_mobile/widgets/main/item_homepage.dart';

class SellerHomepage extends StatelessWidget {
  SellerHomepage({super.key});

  final List<ItemHomepage> items = [
    ItemHomepage("My Products", Icons.card_giftcard),
    ItemHomepage("Profile", Icons.person),
    ItemHomepage("Logout", Icons.logout),
  ];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseSeller(
      appBar:AppBar(
        // Judul aplikasi "Mental Health Tracker" dengan teks putih dan tebal.
        title: const Text(
          'OlehBali',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Warna latar belakang AppBar diambil dari skema warna tema aplikasi.
        backgroundColor: Theme.of(context).colorScheme.primary,
      ), 
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Menyusun widget secara vertikal dalam sebuah kolom.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://youngontop.com/wp-content/uploads/2024/10/We-Asked-Photographers-From-All-Over-The-World-To-Show-Their-Most-Stunning-Shots-Of-Women-30-Pics.jpeg',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                        ),
              // Row untuk menampilkan 3 InfoCard secara horizontal.
              const Text(
                'OlehBali.',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // Memberikan jarak vertikal 16 unit.
              const SizedBox(height: 16.0),

              // Menempatkan widget berikutnya di tengah halaman.
              Center(
                child: Column(
                  // Menyusun teks dan grid item secara vertikal.

                  children: [
                    // Menampilkan teks sambutan dengan gaya tebal dan ukuran 18.

                    // Grid untuk menampilkan ItemCard dalam bentuk grid 3 kolom.
                    GridView.count(
                      primary: true,
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 3,
                      // Agar grid menyesuaikan tinggi kontennya.
                      shrinkWrap: true,

                      // Menampilkan ItemCard untuk setiap item dalam list items.
                      children: items.map((ItemHomepage item) {
                        return ItemCard(item);
                      }).toList(),
                    ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bringing the Heart of Indonesia to the World, Crafted by You.',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 8.0),
                              Container(
                                width: 80.0,
                                height: 4.0,
                                color: Colors.red[700],
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'OlehBali is here to help You, Bali souvenir sellers, introduce your store and products to tourists from around the world. With our website, you can easily add products, manage your store, and reach customers looking for authentic Balinese souvenirs. Let your business grow and gain wider recognition, while we help connect you with global buyers who appreciate the beauty of Balinese craftsmanship and culture.',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                  
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
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
      )
    );
  }
}

