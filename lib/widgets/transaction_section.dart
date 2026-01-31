  import 'package:flutter/material.dart';
  import '../models/transaction_model.dart';
  import 'transaction_item.dart';
  import 'package:intl/intl.dart';


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

          /// ===== LIST TRANSACTIONS =====
          Column(
            children: transactions.map((tran) {
              return TransactionItem(
                title: tran.title,
                category: tran.categoryName,
                amount:
                  "${tran.type == 'expense' ? '-' : '+'}"
                  "${_moneyFormat.format(tran.amount)} đ",
                icon: tran.categoryIcon,
              
              );
            }).toList(),
          ),
        ],
      );
    }
  }
