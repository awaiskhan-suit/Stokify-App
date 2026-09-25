import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_products.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChange() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProductStream() {
    return _firebase.collection('products').orderBy('name').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoryStream() {
    return _firebase.collection('products').orderBy('category').snapshots();
  }

  List<String> _extractUniqueCategories(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final Set<String> categories = {};
    for (var doc in snapshot.docs) {
      final category = doc.data()['category'] ?? 'Uncategorized';
      categories.add(category);
    }
    final list = categories.toList()..sort();
    return ['All', ...list];
  }

  Map<String, List<DocumentSnapshot>> _filterAndGroupProducts(
      QuerySnapshot<Map<String, dynamic>> snapshot) {

    final Map<String, List<DocumentSnapshot>> groupedMap = {};

    final filteredDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toLowerCase();
      final category = data['category'] ?? 'Uncategorized';

      final categoryMatch =
      (_selectedCategory == null ||
          _selectedCategory == 'All' ||
          category == _selectedCategory);

      final searchMatch = name.contains(_searchText);

      return categoryMatch && searchMatch;
    }).toList();

    for (var doc in filteredDocs) {
      final data = doc.data();
      final category = data['category'] ?? 'Uncategorized';

      final groupKey = (_selectedCategory == null || _selectedCategory == 'All')
          ? category
          : "products";

      groupedMap.putIfAbsent(groupKey, () => []);
      groupedMap[groupKey]!.add(doc);
    }

    return groupedMap;
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firebase.collection('products').doc(productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully")),
      );
    }
  }

  void _editProduct(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(documentSnapshot: doc),
      ),
    );
  }

  Widget _buildProductItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final name = data['name'] ?? '';
    final price = data['price'] ?? '';
    final imagePath = data['localImagePath']; // ✅ FIXED

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: _buildProductImage(imagePath),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("PKR: $price"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduct(doc),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(doc.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (File(imagePath).existsSync()) {
        return ClipOval(
          child: Image.file(
            File(imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipOval(
          child: Image.network(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return const CircleAvatar(
      radius: 25,
      child: Icon(Icons.shopping_bag, color: Colors.grey), // ✅ changed icon
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Management"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔍 Search
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Search Products",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // 📂 Categories
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getCategoryStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();

                    final categories =
                    _extractUniqueCategories(snapshot.data!);

                    return SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          final isActive =
                              _selectedCategory == category ||
                                  (_selectedCategory == null &&
                                      category == 'All');

                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory =
                                category == 'All' ? null : category;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              isActive ? Colors.black : Colors.white,
                              foregroundColor:
                              isActive ? Colors.white : Colors.black,
                            ),
                            child: Text(category),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 📦 Product List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getProductStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groupedProducts =
                _filterAndGroupProducts(snapshot.data!);

                return ListView(
                  children: groupedProducts.entries.map((entry) {
                    final category = entry.key;
                    final products = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedCategory == null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              category,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...products.map(_buildProductItem).toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}