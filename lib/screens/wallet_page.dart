import 'package:flutter/material.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/transaction_item.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = TransactionService();

    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),

            /// SUMMARY CARD
            const WalletSummaryCard(),

            const SizedBox(height: 20),

            /// TRANSACTION LIST
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

                return Column(
                  children: transactions.map((tran) {
                    final sign = tran.type == 'expense' ? '-' : '+';
                    final amount =
                        '$sign${_moneyFormat.format(tran.amount)} đ';

                    return TransactionItem(
                      title: tran.title,
                      category: tran.categoryName,
                      amount: amount,
                      icon: tran.categoryIcon,
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
}
