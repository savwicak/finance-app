class DashboardTransaction {
  final String id;
  final String title;
  final String description;
  final int amount;
  final String type;
  final DateTime createdAt;
  final String categoryName;

  const DashboardTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.categoryName,
  });

  factory DashboardTransaction.fromMap(Map<String, dynamic> map) {
    final rawDate = map['occurred_at'] ?? map['created_at'];
    return DashboardTransaction(
      id: map['id']?.toString() ?? '',
      title: (map['merchant'] ?? map['title'] ?? map['name'] ?? 'Transaksi').toString(),
      description: (map['description'] ?? map['note'] ?? '').toString(),
      amount: (map['amount'] as num?)?.round() ?? 0,
      type: (map['type'] ?? 'expense').toString().toLowerCase(),
      createdAt: rawDate == null ? DateTime.now() : DateTime.tryParse(rawDate.toString()) ?? DateTime.now(),
      categoryName: (map['category_name'] ?? map['category'] ?? 'Lainnya').toString(),
    );
  }

  bool get isIncome => type == 'income' || type == 'deposit' || type == 'topup';
}


class DashboardSavingsGoal {
  final String id;
  final String name;
  final int targetAmount;
  final int savedAmount;
  final DateTime? dueDate;
  final bool isDone;

  const DashboardSavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.dueDate,
    this.isDone = false,
  });

  double get progress => targetAmount <= 0
      ? 0
      : (savedAmount / targetAmount).clamp(0.0, 1.0);

  factory DashboardSavingsGoal.fromMap(
    Map<String, dynamic> map, {
    int savedAmount = 0,
  }) {
    return DashboardSavingsGoal(
      id: map['id'].toString(),
      name: (map['name'] ?? 'Savings').toString(),
      targetAmount: (map['target_amount'] as num?)?.round() ?? 0,
      savedAmount: savedAmount,
      dueDate: map['due_date'] == null
          ? null
          : DateTime.tryParse(map['due_date'].toString()),
      isDone: map['is_done'] as bool? ?? false,
    );
  }
}

class DashboardSummary {
  final int balance;
  final int todayExpense;
  final int monthlyBudget;
  final int monthlyExpense;
  final List<DashboardTransaction> transactions;
  final List<DashboardSavingsGoal> goals;

  const DashboardSummary({
    required this.balance,
    required this.todayExpense,
    required this.monthlyBudget,
    required this.monthlyExpense,
    required this.transactions,
    required this.goals,
  });

  int get remainingBudget => monthlyBudget - monthlyExpense;
  double get budgetProgress => monthlyBudget <= 0
      ? 0
      : (monthlyExpense / monthlyBudget).clamp(0.0, 1.0);
}
