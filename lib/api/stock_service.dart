import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  final String baseUrl = "https://inventory-ctvh.vercel.app/api";

  Future<List<dynamic>> fetchStock(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stock/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stock transactions');
    }
  }

  Future<void> addStock(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stock/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add stock transaction');
    }
  }

  Future<void> updateStock(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/stock/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update stock transaction');
    }
  }

  Future<void> deleteStock(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/stock/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete stock transaction');
    }
  }
}
