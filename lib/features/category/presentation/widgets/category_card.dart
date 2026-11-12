import 'package:flutter/material.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  Color parseColor(String? value) {
    try {
      final hex = (value ?? '#B8E600').replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  IconData parseIcon(String? value) {
    const icons = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'movie': Icons.movie,
      'payments': Icons.payments,
      'pets': Icons.pets,
      'sports': Icons.sports,
      'category': Icons.category,
    };

    return icons[value] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final color = parseColor(category['color']);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 135,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5ED)),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  parseIcon(category['icon']),
                  color: color,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category['name'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF292525),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  '0% out of total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppTheme.primary,
                child: Icon(
                  Icons.north_east,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
