import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  final supabase = Supabase.instance.client;

  /// Lấy category user đã chọn + info từ store
  Future<List<Map<String, dynamic>>> getUserCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Chưa đăng nhập");
    }

    final res = await supabase
    .from('categories')
    .select('''
      id,
      category_store (
        name,
        icon,
        type
      )
    ''')
    .eq('user_id', userId);
    print(res);


    return (res as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
