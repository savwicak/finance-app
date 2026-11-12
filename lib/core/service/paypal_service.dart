import 'package:supabase_flutter/supabase_flutter.dart';

class PayPalService {
  final _supabase = Supabase.instance.client;

  /// Trigger Deposit (Setor Tabungan via Orders API)
  Future<Map<String, dynamic>?> createDeposit({
    required String userId,
    required double amount,
    String? goalId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'paypal-deposit',
        body: {
          'userId': userId,
          'goalId': goalId,
          'amount': amount,
          'currency': 'USD',
        },
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        print('Deposit Error: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Exception Deposit: $e');
      return null;
    }
  }
  Future<bool> withdrawSavings({
    required String userId,
    required String receiverEmail,
    required double amount,
    String? goalId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'paypal-payout',
        body: {
          'userId': userId,
          'goalId': goalId,
          'receiverEmail': receiverEmail,
          'amount': amount,
          'currency': 'USD',
        },
      );

      return response.status == 200 && response.data['success'] == true;
    } catch (e) {
      print('Exception Payout: $e');
      return false;
    }
  }
}