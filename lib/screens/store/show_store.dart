import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ShowStore extends StatefulWidget {
  const ShowStore({Key? key}) : super(key: key);

  @override
  _ShowStoreState createState() => _ShowStoreState();
}

class _ShowStoreState extends State<ShowStore> {
  List<dynamic> _stores = [];
  List<dynamic> _filteredStores = [];
  bool _isFilterApplied = false;
  String _filterType = 'village';

  Map<String, String> subdistricts = {};
  Map<String, String> villages = {};

  String? selectedSubdistrict;
  String? selectedVillage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    fetchStores();
    fetchDataDropdown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStores() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/store/api/seller/');

    setState(() {
      _stores = List.from(response['sellers']);
      _filteredStores = _stores;
    });
  }

  Future<void> fetchDataDropdown() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/profile/api/edit/choices/');

    setState(() {
      subdistricts = Map<String, String>.from(response['subdistricts']);
      villages = Map<String, String>.from(response['villages']);
    });
  }

  void _applyFilter() {
    setState(() {
      // First filter by store name
      var nameFiltered = _stores.where((store) {
        return store['store_name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();

      // Then apply location filters if selected
      _filteredStores = nameFiltered.where((store) {
        bool matchesFilter = true;
        if (selectedVillage != null && selectedVillage!.isNotEmpty) {
          matchesFilter = matchesFilter && store['village'] == selectedVillage;
        }
        if (selectedSubdistrict != null && selectedSubdistrict!.isNotEmpty) {
          matchesFilter = matchesFilter && store['subdistrict'] == selectedSubdistrict;
        }
        return matchesFilter;
      }).toList();

      _isFilterApplied = _searchQuery.isNotEmpty ||
          (selectedVillage != null && selectedVillage!.isNotEmpty) ||
          (selectedSubdistrict != null && selectedSubdistrict!.isNotEmpty);
    });
  }

  void _clearFilter() {
    setState(() {
      selectedVillage = null;
      selectedSubdistrict = null;
      _searchQuery = '';
      _searchController.clear();
      _filteredStores = _stores;
      _isFilterApplied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseBuyer(
      currentIndex: 2,
      appBar: AppBar(
        title: const Text('Store List'),
        elevation: 0,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Modern search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search stores...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _applyFilter();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilter();
                          });
                        },
                      ),
                    ),

                    // Active filters display
                    if (_isFilterApplied) ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (selectedSubdistrict != null && selectedSubdistrict!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(subdistricts[selectedSubdistrict] ?? ''),
                                  onDeleted: () {
                                    setState(() {
                                      selectedSubdistrict = null;
                                      _applyFilter();
                                    });
                                  },
                                ),
                              ),
                            if (selectedVillage != null && selectedVillage!.isNotEmpty)
                              Chip(
                                label: Text(villages[selectedVillage] ?? ''),
                                onDeleted: () {
                                  setState(() {
                                    selectedVillage = null;
                                    _applyFilter();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Store list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
                  itemCount: _filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = _filteredStores[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(store['profile_picture']),
                        ),
                        title: Text(store['store_name']),
                        subtitle: Text('${store['village']}, ${store['subdistrict']}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Address: ${store['address']}'),
                                Text('City: ${store['city']}'),
                                const SizedBox(height: 8),
                                const Text('Products:'),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: store['products'].length,
                                  itemBuilder: (context, productIndex) {
                                    final product = store['products'][productIndex];
                                    return ListTile(
                                      title: Text(product['product_name']),
                                      trailing: Text('Rp ${product['price']}'),
                                    );
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Open maps URL
                                    // You might want to add url_launcher package to handle this
                                    print('Opening maps: ${store['maps']}');
                                  },
                                  child: const Text('View on Maps'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating filter button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Filter Stores',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedSubdistrict,
                          decoration: const InputDecoration(
                            labelText: 'Subdistrict',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('All Subdistricts'),
                            ),
                            ...subdistricts.entries.map((e) =>
                              DropdownMenuItem(value: e.key, child: Text(e.value))
                            ).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSubdistrict = value;
                              Navigator.pop(context);
                              _applyFilter();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedVillage,
                          decoration: const InputDecoration(
                            labelText: 'Village',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('All Villages'),
                            ),
                            ...villages.entries.map((e) =>
                              DropdownMenuItem(value: e.key, child: Text(e.value))
                            ).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedVillage = value;
                              Navigator.pop(context);
                              _applyFilter();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Filter'),
            ),
          ),
        ],
      ),
    );
  }
}
