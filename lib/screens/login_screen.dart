import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final data = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // เก็บ token ใน AuthProvider
      await Provider.of<AuthProvider>(context, listen: false)
          .login(data['access'], data['refresh']);

      if (!mounted) return;

      // ไปหน้า Dashboard ด้วย Named Route
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;

      // ตัด prefix "Exception:" ออกไป ให้เหลือข้อความสั้น ๆ
      String errorMessage = e.toString().replaceFirst("Exception: ", "");

      // ถ้า error เป็น response JSON ยาว ๆ ให้แปลงเป็นข้อความสั้น
      if (errorMessage.contains("Login failed")) {
        errorMessage = "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: () {
                // ไปหน้า Register ด้วย Named Route
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
