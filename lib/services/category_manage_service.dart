import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryManageService {
  final supabase = Supabase.instance.client;

  Future<String> _userId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id')!;
  }

  /// Lấy category store + user selected
  Future<List<Map<String, dynamic>>> getStoreCategories(String type) async {
    final uid = await _userId();

    final res = await supabase.rpc(
      'get_store_categories_with_selected',
      params: {
        'p_user_id': uid,
        'p_type': type,
      },
    );

    return List<Map<String, dynamic>>.from(res);
  }

  /// Bật / tắt category cho user
  Future<void> toggleUserCategory(Map<String, dynamic> c) async {
    final uid = await _userId();

    if (c['selected']) {
      await supabase
          .from('categories')
          .delete()
          .eq('user_id', uid)
          .eq('store_category_id', c['id']);
    } else {
      await supabase.from('categories').insert({
        'user_id': uid,
        'store_category_id': c['id'],
      });
    }
  }
}
