
class TransactionModel {
  final int? id;
  final int amount;
  final int? categoryId;
  final int? periodId;
  final String method;
  final String type;
  final String? note;
  final DateTime occurredAt;
  final int? receiptId;

  // data kategori dari relasi supabase, untuk ditampilkan di ui
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;

  const TransactionModel({
    this.id,
    required this.amount,
    this.categoryId,
    this.periodId,
    this.method = 'tunai',
    this.type = 'expense',
    this.note,
    required this.occurredAt,
    this.receiptId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'];

    return TransactionModel(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toInt(),
      categoryId: json['category_id'] as int?,
      periodId: json['period_id'] as int?,
      method: json['method'] as String? ?? 'tunai',
      type: json['type'] as String? ?? 'expense',
      note: json['note'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'].toString()),
      receiptId: json['receipt_id'] as int?,
      categoryName: category is Map
          ? category['name'] as String?
          : null,
      categoryColor: category is Map
          ? category['color']?.toString()
          : null,
      categoryIcon: category is Map
          ? category['icon']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category_id': categoryId,
      'period_id': periodId,
      'method': method,
      'type': type,
      'note': note,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'receipt_id': receiptId,
    };
  }
}
