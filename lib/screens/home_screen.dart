import 'package:flutter/material.dart';

import '../widgets/header_user.dart';
import '../widgets/overview_chart.dart';
import '../widgets/transaction_section.dart';

import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = TransactionService();
  
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HeaderUser(),
            const SizedBox(height: 16),
            const OverviewChart(),
            const SizedBox(height: 20),

            /// ================= TRANSACTIONS =================
            FutureBuilder<List<Map<String, dynamic>>>(
              future: transactionService.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "Chưa có giao dịch nào",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                /// Map DB → Model
                final transactions = data
                    .map((e) => TransactionModel.fromMap(e))
                    .toList();

                /// Group theo date
                final grouped = _groupByDate(transactions);

                return Column(
                  children: grouped.entries.map((entry) {
                    final date = entry.key;
                    final list = entry.value;

                    return TransactionSection(
                      date: _formatDate(date),
                      day: _weekday(date),
                      transactions: list,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER =================

  Map<DateTime, List<TransactionModel>> _groupByDate(
    List<TransactionModel> transactions,
  ) {
    final Map<DateTime, List<TransactionModel>> grouped = {};

    for (final t in transactions) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }

    return grouped;
  }

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  String _weekday(DateTime d) {
    const days = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật'
    ];
    return days[d.weekday - 1];
  }
}
