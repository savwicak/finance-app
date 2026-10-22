import 'package:supabase_flutter/supabase_flutter.dart';

/// Satu-satunya tempat yang bicara langsung ke Supabase untuk urusan auth.
class AuthRemoteDatasource {
  SupabaseClient get _db => Supabase.instance.client;

  Stream<AuthState> get authChanges => _db.auth.onAuthStateChange;
  Session? get session => _db.auth.currentSession;
  User? get user => _db.auth.currentUser;

  Future<AuthResponse> signUp(String email, String password, String name) =>
      _db.auth.signUp(email: email, password: password, data: {'name': name});

  Future<AuthResponse> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _db.auth.signOut();

  // --- Hanya untuk mengecek hasil setup database di HomeScreen ---

  /// Baris profil milik pengguna. Dibuat otomatis oleh trigger saat daftar.
  Future<Map<String, dynamic>?> fetchProfile() =>
      _db.from('profiles').select().maybeSingle();

  /// Jumlah kategori milik pengguna. Seharusnya 6 (kategori bawaan dari trigger).
  Future<int> fetchCategoryCount() async {
    final rows = await _db.from('categories').select('id');
    return rows.length;
  }
}
