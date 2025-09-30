import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/dashboard.dart';
import '../api/dashboard_service.dart';
import '../providers/auth_provider.dart';
import '../screens/product_screen.dart';
import '../screens/stock_screen.dart';

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
  late String _token;

  @override
  void initState() {
    super.initState();
    _service = DashboardService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _token = Provider.of<AuthProvider>(context, listen: false).accessToken!;
      _fetchDashboard();
    });
  }

  Future<void> _fetchDashboard() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchDashboard(_token);
      setState(() {
        _dashboard = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
    }
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardPage(),
      ProductScreen(
        token: _token,
        reloadCallback: _fetchDashboard,
      ),
      StockScreen(
        token: _token,
        reloadCallback: _fetchDashboard,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory App"),
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
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Stock"),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_dashboard == null) return const Center(child: Text("No data"));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCard("Total Products", _dashboard!.totalProducts.toString(), Colors.blue),
              _buildCard("Stock In", _dashboard!.totalStockIn.toString(), Colors.green),
              _buildCard("Stock Out", _dashboard!.totalStockOut.toString(), Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
              "Total Revenue", "\$${_dashboard!.totalRevenue.toStringAsFixed(2)}", Colors.orange),
          const SizedBox(height: 24),
          const Text(
            "Last 7 Days Stock",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: color)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_dashboard!.chartData.isEmpty) {
      return const Center(child: Text("No chart data"));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < _dashboard!.chartData.length) {
                  return Text(
                    _dashboard!.chartData[index].date.split('-').last,
                    style: const TextStyle(fontSize: 12),
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
            spots: _dashboard!.chartData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.stockIn.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: _dashboard!.chartData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.stockOut.toDouble());
            }).toList(),
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
