import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header_user.dart';
import '../widgets/overview_chart.dart';
import '../widgets/transaction_section.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121826),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF121826),
        body: Center(
          child: Text(
            "Chưa có giao dịch nào",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final grouped = _groupByDate(transactions);

    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadTransactions,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const HeaderUser(),
              const SizedBox(height: 16),
              const OverviewChart(),
              const SizedBox(height: 20),

              ...grouped.entries.map((entry) {
                return TransactionSection(
                  date: _formatDate(entry.key),
                  day: _weekday(entry.key),
                  transactions: entry.value,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

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
