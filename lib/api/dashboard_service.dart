import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard.dart';

class DashboardService {
  final String baseUrl = "https://your-vercel-domain.vercel.app/api";

  Future<Dashboard> fetchDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Dashboard.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }
}
