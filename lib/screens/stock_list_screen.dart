import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockListScreen extends StatefulWidget {
  final String token;
  final VoidCallback? reloadCallback;

  const StockListScreen({Key? key, required this.token, this.reloadCallback})
      : super(key: key);

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<Map<String, dynamic>> _stocks = [];
  final String apiBaseUrl = "https://inventory-ctvh.vercel.app/api";

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  // โหลด stock จาก backend (StockSummaryView)
  Future<void> _loadStock() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/stock/summary/"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (!mounted) return; // ✅ widget ถูก dispose ห้าม setState

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _stocks = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception("Failed to load stock: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return; // ✅ ป้องกัน SnackBar หลัง dispose
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading stock: $e")),
      );
    }
  }

  // เพิ่ม / ลด stock
  Future<void> _updateStock(int productId, String type, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/stock/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "product": productId,
          "type": type,
          "quantity": quantity,
        }),
      );

      if (!mounted) return; // ✅

      if (response.statusCode == 201) {
        await _loadStock(); // โหลดใหม่หลังอัปเดต
        widget.reloadCallback?.call(); // รีโหลด Dashboard
      } else {
        throw Exception("Failed to update stock: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Dialog เพิ่ม / ลด stock
  void _showStockDialog(Map<String, dynamic> product) {
    int quantity = 0;
    String type = 'IN';

    if (!mounted) return; // ✅

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Stock: ${product['product_name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'IN', child: Text("Stock In")),
                DropdownMenuItem(value: 'OUT', child: Text("Stock Out")),
              ],
              onChanged: (v) => type = v ?? 'IN',
              decoration: const InputDecoration(labelText: "Type"),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
              onChanged: (v) => quantity = int.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (quantity > 0) {
                await _updateStock(product['product_id'], type, quantity);

                if (!mounted) return; // ✅ ป้องกัน Navigator.pop หลัง dispose
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock list")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _stocks.isEmpty
            ? const Center(child: Text("No stock data"))
            : ListView.builder(
                itemCount: _stocks.length,
                itemBuilder: (context, index) {
                  final s = _stocks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        s['product_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Quantity: ${s['quantity'] ?? 0}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showStockDialog(s),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
