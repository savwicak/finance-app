
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/features/wishlist/controller/savings_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImpulseCalculatorScreen extends StatefulWidget {
  const ImpulseCalculatorScreen({super.key});

  @override
  State<ImpulseCalculatorScreen> createState() =>
      _ImpulseCalculatorScreenState();
}

class _ImpulseCalculatorScreenState
    extends State<ImpulseCalculatorScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  final SavingsController savingsController =
      Get.find<SavingsController>();

  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;
  bool isOutOfPlan = true;
  bool isLoading = false;

  int get price =>
      int.tryParse(priceController.text.replaceAll('.', '').trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    priceController.addListener(() {
      setState(() {});
    });
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('is_archive', false)
          .order('sort_order');

      if (!mounted) return;

      setState(() {
        categories =
            List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil kategori: $e');
    }
  }

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  Future<void> saveToSavings() async {
    final name = nameController.text.trim();

    if (name.isEmpty || price <= 0) {
      Get.snackbar(
        'Input belum lengkap',
        'Isi nama barang dan harga terlebih dahulu.',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await savingsController.addGoal(
        name: name,
        targetAmount: price,
      );

      if (success && mounted) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
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
                        decoration: inputDecoration(
                          'Nama barang',
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price'),
                          Text(
                            formatRupiah(price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration(
                          'Masukkan harga',
                          prefix: 'Rp ',
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text('Category'),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        isExpanded: true,
                        decoration: inputDecoration('Pilih kategori'),
                        items: categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'] as int,
                            child: Text(
                              category['name'] ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        activeColor: const Color(0xFFB8E600),
                        title: const Text(
                          'Mark as out-of-plan expenses',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: isOutOfPlan,
                        onChanged: (value) {
                          setState(() {
                            isOutOfPlan = value ?? false;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Result',
                        style: TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 12),

                      // RESULT CARD
                      Container(
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
                              'Harga barang: ${formatRupiah(price)}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isOutOfPlan
                                  ? 'Pengeluaran di luar rencana'
                                  : 'Pengeluaran terencana',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // BALANCE CARDS
                      Row(
                        children: [
                          Expanded(
                            child: resultCard(
                              'Balance Remaining',
                              'Belum dihitung',
                              'Menunggu data saldo',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: resultCard(
                              'Daily Funds',
                              'Belum dihitung',
                              'Menunggu data periode',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      resultCard(
                        'Daya Tahan Uang',
                        'Belum dihitung',
                        'Menunggu data transaksi',
                      ),

                      const SizedBox(height: 30),

                      // BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Buy Anyway',
                                  'Integrasi pencatatan transaksi akan '
                                      'ditambahkan setelah struktur '
                                      'transactions diketahui.',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF292525),
                                foregroundColor: Colors.white,
                                minimumSize:
                                    const Size(double.infinity, 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(35),
                                ),
                              ),
                              child: const Text('Buy Anyway'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          GestureDetector(
                            onTap: isLoading ? null : saveToSavings,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB8E600),
                                shape: BoxShape.circle,
                              ),
                              child: isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(18),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                            ),
                          ),
                        ],
                      ),

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
