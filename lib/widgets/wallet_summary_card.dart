import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');
class WalletSummaryCard extends StatelessWidget {
  final DateTime month;

  const WalletSummaryCard({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    final service = TransactionService();

    return FutureBuilder<Map<String, int>>(
      future: service.getSummaryByMonth(month),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _loading();
        }

        final data = snapshot.data!;
        final income = data['income']!;
        final expense = data['expense']!;
        final balance = data['balance']!;

        final total = income + expense;
        final incomeRatio = total == 0 ? 0.0 : income / total;
        final expenseRatio = total == 0 ? 0.0 : expense / total;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tổng số dư",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    DateFormat('MM/yyyy').format(month),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// BALANCE
              Text(
                "${_moneyFormat.format(balance)} đ",
                style: const TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              /// INCOME
              _progress(
                label: "Thu nhập",
                value: incomeRatio,
                amount: income,
                color: const Color(0xFF22C55E),
              ),

              const SizedBox(height: 16),

              /// EXPENSE
              _progress(
                label: "Chi tiêu",
                value: expenseRatio,
                amount: expense,
                color: const Color(0xFFEF4444),
                isExpense: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _progress({
    required String label,
    required double value,
    required int amount,
    required Color color,
    bool isExpense = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            )),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${isExpense ? "-" : "+"}${_moneyFormat.format(amount)} đ",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _loading() => Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
}