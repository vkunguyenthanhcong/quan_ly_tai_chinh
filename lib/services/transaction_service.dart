import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final supabase = Supabase.instance.client;

  /// ================= PRIVATE =================
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Chưa đăng nhập");
    }

    return userId;
  }

  Future<List<TransactionModel>> _mapResponse(dynamic response) async {
    final List data = response;

    return data
        .map((e) =>
            TransactionModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// ================= GET ALL =================
  Future<List<TransactionModel>> getTransactions() async {
    final userId = await _getUserId();

    final res = await supabase
        .from('transactions')
        .select('''
          id,
          title,
          amount,
          type,
          date,
          categories (
            category_store (
              name,
              icon
            )
          )
        ''')
        .eq('user_id', userId)
        .order('date', ascending: false);

    return _mapResponse(res);
  }

  /// ================= GET BY MONTH =================
  Future<List<TransactionModel>> getTransactionsByMonth(
      DateTime month) async {
    final userId = await _getUserId();

    final start = DateTime(month.year, month.month, 1);
    final end =
        DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final res = await supabase
        .from('transactions')
        .select('''
          id,
          title,
          amount,
          type,
          date,
          categories (
            category_store (
              name,
              icon
            )
          )
        ''')
        .eq('user_id', userId)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false);

    return _mapResponse(res);
  }

  /// ================= ADD =================
  Future<void> addTransaction({
    required String categoryId,
    required String title,
    required int amount,
    required String type,
    required DateTime date,
  }) async {
    final userId = await _getUserId();

    await supabase.from('transactions').insert({
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    });
  }

  /// ================= DELETE =================
  Future<void> deleteTransaction(String id) async {
    await supabase
        .from('transactions')
        .delete()
        .eq('id', id);
  }

  /// ================= SUMMARY BY MONTH =================
  Future<Map<String, int>> getSummaryByMonth(
      DateTime month) async {
    final transactions =
        await getTransactionsByMonth(month);

    int income = 0;
    int expense = 0;

    for (final t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  /// ================= YEAR SUMMARY =================
  Future<List<Map<String, int>>> getYearSummary(
      int year) async {
    final userId = await _getUserId();

    final res = await supabase
        .from('transactions')
        .select('amount, type, date')
        .eq('user_id', userId)
        .gte('date', '$year-01-01')
        .lte('date', '$year-12-31');

    final Map<int, Map<String, int>> monthly = {
      for (int m = 1; m <= 12; m++)
        m: {'income': 0, 'expense': 0}
    };

    for (final e in res) {
      final date = DateTime.parse(e['date']);
      final month = date.month;

      if (e['type'] == 'income') {
        monthly[month]!['income'] =
            monthly[month]!['income']! +
                (e['amount'] as int);
      } else {
        monthly[month]!['expense'] =
            monthly[month]!['expense']! +
                (e['amount'] as int);
      }
    }

    return monthly.entries.map((e) {
      return {
        'month': e.key,
        'income': e.value['income']!,
        'expense': e.value['expense']!,
      };
    }).toList();
  }
}