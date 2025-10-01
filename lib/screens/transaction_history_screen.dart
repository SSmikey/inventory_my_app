import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionHistoryScreen extends StatefulWidget {
  final String token;

  const TransactionHistoryScreen({Key? key, required this.token}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  final String apiBaseUrl = "https://inventory-ctvh.vercel.app/api";

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/stock/"), // API transaction history
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as List).reversed.toList(); // เรียงล่าสุดก่อน
        if (!mounted) return; // ✅ ป้องกัน setState หลัง dispose
        setState(() {
          _transactions = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception("Failed to load transactions");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading transactions: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _transactions.isEmpty
            ? const Center(child: Text("No transaction data"))
            : ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final t = _transactions[index];
                  return ListTile(
                    title: Text("${t['product_name']}"),
                    subtitle: Text(
                      "Type: ${t['type']} | Qty: ${t['quantity']} | Date: ${t['date']}",
                    ),
                  );
                },
              ),
      ),
    );
  }
}
