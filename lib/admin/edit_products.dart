import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const EditProductPage({
    super.key,
    required this.documentSnapshot,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;

  // ✅ Shopping Mart Categories
  final List<String> _categories = [
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

  String? _selectedCategory;
  String? _currentImagePath;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();

    final data = widget.documentSnapshot.data() as Map<String, dynamic>;

    _nameController = TextEditingController(text: data['name'] ?? '');
    _priceController =
        TextEditingController(text: data['price']?.toString() ?? '');

    _selectedCategory = data['category'];

    // ✅ FIX: Ensure category exists in list
    if (_selectedCategory != null &&
        !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }

    _currentImagePath = data['localImagePath'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// 📸 Pick new image
  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final pickedImage =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedImage != null) {
      setState(() {
        _newImageFile = File(pickedImage.path);
      });
    }
  }

  /// 🔄 Update Product
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String imageToSave = _currentImagePath ?? '';

      if (_newImageFile != null) {
        imageToSave = _newImageFile!.path;
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.documentSnapshot.id)
          .update({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'category': _selectedCategory,
        'localImagePath': imageToSave, // ✅ FIXED
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating product: $e")),
      );
    }
  }

  /// 🖼 Image Preview
  Widget _buildCurrentImage() {
    String? imagePath = _newImageFile?.path ?? _currentImagePath;

    if (imagePath == null || imagePath.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
      );
    }

    if (File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const CircleAvatar(
          radius: 50,
          child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// 📝 Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter product name" : null,
                ),

                const SizedBox(height: 16),

                /// 💲 Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter price" : null,
                ),

                const SizedBox(height: 16),

                /// 📂 Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Select a category" : null,
                ),

                const SizedBox(height: 16),

                /// 🖼 Image + Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCurrentImage(),
                    ElevatedButton.icon(
                      onPressed: _pickNewImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Change Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔄 Update Button
                ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Update Product"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}