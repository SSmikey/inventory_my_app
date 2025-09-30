import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard.dart';
import '../api/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  final String token; // รับ token จาก login

  const DashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardService _service;
  Dashboard? _dashboard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = DashboardService();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _service.fetchDashboard(widget.token);
      setState(() {
        _dashboard = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _dashboard == null
              ? const Center(child: Text("No data"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // สรุปตัวเลข
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCard("Total Products", _dashboard!.totalProducts.toString(), Colors.blue),
                          _buildCard("Stock In", _dashboard!.totalStockIn.toString(), Colors.green),
                          _buildCard("Stock Out", _dashboard!.totalStockOut.toString(), Colors.red),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCard("Total Revenue", "\$${_dashboard!.totalRevenue.toStringAsFixed(2)}", Colors.orange),
                      const SizedBox(height: 24),
                      const Text("Last 7 Days Stock", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Expanded(child: _buildChart()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: color)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
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
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < _dashboard!.chartData.length) {
                return Text(_dashboard!.chartData[index].date.split('-').last);
              }
              return const Text("");
            },
            reservedSize: 32,
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
