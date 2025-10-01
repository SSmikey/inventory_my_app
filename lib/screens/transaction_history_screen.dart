import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui';

class TransactionHistoryScreen extends StatefulWidget {
  final String token;

  const TransactionHistoryScreen({Key? key, required this.token}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _transactions = [];
  final String apiBaseUrl = "https://inventory-ctvh.vercel.app/api";
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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
      if (!mounted) return;
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

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
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
              : ListView.separated(
                  itemCount: _transactions.length,
                  separatorBuilder: (context, idx) => Divider(
                    color: Colors.grey.shade300,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(
                        CurvedAnimation(
                          parent: _controller..forward(),
                          curve: Interval(index / _transactions.length, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        splashColor: Colors.orange.withOpacity(0.2),
                        onTap: () {
                          // สามารถเพิ่มฟังก์ชันเมื่อแตะรายการได้
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        getTypeColor(t['type']).withOpacity(0.12),
                                        Colors.white.withOpacity(0.7)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getTypeColor(t['type']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  formatDate(t['date']),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Tooltip(
                                message: t['type'] == 'in' ? 'Stock In' : 'Stock Out',
                                child: CircleAvatar(
                                  backgroundColor: getTypeColor(t['type']),
                                  child: Icon(
                                    getTypeIcon(t['type']),
                                    color: Colors.white,
                                  ),
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
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: getTypeColor(t['type']).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Type: ${t['type'].toUpperCase()}",
                                          style: TextStyle(
                                            color: getTypeColor(t['type']),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Qty: ${t['quantity']}",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.orange),
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