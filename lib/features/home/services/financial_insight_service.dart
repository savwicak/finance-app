import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_models.dart';

class FinancialInsightService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> getInsight(List<DashboardTransaction> transactions) async {
    try {
      final response = await _client.functions.invoke(
        'financial-insight',
        body: {
          'transactions': transactions.map((t) => {
            'title': t.title,
            'category': t.categoryName,
            'amount': t.amount,
            'type': t.type,
            'created_at': t.createdAt.toIso8601String(),
          }).toList(),
        },
      );

      if (response.status == 200 && response.data is Map) {
        final message = response.data['insight']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Fallback lokal agar dashboard tetap bisa dipakai saat AI belum tersedia.
    }

    final expenses = transactions.where((t) => !t.isIncome).toList();
    if (expenses.isEmpty) {
      return 'Belum ada pengeluaran yang tercatat. Yuk mulai catat transaksi agar kondisi keuanganmu bisa dianalisis.';
    }

    final totals = <String, int>{};
    for (final item in expenses) {
      totals[item.categoryName] = (totals[item.categoryName] ?? 0) + item.amount;
    }
    final top = totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return 'Pengeluaran terbesarmu saat ini ada di kategori ${top.key}. Totalnya ${_rupiah(top.value)}. Coba cek kembali budget kategori ini dan sisihkan sisa uang ke tabungan.';
  }

  String _rupiah(int value) {
    final text = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $text';
  }
}
