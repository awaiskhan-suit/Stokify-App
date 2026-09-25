import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'invoice_page.dart';


class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Orders"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
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
            return const Center(child: Text("No orders available"));
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

              // 🔹 Status Color
              Color statusColor;
              switch (status.toLowerCase()) {
                case "delivered":
                  statusColor = Colors.green;
                  break;
                case "accepted":
                  statusColor = Colors.orange;
                  break;
                case "pending":
                  statusColor = Colors.grey;
                  break;
                default:
                  statusColor = Colors.blue;
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

                          // 🔹 Status Dropdown
                          DropdownButton<String>(
                            value: status,
                            items: const [
                              DropdownMenuItem(
                                value: "pending",
                                child: Text("Pending"),
                              ),
                              DropdownMenuItem(
                                value: "accepted",
                                child: Text("Accepted"),
                              ),
                              DropdownMenuItem(
                                value: "delivered",
                                child: Text("Delivered"),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(doc.id)
                                    .update({'status': value});
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text("Order Date: ${date.day}-${date.month}-${date.year}"),

                      const Divider(),

                      /// 🔹 PRODUCT LIST
                      const Text(
                        "Products:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      ...items.map((item) => Text(
                          "• ${item['name']} x${item['quantity']} (Rs ${item['price']})")),

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

                      const SizedBox(height: 10),

                      /// 🔹 INVOICE BUTTON
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InvoicePage(
                                  orderData: {
                                    ...data,
                                    'orderDate': timestamp,
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text("View Invoice"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
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