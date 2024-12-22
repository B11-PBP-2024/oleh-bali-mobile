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
        title: const Center(
          child: Text(
            'Confirm Deletion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
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
                      const SnackBar(
                        content: Text('Product successfully deleted!'),
                        backgroundColor: Colors.green,  // Pindahkan ke dalam SnackBar
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete product'),
                        backgroundColor: Colors.red,  // Pindahkan ke dalam SnackBar
                      ),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    
    return BaseSeller(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      currentIndex: 1,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isVerySmallScreen ? 6 : (isSmallScreen ? 8.0 : 16.0),
                16.0,
                isVerySmallScreen ? 6 : (isSmallScreen ? 8.0 : 16.0),
                110.0
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14)
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14)
                      ),
                      prefixIcon: Icon(
                        Icons.search, 
                        size: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                        horizontal: 12
                      ),
                    ),
                    onChanged: (value) => refreshProducts(),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Sort by Price',
                      labelStyle: TextStyle(
                        fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                        horizontal: 12
                      ),
                      suffixIcon: selectedSort != null
                          ? IconButton(
                              icon: Icon(
                                Icons.clear, 
                                size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                                color: Colors.blue,
                              ),
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
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSort = newValue;
                        refreshProducts();
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    dropdownColor: Colors.white,
                    hint: Text(
                      'No Sorting',
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                        color: Colors.blue,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                  
                  SizedBox(
                    height: isVerySmallScreen ? 30 : (isSmallScreen ? 36 : 40),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final category = categoryList[index];
                        final isSelected = selectedCategory == category.name;
                        
                        return Container(
                          margin: EdgeInsets.only(
                            right: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = isSelected ? null : category.name;
                                refreshProducts();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8),
                                vertical: isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 4),
                              ),
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
                                    size: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                                    color: isSelected ? Colors.blue : Colors.grey[700],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.blue : Colors.grey[700],
                                      fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 13),
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
                  SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.add, 
                            size: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)
                          ),
                          label: Text(
                            "Add New Product",
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                            ),
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
                      SizedBox(width: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8)),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.shopping_cart,
                            size: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)
                          ),
                          label: Text(
                            "Add Existing Product",
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                            ),
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
                  SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                  
                  FutureBuilder<List<ProductSellerEntry>>(
                    future: _products,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/no-item-found.png',
                                height: isVerySmallScreen ? 100 : (isSmallScreen ? 120 : 150),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "You don't have any products in this category yet.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          double width = constraints.maxWidth;
                          int crossAxisCount;
                          const double aspectRatio = 0.65;
                          
                          double desiredItemWidth = 160.0;
                          double availableWidth = width - (16 * 2);
                          int calculatedColumns = (availableWidth ~/ desiredItemWidth);
                          
                          if (width < 320) {
                            crossAxisCount = 2;
                          } else {
                            crossAxisCount = calculatedColumns.clamp(2, 6);
                          }

                          double spacing = 8.0;
                          if (width < 320) {
                            spacing = 4.0;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: aspectRatio,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                            ),
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 80 : 100,
                              left: spacing,
                              right: spacing,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                            final product = snapshot.data![index];
                            return ProductCard(
                              product: product,
                              onEdit: refreshProducts,  // Langsung passing refreshProducts sebagai callback
                              onDelete: () => showDeleteDialog(context, product),
                            );
                          },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: isVerySmallScreen ? 10 : (isSmallScreen ? 15 : 25),
            right: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 16),
            child: FutureBuilder<List<ProductSellerEntry>>(
              future: _products,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                    vertical: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 6),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
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
