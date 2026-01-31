import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/widgets/confirm_dialog.dart';
import '../models/transaction_model.dart';
import 'transaction_item.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../widgets/app_toast.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');

class TransactionSection extends StatelessWidget {
  final String date;
  final String day;
  final List<TransactionModel> transactions;

  const TransactionSection({
    super.key,
    required this.date,
    required this.day,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final transactionService = TransactionService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ===== HEADER DATE =====
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                day,
                style: const TextStyle(color: Colors.white38),
              ),
            ],
          ),
        ),

        /// ===== LIST TRANSACTIONS (SWIPE TO DELETE) =====
        Column(
          children: transactions.map((tran) {
            return Dismissible(
              key: ValueKey(tran.id), // ⚠️ bắt buộc unique
              direction: DismissDirection.endToStart,
              background: _deleteBackground(),
              confirmDismiss: (_) async {
                  return await BeautifulConfirmDialog.show(
                    context,
                    title: "Xoá giao dịch?",
                    message: "Bạn có chắc muốn xoá giao dịch này không?",
                  );
                },

              onDismissed: (_) async {
                await transactionService.deleteTransaction(tran.id);

                AppToast.show(
                  context,
                  message: "🗑️ Đã xoá giao dịch",
                  type: ToastType.success,
                );
              },
              child: TransactionItem(
                title: tran.title,
                category: tran.categoryName,
                amount:
                    "${tran.type == 'expense' ? '-' : '+'}"
                    "${_moneyFormat.format(tran.amount)} đ",
                icon: tran.categoryIcon,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= DELETE UI =================

  Widget _deleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  
}
