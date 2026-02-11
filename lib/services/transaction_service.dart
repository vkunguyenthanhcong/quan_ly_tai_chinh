import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class   TransactionService {
  final supabase = Supabase.instance.client;
Future<int> getTodayExpenseTotal() async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final data = await supabase
      .from('transactions')
      .select('amount')
      .eq('type', 'expense')
      .gte('date', startOfDay.toIso8601String())
      .lt('date', endOfDay.toIso8601String());

  int total = 0;
  for (final item in data) {
    total += item['amount'] as int;
  }
  return total;
}
Future<void> updateTodayExpenseWidget() async {
  final total = await getTodayExpenseTotal();
    print(total);
  await HomeWidget.saveWidgetData(
    'today_expense',
    '$total',
  );

  await HomeWidget.updateWidget(
    androidName: 'ExpenseWidget',
    iOSName: 'ExpenseWidget',
  );
}
  Future<List<Map<String, dynamic>>> getTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

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
    .eq('user_id', userId!)
    .order('date', ascending: false);

  return List<Map<String, dynamic>>.from(res);
}
Future<void> addTransaction({
    required String categoryId,
    required String title,
    required int amount,
    required String type, // expense | income
    String? note,
    required DateTime date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Chưa đăng nhập");
    }

    await supabase.from('transactions').insert({
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date.toIso8601String().substring(0, 10),
    });
  }

Future<Map<String, int>> getSummary() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  if (userId == null) {
    throw Exception("Chưa đăng nhập");
  }

  final res = await supabase
      .from('transactions')
      .select('amount, type')
      .eq('user_id', userId);

  int income = 0;
  int expense = 0;

  for (final e in res) {
    if (e['type'] == 'income') {
      income += e['amount'] as int;
    } else if (e['type'] == 'expense') {
      expense += e['amount'] as int;
    }
  }

  return {
    'income': income,
    'expense': expense,
    'balance': income - expense,
  };
}
Future<List<Map<String, dynamic>>> getMonthlySummary(int year) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  if (userId == null) {
    throw Exception("Chưa đăng nhập");
  }

  final res = await supabase
      .from('transactions')
      .select('amount, type, date')
      .eq('user_id', userId)
      .gte('date', '$year-01-01')
      .lte('date', '$year-12-31');

  /// init 12 tháng
  final Map<int, Map<String, int>> monthly = {
    for (int m = 1; m <= 12; m++)
      m: {'income': 0, 'expense': 0}
  };

  for (final e in res) {
    final date = DateTime.parse(e['date']);
    final month = date.month;

    if (e['type'] == 'income') {
      monthly[month]!['income'] =
          monthly[month]!['income']! + (e['amount'] as int);
    } else if (e['type'] == 'expense') {
      monthly[month]!['expense'] =
          monthly[month]!['expense']! + (e['amount'] as int);
    }
  }

  return monthly.entries.map((e) {
    return {
      'month': e.key,
      'income': e.value['income'],
      'expense': e.value['expense'],
    };
  }).toList();
}
Future<void> deleteTransaction(String id) async {
  await supabase
      .from('transactions')
      .delete()
      .eq('id', id);
}

}
