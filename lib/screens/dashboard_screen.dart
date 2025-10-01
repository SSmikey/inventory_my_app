import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/dashboard.dart';
import '../api/dashboard_service.dart';
import '../providers/auth_provider.dart';
import '../screens/product_screen.dart';
import 'stock_list_screen.dart';
import 'transaction_history_screen.dart';

// ใช้ธีมสีเดียวกับ LoginScreen
class AppColors {
  static const primaryOrange = Color(0xFFFFAA80); // Soft Coral
  static const secondaryOrange = Color(0xFFFFCC99); // Warm Peach
  static const accentOrange = Color(0xFFFF8C66); // Muted Orange
  static const backgroundStart = Color(0xFFFFF5EB); // Cream White
  static const backgroundEnd = Color(0xFFFFE4CC); // Light Peach
  static const cardBackground = Color(0xFFFFFAF5); // Off White
  static const textDark = Color(0xFF5A4A42); // Warm Brown
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late DashboardService _service;
  Dashboard? _dashboard;
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _service = DashboardService();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _token = auth.accessToken;

      if (_token != null) {
        await _fetchDashboard();
        setState(() {});
      }
    });
  }

  Future<void> _fetchDashboard() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchDashboard(_token!);
      setState(() {
        _dashboard = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      _buildDashboardPage(),
      ProductScreen(token: _token!, reloadCallback: _fetchDashboard),
      StockListScreen(token: _token!, reloadCallback: _fetchDashboard),
      TransactionHistoryScreen(token: _token!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory App"),
        backgroundColor: AppColors.primaryOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accentOrange,
        unselectedItemColor: AppColors.textDark.withOpacity(0.6),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Stock"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_dashboard == null) return const Center(child: Text("No data"));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCard("Total Products", _dashboard!.totalProducts.toString(), AppColors.primaryOrange),
                _buildCard("Stock In", _dashboard!.totalStockIn.toString(), Colors.green),
                _buildCard("Stock Out", _dashboard!.totalStockOut.toString(), Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard("Total Revenue", "\$${_dashboard!.totalRevenue.toStringAsFixed(2)}", AppColors.accentOrange),
            const SizedBox(height: 24),
            const Text(
              "Last 7 Days Stock",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.35),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_dashboard!.chartData.isEmpty) return const Center(child: Text("No chart data"));

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < _dashboard!.chartData.length) {
                  return Text(
                    _dashboard!.chartData[index].date.split('-').last,
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                  );
                }
                return const Text("");
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _dashboard!.chartData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.stockIn.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: _dashboard!.chartData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.stockOut.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
