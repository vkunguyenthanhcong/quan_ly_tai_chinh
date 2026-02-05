import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// ================= GET USER ID =================
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Chưa đăng nhập");
    }
    return userId;
  }

  /// ================= GET CURRENT USER =================
  Future<Map<String, dynamic>> getCurrentUser() async {
    final userId = await _getUserId();

    final res = await supabase
        .from('users')
        .select('id, full_name, avatar_url, email')
        .eq('id', userId)
        .single();

    return res;
  }

  /// ================= UPLOAD AVATAR =================
  /// Upload ảnh → trả về public URL
  Future<String> uploadAvatar(File file) async {
    final userId = await _getUserId();

    final ext = file.path.split('.').last.toLowerCase();
    final filePath = '$userId/avatar/avatar.$ext';

    // 🔥 upload (upsert để ghi đè)
    await supabase.storage.from('avatars').upload(
          filePath,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            cacheControl: '3600',
          ),
        );

    // 🔥 lấy public url
    final publicUrl =
        supabase.storage.from('avatars').getPublicUrl(filePath);

    return publicUrl;
  }

  /// ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final userId = await _getUserId();

    await supabase.from('users').update({
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', userId);
  }
}
