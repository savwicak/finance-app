import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/wishlist/controller/savings_controller.dart';
import 'package:nvidiaapp/features/category/controllers/category_controller.dart';

class SavingsScreen extends StatelessWidget {
  SavingsScreen({super.key});

  final SavingsController controller = Get.put(SavingsController());
  final CategoryController categoryController = Get.put(CategoryController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController targetController = TextEditingController();

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  void showAddGoalDialog() {
    nameController.clear();
    targetController.clear();

    int? selectedCategoryId;
    DateTime? selectedDate;
    bool isOutOfPlan = false;
    bool isDone = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          final categories = categoryController.categories;

          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              'Add Wishlist',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama barang wishlist',
                        filled: true,
                        fillColor: const Color(0xFFF8F6F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Target harga',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: const Color(0xFFF8F6F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // CATEGORY DROPDOWN
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Pilih kategori',
                        filled: true,
                        fillColor: const Color(0xFFF8F6F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((category) {
                        final id = (category['id'] as num).toInt();

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            category['name']?.toString() ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // DATE PICKER
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? 'Pilih tanggal target'
                                    : '${selectedDate!.day.toString().padLeft(2, '0')}/'
                                      '${selectedDate!.month.toString().padLeft(2, '0')}/'
                                      '${selectedDate!.year}',
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Out of Plan'),
                      value: isOutOfPlan,
                      activeColor: const Color(0xFFB8E600),
                      onChanged: (value) {
                        setDialogState(() {
                          isOutOfPlan = value ?? false;
                        });
                      },
                    ),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Wishlist sudah terpenuhi'),
                      value: isDone,
                      activeColor: const Color(0xFFB8E600),
                      onChanged: (value) {
                        setDialogState(() {
                          isDone = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
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
                  final target = int.tryParse(
                    targetController.text.trim(),
                  );

                  if (name.isEmpty || target == null || target <= 0) {
                    Get.snackbar(
                      'Invalid Input',
                      'Isi nama barang dan target harga dengan benar.',
                    );
                    return;
                  }

                  final success = await controller.addGoal(
                    name: name,
                    targetAmount: target,
                    categoryId: selectedCategoryId,
                    dueDate: selectedDate,
                    isOutOfPlan: isOutOfPlan,
                    isDone: isDone,
                  );

                  if (success) {
                    Get.back(closeOverlays: true);
                  }
                },
                child: const Text('Save Wishlist'),
              ),
            ],
          );
        },
      ),
    );
  }
  // Tipe data goalId diubah menjadi int
  void showDepositDialog(int goalId, String goalName) {
    final TextEditingController depositController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Setor ke $goalName',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: depositController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nominal setor',
            prefixText: 'Rp ',
            filled: true,
            fillColor: const Color(0xFFF8F6F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8E600),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final amount = int.tryParse(depositController.text.trim());

              if (amount == null || amount <= 0) {
                Get.snackbar(
                  'Invalid Input',
                  'Masukkan nominal setor yang valid.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(15),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2),
                  icon: const Icon(Icons.error, color: Colors.white),
                );
                return;
              }

              // TODO: Ganti dengan memanggil method deposit dari PayPal controller kamu
              // Contoh:
              // final success = await payPalController.processDeposit(goalId: goalId, amount: amount);
              // if (success) { await controller.fetchGoals(); }

              Get.back(); // Tutup dialog input nominal

              // Contoh simulasi update state setelah berhasil:
              await controller.fetchGoals();

              Get.snackbar(
                'Success!',
                'Berhasil menyetor ${formatRupiah(amount)} ke $goalName!',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppTheme.primary,
                colorText: Colors.black,
                margin: const EdgeInsets.all(15),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.check_circle, color: Colors.black),
              );
            },
            child: const Text('Setor'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525), // Background gelap untuk header
      body: Column(
        children: [
          // HEADER SECTION
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Savings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Savings:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      formatRupiah(controller.totalSavings),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Text(
                      '${controller.goals.length} Items in list',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BODY SECTION (Putih melengkung ke atas)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Row Search Bar & Add Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Find category..',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black26,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE3E8EF),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE3E8EF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: showAddGoalDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Add',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB8E600),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List Tabungan
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFB8E600),
                          ),
                        );
                      }

                      if (controller.goals.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada target tabungan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: controller.fetchGoals,
                        color: const Color(0xFFB8E600),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.goals.length,
                          itemBuilder: (context, index) {
                            final goal = controller.goals[index];

                            // Hitung progress secara manual untuk di-pass ke widget
                            final saved = controller.totalSavedForGoal(goal.id);
                            final progress = goal.targetAmount > 0
                                ? (saved / goal.targetAmount).clamp(0.0, 1.0)
                                : 0.0;

                            return _buildSavingsGoalCard(
                              name: goal.name,
                              savedAmount: saved,
                              targetAmount: goal.targetAmount,
                              progress: progress,
                              onDelete: () async {
                                final confirm = await Get.dialog<bool>(
                                  AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('Delete Savings?'),
                                    content: const Text(
                                      'Yakin ingin menghapus target tabungan ini beserta riwayat setorannya?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Get.back(result: true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await controller.deleteGoal(goal.id);
                                }
                              },
                              onDeposit: () async {
                                // Memanggil fungsi showDepositDialog
                                // Data state akan otomatis ke-update dari dalam fungsi tersebut
                                showDepositDialog(goal.id, goal.name);
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tipe data onDeposit diubah menjadi Future<void> Function()
  Widget _buildSavingsGoalCard({
    required String name,
    required int savedAmount,
    required int targetAmount,
    required double progress,
    required VoidCallback onDelete,
    required Future<void> Function() onDeposit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Target: 25 Okt 2026',
                      style: TextStyle(fontSize: 13, color: Color(0xFFB0B4BA)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 22),
                color: const Color(0xFFD1D5DB),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  formatRupiah(savedAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                formatRupiah(targetAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFFB0B4BA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFB8E600)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                // Perbaikan operasi matematika persentase
                '${(progress * 100).toStringAsFixed(0)}% tercapai',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                // Memanggil fungsi onDeposit secara asinkron
                onPressed: () async {
                  await onDeposit();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Quick Deposit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
