
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/home/controllers/home_controller.dart';

import '../../controllers/category_controller.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final CategoryController controller = Get.find<CategoryController>();
  final HomeController homeController = Get.find<HomeController>();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final allocationController = TextEditingController();

  String selectedIcon = 'restaurant';
  String selectedColor = '#B8E600';

  bool isImpulsive = false;
  bool isSaving = false;

  final Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant,
    'shopping_bag': Icons.shopping_bag,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'movie': Icons.movie,
    'payments': Icons.payments,
    'pets': Icons.pets,
    'sports': Icons.sports,
    'category': Icons.category,
  };

  final List<String> availableColors = [
    '#B4DE00', // Lime
    '#DE9800', // Orange
    '#00DEC0', // Turquoise
  ];

  int get currentBalance =>
      homeController.summary.value?.balance ?? 0;

  String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  Color getColor(String hex) {
    return Color(
      int.parse(
        'FF${hex.replaceAll('#', '')}',
        radix: 16,
      ),
    );
  }

  int get allocationAmount {
    return int.tryParse(
          allocationController.text.replaceAll('.', '').trim(),
        ) ??
        0;
  }

  Future<void> saveCategory() async {
    if (isSaving) return;

    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final success = await controller.addCategory(
        name: nameController.text,
        icon: selectedIcon,
        color: selectedColor,
        isImpulsive: isImpulsive,
        allocation: allocationAmount,
      );

      if (!mounted) return;

      if (success) {
        Get.back(result: true);
        return;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan kategori: $e',
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    homeController.loadDashboard();

    allocationController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    allocationController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // BALANCE CARD
  Widget buildBalanceCard() {
    return Obx(() {
      final balance = currentBalance;
      final allocation = allocationAmount;
      final afterAllocation = balance - allocation;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFB8E600),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your Current Balance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.circle,
                  color: Color(0xFF218838),
                  size: 10,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              formatCurrency(balance),
              style: const TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.07),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alokasi baru',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        formatCurrency(allocation),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Divider(
                    color: Colors.black.withOpacity(0.15),
                    height: 1,
                  ),

                  const SizedBox(height: 9),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sisa setelah alokasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        formatCurrency(afterAllocation),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: afterAllocation < 0
                              ? Colors.red.shade900
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (afterAllocation < 0) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Alokasi melebihi saldo yang tersedia!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFFCFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Add Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CURRENT BALANCE
                        buildBalanceCard(),

                        const SizedBox(height: 25),

                        // CATEGORY NAME
                        const Text(
                          'Category Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: nameController,
                          textCapitalization:
                              TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Example: Food & Drink',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppTheme.border,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama kategori wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        // ALLOCATION
                        const Text(
                          'Category Allocation',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: allocationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Contoh: 500000',
                            prefixText: 'Rp ',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppTheme.border,
                              ),
                            ),
                            helperText:
                                'Kosongkan jika belum ingin mengalokasikan uang',
                          ),
                        ),

                        const SizedBox(height: 25),

                        // CHOOSE ICON
                        const Text(
                          'Choose Icon',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: availableIcons.entries.map((entry) {
                            final selected =
                                selectedIcon == entry.key;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIcon = entry.key;
                                });
                              },
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? getColor(selectedColor)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.black
                                        : const Color(0xFFE5E5ED),
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  entry.value,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 25),

                        // CHOOSE COLOR
                        const Text(
                          'Choose Color',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 13,
                          runSpacing: 13,
                          children: availableColors.map((color) {
                            final selected =
                                selectedColor == color;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: getColor(color),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 25),

                        // IMPULSIVE CATEGORY
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5E5ED),
                            ),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Impulsive Category',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              'Tandai kategori untuk pengeluaran impulsif',
                              style: TextStyle(fontSize: 12),
                            ),
                            activeTrackColor: AppTheme.primary,
                            value: isImpulsive,
                            onChanged: (value) {
                              setState(() {
                                isImpulsive = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),

              // SAVE BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppTheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
