import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const InvoicePage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items =
    List<Map<String, dynamic>>.from(orderData['items'] ?? []);

    final status = orderData['status'] ?? 'Pending';

    // ✅ FIX: support both old & new data
    final address =
        orderData['address'] ?? orderData['location'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Mart Invoice"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      "City Mart",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("👤 Customer: ${orderData['customerName'] ?? 'N/A'}"),
                  Text("📞 Mobile: ${orderData['phone'] ?? 'N/A'}"),
                  Text("🏠 Address: $address"), // ✅ FIXED
                  Text("💳 Payment: ${orderData['paymentMethod'] ?? 'Not selected'}"),
                  Text("📅 Date: ${_formatOrderDate(orderData['timestamp'])}"),
                  Text("📌 Status: $status",
                      style: TextStyle(color: _getStatusColor(status))),

                  const SizedBox(height: 20),

                  const Text("🛒 Items:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),

                  ...items.map((item) => ListTile(
                    title: Text(item['name'] ?? 'Item'),
                    subtitle: Text("Qty: ${item['quantity'] ?? 1}"),
                    trailing: Text("Rs ${item['price'] ?? 0}"),
                  )),

                  const Divider(),

                  Text(
                    "Total Amount: Rs ${orderData['total'] ?? 0}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Share Invoice"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  final pdfBytes = await _generatePdf();

                  await Share.shareXFiles([
                    XFile.fromData(
                      pdfBytes,
                      name:
                      "Shopping_Invoice_${orderData['orderId'] ?? '001'}.pdf",
                      mimeType: "application/pdf",
                    ),
                  ]);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error sharing invoice: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatOrderDate(dynamic date) {
    if (date is Timestamp) {
      final dt = date.toDate();
      return "${dt.day}-${dt.month}-${dt.year} ${dt.hour}:${dt.minute}";
    } else if (date is DateTime) {
      return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
    }
    return "Unknown";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final List<Map<String, dynamic>> items =
    List<Map<String, dynamic>>.from(orderData['items'] ?? []);

    final status = orderData['status'] ?? 'Pending';

    // ✅ FIX HERE ALSO
    final address =
        orderData['address'] ?? orderData['location'] ?? 'N/A';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('City Mart',
                        style: pw.TextStyle(
                            fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Shahi Bala, Peshawar',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700)),
                    pw.SizedBox(height: 10),
                    pw.Text('Sales Invoice',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Customer: ${orderData['customerName'] ?? 'N/A'}"),
              pw.Text("Mobile: ${orderData['phone'] ?? 'N/A'}"),
              pw.Text("Address: $address"), // ✅ FIXED
              pw.Text("Payment: ${orderData['paymentMethod'] ?? 'Not selected'}"),
              pw.Text("Date: ${_formatOrderDate(orderData['timestamp'])}"),
              pw.Text("Status: $status"),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ['Item', 'Qty', 'Price'],
                data: items
                    .map((item) => [
                  item['name'] ?? 'Item',
                  item['quantity']?.toString() ?? '1',
                  "Rs ${item['price'] ?? 0}",
                ])
                    .toList(),
              ),

              pw.SizedBox(height: 10),

              pw.Text(
                "Total Amount: Rs ${orderData['total'] ?? 0}",
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}