
class SavingsGoalModel {
  final int id;
  final String userId;
  final String name;
  final int targetAmount;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.dueDate,
    required this.isDone,
    required this.createdAt,
  });

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'])
          : null,
      isDone: map['is_done'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'is_done': isDone,
    };
  }
}
