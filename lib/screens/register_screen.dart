import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import 'dart:ui';

// ธีมสีส้มนุ่มนวล ไม่แสบตา (เหมือนกับ login_screen.dart)
class AppColors {
  static const primaryOrange = Color(0xFFFFAA80);
  static const secondaryOrange = Color(0xFFFFCC99);
  static const accentOrange = Color(0xFFFF8C66);
  static const backgroundStart = Color(0xFFFFF5EB);
  static const backgroundEnd = Color(0xFFFFE4CC);
  static const textDark = Color(0xFF5A4A42);
  static const shadowColor = Color(0x1AFF8C66);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: isSuccess
            ? Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(message, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              )
            : Text(message, style: const TextStyle(fontSize: 15)),
        backgroundColor: isError
            ? const Color(0xFFE57373)
            : isSuccess
            ? const Color(0xFF81C784)
            : AppColors.accentOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  void _register() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showSnackBar("กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showSnackBar("รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง");
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _showSnackBar("รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.register(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      _showSnackBar("สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ", isSuccess: true);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst("Exception: ", "");

      if (errorMessage.contains("already exists") ||
          errorMessage.contains("duplicate")) {
        errorMessage = "ชื่อผู้ใช้นี้ถูกใช้งานแล้ว กรุณาเลือกชื่อื่น";
      }

      _showSnackBar(errorMessage, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LogoWidget(),
                        const SizedBox(height: 35),
                        _HeaderSection(),
                        const SizedBox(height: 45),
                        _RegisterCard(
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          obscurePassword: _obscurePassword,
                          obscureConfirmPassword: _obscureConfirmPassword,
                          isLoading: _isLoading,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onToggleConfirmPassword: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                          onRegister: _register,
                        ),
                        const SizedBox(height: 28),
                        _LoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Logo Widget with Glow Effect
class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_add_rounded,
        size: 55,
        color: Colors.white,
      ),
    );
  }
}

// Header Section
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "สร้างบัญชีใหม่",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "กรอกข้อมูลเพื่อเริ่มต้นใช้งาน",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textDark.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Register Card with Glass Effect
class _RegisterCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onRegister;

  const _RegisterCard({
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              _GlassTextField(
                controller: usernameController,
                label: "ชื่อผู้ใช้",
                icon: Icons.person_outline_rounded,
                hintText: "เลือกชื่อผู้ใช้ของคุณ",
              ),
              const SizedBox(height: 18),
              _GlassTextField(
                controller: passwordController,
                label: "รหัสผ่าน",
                icon: Icons.lock_outline_rounded,
                hintText: "อย่างน้อย 6 ตัวอักษร",
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              const SizedBox(height: 18),
              _GlassTextField(
                controller: confirmPasswordController,
                label: "ยืนยันรหัสผ่าน",
                icon: Icons.lock_outline_rounded,
                hintText: "กรอกรหัสผ่านอีกครั้ง",
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                  onPressed: onToggleConfirmPassword,
                ),
              ),
              const SizedBox(height: 28),
              _GradientButton(
                text: "สมัครสมาชิก",
                onPressed: onRegister,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Glass TextField
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              labelStyle: TextStyle(
                color: AppColors.textDark.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppColors.textDark.withOpacity(0.4),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.accentOrange, size: 22),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Gradient Button
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, AppColors.primaryOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Login Link
class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "มีบัญชีอยู่แล้ว? ",
          style: TextStyle(
            color: AppColors.textDark.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            "เข้าสู่ระบบ",
            style: TextStyle(
              color: AppColors.accentOrange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accentOrange,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }
}
