
class TransactionModel {
  final int id;
  final int amount;
  final String type;
  final String method;
  final String source;
  final String? note;
  final DateTime occurredAt;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? merchant;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.method,
    required this.source,
    required this.occurredAt,
    this.note,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.merchant,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'] is Map
        ? Map<String, dynamic>.from(json['categories'])
        : <String, dynamic>{};

    final receipt = json['receipts'] is Map
        ? Map<String, dynamic>.from(json['receipts'])
        : <String, dynamic>{};

    return TransactionModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toInt(),
      type: json['type']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      note: json['note']?.toString(),
      occurredAt: DateTime.parse(json['occurred_at'].toString()).toLocal(),
      categoryName: category['name']?.toString(),
      categoryIcon: category['icon']?.toString(),
      categoryColor: category['color']?.toString(),
      merchant: receipt['merchant']?.toString(),
    );
  }

  bool get isIncome => type.toLowerCase() == 'income';

  String get displayTitle {
    if (merchant != null && merchant!.isNotEmpty) {
      return merchant!;
    }

    if (categoryName != null && categoryName!.isNotEmpty) {
      return categoryName!;
    }

    return 'Other Transaction';
  }

  String get displayDescription {
    if (note != null && note!.isNotEmpty) {
      return note!;
    }

    if (source.toLowerCase().contains('paypal')) {
      return 'PayPal Transaction';
    }

    if (source.toLowerCase().contains('receipt') ||
        source.toLowerCase().contains('ocr')) {
      return 'AI Receipt Scan';
    }

    return categoryName ?? 'No description';
  }
}
