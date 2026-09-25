import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';
import 'add_to_cart.dart';
import 'my_order_page.dart';


class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';
  List<DocumentSnapshot> allProducts = [];
  List<DocumentSnapshot> filteredProducts = [];

  // ✅ Shopping Mart Categories
  final List<String> categories = [
    'All',
    'Groceries',
    'Fruits & Vegetables',
    'Dairy Products',
    'Beverages',
    'Snacks & Biscuits',
    'Frozen Foods',
    'Meat & Poultry',
    'Bakery Items',
    'Household Items',
    'Cleaning Supplies',
    'Personal Care',
    'Beauty & Cosmetics',
    'Baby Products',
    'Stationery',
    'Electronics',
    'Clothing',
    'Footwear',
    'Kitchen Appliances'
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      allProducts = snapshot.docs;
      filteredProducts = snapshot.docs;
    });
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredProducts = allProducts.where((product) {
        final data = product.data() as Map<String, dynamic>;

        final name = (data['name'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString();

        final matchesSearch = name.contains(query);
        final matchesCategory =
            selectedCategory == 'All' || category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () {
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please login first")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                );
              },
            ),
            title: const Text("Products"),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            centerTitle: true,
            actions: [
              // Login / Logout
              IconButton(
                icon: Icon(user == null ? Icons.person : Icons.logout),
                onPressed: () async {
                  if (user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  } else {
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logged out successfully")),
                    );
                  }
                },
              ),

              // Cart
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please login first")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
            ],
          ),

          body: Column(
            children: [
              // 🔍 Search
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => applyFilters(),
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              // 📂 Categories
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selectedCategory == cat,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = cat;
                            applyFilters();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 🛒 Products Grid
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(child: Text("No products found"))
                    : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.48,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredProducts[index],
                      user: user,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- PRODUCT CARD ----------------
class ProductCard extends StatefulWidget {
  final DocumentSnapshot product;
  final User? user;

  const ProductCard({super.key, required this.product, this.user});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final data = widget.product.data() as Map<String, dynamic>;

    final name = data['name'] ?? 'No Name';
    final price = data['price'] ?? 0;
    final imagePath = data['localImagePath'] ?? '';

    Widget imageWidget;

    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      imageWidget = Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.shopping_bag, size: 50),
      );
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          SizedBox(
            height: 140,
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: imageWidget,
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 4),

                  Text("PKR ${price * quantity}",
                      style: const TextStyle(fontSize: 14)),

                  const SizedBox(height: 8),

                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Add to Cart
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = widget.user;

                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please login first")),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                          return;
                        }

                        final uid = user.uid;

                        await FirebaseFirestore.instance
                            .collection('carts')
                            .doc(uid)
                            .collection('items')
                            .add({
                          'productId': widget.product.id,
                          'name': name,
                          'price': price,
                          'quantity': quantity,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$name added to cart")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Add to Cart"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}