import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:oleh_bali_mobile/base_seller.dart';
import 'add_product_form.dart';
import 'add_existing_product_form.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String? selectedSort;
  String? selectedCategory;
  final TextEditingController searchController = TextEditingController();
  Future<List<dynamic>>? _products;
  List<String> categories = ["All Categories"];
  Future<List<String>>? _categories;

  String formatRupiah(dynamic number) {
    if (number == null) return 'Rp 0';
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Ubah sortOptions menjadi Map untuk memetakan opsi sort ke nilai query
  final Map<String, String> sortOptions = {
    "Lowest to Highest": "asc",
    "Highest to Lowest": "desc",
  };

  Future<List<dynamic>> fetchProducts() async {
    final request = context.read<CookieRequest>();
    var url = 'http://localhost:8000/products/seller/show-products/json/';
    
    // Buat list parameter query
    List<String> queryParams = [];
    
    // Tambahkan parameter kategori jika ada
    if (selectedCategory != null && selectedCategory != "All Categories") {
      queryParams.add('category=${Uri.encodeComponent(selectedCategory!)}');
    }
    
    // Tambahkan parameter pencarian jika ada
    if (searchController.text.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchController.text)}');
    }

    // Tambahkan parameter sort jika ada
    if (selectedSort != null) {
      queryParams.add('sort_price=${sortOptions[selectedSort]}');
    }
    
    // Gabungkan semua parameter query
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }
    
    final response = await request.get(url);
    return response;
  }

  Future<List<String>> fetchCategories() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'http://localhost:8000/products/get-categories/',
    );
    
    List<String> fetchedCategories = ["All Categories"];
    if (response is List) {
      fetchedCategories.addAll(
        response.map((category) => category.toString()).toList()
      );
    }
    
    return fetchedCategories;
  }

  // Tambahkan fungsi untuk refresh produk saat kategori berubah
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

  void showEditDialog(BuildContext context, dynamic product) {
    final TextEditingController priceController = TextEditingController();
    priceController.text = product['price'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              labelText: 'Price',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price cannot be empty')),
                  );
                  return;
                }

                final request = context.read<CookieRequest>();
                final response = await request.post(
                  'http://localhost:8000/products/seller/edit/${product['id']}/json/',
                  {
                    'price': priceController.text,
                  },
                );

                if (response['status'] == true) {
                  Navigator.pop(context);
                  refreshProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price updated successfully!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update price'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus produk "${product['name']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final request = context.read<CookieRequest>();
                final response = await request.post(
                  'http://localhost:8000/products/seller/delete/${product['id']}/json/',
                  {},
                );

                Navigator.pop(context);

                if (response['status'] == true) {
                  refreshProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk berhasil dihapus!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus produk'),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "The Products You're Selling",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                onChanged: (value) {
                  // Refresh produk setiap kali input pencarian berubah
                  refreshProducts();
                },
              ),
              const SizedBox(height: 16),

              // Sort Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Sort by Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // Tambahkan suffix icon untuk clear
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
                    // Refresh produk setiap kali sorting berubah
                    refreshProducts();
                  });
                },
                // Tambahkan hint text
                hint: const Text('No sorting'),
              ),
              const SizedBox(height: 16),

              // Categories
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<String>>(
                future: _categories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      bool isSelected = selectedCategory == category;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedCategory = selected ? category : null;
                            // Refresh produk setiap kali kategori berubah
                            refreshProducts();
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Add Product Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProductForm(),
                          ),
                        );
                        
                        // Refresh products list if new product was added
                        if (result == true) {
                          refreshProducts();
                        }
                      },
                      child: const Text("Add New Product"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddExistingProductForm(),
                          ),
                        );
                        
                        // Refresh products list if new product was added
                        if (result == true) {
                          refreshProducts();
                        }
                      },
                      child: const Text("Add Existing Product"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product List dari Django
              FutureBuilder<List<dynamic>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada produk.'));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.63,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    padding: const EdgeInsets.only(bottom: 2),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var product = snapshot.data![index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  image: product['image'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(product['image']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: product['image'] == null
                                    ? const Icon(Icons.image, size: 50)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      formatRupiah(product['price']),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      product['category'] ?? 'No Category',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              showEditDialog(context, product);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 18),
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              showDeleteDialog(context, product);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 