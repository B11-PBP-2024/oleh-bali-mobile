import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/widgets/main/item_card.dart';
import 'package:oleh_bali_mobile/widgets/main/item_homepage.dart';

class BuyerHomepage extends StatelessWidget {
  BuyerHomepage({super.key});

  final List<ItemHomepage> items = [
    ItemHomepage("Articles", Icons.article),
    ItemHomepage("Catalog", Icons.shopping_cart),
    ItemHomepage("See Stores", Icons.store),
    ItemHomepage("Wishlist", Icons.star),
    ItemHomepage("Profile", Icons.person),
    ItemHomepage("Logout", Icons.logout),
  ];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseBuyer(
      appBar: AppBar(
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
        padding: const EdgeInsets.all(16.0),
        // Menyusun widget secara vertikal dalam sebuah kolom.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row untuk menampilkan 3 InfoCard secara horizontal.

            // Memberikan jarak vertikal 16 unit.
            const SizedBox(height: 16.0),

            // Menempatkan widget berikutnya di tengah halaman.
            Center(
              child: Column(
                // Menyusun teks dan grid item secara vertikal.
                children: [
                  ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://media.licdn.com/dms/image/v2/D5612AQFy-SwVphJoUQ/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1677468617732?e=2147483647&v=beta&t=JxDYsDuLnHSUxBXZ1QWeWS0LT_dfcMhuimfZtQyC3IQ',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                        ),
                  // Menampilkan teks sambutan dengan gaya tebal dan ukuran 18.
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: const Text(
                      'OlehBali.',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Grid untuk menampilkan ItemCard dalam bentuk grid 3 kolom.
                  GridView.count(
                    primary: true,
                    padding: const EdgeInsets.all(30),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
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
                                'About OlehBali',
                                style: TextStyle(
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Container(
                                width: 80.0,
                                height: 4.0,
                                color: Colors.red[700],
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Your ultimate destination for Indonesian souvenirs! Dive into our catalog and find treasures that reflect the beauty of Indonesia\'s diverse cultures. Each item is handpicked from Denpasar artisans, crafted with passion and tradition.',
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
      )
    );
  }
}

