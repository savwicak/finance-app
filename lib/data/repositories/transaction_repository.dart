
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final TransactionRemoteDataSource _dataSource;

  TransactionRepository({
    TransactionRemoteDataSource? dataSource,
  }) : _dataSource =
           dataSource ?? TransactionRemoteDataSource();

  Future<TransactionModel> add(TransactionModel transaction) {
    return _dataSource.add(transaction);
  }

  Future<List<TransactionModel>> history({
    int page = 0,
    int? categoryId,
    int? periodId,
    String? method,
    String? type,
    String? search,
    DateTime? from,
    DateTime? to,
  }) {
    return _dataSource.history(
      page: page,
      categoryId: categoryId,
      periodId: periodId,
      method: method,
      type: type,
      search: search,
      from: from,
      to: to,
    );
  }

  Future<TransactionModel> update(TransactionModel transaction) {
    return _dataSource.update(transaction);
  }

  Future<void> delete(int id) {
    return _dataSource.delete(id);
  }
}
