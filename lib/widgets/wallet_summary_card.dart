import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TransactionService();

    return FutureBuilder<Map<String, int>>(
      future: service.getSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        if (snapshot.hasError) {
          return _error(snapshot.error.toString());
        }

        final data = snapshot.data!;
        final income = data['income']!;
        final expense = data['expense']!;
        final balance = data['balance']!;

        final total = income + expense;
        final incomeRatio = total == 0 ? 0.0 : income / total;
        final expenseRatio = total == 0 ? 0.0 : expense / total;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2F3E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== BALANCE =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tài khoản của tôi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_moneyFormat.format(balance)} đ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ===== INCOME =====
              const Text("Thu nhập",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: incomeRatio,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation(Colors.greenAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 6),
              Text(
                "+${_moneyFormat.format(income)} đ",
                style: const TextStyle(color: Colors.greenAccent),
              ),

              const SizedBox(height: 16),

              /// ===== EXPENSE =====
              const Text("Chi tiêu",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: expenseRatio,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation(Colors.redAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 6),
              Text(
                "-${_moneyFormat.format(expense)} đ",
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= STATES =================

  Widget _loading() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F3E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _error(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F3E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
