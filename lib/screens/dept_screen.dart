import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
import 'package:quan_ly_chi_tieu/models/dept_model.dart';
import 'package:quan_ly_chi_tieu/providers/category_provider.dart';
import 'package:quan_ly_chi_tieu/providers/dept_provider.dart';
import 'package:quan_ly_chi_tieu/providers/transaction_provider.dart';
import 'package:quan_ly_chi_tieu/screens/add_dept_screen.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');

class DebtPage extends StatelessWidget {
  const DebtPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebtProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Quản lý khoản nợ",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDebtScreen()),
          );
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: provider.loadDebts,
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                )
              : _buildContent(provider.debts, context),
        ),
      ),
    );
  }

  Widget _buildContent(List<DebtModel> debts, BuildContext context) {
    if (debts.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              "Chưa có khoản nợ nào",
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    final borrowed =
        debts.where((d) => d.type == 'borrowed_to_me').toList();
    final owe = debts.where((d) => d.type == 'i_owe').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (borrowed.isNotEmpty) ...[
          _sectionTitle("Người khác nợ tôi", AppColors.income),
          const SizedBox(height: 10),
          ...borrowed.map((d) => _debtCard(d, context)),
          const SizedBox(height: 28),
        ],
        if (owe.isNotEmpty) ...[
          _sectionTitle("Tôi đang nợ", AppColors.expense),
          const SizedBox(height: 10),
          ...owe.map((d) => _debtCard(d, context)),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _debtCard(DebtModel debt, BuildContext context) {
    final isIncome = debt.type == 'borrowed_to_me';
    final color = isIncome ? AppColors.income : AppColors.expense;

    final amount = "${_moneyFormat.format(debt.amount)} đ";

    return Slidable(
      key: ValueKey(debt.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final categoryProvider = context.read<CategoryProvider>();
              final transactionProvider =
                  context.read<TransactionProvider>();
              final debtProvider = context.read<DebtProvider>();

              final type = isIncome ? "income" : "expense";

              final categoryId =
                  await categoryProvider.getOrCreateDebtCategory(type);

              await transactionProvider.addTransaction(
                categoryId: categoryId,
                title: isIncome
                    ? "${debt.personName} trả nợ"
                    : "Trả nợ ${debt.personName}",
                amount: debt.amount,
                type: type,
                note: isIncome
                    ? "${debt.personName} trả nợ"
                    : "Trả nợ cho ${debt.personName}",
                date: DateTime.now(),
              );

              await debtProvider.markAsPaid(debt.id);
            },
            backgroundColor: AppColors.income,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: "Đã trả",
          ),
          SlidableAction(
            onPressed: (_) {
              context.read<DebtProvider>().deleteDebt(debt.id);
            },
            backgroundColor: AppColors.expense,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: "Xóa",
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.personName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (debt.note != null && debt.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        debt.note!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    "Tạo ngày: ${_formatDate(debt.createdAt)}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  debt.isPaid == true ? "Đã trả" : "Chưa trả",
                  style: TextStyle(
                    fontSize: 12,
                    color: debt.isPaid == true
                        ? AppColors.accent
                        : AppColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }
}