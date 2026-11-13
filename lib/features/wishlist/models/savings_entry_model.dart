
class SavingsEntryModel {
  final int id;
  final String userId;
  final int goalId;
  final int? periodId;
  final int amount;
  final String? note;
  final DateTime createdAt;

  SavingsEntryModel({
    required this.id,
    required this.userId,
    required this.goalId,
    this.periodId,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory SavingsEntryModel.fromMap(Map<String, dynamic> map) {
    return SavingsEntryModel(
      id: map['id'],
      userId: map['user_id'],
      goalId: map['goal_id'],
      periodId: map['period_id'],
      amount: map['amount'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
