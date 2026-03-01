import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';

import '../widgets/wallet_summary_card.dart';
import '../widgets/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    if (provider.isLoading) {
  return const Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: CircularProgressIndicator(
        color: AppColors.accent,
      ),
    ),
  );
}

    final transactions = provider.transactions;
   Widget _monthDropdown(BuildContext context) {
  final provider = context.watch<TransactionProvider>();
  final now = DateTime.now();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<DateTime>(
        dropdownColor: AppColors.surface,
        value: provider.selectedMonth,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        items: List.generate(12, (index) {
          final month = DateTime(now.year, index + 1, 1);
          return DropdownMenuItem(
            value: month,
            child: Text("Tháng ${index + 1}/${now.year}"),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            provider.changeMonth(value);
          }
        },
      ),
    ),
  );
}

    return Scaffold(
     backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadTransactions,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),

              /// SUMMARY CARD
              _monthDropdown(context),

              const SizedBox(height: 16),

              WalletSummaryCard(month: provider.selectedMonth),

              const SizedBox(height: 20),

              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      "Chưa có giao dịch nào",
                      style: TextStyle(
  color: AppColors.textSecondary,
  fontSize: 14,
),
                    ),
                  ),
                )
              else
                ...transactions.map((tran) {
                  final sign = tran.type == 'expense' ? '-' : '+';

                  final amount = '$sign${_moneyFormat.format(tran.amount)} đ';

                  return TransactionItem(
                    title: tran.title,
                    category: tran.categoryName,
                    amount: amount,
                    icon: tran.categoryIcon,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
