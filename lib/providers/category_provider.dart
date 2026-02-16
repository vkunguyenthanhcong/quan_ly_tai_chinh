import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/models/category_model.dart';
import '../services/category_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryProvider with ChangeNotifier {
  final _service = CategoryService();
  final _supabase = Supabase.instance.client;
    bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    final data = await _service.getUserCategories();
    _categories =
        data.map((e) => CategoryModel.fromMap(e)).toList();

    _isLoading = false;
    notifyListeners();
  }
  Future<String> getOrCreateDebtCategory(String type) async {
    
    /// 1️⃣ lấy store category "Trả nợ"
    final store =
        await _service.getStoreCategoryByName("Trả nợ", type);

    if (store == null) {
      throw Exception("Không tìm thấy store_category Trả nợ");
    }

    final storeId = store['id'];

    /// 2️⃣ kiểm tra user đã có chưa
    final exist = await _service.getUserCategory(
      storeCategoryId: storeId,
    );

    if (exist != null) {
      return exist['id'];
    }

    /// 3️⃣ chưa có → tạo
    return await _service.createUserCategory(
      storeCategoryId: storeId,
    );
  }
}
