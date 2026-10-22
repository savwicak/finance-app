import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo);
  final AuthRepository _repo;

  bool loading = false;
  String? error;
  String? info;

  void clearMessages() {
    error = null;
    info = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) =>
      _run('login', () => _repo.login(email, password));

  Future<bool> register(String name, String email, String password) =>
      _run('register', () async {
        final res = await _repo.register(name, email, password);
        if (res.session == null) {
          info = 'Akun dibuat. Cek email untuk verifikasi, lalu login.';
        }
      });

  Future<void> logout() => _repo.logout();

  Future<bool> _run(String label, Future<void> Function() action) async {
    debugPrint('[AUTH] $label mulai');
    loading = true;
    error = null;
    info = null;
    notifyListeners();
    try {
      await action();
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      debugPrint('[AUTH] $label OK, sesi ada: $hasSession');
      return true;
    } on AuthException catch (e) {
      debugPrint('[AUTH] $label GAGAL (AuthException): ${e.message} | status: ${e.statusCode}');
      error = e.message;
      return false;
    } catch (e, st) {
      debugPrint('[AUTH] $label ERROR: $e\n$st');
      error = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}