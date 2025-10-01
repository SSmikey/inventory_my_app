import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
        Uri.parse("$apiBaseUrl/stock/"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as List).reversed.toList();
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

  Color getTypeColor(String type) {
    switch (type) {
      case 'in':
        return Colors.orange;
      case 'out':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type) {
      case 'in':
        return Icons.arrow_downward;
      case 'out':
        return Icons.arrow_upward;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.orange,
        elevation: 2,
        foregroundColor: Colors.white,
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
          child: _transactions.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text("No transaction data",
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                )
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getTypeColor(t['type']),
                          child: Icon(
                            getTypeIcon(t['type']),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          "${t['product_name']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Type: ${t['type'].toUpperCase()}",
                              style: TextStyle(
                                color: getTypeColor(t['type']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Qty: ${t['quantity']} | Date: ${t['date']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}