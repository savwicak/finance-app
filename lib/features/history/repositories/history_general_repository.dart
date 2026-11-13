
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

    // Batas bulan berdasarkan waktu lokal
    final startDate = DateTime(
      month.year,
      month.month,
      1,
    );

    final endDate = DateTime(
      month.year,
      month.month + 1,
      1,
    );

    final response = await supabase
        .from('transactions')
        .select('''
          *,
          categories (
            name,
            icon,
            color
          )
        ''')
        .eq('user_id', user.id)
        .gte(
          'occurred_at',
          startDate.toUtc().toIso8601String(),
        )
        .lt(
          'occurred_at',
          endDate.toUtc().toIso8601String(),
        )
        .order('occurred_at', ascending: false);

    print('===== HISTORY TRANSACTIONS =====');
    print('USER: ${user.id}');
    print('START: ${startDate.toUtc()}');
    print('END: ${endDate.toUtc()}');
    print('TOTAL: ${(response as List).length}');
    print('DATA: $response');

    return (response as List)
        .map(
          (item) => TransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
