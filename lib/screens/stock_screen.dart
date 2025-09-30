import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class StockScreen extends StatefulWidget {
  final VoidCallback? reloadCallback; // callback เรียกหลังเพิ่มรายการ

  const StockScreen({Key? key, this.reloadCallback, required String token}) : super(key: key);

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _transactions = [];

  int? selectedProductId;
  String type = 'IN';
  final quantityController = TextEditingController();

  final String apiBaseUrl = "https://inventory-ctvh.vercel.app/api";

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadTransactions();
  }

  Future<String> _getToken() async {
    return Provider.of<AuthProvider>(context, listen: false).accessToken!;
  }

  Future<void> _loadProducts() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("$apiBaseUrl/products/"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _products = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading products: $e")),
      );
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("$apiBaseUrl/stock/"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _transactions = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception("Failed to load transactions");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading transactions: $e")),
      );
    }
  }

  Future<void> _addTransaction() async {
    if (selectedProductId == null || quantityController.text.isEmpty) return;

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse("$apiBaseUrl/stock/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "product": selectedProductId,
          "type": type,
          "quantity": int.parse(quantityController.text),
        }),
      );

      if (response.statusCode == 201) {
        quantityController.clear();
        await _loadTransactions();
        widget.reloadCallback?.call(); // รีโหลด dashboard
      } else {
        throw Exception("Failed to add transaction: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Transactions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedProductId,
              items: _products
                  .map((p) => DropdownMenuItem(
                        value: int.tryParse(p['id'].toString()),
                        child: Text(p['name'].toString()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedProductId = v),
              decoration: const InputDecoration(labelText: "Product"),
            ),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'IN', child: Text("Stock In")),
                DropdownMenuItem(value: 'OUT', child: Text("Stock Out")),
              ],
              onChanged: (v) => setState(() => type = v ?? 'IN'),
              decoration: const InputDecoration(labelText: "Type"),
            ),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text("Add Transaction"),
            ),
            const SizedBox(height: 24),
            const Text("Transactions", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final t = _transactions[index];
                  return ListTile(
                    title: Text("${t['product_name']}"),
                    subtitle: Text("Type: ${t['type']} | Qty: ${t['quantity']}"),
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
