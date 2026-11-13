import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nvidiaapp/features/home/controllers/home_controller.dart';

class ImpulseCalculatorController extends GetxController {
  final supabase = Supabase.instance.client;

  // CATEGORY
  final categories = <Map<String, dynamic>>[].obs;

  // WISHLIST
  final wishlist = <Map<String, dynamic>>[].obs;
  final selectedWishlistId = Rxn<int>();
  final selectedCategoryId = Rxn<int>();

  // ITEM
  final name = ''.obs;
  final price = 0.obs;
  final isOutOfPlan = true.obs;

  // LOADING
  final isSaving = false.obs;
  final isUpdatingCategory = false.obs;
  final isLoading = false.obs;

  // CALCULATION
  final balanceRemaining = 0.obs;
  final dailyFunds = 0.obs;
  final moneyDurability = 0.0.obs;
  final budgetRemainingAfterPurchase = 0.obs;
  // PAYMENT METHOD
  final selectedMethod = 'tunai'.obs;

  final paymentMethods = [
    {'label': 'Tunai', 'value': 'tunai'},
    {'label': 'QRIS', 'value': 'qris'},
    {'label': 'E-Wallet', 'value': 'ewallet'},
    {'label': 'Transfer', 'value': 'transfer'},
  ];

  HomeController get homeController => Get.find<HomeController>();

  Worker? _summaryWorker;

  String? get userId => supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();

    _summaryWorker = ever(
      homeController.summary,
      (_) => calculate(),
    );

