import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';

class ApiService {
  final String baseUrl = "https://inventory-ctvh.vercel.app/api";

  Future<http.Response> get(BuildContext context, String endpoint) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? token = auth.accessToken;

    // 🔄 ถ้า token หมดหรือไม่ถูกต้อง ให้ refresh
    http.Response response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401) {
      bool refreshed = await auth.refreshAccessToken();
      if (refreshed) {
        token = auth.accessToken;
        response = await http.get(
          Uri.parse("$baseUrl/$endpoint"),
          headers: {"Authorization": "Bearer $token"},
        );
      }
    }

    return response;
  }

  Future<http.Response> post(BuildContext context, String endpoint, Map body) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? token = auth.accessToken;

    http.Response response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      bool refreshed = await auth.refreshAccessToken();
      if (refreshed) {
        token = auth.accessToken;
        response = await http.post(
          Uri.parse("$baseUrl/$endpoint"),
          headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }
}
