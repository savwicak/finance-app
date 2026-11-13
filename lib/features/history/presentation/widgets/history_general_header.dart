import 'package:flutter/material.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';

String formatRupiah(int amount) {
  return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
}

class HistoryGeneralHeader extends StatefulWidget {
  const new({super.key,
   required this.balance,
    required this.todayExpense,
    required this.remainingBudget,
    required this.monthlyBudget,});

  final int balance;
  final int todayExpense;
  final int remainingBudget;
  final int monthlyBudget;

  @override
  State<HistoryGeneralHeader> createState() => _HistoryGeneralHeaderState();
}

class _HistoryGeneralHeaderState extends State<HistoryGeneralHeader> {
  @override
  Widget build(BuildContext context) {
     final safeRemaining = widget.remainingBudget < 0 ? 0 : widget.remainingBudget;
    final progress = widget.monthlyBudget <= 0
        ? 0.0
        : ((widget.monthlyBudget - safeRemaining) / widget.monthlyBudget).clamp(0.0, 1.0);
    return  Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF252525),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Howdy, Eula!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.secondary,
                  ),  
                ),
              ],
            ),
            SizedBox(height: 15),
            Text('Your balance', style: TextStyle(
              fontSize: 14,
              color: Colors.white
            )),
            const SizedBox(height: 5),
            Text(
              formatRupiah(widget.balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pengeluaran hari ini',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Text(
                  formatRupiah(widget.todayExpense),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sisa budget bulan ini',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: widget.remainingBudget < 0
                        ? Colors.redAccent
                        : const Color(0xFFB7E900),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.remainingBudget < 0 ? 'Melebihi budget' : 'Aman',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              formatRupiah(widget.remainingBudget < 0 ? 0 : widget.remainingBudget),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFB7E900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}