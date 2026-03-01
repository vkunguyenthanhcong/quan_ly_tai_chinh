class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final String type;
  final DateTime date;
  final String categoryName;
  final String? categoryIcon;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.categoryName,
    this.categoryIcon,
  });

  /// ================= FROM SUPABASE =================
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];
    final store =
        category != null ? category['category_store'] : null;

    return TransactionModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      amount: map['amount'] ?? 0,
      type: map['type'] ?? 'expense',
      date: DateTime.parse(map['date']),
      categoryName: store?['name'] ?? 'Khác',
      categoryIcon: store?['icon'],
    );
  }

  /// ================= TO MAP (INSERT/UPDATE) =================
  Map<String, dynamic> toMap({
    required String userId,
    required String categoryId,
  }) {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  /// ================= COPY WITH =================
  TransactionModel copyWith({
    String? id,
    String? title,
    int? amount,
    String? type,
    DateTime? date,
    String? categoryName,
    String? categoryIcon,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}