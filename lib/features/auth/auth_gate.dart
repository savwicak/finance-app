
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nvidiaapp/features/on_boarding/storage/onboarding_storage.dart';
import 'package:nvidiaapp/core/navigation/app_navigation.dart';
import 'package:nvidiaapp/features/auth/presentation/screens/login_screen.dart';
import 'package:nvidiaapp/features/on_boarding/controller/onboarding_controller.dart';
import 'package:nvidiaapp/features/on_boarding/presentation/screens/on_boarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? supabase.auth.currentSession;

        if (session == null) {
          return const LoginScreen();
        }

        final userId = session.user.id;

        return FutureBuilder<bool>(
          future: OnboardingStorage.isCompleted(userId),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (onboardingSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text('Gagal memuat status onboarding.'),
                ),
              );
            }

            if (onboardingSnapshot.data == true) {
              return const AppNavigation();
            }

            if (!Get.isRegistered<OnboardingController>()) {
              Get.put(OnboardingController());
            }

            return const OnboardingScreen();
          },
        );
      },
    );
  }
}
