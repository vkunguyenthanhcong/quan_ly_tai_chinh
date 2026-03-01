import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  /// ================= CHANGE MONTH =================
  Future<void> changeMonth(DateTime month) async {
    selectedMonth = DateTime(month.year, month.month, 1);
    await loadTransactions();
  }

  /// ================= LOAD =================
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await _service.getTransactionsByMonth(selectedMonth);

    _isLoading = false;
    notifyListeners();
  }

  /// ================= ADD =================
  Future<void> addTransaction({
    required String categoryId,
    required String title,
    required int amount,
    required String type,
    required String note,
    required DateTime date,
  }) async {
    await _service.addTransaction(
      categoryId: categoryId,
      title: title,
      amount: amount,
      type: type,
      date: date,
    );

    await loadTransactions();
  }

  /// ================= DELETE =================
  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
    await loadTransactions();
  }
}
