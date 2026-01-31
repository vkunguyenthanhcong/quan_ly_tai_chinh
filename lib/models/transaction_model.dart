class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final String type;
  final DateTime date;

  final String categoryName;
  final String categoryIcon;
  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.categoryName,
    required this.categoryIcon,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
  final category = map['categories'];
  final store = category != null ? category['category_store'] : null;

  return TransactionModel(
    id: map['id'],
    title: map['title'],
    amount: map['amount'],
    type: map['type'],
    date: DateTime.parse(map['date']),
    categoryName: store?['name'] ?? 'Khác',
    categoryIcon: store?['icon'], // có thể null
  );
}

}
