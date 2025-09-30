import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  final String baseUrl = "https://inventory-ctvh.vercel.app/api";

  Future<void> login(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    notifyListeners();
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    notifyListeners();
  }

  // 🔄 ฟังก์ชัน refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    final response = await http.post(
      Uri.parse("$baseUrl/token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      notifyListeners();
      return true;
    } else {
      await logout();
      return false;
    }
  }
}
