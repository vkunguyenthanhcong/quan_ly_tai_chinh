import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Chưa đăng nhập");
    }

    final res = await supabase
        .from('users')
        .select('id, full_name, avatar_url, email')
        .eq('id', userId)
        .single();

    return res;
  }
}
