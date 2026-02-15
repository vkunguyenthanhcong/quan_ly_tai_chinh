import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    final data = await _service.getTransactions();
    _transactions =
        data.map((e) => TransactionModel.fromMap(e)).toList();

    _isLoading = false;
    notifyListeners();
  }

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
      note: note,
      date: date,
    );

    await loadTransactions();
  }
}
