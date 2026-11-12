
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class HistoryGeneralRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TransactionModel>> getTransactions({
    required DateTime month,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final startDate = DateTime(month.year, month.month, 1).toUtc();
    final endDate = DateTime(month.year, month.month + 1, 1).toUtc();

    final response = await supabase
        .from('transactions')
        .select('''
          *,
          categories (
            name,
            icon,
            color
          ),
          receipts (
            merchant
          )
        ''')
        .eq('user_id', user.id)
        .gte('occurred_at', startDate.toIso8601String())
        .lt('occurred_at', endDate.toIso8601String())
        .order('occurred_at', ascending: false);

    return (response as List)
        .map((item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }
}
