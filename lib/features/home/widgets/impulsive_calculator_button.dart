import 'package:flutter/material.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';

class ImpulsiveCalculatorButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.secondary
      ),
      child: Text(
        "Impulsive Calculator",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}