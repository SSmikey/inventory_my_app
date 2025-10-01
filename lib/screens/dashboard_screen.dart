import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/dashboard.dart';
import '../api/dashboard_service.dart';
import '../providers/auth_provider.dart';
import '../screens/product_screen.dart';
import 'stock_list_screen.dart';
import 'transaction_history_screen.dart';
import 'dart:ui';

// ใช้ธีมสีเดียวกับ LoginScreen
class AppColors {
  static const primaryOrange = Color(0xFFFFAA80);
  static const secondaryOrange = Color(0xFFFFCC99);
  static const accentOrange = Color(0xFFFF8C66);
  static const backgroundStart = Color(0xFFFFF5EB);
  static const backgroundEnd = Color(0xFFFFE4CC);
  static const textDark = Color(0xFF5A4A42);
  static const shadowColor = Color(0x1AFF8C66);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late DashboardService _service;
  Dashboard? _dashboard;
  bool _loading = true;
  String? _token;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _service = DashboardService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _token = auth.accessToken;

      if (_token != null) {
        await _fetchDashboard();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboard() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchDashboard(_token!);
      setState(() {
        _dashboard = data;
        _loading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading dashboard: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _buildDashboardPage(),
      ProductScreen(token: _token!, reloadCallback: _fetchDashboard),
      StockListScreen(token: _token!, reloadCallback: _fetchDashboard),
      TransactionHistoryScreen(token: _token!),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentOrange, AppColors.primaryOrange],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          "Inventory App",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.accentOrange,
              unselectedItemColor: AppColors.textDark.withOpacity(0.5),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: "Products",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store_rounded),
                  label: "Stock",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  label: "History",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPage() {
    if (_loading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
          ),
        ),
      );
    }

    if (_dashboard == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: const Center(child: Text("No data")),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      "Total Products",
                      _dashboard!.totalProducts.toString(),
                      Icons.inventory_2_rounded,
                      AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassCard(
                      "Stock In",
                      _dashboard!.totalStockIn.toString(),
                      Icons.arrow_downward_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      "Stock Out",
                      _dashboard!.totalStockOut.toString(),
                      Icons.arrow_upward_rounded,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassCard(
                      "Revenue",
                      "\$${_dashboard!.totalRevenue.toStringAsFixed(2)}",
                      Icons.attach_money_rounded,
                      AppColors.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Last 7 Days Stock",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              _buildChartContainer(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer() {
    if (_dashboard!.chartData.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Center(child: Text("No chart data")),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
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
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.textDark.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < _dashboard!.chartData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _dashboard!.chartData[index].date.split('-').last,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const Text("");
                    },
                    reservedSize: 32,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: AppColors.textDark.withOpacity(0.1),
                  width: 1,
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _dashboard!.chartData
                      .asMap()
                      .entries
                      .map(
                        (e) => FlSpot(
                          e.key.toDouble(),
                          e.value.stockIn.toDouble(),
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: _dashboard!.chartData
                      .asMap()
                      .entries
                      .map(
                        (e) => FlSpot(
                          e.key.toDouble(),
                          e.value.stockOut.toDouble(),
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: Colors.red,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
