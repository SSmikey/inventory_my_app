import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://inventory-ctvh.vercel.app/api";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      // สมัครสำเร็จ → ไม่ต้องส่ง token ออกมา
      return {"success": true};
    } else if (response.statusCode == 400) {
      // ถ้าชื่อซ้ำหรือข้อมูลไม่ครบ
      final body = jsonDecode(response.body);
      if (body['username'] != null) {
        throw Exception('ชื่อผู้ใช้นี้ถูกใช้แล้ว');
      }
      throw Exception('ข้อมูลไม่ถูกต้อง');
    } else {
      throw Exception('Register failed');
    }
  }
}
