import '../../core/supabase_client.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final _db = SupabaseClientManager.db;

  static const int _pageSize = 30;
  static const String _columns =
      '*, categories(name, color, icon)';

  // Tambah transaksi.
  Future<TransactionModel> add(
    TransactionModel transaction,
  ) async {
    final userId = _db.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User belum login.');
    }

    final data = transaction.toJson();
    data['user_id'] = userId;

    final response = await _db
        .from('transactions')
        .insert(data)
        .select(_columns)
        .single();

    return TransactionModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // Ambil riwayat transaksi dengan filter opsional.
  Future<List<TransactionModel>> history({
    int page = 0,
    int? categoryId,
    int? periodId,
    String? type,
    String? method,
    String? source,
    String? search,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _db
        .from('transactions')
        .select(_columns);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (periodId != null) {
      query = query.eq('period_id', periodId);
    }

    if (type != null) {
      query = query.eq('type', type);
    }

    if (method != null) {
      query = query.eq('method', method);
    }

    if (source != null) {
      query = query.eq('source', source);
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
        .range(
          page * _pageSize,
          (page + 1) * _pageSize - 1,
        );

    return response
        .map<TransactionModel>(
          (item) => TransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // Ambil satu transaksi berdasarkan ID.
  Future<TransactionModel> getById(int id) async {
    final response = await _db
        .from('transactions')
        .select(_columns)
        .eq('id', id)
        .single();

    return TransactionModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // Edit transaksi.
  Future<TransactionModel> update(
    TransactionModel transaction,
  ) async {
    final id = transaction.id;

    if (id == null) {
      throw ArgumentError(
        'ID transaksi wajib diisi untuk edit.',
      );
    }

    final response = await _db
        .from('transactions')
        .update({
          ...transaction.toJson(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select(_columns)
        .single();

    return TransactionModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // Hapus transaksi.
  Future<void> delete(int id) async {
    await _db
        .from('transactions')
        .delete()
        .eq('id', id);
  }
}