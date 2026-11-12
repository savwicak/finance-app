
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
  static const String categoriesTable = 'categories';

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User belum login.');
    }

    final response = await _client
        .from('categories')
        .select(
          'id, name, icon, color, is_impulsive, is_default, '
          'is_archived, is_archive, user_id',
        )
        .or('user_id.eq.$userId,is_default.eq.true')
        .order('sort_order', ascending: true);

    return List<Map<String, dynamic>>.from(response)
        .where((category) =>
            category['is_archived'] != true &&
            category['is_archive'] != true)
        .toList();
  }

  Future<int> addTransaction({
    required int categoryId,
    required int amount,
    required String type,
    required String note,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login.');

    final today = DateTime.now().toIso8601String().split('T')[0];

    final periodRows = await _client
        .from('periods')
        .select('id')
        .eq('user_id', userId)
        .lte('start_date', today)
        .gte('end_date', today)
        .order('start_date', ascending: false)
        .limit(1);

    if (periodRows.isEmpty) {
      throw Exception('Periode keuangan aktif tidak ditemukan.');
    }

    final periodId = periodRows.first['id'];

    await _client.from(transactionsTable).insert({
      'user_id': userId,
      'period_id': periodId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'note': note.trim(),
      'occurred_at': today,
    });

    return amount;
  }

  Future<DashboardSummary> fetchSummary() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login.');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrow = todayStart.add(const Duration(days: 1));

    final date = todayStart.toIso8601String().split('T')[0];

    final results = await Future.wait([
      _client
          .from(periodsTable)
          .select('id')
          .eq('user_id', userId)
          .lte('start_date', date)
          .gte('end_date', date)
          .order('start_date', ascending: false)
          .limit(1),

      _client
          .from(transactionsTable)
          .select()
          .eq('user_id', userId)
          .gte('occurred_at', monthStart.toIso8601String())
          .lt('occurred_at', nextMonth.toIso8601String())
          .order('occurred_at', ascending: false),

      _client
          .from(goalsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false),

      _client
          .from(entriesTable)
          .select('goal_id, amount')
          .eq('user_id', userId),

      _client
          .from(categoriesTable)
          .select('id, name')
          .eq('user_id', userId),
    ]);

    final periodRows =
        List<Map<String, dynamic>>.from(results[0] as List);

    final transactionMaps =
        List<Map<String, dynamic>>.from(results[1] as List);

    final goalMaps =
        List<Map<String, dynamic>>.from(results[2] as List);

    final entryMaps =
        List<Map<String, dynamic>>.from(results[3] as List);

    final categoryMaps =
        List<Map<String, dynamic>>.from(results[4] as List);

    final categoryNames = <String, String>{};

    for (final category in categoryMaps) {
      categoryNames[category['id'].toString()] =
          category['name']?.toString() ?? 'Lainnya';
    }

    for (final transaction in transactionMaps) {
      final categoryId = transaction['category_id']?.toString();

      transaction['category_name'] =
          categoryNames[categoryId] ?? 'Lainnya';
    }

    int budget = 0;

    if (periodRows.isNotEmpty) {
      final periodId = periodRows.first['id'];

      final budgetRows = await _client
          .from(budgetsTable)
          .select('amount')
          .eq('user_id', userId)
          .eq('period_id', periodId);

      budget = budgetRows.fold<int>(
        0,
        (sum, row) =>
            sum + ((row['amount'] as num?)?.round() ?? 0),
      );
    }

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
