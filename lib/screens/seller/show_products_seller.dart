import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../models/products_seller_entry.dart';
import '../../widgets/seller/products_seller_card.dart';
import 'add_existing_product.dart';
import 'add_new_product.dart';
import 'edit_products_seller.dart';
import 'package:oleh_bali_mobile/base_seller.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  
  CategoryModel({
    required this.name,
    required this.icon,
  });
}

class ShowProductsPage extends StatefulWidget {
  const ShowProductsPage({super.key});

  @override
  State<ShowProductsPage> createState() => _ShowProductsPageState();
}

class _ShowProductsPageState extends State<ShowProductsPage> {
  String? selectedSort;
  String? selectedCategory;
  final TextEditingController searchController = TextEditingController();
  Future<List<ProductSellerEntry>>? _products;
  List<String> categories = ["All Categories"];
  Future<List<String>>? _categories;

  final Map<String, String> sortOptions = {
    "Lowest to Highest": "asc",
    "Highest to Lowest": "desc",
  };

  final List<CategoryModel> categoryList = [
    CategoryModel(name: "All Categories", icon: Icons.category_outlined),
    CategoryModel(name: "Textile", icon: Icons.curtains_outlined),
    CategoryModel(name: "Art", icon: Icons.palette_outlined),
    CategoryModel(name: "Handicraft", icon: Icons.handyman_outlined),
    CategoryModel(name: "Traditional Wear", icon: Icons.checkroom_outlined),
    CategoryModel(name: "Food", icon: Icons.restaurant_outlined),
    CategoryModel(name: "Jewelry", icon: Icons.diamond_outlined),
    CategoryModel(name: "Souvenir", icon: Icons.card_giftcard_outlined),
    CategoryModel(name: "Accessory", icon: Icons.watch_outlined),
    CategoryModel(name: "Traditional Weapon", icon: Icons.gavel_outlined),
    CategoryModel(name: "Musical Instrument", icon: Icons.music_note_outlined),
    CategoryModel(name: "Beverage", icon: Icons.local_drink_outlined),
  ];

  String formatRupiah(double number) {
    if (number == 0) return 'Rp 0';
    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<List<ProductSellerEntry>> fetchProducts() async {
    final request = context.read<CookieRequest>();
    var url = 'http://localhost:8000/products/seller/show-products/json/';

    List<String> queryParams = [];
    if (selectedCategory != null && selectedCategory != "All Categories") {
      queryParams.add('category=${Uri.encodeComponent(selectedCategory!)}');
    }
    if (searchController.text.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchController.text)}');
    }
    if (selectedSort != null) {
      queryParams.add('sort_price=${sortOptions[selectedSort]}');
    }
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await request.get(url);
    return response.map<ProductSellerEntry>((json) => ProductSellerEntry.fromJson(json)).toList();
  }

  Future<List<String>> fetchCategories() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/products/get-categories/');

    List<String> fetchedCategories = ["All Categories"];
    if (response is List) {
      fetchedCategories.addAll(response.map((category) => category.toString()).toList());
    }
    return fetchedCategories;
  }

  void refreshProducts() {
    setState(() {
      _products = fetchProducts();
    });
  }

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
    _categories = fetchCategories().then((value) {
      setState(() {
        categories = value;
      });
      return value;
    });
  }

  void showDeleteDialog(BuildContext context, ProductSellerEntry product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final request = context.read<CookieRequest>();
                final response = await request.post(
                  'http://localhost:8000/products/seller/delete/${product.id}/json/',
                  {},
                );

                Navigator.pop(context);
                if (response['status'] == true) {
                  refreshProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product successfully deleted!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete product')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseSeller(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      currentIndex: 1,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "The Products You're Selling",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => refreshProducts(),
                  ),
                  const SizedBox(height: 16),

                  // Sort Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Sort by Price',
                      border: const OutlineInputBorder(),
                      suffixIcon: selectedSort != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedSort = null;
                                  refreshProducts();
                                });
                              },
                            )
                          : null,
                    ),
                    value: selectedSort,
                    items: sortOptions.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSort = newValue;
                        refreshProducts();
                      });
                    },
                    hint: const Text('No sorting'),
                  ),
                  const SizedBox(height: 16),

                  // Categories with Icons
                  SizedBox(
  height: 40,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categoryList.length,
    itemBuilder: (context, index) {
      final category = categoryList[index];
      final isSelected = selectedCategory == category.name;
      
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedCategory = isSelected ? null : category.name;
              refreshProducts();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey[700],
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
),

                  // Add Product Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add New Product"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddProductForm(),
                              ),
                            );
                            if (result == true) refreshProducts();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_cart, size: 18),
                          label: const Text("Add Existing"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddExistingProductForm(),
                              ),
                            );
                            if (result == true) refreshProducts();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Grid
                  FutureBuilder<List<ProductSellerEntry>>(
                    future: _products,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/no-item-found.png',
                                height: 150,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "You don't have any products in this category yet.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        padding: const EdgeInsets.only(bottom: 60),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final product = snapshot.data![index];
                          return ProductCard(
                            product: product,
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProductScreen(product: product),
                                ),
                              );
                              if (result == true) refreshProducts();
                            },
                            onDelete: () => showDeleteDialog(context, product),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Products Counter
          Positioned(
            bottom: 16,
            right: 16,
            child: FutureBuilder<List<ProductSellerEntry>>(
              future: _products,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Total Products : ${snapshot.data!.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}