
import 'package:supabase_flutter/supabase_flutter.dart';

class PaypalService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await supabase.functions.invoke(
        'paypal-connection-test',
        method: HttpMethod.post,
      );

      final data = Map<String, dynamic>.from(response.data);

      if (response.status != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'PayPal connection failed');
      }

      return data;
    } catch (e) {
      throw Exception('Gagal menghubungkan PayPal: $e');
    }
  }
}
