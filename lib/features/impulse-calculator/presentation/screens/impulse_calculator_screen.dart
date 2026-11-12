
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/features/impulse-calculator/controller/impulse_calculator_controller.dart';

class ImpulseCalculatorScreen extends StatelessWidget {
  ImpulseCalculatorScreen({super.key});

  final ImpulseCalculatorController controller =
      Get.put(ImpulseCalculatorController());

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF292525),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Download ↓',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),
                  const Text(
                    'Kalkulator\nImpulsif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // FORM
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 15),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFCFC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(45),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('What Do You Want to Buy?'),
                      const SizedBox(height: 8),

                      TextField(
                        controller: nameController,
                        onChanged: controller.updateName,
                        decoration: inputDecoration('Nama barang'),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price'),
                          Obx(() => Text(
                            formatRupiah(controller.price.value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ],
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        onChanged: controller.updatePrice,
                        decoration: inputDecoration(
                          'Masukkan harga',
                          prefix: 'Rp ',
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text('Category'),
                      const SizedBox(height: 8),

                      Obx(() {
                        if (controller.categories.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F6F7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E5ED)),
                            ),
                            child: const Text(
                              'Kategori Impulsive belum tersedia',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return DropdownButtonFormField<int>(
                          value: controller.categories.any(
                            (category) =>
                                (category['id'] as num).toInt() ==
                                controller.selectedCategoryId.value,
                          )
                              ? controller.selectedCategoryId.value
                              : null,
                          isExpanded: true,
                          menuMaxHeight: 300,
                          decoration: inputDecoration('Pilih kategori'),
                          hint: const Text('Pilih kategori'),
                          items: controller.categories.map((category) {
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
                            controller.updateCategory(value);
                          },
                        );
                      }),

                      const SizedBox(height: 12),

                      Obx(() => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        activeColor: const Color(0xFFB8E600),
                        title: const Text(
                          'Mark as out-of-plan expenses',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: controller.isOutOfPlan.value,
                        onChanged: (value) {
                          controller.updateOutOfPlan(value ?? false);
                        },
                      )),

                      const SizedBox(height: 12),

                      const Text(
                        'Result',
                        style: TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 12),

                      // PURCHASE SUMMARY
                      Obx(() => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
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
                            const Text(
                              'Purchase Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Harga barang: ${formatRupiah(controller.price.value)}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              controller.isOutOfPlan.value
                                  ? 'Pengeluaran di luar rencana'
                                  : 'Pengeluaran terencana',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 15),

                      // BALANCE CARDS
                      Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: resultCard(
                              'Balance Remaining',
                              formatRupiah(
                                controller.balanceRemaining.value,
                              ),
                              'Saldo setelah pembelian',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: resultCard(
                              'Daily Funds',
                              formatRupiah(
                                controller.dailyFunds.value,
                              ),
                              'Dana harian tersedia',
                            ),
                          ),
                        ],
                      )),

                      const SizedBox(height: 15),

                      Obx(() => resultCard(
                        'Daya Tahan Uang',
                        '${controller.moneyDurability.value.toStringAsFixed(1)} hari',
                        'Estimasi ketahanan uang',
                      )),

                      const SizedBox(height: 30),

                      // BUTTON
                      Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.buyAnyway,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF292525),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(
                              double.infinity,
                              60,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Buy Anyway'),
                        ),
                      )),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String hint, {
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: const Color(0xFFF8F6F7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE5E5ED),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE5E5ED),
        ),
      ),
    );
  }

  Widget resultCard(
    String title,
    String value,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5E5ED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
