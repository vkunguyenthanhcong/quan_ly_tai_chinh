import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/password_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Tạo tài khoản ✨",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Đăng ký để bắt đầu quản lý chi tiêu",
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 30),

              _input(nameCtrl, "Họ và tên"),
              _input(emailCtrl, "Email (@gmail.com)"),
              _input(passCtrl, "Mật khẩu (6 số)", isPassword: true),

              const SizedBox(height: 30),

              _registerButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= BUTTON =================

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "ĐĂNG KÝ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// ================= LOGIC =================

  Future<void> _handleRegister() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack("Vui lòng nhập đầy đủ thông tin", Colors.orange);
      return;
    }

    if (!isValidGmail(email)) {
      _showSnack("Email phải có dạng @gmail.com", Colors.orange);
      return;
    }

    if (!isValidPassword(password)) {
      _showSnack("Mật khẩu phải đúng 6 chữ số", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.register(
        email: email,
        password: password,
        fullName: name,
      );

      if (!mounted) return;

      _showSnack("🎉 Đăng ký thành công!", Colors.green);

      // Chờ 1.5s rồi quay về Login
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ================= COMPONENT =================

  Widget _input(
    TextEditingController ctrl,
    String hint, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword,
        keyboardType:
            isPassword ? TextInputType.number : TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF1E2538),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }
}
