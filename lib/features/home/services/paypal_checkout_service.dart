import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PayPalCheckoutService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Edge Function harus membuat order di PayPal dan mengembalikan
  /// { "orderId": "...", "approvalUrl": "https://..." }.
  Future<String> createDepositOrder({
    required int amount,
    required String goalId,
  }) async {
    if (amount <= 0) throw Exception('Nominal deposit harus lebih dari 0.');

    final response = await _client.functions.invoke(
      'paypal-create-order',
      body: {
        'amount': amount,
        'currency': 'USD',
        'goal_id': goalId,
      },
    );

    if (response.status != 200 || response.data is! Map) {
      throw Exception('Gagal membuat PayPal order: ${response.data}');
    }

    final approvalUrl = response.data['approvalUrl']?.toString();
    if (approvalUrl == null || approvalUrl.isEmpty) {
      throw Exception('Approval URL tidak ditemukan dari server.');
    }

    final uri = Uri.tryParse(approvalUrl);
    if (uri == null || !uri.hasScheme) {
      throw Exception('Approval URL PayPal tidak valid.');
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) throw Exception('Tidak bisa membuka halaman PayPal.');
    return response.data['orderId']?.toString() ?? '';
  }

  /// Panggil setelah user kembali dari approval PayPal.
  /// Edge Function wajib memverifikasi order dan menyimpan hasil capture
  /// secara server-side sebelum menambahkan savings_entries.
  Future<void> captureDeposit(String orderId) async {
    if (orderId.isEmpty) throw Exception('PayPal order ID kosong.');

    final response = await _client.functions.invoke(
      'paypal-capture-order',
      body: {'order_id': orderId},
    );

    if (response.status != 200 ||
        response.data is! Map ||
        response.data['success'] != true) {
      throw Exception('PayPal capture gagal: ${response.data}');
    }
  }
}
