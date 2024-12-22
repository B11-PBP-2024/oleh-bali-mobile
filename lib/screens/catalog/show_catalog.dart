import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/models/product_entry.dart';
import 'package:oleh_bali_mobile/widgets/catalog/product_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ShowCatalog extends StatefulWidget {
  const ShowCatalog({super.key});

  @override
  State<ShowCatalog> createState() => _ShowCatalogState();
}

class _ShowCatalogState extends State<ShowCatalog> {
  List<ProductEntry> products = [];
  late Future<void> _fetchProductsFuture;
  late Future<void> _categoriesFuture;
  List<String> filters = [];
  String selectedFilter = 'All Categories';
  String searchValue = 'NoSearch';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _fetchProductsFuture = fetchProducts(context.read<CookieRequest>());
    _categoriesFuture = _getCategories(context.read<CookieRequest>());
  }

  Future<void> fetchProducts(CookieRequest request) async {
    final response = await request.get("https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/catalog/json");
    var data = response;
    List<ProductEntry> fetchedProducts = [];
    for (var d in data) {
      if (d != null) {
        ProductEntry product = ProductEntry.fromJson(d);
        fetchedProducts.add(product);
      }
    }
    setState(() {
      products = fetchedProducts;
    });
  }

  Future<void> _getCategories(CookieRequest request) async {
    final response = await request.get("https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/catalog/categories");
    var data = response;
    List<String> fetchedCategories = [];
    for (var d in data) {
      if (d != null) {
        fetchedCategories.add(d);
      }
    }
    fetchedCategories.add("All Categories");
    setState(() {
      filters = fetchedCategories;
    });
  }

  void _refreshProducts() {
    setState(() {
      _fetchProductsFuture = _applySearchFilter(context.read<CookieRequest>());
    });
  }
  
  Future<void> _applySearchFilter(CookieRequest request) async {
    if(searchValue == "") {
      searchValue = "NoSearch";
    }
    final response = await request.get("https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/catalog/json/key:${searchValue}/cat:${selectedFilter}");
    List<ProductEntry> fetchedProducts = [];
    var data = response;
    for (var d in data) {
      if (d != null) {
        ProductEntry product = ProductEntry.fromJson(d);
        fetchedProducts.add(product);
      }
    }
    setState(() {
      products = fetchedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / (screenHeight / 2);
    return BaseBuyer(
      appBar: AppBar(
        title: const Text("Catalog"),
      ),
      currentIndex: 2,
      backgroundColor: const Color.fromARGB(255, 185, 28, 27),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Row(
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                  onChanged: (value) {
                    // Handle search input
                    setState(() {
                            searchValue = value;
                            // Handle filter change
                          });
                    _applySearchFilter(request);
                  },
                ),
              ),
              const SizedBox(width: 10),
              FutureBuilder(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading categories');
                  } else {
                    return Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFilter,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilter = newValue!;
                            // Handle filter change
                          });
                          _applySearchFilter(request);
                        },
                        items: filters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 5,),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: _fetchProductsFuture,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (products.isEmpty) {
                  return const Center(
                    child: Text("No products found"),
                  );
                } else {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.575, // Adjust the aspect ratio as needed
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index],
                      onRefresh: _refreshProducts,);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}



