
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static String _key(String userId) {
    return 'onboarding_completed_$userId';
  }

  static Future<bool> isCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  static Future<void> setCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}
