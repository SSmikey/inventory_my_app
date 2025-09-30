class Dashboard {
  final int totalProducts;
  final int totalStockIn;
  final int totalStockOut;
  final double totalRevenue;
  final List<ChartData> chartData;

  Dashboard({
    required this.totalProducts,
    required this.totalStockIn,
    required this.totalStockOut,
    required this.totalRevenue,
    required this.chartData,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalProducts: json['total_products'] ?? 0,
      totalStockIn: json['total_stock_in'] ?? 0,
      totalStockOut: json['total_stock_out'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      chartData: (json['chart_data'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ChartData {
  final String date;
  final int stockIn;
  final int stockOut;

  ChartData({required this.date, required this.stockIn, required this.stockOut});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: json['date'] ?? '',
      stockIn: json['in'] ?? 0,
      stockOut: json['out'] ?? 0,
    );
  }
}
