import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/features/home/widgets/impulsive_calculator_button.dart';
import '../../controllers/home_controller.dart';
import '../../models/dashboard_models.dart';
import '../../widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  Future<void> _showDepositDialog(
    BuildContext context,
    DashboardSavingsGoal goal,
  ) async {
    final amountController = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Deposit • ${goal.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nominal deposit (angka)',
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(amountController.text.replaceAll('.', '').replaceAll(',', ''));
              if (value != null && value > 0) Navigator.pop(context, value);
            },
            child: const Text('Lanjut ke PayPal'),
          ),
        ],
      ),
    );
    amountController.dispose();

    if (amount != null) {
      await controller.quickDeposit(goalId: goal.id, amount: amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty && controller.summary.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 42),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: controller.loadDashboard, child: const Text('Coba lagi')),
                ],
              ),
            ),
          );
        }

        final data = controller.summary.value;
        if (data == null) return const Center(child: Text('Belum ada data dashboard.'));

      return RefreshIndicator(
        onRefresh: () async {
          await controller.loadDashboard();
        },
        color: Colors.deepPurple,
        backgroundColor: Colors.white,
        displacement: 50,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: BalanceHeader(
                balance: data.balance,
                todayExpense: data.todayExpense,
                remainingBudget: data.remainingBudget,
                monthlyBudget: data.monthlyBudget,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  InsightCard(insight: controller.insight.value),
                  const SizedBox(height: 18),
                  ImpulsiveCalculatorButton(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tabungan',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data.goals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Belum ada target tabungan. Tambahkan target dari menu Savings.',
                      ),
                    )
                  else
                    ...data.goals.map(
                      (goal) => SavingsGoalCard(
                        goal: goal,
                        onDeposit: () => _showDepositDialog(context, goal),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Riwayat',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data.transactions.isEmpty)
                    const Text('Belum ada transaksi.')
                  else
                    ...data.transactions.map(
                      (transaction) => RecentTransactionTile(
                        transaction: transaction,
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      );

      }),
    );
  }
}
