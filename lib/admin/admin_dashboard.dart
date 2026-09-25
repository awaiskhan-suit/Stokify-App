import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stokify/admin/sales.dart';
import 'package:stokify/admin/supplier_mgt.dart';
import '../auth/login.dart';
import 'add_products.dart';
import 'admin_order_page.dart';
import 'categories.dart';
import 'expense_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  /// 🔥 COUNT STREAM
  Stream<int> getCount(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// ================= CARD =================
  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  /// ================= DASHBOARD =================
  Widget dashboardPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Shopping Mart Dashboard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        /// 🔹 PRODUCTS & ORDERS
        Row(
          children: [
            StreamBuilder<int>(
              stream: getCount("products"),
              builder: (context, snapshot) {
                return statCard(
                  "Products",
                  snapshot.data?.toString() ?? "0",
                  Icons.shopping_bag,
                  Colors.blue,
                );
              },
            ),
            StreamBuilder<int>(
              stream: getCount("orders"),
              builder: (context, snapshot) {
                return statCard(
                  "Orders",
                  snapshot.data?.toString() ?? "0",
                  Icons.receipt,
                  Colors.orange,
                );
              },
            ),
          ],
        ),

        /// 🔹 CUSTOMERS & PENDING ORDERS
        Row(
          children: [
            /// 👤 CUSTOMERS
            StreamBuilder<int>(
              stream: getCount("users"),
              builder: (context, snapshot) {
                return statCard(
                  "Customers",
                  snapshot.data?.toString() ?? "0",
                  Icons.people,
                  Colors.green,
                );
              },
            ),

            /// ⏳ PENDING ORDERS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.data?.docs.length ?? 0;

                return statCard(
                  "Pending",
                  count.toString(),
                  Icons.pending_actions,
                  Colors.redAccent,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 30),

        /// 🎉 WELCOME BOX
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.redAccent, Colors.indigo],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Icon(Icons.store, size: 60, color: Colors.white),
              SizedBox(height: 10),
              Text(
                "Welcome Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Manage your business easily",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      /// ================= DRAWER =================
      drawer: Drawer(
        child: Column(
          children: [

            /// 🔝 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.indigo],
                ),
              ),
              child: const Column(
                children: [
                  CircleAvatar(radius: 40, backgroundColor: Colors.white,backgroundImage: AssetImage('assets/images/download.png'),),
                  SizedBox(height: 10),
                  Text("City Mart",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            /// 📋 MENU
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Categories"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProductPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Product"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddProductPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text("Supplier"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddSupplierPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.money),
              title: const Text("Sales"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SalesPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text("Expenses"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ExpenseScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Invoices"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminOrdersPage()));
              },
            ),

            const Spacer(),
            const Divider(),

            /// 🔴 LOGOUT
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

      /// ================= BODY =================
      body: dashboardPage(),
    );
  }
}
