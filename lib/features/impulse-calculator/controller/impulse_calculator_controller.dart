
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nvidiaapp/features/home/controllers/home_controller.dart';

class ImpulseCalculatorController extends GetxController {
  final supabase = Supabase.instance.client;

  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = Rxn<int>();

  final name = ''.obs;
  final price = 0.obs;
  final isOutOfPlan = true.obs;

  final isSaving = false.obs;

  final balanceRemaining = 0.obs;
  final dailyFunds = 0.obs;
  final moneyDurability = 0.0.obs;
  final budgetRemainingAfterPurchase = 0.obs;

  DateTime? periodStart;
  DateTime? periodEnd;

  HomeController get homeController => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchPeriod();
  }

  Future<void> fetchCategories() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('categories')
          .select('id, name')
          .eq('user_id', userId)
          .eq('is_archive', false)
          .order('sort_order');

      categories.assignAll(
        List<Map<String, dynamic>>.from(response),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil kategori: $e');
    }
  }

  Future<void> fetchPeriod() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final today = DateTime.now();
      final date = today.toIso8601String().split('T')[0];

      final response = await supabase
          .from('periods')
          .select('id, start_date, end_date')
          .eq('user_id', userId)
          .lte('start_date', date)
          .gte('end_date', date)
          .order('start_date', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        periodStart = DateTime.parse(response.first['start_date']);
        periodEnd = DateTime.parse(response.first['end_date']);
      }

      calculate();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil periode: $e');
    }
  }

  void updateName(String value) {
    name.value = value;
  }

  void updatePrice(String value) {
    price.value = int.tryParse(
          value.replaceAll('.', '').replaceAll(',', '').trim(),
        ) ??
        0;
    calculate();
  }

  void updateCategory(int? value) {
    selectedCategoryId.value = value;
  }

  void updateOutOfPlan(bool value) {
    isOutOfPlan.value = value;
    calculate();
  }

  void calculate() {
    final summary = homeController.summary.value;

    if (summary == null) return;

    final currentBalance = summary.balance;
    final remainingBudget = summary.remainingBudget;

    // Saldo setelah pembelian.
    balanceRemaining.value = currentBalance - price.value;

    // Anggaran tersisa setelah simulasi pembelian.
    budgetRemainingAfterPurchase.value = isOutOfPlan.value
        ? remainingBudget
        : remainingBudget - price.value;

    // Hitung sisa hari periode aktif.
    final today = DateTime.now();

    int remainingDays;

    if (periodEnd != null) {
      final end = DateTime(
        periodEnd!.year,
        periodEnd!.month,
        periodEnd!.day,
      );

      final current = DateTime(today.year, today.month, today.day);

      remainingDays = end.difference(current).inDays + 1;
      if (remainingDays < 1) remainingDays = 1;
    } else {
      // Fallback jika belum ada periode aktif.
      final lastDay = DateTime(today.year, today.month + 1, 0).day;
      remainingDays = lastDay - today.day + 1;
    }

    dailyFunds.value =
        (budgetRemainingAfterPurchase.value / remainingDays).floor();

    // Hitung rata-rata pengeluaran harian aktual.
    final firstDay = DateTime(today.year, today.month, 1);
    final elapsedDays = today.difference(firstDay).inDays + 1;

    final averageDailyExpense =
        summary.monthlyExpense / elapsedDays;

    if (averageDailyExpense > 0) {
      moneyDurability.value =
          balanceRemaining.value / averageDailyExpense;
    } else {
      moneyDurability.value = 0;
    }
  }

  Future<void> buyAnyway() async {
    if (name.value.trim().isEmpty) {
      Get.snackbar('Input belum lengkap', 'Masukkan nama barang.');
      return;
    }

    if (price.value <= 0) {
      Get.snackbar('Input belum lengkap', 'Masukkan harga barang.');
      return;
    }

    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      Get.snackbar('Error', 'Silakan login terlebih dahulu.');
      return;
    }

    isSaving.value = true;

    try {
      await supabase.from('transactions').insert({
        'user_id': userId,
        'category_id': selectedCategoryId.value,
        'type': 'expense',
        'amount': price.value,
        'method': 'manual',
        'note': name.value.trim(),
        'occurred_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'manual',
      });

      // Ambil data Home terbaru setelah transaksi tersimpan.
      await homeController.loadDashboard();

      calculate();

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Transaksi berhasil ditambahkan.',
      );
    } catch (e) {
      Get.snackbar('Gagal menyimpan transaksi', e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