    Future.microtask(() {
      loadInitialData();
    });
  }

  @override
  void onClose() {
    _summaryWorker?.dispose();
    super.onClose();
  }

  // LOAD INITIAL DATA
  Future<void> loadInitialData() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      if (userId == null) {
        Get.snackbar('Error', 'Silakan login terlebih dahulu.');
        return;
      }

      await homeController.loadDashboard();

      await Future.wait([
        fetchCategories(),
        fetchWishlist(),
      ]);

      calculate();
    } catch (e) {
      print('LOAD INITIAL DATA ERROR: $e');
      Get.snackbar('Error', 'Gagal memuat kalkulator: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // FETCH CATEGORY
  Future<void> fetchCategories() async {
    try {
      final uid = userId;
      if (uid == null) return;

      final response = await supabase
          .from('categories')
          .select('id, name, is_archive, is_archived')
          .eq('user_id', uid)
          .eq('is_archive', false)
          .eq('is_archived', false)
          .order('sort_order');

      categories.assignAll(
        List<Map<String, dynamic>>.from(response),
      );

      print('CATEGORY LOADED: ${categories.length}');
    } catch (e) {
      print('FETCH CATEGORY ERROR: $e');
      Get.snackbar('Error', 'Gagal mengambil kategori: $e');
    }
  }

  // CATEGORY NAME
  String get selectedCategoryName {
    final id = selectedCategoryId.value;

    if (id == null) return '-';

    for (final category in categories) {
      final categoryId = (category['id'] as num?)?.toInt();

      if (categoryId == id) {
        return category['name']?.toString() ?? '-';
      }
    }

    return '-';
  }

  // FETCH WISHLIST
  Future<void> fetchWishlist() async {
    try {
      final uid = userId;
      if (uid == null) return;

      final response = await supabase
          .from('savings_goals')
          .select(
            'id, name, target_amount, category_id, is_out_of_plan',
          )
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      wishlist.assignAll(
        List<Map<String, dynamic>>.from(response),
      );

      print('WISHLIST LOADED: ${wishlist.length}');
    } catch (e) {
      print('FETCH WISHLIST ERROR: $e');
      Get.snackbar('Error', 'Gagal mengambil Wishlist: $e');
    }
  }

  // SELECT WISHLIST
  void updateWishlist(int? value) {
    selectedWishlistId.value = value;

    if (value == null) {
      name.value = '';
      price.value = 0;
      selectedCategoryId.value = null;
      isOutOfPlan.value = true;

      calculate();
      return;
    }

    Map<String, dynamic>? selected;

    for (final item in wishlist) {
      if ((item['id'] as num?)?.toInt() == value) {
        selected = item;
        break;
      }
    }

    if (selected == null) return;

    name.value = selected['name']?.toString() ?? '';

    price.value =
        (selected['target_amount'] as num?)?.toInt() ?? 0;

    selectedCategoryId.value =
        (selected['category_id'] as num?)?.toInt();

    isOutOfPlan.value =
        selected['is_out_of_plan'] as bool? ?? true;

    calculate();

    print('SELECTED WISHLIST: ${name.value}');
    print('SELECTED CATEGORY: ${selectedCategoryId.value}');
  }

  // UPDATE CATEGORY
  Future<void> updateCategory(int? value) async {
    if (value == null) return;

    final wishlistId = selectedWishlistId.value;
    final uid = userId;

    if (wishlistId == null || uid == null) {
      Get.snackbar('Error', 'Pilih Wishlist terlebih dahulu.');
      return;
    }

    final categoryExists = categories.any(
      (item) => (item['id'] as num).toInt() == value,
    );

    if (!categoryExists) {
      Get.snackbar('Error', 'Kategori tidak ditemukan.');
      return;
    }

    isUpdatingCategory.value = true;

    try {
      await supabase
          .from('savings_goals')
          .update({'category_id': value})
          .eq('id', wishlistId)
          .eq('user_id', uid);

      selectedCategoryId.value = value;

      final index = wishlist.indexWhere(
        (item) => (item['id'] as num).toInt() == wishlistId,
      );

      if (index != -1) {
        wishlist[index]['category_id'] = value;
        wishlist.refresh();
      }

      calculate();

      Get.snackbar(
        'Berhasil',
        'Kategori berhasil disimpan ke Wishlist.',
      );

      print('CATEGORY UPDATED: $value');
    } catch (e) {
      print('UPDATE CATEGORY ERROR: $e');

      Get.snackbar(
        'Gagal',
        'Tidak dapat menyimpan kategori: $e',
      );
    } finally {
      isUpdatingCategory.value = false;
    }
  }

  // UPDATE OUT OF PLAN
  void updateOutOfPlan(bool value) {
    isOutOfPlan.value = value;
    calculate();
  }

  // CALCULATE
  void calculate() {
    final summary = homeController.summary.value;

    if (summary == null) {
      balanceRemaining.value = 0;
      dailyFunds.value = 0;
      moneyDurability.value = 0;
      budgetRemainingAfterPurchase.value = 0;
      return;
    }

    final currentBalance =
        (summary.balance as num).toInt();

    final remainingBudget =
        (summary.remainingBudget as num).toInt();

    final monthlyExpense =
        (summary.monthlyExpense as num).toDouble();

    final itemPrice = price.value;

    // BALANCE AFTER PURCHASE
    balanceRemaining.value = currentBalance - itemPrice;

    // BUDGET AFTER PURCHASE
    budgetRemainingAfterPurchase.value =
        isOutOfPlan.value
            ? remainingBudget
            : remainingBudget - itemPrice;

    // REMAINING DAYS UNTIL END OF MONTH
    final today = DateTime.now();

    final currentDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final lastDay = DateTime(
      today.year,
      today.month + 1,
      0,
    ).day;

    int remainingDays = lastDay - today.day + 1;

    if (remainingDays < 1) remainingDays = 1;

    // DAILY FUNDS
    dailyFunds.value = (
      budgetRemainingAfterPurchase.value / remainingDays
    ).floor();

    // AVERAGE DAILY EXPENSE
    final startDate = DateTime(
      today.year,
      today.month,
      1,
    );

    int elapsedDays =
        currentDate.difference(startDate).inDays + 1;

    if (elapsedDays < 1) elapsedDays = 1;

    final averageDailyExpense =
        monthlyExpense / elapsedDays;

    // MONEY DURABILITY
    if (averageDailyExpense > 0) {
      moneyDurability.value =
          balanceRemaining.value / averageDailyExpense;
    } else {
      moneyDurability.value = 0;
    }
  }

  // BUY ANYWAY
  Future<void> buyAnyway() async {
    if (selectedWishlistId.value == null) {
      Get.snackbar(
        'Input belum lengkap',
        'Pilih barang dari Wishlist terlebih dahulu.',
      );
      return;
    }

    if (price.value <= 0) {
      Get.snackbar(
        'Input belum lengkap',
        'Harga barang tidak valid.',
      );
      return;
    }

    if (selectedCategoryId.value == null) {
      Get.snackbar(
        'Input belum lengkap',
        'Pilih kategori barang terlebih dahulu.',
      );
      return;
    }

    final uid = userId;

    if (uid == null) {
      Get.snackbar('Error', 'Silakan login terlebih dahulu.');
      return;
    }

    if (isSaving.value) return;

    isSaving.value = true;

    try {
      await supabase.from('transactions').insert({
        'user_id': uid,
        'category_id': selectedCategoryId.value,
        'type': 'expense',
        'amount': price.value,
        'method': selectedMethod.value,
        'note': name.value.trim(),
        'occurred_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'manual',
      });

      await homeController.loadDashboard();

      calculate();

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Transaksi berhasil ditambahkan.',
      );
    } catch (e) {
      print('BUY ANYWAY ERROR: $e');

      Get.snackbar(
        'Gagal menyimpan transaksi',
        e.toString(),
        duration: const Duration(seconds: 8),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
