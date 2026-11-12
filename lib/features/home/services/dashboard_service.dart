
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_models.dart';

class DashboardService {
  DashboardService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String transactionsTable = 'transactions';
  static const String goalsTable = 'savings_goals';
  static const String entriesTable = 'savings_entries';
  static const String budgetsTable = 'budgets';
  static const String periodsTable = 'periods';

  Future<DashboardSummary> fetchSummary() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login.');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrow = todayStart.add(const Duration(days: 1));

    // Cari periode aktif berdasarkan tanggal hari ini.
    final periodRows = await _client
        .from(periodsTable)
        .select('id')
        .eq('user_id', userId)
        .lte('start_date', todayStart.toIso8601String().split('T')[0])
        .gte('end_date', todayStart.toIso8601String().split('T')[0])
        .order('start_date', ascending: false)
        .limit(1);

    int budget = 0;

    final results = await Future.wait([
      _client
          .from(transactionsTable)
          .select()
          .eq('user_id', userId)
          .gte('created_at', monthStart.toIso8601String())
          .lt('created_at', nextMonth.toIso8601String())
          .order('created_at', ascending: false),

      _client
          .from(goalsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false),

      _client
          .from(entriesTable)
          .select('goal_id, amount')
          .eq('user_id', userId),
    ]);

    // Ambil total budget dari tabel budgets berdasarkan period_id.
    if (periodRows.isNotEmpty) {
      final periodId = periodRows.first['id'];

      final budgetRows = await _client
          .from(budgetsTable)
          .select('amount')
          .eq('user_id', userId)
          .eq('period_id', periodId);

      budget = budgetRows.fold<int>(
        0,
        (sum, row) => sum + ((row['amount'] as num?)?.round() ?? 0),
      );
    }

    final transactionMaps =
        List<Map<String, dynamic>>.from(results[0] as List);

    final goalMaps =
        List<Map<String, dynamic>>.from(results[1] as List);

    final entryMaps =
        List<Map<String, dynamic>>.from(results[2] as List);

    final transactions = transactionMaps
        .map(DashboardTransaction.fromMap)
        .toList();

    final monthExpense = transactions
        .where((t) => !t.isIncome)
        .fold<int>(0, (sum, t) => sum + t.amount);

    final monthIncome = transactions
        .where((t) => t.isIncome)
        .fold<int>(0, (sum, t) => sum + t.amount);

    final todayExpense = transactions
        .where((t) =>
            !t.isIncome &&
            !t.createdAt.isBefore(todayStart) &&
            t.createdAt.isBefore(tomorrow))
        .fold<int>(0, (sum, t) => sum + t.amount);

    final savedByGoal = <String, int>{};

    for (final entry in entryMaps) {
      final id = entry['goal_id']?.toString();
      if (id == null) continue;

      savedByGoal[id] = (savedByGoal[id] ?? 0) +
          ((entry['amount'] as num?)?.round() ?? 0);
    }

    final goals = goalMaps.map((map) {
      final id = map['id'].toString();

      return DashboardSavingsGoal.fromMap(
        map,
        savedAmount: savedByGoal[id] ?? 0,
      );
    }).toList();

    return DashboardSummary(
      balance: monthIncome - monthExpense,
      todayExpense: todayExpense,
      monthlyBudget: budget,
      monthlyExpense: monthExpense,
      transactions: transactions.take(5).toList(),
      goals: goals.take(3).toList(),
    );
  }
}
