class DebtModel {
  final String id;
  final String personName;
  final int amount;
  final String type; // borrowed_to_me | i_owe
  final String? note;
  final DateTime createdAt;
  final DateTime? nextRemindAt;
  final bool isPaid;

  const DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.note,
    required this.createdAt,
    this.nextRemindAt,
    required this.isPaid,
  });

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      personName: map['person_name'],
      amount: map['amount'],
      type: map['type'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
      nextRemindAt: map['next_remind_at'] != null
          ? DateTime.parse(map['next_remind_at'])
          : null,
      isPaid: map['is_paid'] ?? false,
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'user_id': userId,
      'person_name': personName,
      'amount': amount,
      'type': type,
      'note': note,
      'next_remind_at':
          DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    };
  }
}
