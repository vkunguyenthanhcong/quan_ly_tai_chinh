import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticService {
  final supabase = Supabase.instance.client;

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) throw Exception("Chưa đăng nhập");
    return userId;
  }

  DateTime _start(int year, int month) => DateTime(year, month, 1);
  DateTime _end(int year, int month) => DateTime(year, month + 1, 0);

  /// ===== LOAD TOÀN BỘ DATA =====
  Future<StatisticResult> loadStatistic({
    required String type, // expense | income
    required int month,
    required int year,
  }) async {
    final userId = await _getUserId();
    final start = _start(year, month);
    final end = _end(year, month);

    /// total
    final totalRes = await supabase
        .from('transactions')
        .select('amount')
        .eq('user_id', userId)
        .eq('type', type)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String());

    int total = 0;
    for (final r in totalRes) {
      total += r['amount'] as int;
    }

    /// bar (theo ngày)
    final barRes = await supabase
        .from('transactions')
        .select('amount, date')
        .eq('user_id', userId)
        .eq('type', type)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String());

    final Map<int, int> barData = {};
    for (final r in barRes) {
      final day = DateTime.parse(r['date']).day;
      barData[day] = (barData[day] ?? 0) + (r['amount'] as int);
    }

    /// pie (theo category_store)
    final pieRes = await supabase
        .from('transactions')
        .select('''
          amount,
          categories (
            category_store ( name )
          )
        ''')
        .eq('user_id', userId)
        .eq('type', type)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String());

    final Map<String, int> pieData = {};
    for (final r in pieRes) {
      final name =
          r['categories']?['category_store']?['name'] ?? 'Khác';
      pieData[name] = (pieData[name] ?? 0) + (r['amount'] as int);
    }

    return StatisticResult(
      total: total,
      barData: barData,
      pieData: pieData,
    );
  }
}

class StatisticResult {
  final int total;
  final Map<int, int> barData;
  final Map<String, int> pieData;

  StatisticResult({
    required this.total,
    required this.barData,
    required this.pieData,
  });
}
