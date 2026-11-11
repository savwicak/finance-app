
import 'package:supabase_flutter/supabase_flutter.dart';

/// nebius ai melalui supabase edge Function
/// API key Nebius disimpan di supabase secrets
class NebiusDatasource {
  final SupabaseClient _db;

  NebiusDatasource({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  /// analisis pemasukan dan pengeluaran uang saku
  Future<String> analyzeMoney({
    required int income,
    required List<Map<String, dynamic>> expenses,
  }) async {
    final response = await _db.functions.invoke(
      'analyze-money',
      body: {
        'income': income,
        'expenses': expenses,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception('Respons analisis AI tidak valid.');
    }

    final analysis = data['analysis'];

    if (response.status < 200 || response.status >= 300) {
      throw Exception(
        data['error']?.toString() ?? 'Gagal menghubungi Nebius AI.',
      );
    }

    if (analysis is! String || analysis.trim().isEmpty) {
      throw Exception(
        data['error']?.toString() ?? 'Hasil analisis AI kosong.',
      );
    }

    return analysis;
  }
}
