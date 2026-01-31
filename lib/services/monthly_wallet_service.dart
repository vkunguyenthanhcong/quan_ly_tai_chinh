import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyWalletService {
  final supabase = Supabase.instance.client;

  /// Set / update tiền gốc cho 1 tháng
  Future<void> setMonthlyBalance({
    required DateTime month,
    required int balance,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Chưa đăng nhập");
    }

    final monthDate = DateTime(month.year, month.month, 1)
        .toIso8601String()
        .substring(0, 10);

    await supabase.from('monthly_wallets').upsert(
      {
        'user_id': userId,
        'month': monthDate,
        'balance': balance,
      },
      onConflict: 'user_id,month',
    );
  }

  /// Lấy số dư tháng hiện tại
  Future<int> getMonthlyBalance(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final res = await supabase
        .from('monthly_wallets')
        .select('balance')
        .eq('user_id', userId!)
        .eq(
          'month',
          DateTime(month.year, month.month, 1)
              .toIso8601String()
              .substring(0, 10),
        )
        .maybeSingle();

    if (res == null) return 0;
    return res['balance'] as int;
  }
}
