
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
  });

  String formatRupiah(dynamic value) {
    final amount = value is num
        ? value
        : num.tryParse(value.toString()) ?? 0;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  Color parseColor(dynamic value) {
    if (value == null) {
      return const Color(0xFFB4DE00);
    }

    String hex = value.toString().replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(
      int.tryParse(hex, radix: 16) ?? 0xFFB4DE00,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        category['name']?.toString() ?? 'Category';

    final int allocation =
        (category['allocation'] as num?)?.toInt() ?? 0;

    final int spent =
        (category['spent'] as num?)?.toInt() ?? 0;

    final int remaining = allocation - spent;

    final double percentage = allocation > 0
    ? (remaining / allocation * 100).clamp(0, 100).toDouble()
    : 0;

    final String? note = category['note']?.toString();

    final Color cardColor = parseColor(category['color']);

    return Container(
      width: double.infinity,
      height: 222,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                if (percentage > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${percentage.round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(text: ' out of total'),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (onDelete != null) ...[
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Delete category',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.black87,
                      size: 21,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      // TAMPILKAN SISA BUDGET
                      formatRupiah(remaining),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Material(
                  color: const Color(0xFF252525),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onTap,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 58,
                      height: 58,
                      child: Icon(
                        Icons.north_east,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (note != null && note.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
