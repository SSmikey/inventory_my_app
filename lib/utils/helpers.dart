import 'package:flutter/material.dart';

class Helpers {
  /// แสดง SnackBar
  static void showSnackBar(BuildContext context, String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ตรวจสอบว่า String เป็นเลขหรือไม่
  static bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }
}