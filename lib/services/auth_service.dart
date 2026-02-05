import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/password_utils.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ===== KEY LƯU PREFS =====
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyLoginTime = 'login_time';

  // ===== THỜI HẠN ĐĂNG NHẬP =====
  static const Duration sessionDuration = Duration(days: 30);

  /// ================= REGISTER =================
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!isValidGmail(email)) {
      throw Exception("Email phải là @gmail.com");
    }
    if (!isValidPassword(password)) {
      throw Exception("Mật khẩu phải đúng 6 chữ số");
    }

    final hash = hashPassword(password);

    await supabase.from('users').insert({
      'email': email,
      'password_hash': hash,
      'full_name': fullName,
    });
  }

  /// ================= LOGIN =================
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final hash = hashPassword(password);

    final res = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password_hash', hash)
        .maybeSingle();

    if (res == null) {
      throw Exception("Sai email hoặc mật khẩu");
    }

    final prefs = await SharedPreferences.getInstance();

    // 🔥 LƯU SESSION
    await prefs.setString(_keyUserId, res['id']);
    await prefs.setString(_keyUserEmail, res['email']);
    await prefs.setInt(
      _keyLoginTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// ================= CHECK LOGIN (CÓ THỜI HẠN) =================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString(_keyUserId);
    final loginTime = prefs.getInt(_keyLoginTime);

    if (userId == null || loginTime == null) {
      return false;
    }

    final loginDate =
        DateTime.fromMillisecondsSinceEpoch(loginTime);
    final now = DateTime.now();

    // ⛔ HẾT HẠN → LOGOUT
    if (now.difference(loginDate) > sessionDuration) {
      await logout();
      return false;
    }
    return true;
  }

  /// ================= GET USER ID (CHO SERVICE KHÁC) =================
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyLoginTime);
  }
}
