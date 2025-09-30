import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const ChartWidget({Key? key, required this.chartData}) : super(key: key);

  double _getMaxY() {
    if (chartData.isEmpty) return 1; // ป้องกัน division by zero หรือ empty chart
    double maxY = 0;
    for (var item in chartData) {
      double inValue = double.tryParse('${item['in']}') ?? 0;
      double outValue = double.tryParse('${item['out']}') ?? 0;
      maxY = [maxY, inValue, outValue].reduce((a, b) => a > b ? a : b);
    }
    return maxY * 1.2; // เพิ่ม space บนกราฟ
  }

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < chartData.length; i++) {
      final item = chartData[i];
      double inValue = double.tryParse('${item['in']}') ?? 0;
      double outValue = double.tryParse('${item['out']}') ?? 0;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: inValue, color: Colors.green, width: 8),
            BarChartRodData(toY: outValue, color: Colors.red, width: 8),
          ],
        ),
      );
    }
    return groups;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    int index = value.round();
    if (chartData.isEmpty || index < 0 || index >= chartData.length) {
      return const Text('');
    }
    final date = chartData[index]['date'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        date.length > 5 ? date.substring(5) : date, // แสดง MM-DD
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: chartData.isEmpty
          ? const Center(child: Text("No chart data"))
          : BarChart(
              BarChartData(
                maxY: _getMaxY(),
                barGroups: _buildBarGroups(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getBottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
    );
  }
}
