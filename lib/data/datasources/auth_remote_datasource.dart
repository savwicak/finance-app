
import 'package:nvidiaapp/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _db = SupabaseClientManager.db;

  User? get user => _db.auth.currentUser;

  Stream<AuthState> get changes =>
      _db.auth.onAuthStateChange;

  Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) {
    return _db.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<AuthResponse> login(
    String email,
    String password,
  ) {
    return _db.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() {
    return _db.auth.signOut();
  }
}
