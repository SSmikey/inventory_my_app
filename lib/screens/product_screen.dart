import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> _products = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final String apiBaseUrl = "https://your-vercel-url.vercel.app/api";
  String token = ""; // ใส่ token ที่ login ได้

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await http.get(
      Uri.parse("$apiBaseUrl/products/"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        _products = data.map((e) => e as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;

    final response = await http.post(
      Uri.parse("$apiBaseUrl/products/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": nameController.text,
        "price": double.parse(priceController.text),
      }),
    );

    if (response.statusCode == 201) {
      _loadProducts();
      nameController.clear();
      priceController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
    }
  }

  Future<void> _deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse("$apiBaseUrl/products/$id/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 204) {
      _loadProducts();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting product")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text("Add Product"),
            ),
            const SizedBox(height: 24),
            const Text("Product List", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final p = _products[index];
                  return ListTile(
                    title: Text("${p['name']}"),
                    subtitle: Text("Price: ${p['price']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(p['id'] as int),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
