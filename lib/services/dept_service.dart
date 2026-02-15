import 'package:quan_ly_chi_tieu/models/dept_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class DebtService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<DebtModel>> getDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) throw Exception("Chưa đăng nhập");

    final data = await _supabase
        .from('debts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    
    return data.map<DebtModel>((e) => DebtModel.fromMap(e)).toList();
  }

  Future<void> addDebt(DebtModel debt) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) throw Exception("Chưa đăng nhập");

    await _supabase
        .from('debts')
        .insert(debt.toInsertMap(userId));
  }
Future<void> deleteDebt(String id) async {
  await _supabase.from('debts').delete().eq('id', id);
}
  Future<void> markAsPaid(String id) async {
    await _supabase
        .from('debts')
        .update({'is_paid': true})
        .eq('id', id);
  }

  Future<void> updateNextReminder(String id) async {
    final next = DateTime.now().add(const Duration(days: 7));

    await _supabase
        .from('debts')
        .update({'next_remind_at': next.toIso8601String()})
        .eq('id', id);
  }
}
