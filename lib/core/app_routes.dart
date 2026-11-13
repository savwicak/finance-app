
import 'package:get/get.dart';
import 'package:nvidiaapp/features/auth/auth_gate.dart';
import 'package:nvidiaapp/features/auth/presentation/screens/login_screen.dart';
import 'package:nvidiaapp/features/auth/presentation/screens/register_screen.dart';
import 'package:nvidiaapp/features/category/presentation/screen/add_category_screen.dart';
import 'package:nvidiaapp/features/category/presentation/screen/category_screen.dart';
import 'package:nvidiaapp/features/history/presentation/screens/history_category_screen.dart';
import 'package:nvidiaapp/features/history/presentation/screens/history_general.dart';
import 'package:nvidiaapp/features/home/add-balance/add_balance_screen.dart';
import 'package:nvidiaapp/features/home/presentation/screens/home_screen.dart';
import 'package:nvidiaapp/features/on_boarding/presentation/screens/on_boarding_screen.dart';
import 'package:nvidiaapp/features/splash/splash_screen.dart';
import 'package:nvidiaapp/features/impulse-calculator/presentation/screens/impulse_calculator_screen.dart';
import 'package:nvidiaapp/features/wishlist/presentation/screen/savings_screen.dart';

class Routes {
  // Initial
  static const String initial = '/';
  static const String splash = '/splash';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String authGate = '/auth-gate';

  // History
  static const String historyGeneral = '/history-general';
  static const String historyCategory = '/history-category';

  // Home
  static const String home = '/home';

  // Impulsive Calculator
  static const String impulsiveCalculator = '/impulsive-calculator';

  // Add Budget
  static const String addBudget = '/add-budget';

  // Onboarding
  static const String onBoarding = '/on-boarding';

  // Wishlist
  static const String wishlist = '/wishlist';

  // Category
  static const String category = '/category';

  static final pages = [
    GetPage(
      name: initial,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: authGate,
      page: () => const AuthGate(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: historyGeneral,
      page: () => HistoryGeneralScreen(),
    ),
    GetPage(
      name: historyCategory,
      page: () => const HistoryCategoryScreen(),
    ),
    GetPage(
      name: impulsiveCalculator,
      page: () => ImpulseCalculatorScreen(),
    ),
    GetPage(
      name: onBoarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: wishlist,
      page: () => SavingsScreen(),
    ),
    GetPage(
      name: category,
      page: () => CategoryScreen(),
    ),
    GetPage(
      name: addBudget,
      page: () => AddBalanceScreen(),
    ),
  ];
}
