
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/auth_remote_datasource.dart';

class AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepository({
    AuthRemoteDataSource? dataSource,
  }) : _dataSource =
           dataSource ?? AuthRemoteDataSource();

  User? get user => _dataSource.user;

  Stream<AuthState> get changes => _dataSource.changes;

  Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) {
    return _dataSource.register(email, password, name);
  }

  Future<AuthResponse> login(
    String email,
    String password,
  ) {
    return _dataSource.login(email, password);
  }

  Future<void> logout() {
    return _dataSource.logout();
  }
}
