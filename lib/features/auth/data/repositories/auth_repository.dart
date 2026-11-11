import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/auth_remote_datasource.dart';

class AuthRepository {
  AuthRepository(this._remote);
  final AuthRemoteDatasource _remote;

  Stream<AuthState> get authChanges => _remote.authChanges;
  Session? get session => _remote.session;
  User? get user => _remote.user;

  Future<AuthResponse> register(String name, String email, String password) =>
      _remote.signUp(email.trim(), password, name.trim());

  Future<AuthResponse> login(String email, String password) =>
      _remote.signIn(email.trim(), password);

  Future<void> logout() => _remote.signOut();

  Future<Map<String, dynamic>?> myProfile() => _remote.fetchProfile();
  Future<int> myCategoryCount() => _remote.fetchCategoryCount();
}
