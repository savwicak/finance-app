import 'package:flutter/material.dart';
import 'package:nvidiaapp/core/di.dart';
import 'package:nvidiaapp/presentation/screens/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';

/// Memilih layar awal: sudah login masuk ke Home, belum login ke Login.
/// Berganti otomatis saat login atau logout.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: authRepository.authChanges,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? authRepository.session;
        return session == null ? const LoginScreen() : const HomeScreen();
      },
    );
  }
}
