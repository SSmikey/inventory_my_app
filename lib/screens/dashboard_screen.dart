import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalProducts = 0;
  int totalStockIn = 0;
  int totalStockOut = 0;
  double totalRevenue = 0;
  List<Map<String, dynamic>> chartData = [];

  bool isLoading = true;

  // TODO: ดึง token จาก login จริง
  String token = ""; // ใส่ token ของผู้ใช้จริง

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    const url = "https://YOUR_BACKEND_URL/api/dashboard/";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          totalProducts = data['total_products'] ?? 0;
          totalStockIn = data['total_stock_in'] ?? 0;
          totalStockOut = data['total_stock_out'] ?? 0;
          totalRevenue = (data['total_revenue'] ?? 0).toDouble();
          chartData = (data['chart_data'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          isLoading = false;
        });
      } else {
        debugPrint("Error fetching dashboard: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Exception fetching dashboard: $e");
      setState(() => isLoading = false);
    }
  }

  List<BarChartGroupData> _generateBarChartData() {
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final inVal = (data['in'] ?? 0).toDouble();
      final outVal = (data['out'] ?? 0).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: inVal, color: Colors.green),
          BarChartRodData(toY: outVal, color: Colors.red),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard(
                          "Products", totalProducts.toString(), Colors.blue),
                      _buildSummaryCard(
                          "Stock In", totalStockIn.toString(), Colors.green),
                      _buildSummaryCard(
                          "Stock Out", totalStockOut.toString(), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(
                      "Revenue", "\$${totalRevenue.toStringAsFixed(2)}", Colors.purple),
                  const SizedBox(height: 20),

                  // Bar chart
                  Text(
                    "Last 7 days transactions",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 12),
                  chartData.isEmpty
                      ? const Text("No chart data")
                      : SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              barGroups: _generateBarChartData(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 && index < chartData.length) {
                                        final date = chartData[index]['date']?.toString() ?? '';
                                        return Text(date.length >= 5 ? date.substring(5) : date);
                                      }
                                      return const Text("");
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: color,
      child: SizedBox(
        width: 100,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
