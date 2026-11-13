
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';

class HistoryTransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const HistoryTransactionCard({
    super.key,
    required this.transaction,
  });

  Color _categoryColor() {
    final value = transaction.categoryColor;

    if (value == null || value.isEmpty) {
      return const Color(0xFFC4E600);
    }

    try {
      final hex = value.replaceAll('#', '').replaceAll('0x', '');
      final parsed = int.parse(hex, radix: 16);

      return Color(
        hex.length == 6 ? 0xFF000000 | parsed : parsed,
      );
    } catch (_) {
      return const Color(0xFFC4E600);
    }
  }

  IconData _categoryIcon() {
    final icon = transaction.categoryIcon?.toLowerCase() ?? '';

    const icons = {
      'food': Icons.restaurant,
      'restaurant': Icons.restaurant,
      'shopping': Icons.shopping_bag_outlined,
      'transport': Icons.directions_car,
      'health': Icons.medical_services_outlined,
      'education': Icons.school_outlined,
      'home': Icons.home_outlined,
      'entertainment': Icons.movie_outlined,
      'salary': Icons.payments_outlined,
      'other': Icons.category_outlined,
    };

    return icons[icon] ?? Icons.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E5EE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _categoryColor(),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _categoryIcon(),
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  transaction.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isIncome ? Colors.green.shade700 : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE5E5EE),
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 17,
                  color: Color(0xFFB9B9C2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  transaction.displayDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                DateFormat('HH:mm').format(transaction.occurredAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
