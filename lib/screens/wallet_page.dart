import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: Color(0xFF121826),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final transactions = provider.transactions;

    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadTransactions,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),

              /// SUMMARY CARD
              const WalletSummaryCard(),

              const SizedBox(height: 20),

              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      "Chưa có giao dịch nào",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                ...transactions.map((tran) {
                  final sign =
                      tran.type == 'expense' ? '-' : '+';

                  final amount =
                      '$sign${_moneyFormat.format(tran.amount)} đ';

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
