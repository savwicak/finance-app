
import 'package:flutter/material.dart';
import 'package:nvidiaapp/features/auth/data/datasources/nebius_datasource.dart';

Future<void> testNebius() async {
  final ai = NebiusDatasource();

  try {
    final result = await ai.analyzeMoney(
      income: 500000,
      expenses: [
        {'category': 'Makan', 'amount': 100000},
        {'category': 'Transportasi', 'amount': 50000},
        {'category': 'Jajan', 'amount': 75000},
      ],
    );

    debugPrint('=== HASIL ANALISIS NEBIUS ===');
    debugPrint(result);
  } catch (e, st) {
    debugPrint('=== NEBIUS ERROR ===');
    debugPrint('$e');
    debugPrintStack(stackTrace: st);
  }
}
