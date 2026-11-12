
import 'package:flutter/material.dart';

class HistoryFilter extends StatelessWidget {
  final List<String> methods;
  final List<String> dates;
  final String selectedMethod;
  final String selectedDate;
  final ValueChanged<String?> onMethodChanged;
  final ValueChanged<String?> onDateChanged;

  const HistoryFilter({
    super.key,
    required this.methods,
    required this.dates,
    required this.selectedMethod,
    required this.selectedDate,
    required this.onMethodChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDropdown(
          value: selectedMethod,
          items: methods,
          onChanged: onMethodChanged,
          icon: Icons.tune,
        ),
        const SizedBox(width: 12),
        _buildDropdown(
          value: selectedDate,
          items: dates,
          onChanged: onDateChanged,
          icon: Icons.calendar_month_outlined,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF514D4D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: const Color(0xFF514D4D),
          iconEnabledColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
