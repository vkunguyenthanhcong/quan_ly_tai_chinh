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
  Future<Map<String, dynamic>?> getStoreCategoryByName(String name, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return await supabase
        .from('category_store')
        .select()
        .eq('name', name)
        .eq('type', type)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getUserCategory({
    required String storeCategoryId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return await supabase
        .from('categories')
        .select()
        .eq('user_id', userId.toString())
        .eq('store_category_id', storeCategoryId)
        .maybeSingle();
  }

  /// Tạo category cho user
  Future<String> createUserCategory({
    required String storeCategoryId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final inserted = await supabase
        .from('categories')
        .insert({
          'user_id': userId,
          'store_category_id': storeCategoryId,
        })
        .select()
        .single();

    return inserted['id'];
  }
}
