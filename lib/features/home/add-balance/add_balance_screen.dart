
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/home/controllers/home_controller.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String selectedType = 'expense';
  String selectedMethod = 'qris';
  DateTime selectedDate = DateTime.now();

  int? selectedCategoryId;
  List<Map<String, dynamic>> categories = [];

  bool isImpulsive = false;
  bool isLoadingCategories = true;
  bool isSaving = false;

  final List<Map<String, String>> paymentMethods = [
    {'label': 'Cash', 'value': 'tunai'},
    {'label': 'QRIS', 'value': 'qris'},
    {'label': 'E-Wallet', 'value': 'ewallet'},
    {'label': 'Transfer', 'value': 'transfer'},
  ];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  // LOAD CATEGORY FROM SUPABASE
 Future<void> loadCategories() async {
  try {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final response = await supabase
        .from('categories')
        .select('id, name, is_archive, is_archived')
        .eq('user_id', user.id)
        .order('name');

    // FILTER KATEGORI YANG MASIH AKTIF
    final activeCategories =
        List<Map<String, dynamic>>.from(response).where((category) {
      final isArchive = category['is_archive'] == true;
      final isArchived = category['is_archived'] == true;

      return !isArchive && !isArchived;
    }).toList();

    if (!mounted) return;

    setState(() {
      categories = activeCategories;
      isLoadingCategories = false;

      // Pastikan kategori terpilih masih tersedia
      if (selectedCategoryId != null &&
          !categories.any(
            (category) =>
                (category['id'] as num).toInt() == selectedCategoryId,
          )) {
        selectedCategoryId = null;
      }
    });

    debugPrint('ACTIVE CATEGORIES: $categories');
  } catch (e) {
    debugPrint('LOAD CATEGORY ERROR: $e');

    if (!mounted) return;

    setState(() {
      isLoadingCategories = false;
      categories = [];
    });

    Get.snackbar(
      'Gagal',
      'Tidak dapat mengambil kategori: $e',
      snackPosition: SnackPosition.TOP,
    );
  }
}
  // FORMAT DATE
  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  // FORMAT RUPIAH
  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  // SELECT DATE
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF252525),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // SAVE TRANSACTION
  Future<void> saveTransaction() async {
    if (isSaving) return;
    if (!formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'Silakan login terlebih dahulu');
      return;
    }

    final amount = int.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Nominal transaksi tidak valid');
      return;
    }

    if (selectedType == 'expense' &&
        categories.isNotEmpty &&
        selectedCategoryId == null) {
      Get.snackbar('Error', 'Silakan pilih pos anggaran');
      return;
    }

    setState(() => isSaving = true);

    try {
      // Simpan tanggal pilihan pada tengah hari lokal,
      // lalu konversi ke UTC untuk kolom timestamptz.
      final transactionDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        12,
      ).toUtc();

      await supabase.from('transactions').insert({
        'user_id': user.id,
        'category_id':
            selectedType == 'expense' ? selectedCategoryId : null,
        'type': selectedType,
        'amount': amount,
        'method': selectedMethod,
        'note': noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        'occurred_at': transactionDate.toIso8601String(),
        'source': 'manual',
        'is_impulsive':
            selectedType == 'expense' ? isImpulsive : false,
      });

      // REFRESH HOME DASHBOARD
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadDashboard();
      }

      if (!mounted) return;

      Get.back();

      Get.snackbar(
        'Berhasil!',
        'Transaksi berhasil disimpan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primary,
        colorText: Colors.black,
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.black),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal menyimpan',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // INPUT DECORATION
  InputDecoration inputDecoration({
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF252525),
          width: 1.5,
        ),
      ),
    );
  }

  // FIELD LABEL
  Widget fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF35445A),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = selectedType == 'expense';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close, color: Colors.black54),
        ),
        title: const Text(
          'Catat Transaksi Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172238),
          ),
        ),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TRANSACTION TYPE
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF3F8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: typeButton(
                                title: 'Pengeluaran',
                                value: 'expense',
                                icon: Icons.south_east,
                                activeColor: const Color(0xFFE53955),
                              ),
                            ),
                            Expanded(
                              child: typeButton(
                                title: 'Uang Masuk / Kiriman',
                                value: 'income',
                                icon: Icons.north_east,
                                activeColor: const Color(0xFF159B73),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // AMOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          fieldLabel('Nominal (Rp)'),
                          if (isExpense)
                            TextButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Foto Struk AI',
                                  'Fitur scan struk akan ditambahkan berikutnya.',
                                );
                              },
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 17,
                              ),
                              label: const Text('Foto Struk (AI)'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF159B73),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                      ),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: inputDecoration(
                          hint: '0',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),
                            child: Center(
                              widthFactor: 0,
                              child: Text(
                                'Rp',
                                style: TextStyle(
                                  color: Color(0xFF91A0B4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nominal wajib diisi';
                          }

                          if ((int.tryParse(value) ?? 0) <= 0) {
                            return 'Nominal harus lebih dari 0';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // DESCRIPTION
                      fieldLabel('Keterangan / Beli Apa'),
                      TextFormField(
                        controller: noteController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDecoration(
                          hint: isExpense
                              ? 'Contoh: Nasi padang, bensin motor, kopi nugas'
                              : 'Contoh: Kiriman ortu, beasiswa, side gig',
                        ),
                      ),

                      // CATEGORY
                      if (isExpense) ...[
                        const SizedBox(height: 20),
                        fieldLabel('Pilih Pos Anggaran'),
                        DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          decoration: inputDecoration(
                            hint: isLoadingCategories
                                ? 'Memuat kategori...'
                                : 'Pilih kategori',
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: (category['id'] as num).toInt(),
                              child: Text(
                                category['name'].toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: isLoadingCategories
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedCategoryId = value;
                                  });
                                },
                          validator: (value) {
                            if (isLoadingCategories) return null;
                            if (categories.isNotEmpty && value == null) {
                              return 'Pilih pos anggaran';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 20),

                      // PAYMENT METHOD AND DATE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fieldLabel('Metode Bayar'),
                                DropdownButtonFormField<String>(
                                  value: selectedMethod,
                                  isExpanded: true,
                                  decoration: inputDecoration(),
                                  items: paymentMethods.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method['value'],
                                      child: Text(
                                        method['label']!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedMethod = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fieldLabel('Tanggal'),
                                InkWell(
                                  onTap: pickDate,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F9FB),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFDCE5EF),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // IMPULSIVE EXPENSE
                      if (isExpense) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFCF0),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFFFE18A),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isImpulsive,
                                activeColor: const Color(0xFFE58A22),
                                onChanged: (value) {
                                  setState(() {
                                    isImpulsive = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isImpulsive = !isImpulsive;
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Color(0xFFE58A22),
                                            size: 19,
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              'Tandai sebagai pengeluaran di luar rencana / dadakan',
                                              style: TextStyle(
                                                color: Color(0xFF9B4C13),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Bantu melacak berapa rupiah yang bocor halus akibat jajan impulsif atau agenda mendadak bulan ini.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.4,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // SAVE BUTTON
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFEDF0F4)),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF53677F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF101B31),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF101B31),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan Transaksi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TRANSACTION TYPE BUTTON
  Widget typeButton({
    required String title,
    required String value,
    required IconData icon,
    required Color activeColor,
  }) {
    final selected = selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = value;
          if (value == 'income') {
            isImpulsive = false;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? activeColor : const Color(0xFF718198),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? activeColor : const Color(0xFF718198),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
