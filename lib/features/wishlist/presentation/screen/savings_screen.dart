import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/features/wishlist/controller/savings_controller.dart';

class SavingsScreen extends StatelessWidget {
  SavingsScreen({super.key});

  final SavingsController controller = Get.put(SavingsController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController targetController = TextEditingController();

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  void showAddGoalDialog() {
    nameController.clear();
    targetController.clear();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Add Savings Goal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Savings name',
                filled: true,
                fillColor: const Color(0xFFF8F6F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Target amount',
                prefixText: 'Rp ',
                filled: true,
                fillColor: const Color(0xFFF8F6F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8E600),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final target = int.tryParse(targetController.text.trim());

              if (name.isEmpty || target == null || target <= 0) {
                Get.snackbar(
                  'Invalid Input',
                  'Isi nama dan target tabungan dengan benar.',
                );
                return;
              }

              final success = await controller.addGoal(
                name: name,
                targetAmount: target,
              );

              if (success) {
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 25, 25, 15),
              child: Text(
                'Your Savings',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Savings:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      formatRupiah(controller.totalSavings),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Obx(
                    () => Text(
                      '${controller.goals.length} Items in list',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.goals.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada target tabungan',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchGoals,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.goals.length,
                    itemBuilder: (context, index) {
                      final goal = controller.goals[index];

                      final saved = controller.totalSavedForGoal(goal.id);

                      final progress = goal.targetAmount > 0
                          ? (saved / goal.targetAmount).clamp(0.0, 1.0)
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Slidable(
                          key: ValueKey(goal.id),
                          endActionPane: ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  final confirm = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text('Delete Savings?'),
                                      content: const Text(
                                        'Yakin ingin menghapus target tabungan ini beserta riwayat setorannya?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(
                                            result: false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Get.back(
                                            result: true,
                                          ),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await controller.deleteGoal(goal.id);
                                  }
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E5ED),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatRupiah(saved)),
                                    Text(formatRupiah(goal.targetAmount)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 12,
                                    backgroundColor:
                                        const Color(0xFFF0F0F0),
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                      Color(0xFFB8E600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddGoalDialog,
        backgroundColor: const Color(0xFFB8E600),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Savings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
