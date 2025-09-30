import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = "https://inventory-ctvh.vercel.app/api";

  Future<List<dynamic>> fetchProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> addProduct(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add product');
    }
  }

  Future<void> updateProduct(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteProduct(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }
}
