import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/models/dept_model.dart';
import 'package:quan_ly_chi_tieu/providers/dept_provider.dart';
import 'package:quan_ly_chi_tieu/screens/add_dept_screen.dart';

final _moneyFormat = NumberFormat('#,###', 'vi_VN');

class DebtPage extends StatelessWidget {
  const DebtPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebtProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Quản lý khoản nợ",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDebtScreen()),
          );
        },
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadDebts,
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(provider.debts, context),
        ),
      ),
    );
  }

  Widget _buildContent(List<DebtModel> debts, BuildContext context) {
    if (debts.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 100),
          Center(
            child: Text(
              "Chưa có khoản nợ nào",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      );
    }

    final borrowed = debts.where((d) => d.type == 'borrowed_to_me').toList();

    final owe = debts.where((d) => d.type == 'i_owe').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (borrowed.isNotEmpty) ...[
          _sectionTitle("Người khác nợ tôi", Colors.green),
          const SizedBox(height: 8),
          ...borrowed.map((d) => _debtCard(d, context)),
          const SizedBox(height: 24),
        ],
        if (owe.isNotEmpty) ...[
          _sectionTitle("Tôi đang nợ", Colors.red),
          const SizedBox(height: 8),
          ...owe.map((d) => _debtCard(d, context)),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _debtCard(DebtModel debt, BuildContext context) {
    final color = debt.type == 'borrowed_to_me' ? Colors.green : Colors.red;

    final amount = "${_moneyFormat.format(debt.amount)} đ";

    return Slidable(
      key: ValueKey(debt.id),

      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          /// ===== ĐÃ TRẢ =====
          SlidableAction(
            onPressed: (context) {
              context.read<DebtProvider>().markAsPaid(debt.id);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: "Đã trả",
          ),

          /// ===== XÓA =====
          SlidableAction(
            onPressed: (context) {
              context.read<DebtProvider>().deleteDebt(debt.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: "Xóa",
          ),
        ],
      ),

      child: Card(
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            debt.personName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (debt.note != null && debt.note!.isNotEmpty)
                Text(debt.note!, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 4),
              Text(
                "Tạo ngày: ${_formatDate(debt.createdAt)}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                amount,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  context.read<DebtProvider>().markAsPaid(debt.id);
                },
                child: debt.isPaid == true
                    ? const Text(
                        "Đã trả",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                        ),
                      )
                    : const Text(
                        "Chưa trả",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }
}
