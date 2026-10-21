//buat isi routes nanti tinggal di ambil

import 'package:get/get.dart';
import 'package:nvidiaapp/main.dart';
import 'package:nvidiaapp/presentation/screens/auth/login_screen.dart';
import 'package:nvidiaapp/presentation/screens/auth/register_screen.dart';
import 'package:nvidiaapp/presentation/screens/history/history_category_screen.dart';
import 'package:nvidiaapp/presentation/screens/history/history_general_screen.dart';
import 'package:nvidiaapp/presentation/screens/impulsive_calculator/impulsive_calculator_screen.dart';
import 'package:nvidiaapp/presentation/screens/onboarding/on_boarding_screen.dart';
import 'package:nvidiaapp/presentation/screens/splash/splash_screen.dart';
import 'package:nvidiaapp/presentation/screens/wishlist/wishlist_screen.dart';

class Routes {
  static const String main = "/main";
  //auth
  static const String login = "/login";
  static const String register = "/register";
  //history
  static const String historyGeneral = "/history-general";
  static const String historyCategory = "/history-category";
  //home
  static const String home = "/home";
  //implusive calculator
  static const String impulsiveCalculator = "/impulsive-calculator";
  //onboarding
  static const String onBoarding = "/onboarding";
  //splashscreeen
  static const String splash = "/splash";
  //whislist
  static const String wishlist = "/wishlist";


  static final pages = [
    GetPage(
      name: splash, 
      page: () => SplashScreen(),
    ),
    GetPage(
      name: main, 
      page: () => MyApp(),
    ),
    GetPage(
      name: login, 
      page: () => LoginScreen(),
    ),
    GetPage(
      name: register, 
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: historyGeneral, 
      page: () => HistoryGeneralScreen(),
    ),
    GetPage(
      name: historyCategory, 
      page: () => HistoryCategoryScreen(),
    ),
    GetPage(
      name: impulsiveCalculator, 
      page: () => ImpulsiveCalculatorScreen(),
    ),
    GetPage(
      name: onBoarding, 
      page: () => OnBoardingScreen(),
    ),
    GetPage(
      name: wishlist, 
      page: () => WishlistScreen(),
    ),
  ];
}

