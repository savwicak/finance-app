import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

String formatRupiah(int amount) {
  return 'Rp ${amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  )}';
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
                const Expanded(
                  child: Text('Your balance', style: TextStyle(color: Colors.white70)),
                ),
                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              formatRupiah(balance),
              style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: Text('Pengeluaran hari ini', style: TextStyle(color: Colors.white70))),
                Text(formatRupiah(todayExpense), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(child: Text('Sisa budget bulan ini', style: TextStyle(color: Colors.white70))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: remainingBudget < 0 ? Colors.redAccent : const Color(0xFFB7E900),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    remainingBudget < 0 ? 'Melebihi budget' : 'Aman',
                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              formatRupiah(safeRemaining),
              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
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
                const Text('AI Financial Insight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(insight, style: const TextStyle(height: 1.4, fontSize: 13)),
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
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
      return transactions.where((t) =>
        !t.isIncome &&
        t.createdAt.year == day.year &&
        t.createdAt.month == day.month &&
        t.createdAt.day == day.day
      ).fold<int>(0, (sum, t) => sum + t.amount);
    });
    final maxValue = values.fold<int>(0, (a, b) => a > b ? a : b);
    final labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7EAF0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengeluaran 7 hari terakhir', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          SizedBox(
            height: 105,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = maxValue == 0 ? 0.06 : (values[i] / maxValue).clamp(0.06, 1.0);
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
                                  color: i == 6 ? const Color(0xFFB7E900) : const Color(0xFFE5E9EF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(labels[i], style: const TextStyle(fontSize: 11, color: Colors.black54)),
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
  });

  final DashboardSavingsGoal goal;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(formatRupiah(goal.savedAmount), style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(formatRupiah(goal.targetAmount), style: const TextStyle(color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8EDF3),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFB7E900)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('${(goal.progress * 100).toStringAsFixed(0)}% tercapai', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              const Spacer(),
              TextButton.icon(
                onPressed: onDeposit,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Quick Deposit'),
                style: TextButton.styleFrom(foregroundColor: Colors.black, padding: EdgeInsets.zero),
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
            decoration: BoxDecoration(color: const Color(0xFFB7E900), borderRadius: BorderRadius.circular(12)),
            child: Icon(income ? Icons.south_west : Icons.restaurant, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(transaction.description.isEmpty ? transaction.categoryName : transaction.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          Text(
            '${income ? '+' : '-'}${formatRupiah(transaction.amount)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: income ? Colors.green : Colors.black),
          ),
        ],
      ),
    );
  }
}
