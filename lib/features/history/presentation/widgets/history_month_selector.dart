
import 'package:flutter/material.dart';

class HistoryMonthSelector extends StatelessWidget {
  final String monthTitle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const HistoryMonthSelector({
    super.key,
    required this.monthTitle,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFC4E600),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _arrowButton(Icons.chevron_left, onPrevious),
          Expanded(
            child: Center(
              child: Text(
                monthTitle,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          _arrowButton(Icons.chevron_right, onNext),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Material(
        color: const Color(0xFF252222),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 54,
            height: 54,
            child: Icon(
              icon,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }
}
