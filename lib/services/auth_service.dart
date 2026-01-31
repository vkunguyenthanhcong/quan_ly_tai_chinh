import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/password_utils.dart';

class AuthService {
  final supabase = Supabase.instance.client;

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
    await prefs.setString('user_id', res['id']);
    await prefs.setString('user_email', res['email']);
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ================= CHECK LOGIN =================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }
}
