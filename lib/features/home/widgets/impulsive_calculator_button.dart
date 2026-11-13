import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/core/app_routes.dart';

class ImpulsiveCalculatorButton extends StatelessWidget {
  const ImpulsiveCalculatorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Get.toNamed(Routes.impulsiveCalculator);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.secondary,
      ),
      child: const Text(
        "Impulsive Calculator",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}