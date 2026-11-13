import 'package:flutter/material.dart';
import 'package:nvidiaapp/features/history/presentation/widgets/history_general_header.dart';

class HistoryGeneralScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<HistoryGeneralScreen> createState() => _HistoryGeneralScreenState();
}

class _HistoryGeneralScreenState extends State<HistoryGeneralScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HistoryGeneralHeader(balance: 1000000, todayExpense: 10000, remainingBudget: 10000, monthlyBudget: 4000000)
      ),
    );
  }
}