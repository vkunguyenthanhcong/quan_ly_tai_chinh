import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/models/dept_model.dart';
import 'package:quan_ly_chi_tieu/services/dept_service.dart';

class DebtProvider extends ChangeNotifier {
  final DebtService _service = DebtService();

  List<DebtModel> _debts = [];
  List<DebtModel> get debts => _debts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDebts() async {
    _isLoading = true;
    notifyListeners();

    _debts = await _service.getDebts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDebt({
    required String personName,
    required int amount,
    required String type,
    String? note,
  }) async {
    final debt = DebtModel(
      id: '',
      personName: personName,
      amount: amount,
      type: type,
      note: note,
      createdAt: DateTime.now(),
      nextRemindAt:
          DateTime.now().add(const Duration(days: 7)),
      isPaid: false,
    );

    await _service.addDebt(debt);
    await loadDebts();
  }

Future<void> deleteDebt(String id) async {
  await _service.deleteDebt(id);
  await loadDebts();
}
  Future<void> markAsPaid(String id) async {
    await _service.markAsPaid(id);
    await loadDebts();
  }

  /// kiểm tra nhắc nhở mỗi 7 ngày
  Future<void> checkReminders() async {
    for (final debt in _debts) {
      if (!debt.isPaid &&
          debt.nextRemindAt != null &&
          DateTime.now().isAfter(debt.nextRemindAt!)) {
        await _service.updateNextReminder(debt.id);

        // TODO: gọi local notification ở đây
      }
    }
  }
}
