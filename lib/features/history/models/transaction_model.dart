
class TransactionModel {
  final int id;
  final int amount;
  final String type;
  final String method;
  final String source;
  final String? note;
  final DateTime occurredAt;
  final DateTime createdAt;
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
    required this.createdAt,
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
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      type: json['type']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      note: json['note']?.toString(),
      occurredAt: DateTime.parse(
        json['occurred_at'].toString(),
      ).toLocal(),
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ).toLocal(),
      categoryName: category['name']?.toString(),
      categoryIcon: category['icon']?.toString(),
      categoryColor: category['color']?.toString(),
      merchant: receipt['merchant']?.toString(),
    );
  }

  bool get isIncome => type.toLowerCase() == 'income';

  String get displayTitle {
    if (merchant != null && merchant!.trim().isNotEmpty) {
      return merchant!;
    }

    if (categoryName != null && categoryName!.trim().isNotEmpty) {
      return categoryName!;
    }

    if (note != null && note!.trim().isNotEmpty) {
      return note!;
    }

    return isIncome ? 'Pemasukan' : 'Pengeluaran';
  }

  String get displayDescription {
    if (note != null && note!.trim().isNotEmpty) {
      if (note!.trim() != displayTitle) {
        return note!;
      }
    }

    if (source.toLowerCase().contains('paypal')) {
      return 'PayPal Transaction';
    }

    if (source.toLowerCase().contains('receipt') ||
        source.toLowerCase().contains('ocr')) {
      return 'AI Receipt Scan';
    }

    return isIncome ? 'Pemasukan uang' : 'Pengeluaran uang';
  }
}
