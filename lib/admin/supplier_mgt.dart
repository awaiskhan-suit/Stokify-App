import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  List<Map<String, dynamic>> _products = [];

  /// ➕ Add Product
  void _addProduct() {
    setState(() {
      _products.add({'name': '', 'quantity': ''});
    });
  }

  /// 💾 Save Supplier + Generate PDF
  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection('suppliers').add({
        'supplierName': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'products': _products,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Supplier added successfully!")),
      );

      await _generatePdf();

      _formKey.currentState!.reset();
      setState(() => _products.clear());
    }
  }

  /// 📄 Generate PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              /// 🏪 HEADER
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Shopping Mart",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text("Supplier Record",
                        style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              /// 👤 SUPPLIER INFO
              pw.Text("Supplier Name: ${_nameController.text}"),
              pw.Text("Phone: ${_phoneController.text}"),
              pw.Text("Email: ${_emailController.text}"),
              pw.Text("Address: ${_addressController.text}"),

              pw.SizedBox(height: 20),

              /// 📦 PRODUCTS TABLE
              pw.Text("Products Supplied:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("Product Name",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("Quantity",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ]),

                  ..._products.map((p) => pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(p['name'].toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(p['quantity'].toString()),
                    ),
                  ])),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/supplier_${_nameController.text}.pdf");

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Shopping Mart Supplier Record - ${_nameController.text}",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();

    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// 🧾 INPUT FIELDS
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Supplier Name", border: OutlineInputBorder()),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter supplier name" : null,
              ),
              const SizedBox(height: 10),



              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder()),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: "Address", border: OutlineInputBorder()),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter address" : null,
              ),

              const SizedBox(height: 20),

              /// 📦 PRODUCTS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Products", style: TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add_circle,
                        color: Colors.redAccent),
                  ),
                ],
              ),

              Column(
                children: _products.map((product) {
                  final index = _products.indexOf(product);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Product Name",
                                border: OutlineInputBorder()),
                            onSaved: (val) =>
                            _products[index]['name'] = val ?? '',
                            validator: (v) =>
                            v == null || v.isEmpty ? "Enter name" : null,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Qty",
                                border: OutlineInputBorder()),
                            onSaved: (val) =>
                            _products[index]['quantity'] = val ?? '',
                            validator: (v) =>
                            v == null || v.isEmpty ? "Enter qty" : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// ✅ SAVE BUTTON
              ElevatedButton.icon(
                onPressed: _saveSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Save & Generate PDF"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}