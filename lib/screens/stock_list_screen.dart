import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockListScreen extends StatefulWidget {
  final String token;
  final VoidCallback? reloadCallback;

  const StockListScreen({Key? key, required this.token, this.reloadCallback}) : super(key: key);

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _stocks = [];
  final String apiBaseUrl = "https://inventory-ctvh.vercel.app/api";
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadStock();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/stock/summary/"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _stocks = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception("Failed to load stock: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading stock: $e")),
      );
    }
  }

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

      if (response.statusCode == 201) {
        await _loadStock();
        widget.reloadCallback?.call();
      } else {
        throw Exception("Failed to update stock: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showStockDialog(Map<String, dynamic> product) {
    int quantity = 0;
    String type = 'IN';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, color: Colors.orange, size: 40),
              const SizedBox(height: 8),
              Text("Update Stock: ${product['product_name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'IN', child: Text("Stock In")),
                  DropdownMenuItem(value: 'OUT', child: Text("Stock Out")),
                ],
                onChanged: (v) => type = v ?? 'IN',
                decoration: InputDecoration(
                  labelText: "Type",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => quantity = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (quantity > 0) {
                        _updateStock(product['product_id'], type, quantity);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Stock list"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _stocks.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text("No stock data",
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                )
              : ListView.separated(
                  itemCount: _stocks.length,
                  separatorBuilder: (context, idx) => Divider(
                    color: Colors.grey.shade300,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final s = _stocks[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(
                        CurvedAnimation(
                          parent: _controller..forward(),
                          curve: Interval(index / _stocks.length, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.07),
                                    Colors.white
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "ID: ${s['product_id']}",
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.inventory, color: Colors.white),
                              ),
                              title: Text(
                                s['product_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Quantity: ${s['quantity'] ?? 0}",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _showStockDialog(s),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}