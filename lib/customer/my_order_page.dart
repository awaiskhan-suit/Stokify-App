import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // 🔹 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          // 🔹 No Orders
          if (orders.isEmpty) {
            return const Center(child: Text("No orders placed yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {

              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final total = data['total'] ?? 0;
              final status = data['status'] ?? 'pending';
              final items = List.from(data['items'] ?? []);
              final timestamp = data['timestamp'] as Timestamp?;

              final date = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                  timestamp.millisecondsSinceEpoch)
                  : DateTime.now();



              // 🔹 Status Colors
              Color statusColor;
              if (status == "delivered") {
                statusColor = Colors.green;
              } else if (status == "accepted") {
                statusColor = Colors.orange;
              } else {
                statusColor = Colors.grey;
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 ORDER HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID: ${doc.id.substring(0, 6)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: statusColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text("Order Date: ${date.day}-${date.month}-${date.year}"),

                      const Divider(),

                      /// 🔹 ITEMS LIST
                      const Text(
                        "Products:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "• ${item['name']}  x${item['quantity']}  (Rs ${item['price']})",
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      /// 🔹 TOTAL
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total Amount: Rs $total",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}