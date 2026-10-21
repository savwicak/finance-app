
import '../../core/supabase_client.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final _db = SupabaseClientManager.db;

  static const _pageSize = 30;
  static const _cols = '*, categories(name, color, icon)';

  // Tambah transaksi
  Future<TransactionModel> add(TransactionModel transaction) async {
    final response = await _db
        .from('transactions')
        .insert(transaction.toJson())
        .select(_cols)
        .single();

    return TransactionModel.fromJson(response);
  }

  // Riwayat dengan filter dan pagination
  Future<List<TransactionModel>> history({
    int page = 0,
    int? categoryId,
    int? periodId,
    String? method,
    String? type,
    String? search,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _db.from('transactions').select(_cols);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (periodId != null) {
      query = query.eq('period_id', periodId);
    }

    if (method != null) {
      query = query.eq('method', method);
    }

    if (type != null) {
      query = query.eq('type', type);
    }

    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('note', '%${search.trim()}%');
    }

    if (from != null) {
      query = query.gte(
        'occurred_at',
        from.toUtc().toIso8601String(),
      );
    }

    if (to != null) {
      query = query.lt(
        'occurred_at',
        to.toUtc().toIso8601String(),
      );
    }

    final response = await query
        .order('occurred_at', ascending: false)
        .range(page * _pageSize, (page + 1) * _pageSize - 1);

    return response
        .map<TransactionModel>(
          (item) => TransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // Edit transaksi
  Future<TransactionModel> update(
    TransactionModel transaction,
  ) async {
    final id = transaction.id;

    if (id == null) {
      throw ArgumentError('ID transaksi wajib diisi untuk edit.');
    }

    final response = await _db
        .from('transactions')
        .update(transaction.toJson())
        .eq('id', id)
        .select(_cols)
        .single();

    return TransactionModel.fromJson(response);
  }

  // Hapus transaksi
  Future<void> delete(int id) async {
    await _db.from('transactions').delete().eq('id', id);
  }
}
