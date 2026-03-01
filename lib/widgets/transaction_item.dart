import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final String? icon;

  const TransactionItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.icon,
  });

  bool get isExpense => amount.startsWith("-");

  Widget _buildIcon() {
    if (icon == null || icon!.isEmpty) {
      return const Icon(
        Icons.category,
        color: AppColors.textPrimary,
        size: 20,
      );
    }

    return Image.asset(
      icon!,
      width: 22,
      height: 22,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.category,
        color: AppColors.textPrimary,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountColor =
        isExpense ? AppColors.expense : AppColors.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: _buildIcon()),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// AMOUNT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                isExpense
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 14,
                color: amountColor.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}