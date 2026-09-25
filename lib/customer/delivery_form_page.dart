import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'orderConfirmationPage.dart';


class DeliveryFormPage extends StatefulWidget {
  final double total;

  const DeliveryFormPage({super.key, required this.total});

  @override
  State<DeliveryFormPage> createState() => _DeliveryFormPageState();
}

class _DeliveryFormPageState extends State<DeliveryFormPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  String paymentMethod = "Cash on Delivery";
  bool loading = false;

  Future<void> placeOrder() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final location = locationController.text.trim();

    if (name.isEmpty || phone.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // ✅ FIXED (must match CartPage)
      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items');

      final snapshot = await cartRef.get();
      final items = snapshot.docs;

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cart is empty")),
        );
        setState(() => loading = false);
        return;
      }

      // Convert cart items to list
      final orderItems = items.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'],
          'price': data['price'],
          'quantity': data['quantity'],
        };
      }).toList();

      // Save order
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'customerName': name,
        'phone': phone,
        'address': location,
        'paymentMethod': paymentMethod,
        'items': orderItems,
        'total': widget.total,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear cart
      for (var doc in items) {
        await cartRef.doc(doc.id).delete();
      }

      // Navigate to confirmation page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OrderConfirmationPage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Details"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // 📞 Phone
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // 📍 Address
            TextField(
              controller: locationController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Delivery Location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // 💳 Payment Method
            DropdownButtonFormField<String>(
              value: paymentMethod,
              decoration: const InputDecoration(
                labelText: "Payment Method",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Cash on Delivery",
                  child: Text("Cash on Delivery"),
                ),
                DropdownMenuItem(
                  value: "JazzCash",
                  child: Text("JazzCash"),
                ),
                DropdownMenuItem(
                  value: "EasyPaisa",
                  child: Text("EasyPaisa"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            // 🛒 Place Order
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Place Order (Rs ${widget.total})"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
