import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui';

// ใช้ AppColors เดียวกับหน้า Login
class AppColors {
  static const primaryOrange = Color(0xFFFFAA80);
  static const secondaryOrange = Color(0xFFFFCC99);
  static const accentOrange = Color(0xFFFF8C66);
  static const backgroundStart = Color(0xFFFFF5EB);
  static const backgroundEnd = Color(0xFFFFE4CC);
  static const textDark = Color(0xFF5A4A42);
  static const shadowColor = Color(0x1AFF8C66);
}

class TransactionHistoryScreen extends StatefulWidget {
  final String token;

  const TransactionHistoryScreen({Key? key, required this.token})
    : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _transactions = [];
  final String apiBaseUrl = "https://inventory-ctvh.vercel.app/api";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        SnackBar(
          content: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล: $e"),
          backgroundColor: const Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Color getTypeColor(String type) {
    return type == 'in' ? AppColors.accentOrange : Colors.grey.shade600;
  }

  IconData getTypeIcon(String type) {
    return type == 'in'
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _transactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, AppColors.primaryOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "ประวัติรายการ",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange.withOpacity(0.3),
                  AppColors.accentOrange.withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              Icons.history_rounded,
              size: 50,
              color: AppColors.accentOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "ยังไม่มีประวัติรายการ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "รายการจะแสดงที่นี่เมื่อมีการทำธุรกรรม",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textDark.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final t = _transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTransactionCard(t, index),
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> t, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            getTypeColor(t['type']),
                            getTypeColor(t['type']).withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: getTypeColor(t['type']).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        getTypeIcon(t['type']),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${t['product_name']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getTypeColor(
                                    t['type'],
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t['type'].toUpperCase(),
                                  style: TextStyle(
                                    color: getTypeColor(t['type']),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "จำนวน: ${t['quantity']}",
                                style: TextStyle(
                                  color: AppColors.textDark.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(t['date']),
                            style: TextStyle(
                              color: AppColors.textDark.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.accentOrange,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
