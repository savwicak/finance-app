class TransactionModel {
  final int? id;
  final String? userId;
  final int? periodId;
  final int? categoryId;
  final String type;
  final int amount;
  final String method;
  final String? note;
  final DateTime occurredAt;
  final String source;
  final int? receiptId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Data kategori untuk ditampilkan di UI.
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;

  const TransactionModel({
    this.id,
    this.userId,
    this.periodId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.method = 'tunai',
    this.note,
    required this.occurredAt,
    this.source = 'manual',
    this.receiptId,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'];

    return TransactionModel(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      periodId: (json['period_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      method: json['method'] as String? ?? 'tunai',
      note: json['note'] as String?,
      occurredAt: DateTime.parse(
        json['occurred_at'].toString(),
      ),
      source: json['source'] as String? ?? 'manual',
      receiptId: (json['receipt_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'].toString()),
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
      'period_id': periodId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'method': method,
      'note': note,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'source': source,
      'receipt_id': receiptId,
    };
  }
}