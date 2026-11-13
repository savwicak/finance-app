import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/home/add-balance/add_balance_screen.dart';
import 'package:nvidiaapp/features/home/widgets/setting_sheet.dart';

import '../models/dashboard_models.dart';

String formatRupiah(int amount) {
  return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
}

class BalanceHeader extends StatelessWidget {
  const BalanceHeader({
    super.key,
    required this.balance,
    required this.todayExpense,
    required this.remainingBudget,
    required this.monthlyBudget,
  });

  final int balance;
  final int todayExpense;
  final int remainingBudget;
  final int monthlyBudget;

  @override
  Widget build(BuildContext context) {
    final safeRemaining = remainingBudget < 0 ? 0 : remainingBudget;
    final progress = monthlyBudget <= 0
        ? 0.0
        : ((monthlyBudget - safeRemaining) / monthlyBudget).clamp(0.0, 1.0);

    return Container(
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
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled:
                          true, // Agar tinggi sheet menyesuaikan kontennya
                      backgroundColor: Colors.transparent, // Penting agar radius container sheet terlihat
                      builder: (context) => const SettingSheet(),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () {
                Get.to(() => const AddBalanceScreen());
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        formatRupiah(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFB7E900),
                        size: 23,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text('Jatah harian:', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 5),
                Text(
                  formatRupiah(todayExpense),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: remainingBudget < 0
                        ? Colors.redAccent
                        : const Color(0xFFB7E900),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    remainingBudget < 0 ? 'Melebihi budget' : 'Aman',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});
  final String insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0EBC2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFB7E900),
            foregroundColor: Colors.black,
            child: Icon(Icons.auto_awesome),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Financial Insight',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  insight,
                  style: const TextStyle(height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklySpendingChart extends StatelessWidget {
  const WeeklySpendingChart({super.key, required this.transactions});
  final List<DashboardTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final values = List<int>.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      return transactions
          .where(
            (t) =>
                !t.isIncome &&
                t.createdAt.year == day.year &&
                t.createdAt.month == day.month &&
                t.createdAt.day == day.day,
          )
          .fold<int>(0, (sum, t) => sum + t.amount);
    });
    final maxValue = values.fold<int>(0, (a, b) => a > b ? a : b);
    final labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran 7 hari terakhir',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 105,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = maxValue == 0
                    ? 0.06
                    : (values[i] / maxValue).clamp(0.06, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: ratio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: i == 6
                                      ? const Color(0xFFB7E900)
                                      : const Color(0xFFE5E9EF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          labels[i],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onDeposit,
    this.onDelete, // Opsional: Tambahkan callback jika icon tong sampah ingin diaktifkan
    this.targetDate =
        '25 Okt 2026', // Opsional: Sesuaikan dengan field dari model jika ada
  });

  final DashboardSavingsGoal goal;
  final VoidCallback onDeposit;
  final VoidCallback? onDelete;
  final String targetDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        // Menyesuaikan shadow agar lebih subtle mirip gambar
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Nama Goal & Tombol Hapus
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete ?? () {},
                icon: const Icon(Icons.delete_outline, size: 22),
                color: const Color(0xFFD1D5DB),

                constraints: const BoxConstraints(),
                alignment: Alignment.topRight,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Amount Row: Saved & Target Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  formatRupiah(goal.savedAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                formatRupiah(goal.targetAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Color(0xFFB0B4BA),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 12,
              backgroundColor: const Color(
                0xFFF1F5F9,
              ), // Abu-abu background progress
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFFB7E900),
              ), // Lime green
            ),
          ),

          const SizedBox(height: 16),

          // Footer Row: Percentage & Quick Deposit (Tetap dipertahankan)
          Row(
            children: [
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}% tercapai',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onDeposit,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Quick Deposit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentTransactionTile extends StatelessWidget {
  const RecentTransactionTile({super.key, required this.transaction});
  final DashboardTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final income = transaction.isIncome;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB7E900),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              income ? Icons.south_west : Icons.restaurant,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description.isEmpty
                      ? transaction.categoryName
                      : transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '${income ? '+' : '-'}${formatRupiah(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: income ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
