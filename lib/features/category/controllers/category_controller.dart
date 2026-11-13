
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  final categories = <Map<String, dynamic>>[].obs;
  final budgets = <Map<String, dynamic>>[].obs;

  final expenses = <int, int>{}.obs;

  final isLoading = false.obs;
  final searchQuery = ''.obs;

  String get userId {
    final id = supabase.auth.currentUser?.id;
    if (id == null) {
      throw Exception('User belum login');
    }
    return id;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  int get totalAllocation {
    return categories.fold<int>(
      0,
      (sum, item) => sum + _toInt(item['allocation']),
    );
  }

  int get totalSpent {
    return expenses.values.fold<int>(
      0,
      (sum, amount) => sum + amount,
    );
  }

  List<Map<String, dynamic>> get filteredCategories {
    final query = searchQuery.value.toLowerCase();

    return categories.where((category) {
      final name =
          (category['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  int getAllocation(int categoryId) {
    final category = categories.firstWhereOrNull(
      (item) => _toInt(item['id']) == categoryId,
    );

    return _toInt(category?['allocation']);
  }

  int getSpent(int categoryId) {
    return expenses[categoryId] ?? 0;
  }

  int getRemaining(int categoryId) {
    return getAllocation(categoryId) - getSpent(categoryId);
  }

  double getPercentage(int categoryId) {
    if (totalAllocation <= 0) return 0;

    return getAllocation(categoryId) /
        totalAllocation *
        100;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // ==========================================
  // FETCH KATEGORI, BUDGET, DAN TRANSAKSI
  // SEMUA PERIODE DIJUMLAHKAN
  // ==========================================

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        supabase
            .from('categories')
            .select()
            .eq('user_id', userId)
            .order('sort_order', ascending: true),

        supabase
            .from('budgets')
            .select('category_id, amount')
            .eq('user_id', userId),

        supabase
            .from('transactions')
            .select('category_id, amount, type')
            .eq('user_id', userId),
      ]);

      final categoryRows =
          List<Map<String, dynamic>>.from(results[0]);

      final budgetRows =
          List<Map<String, dynamic>>.from(results[1]);

      final transactionRows =
          List<Map<String, dynamic>>.from(results[2]);

      budgets.assignAll(budgetRows);

      // Jumlahkan seluruh alokasi berdasarkan category_id.
      final allocationMap = <int, int>{};

      for (final budget in budgetRows) {
        final categoryId = _toInt(budget['category_id']);
        final amount = _toInt(budget['amount']);

        if (categoryId == 0) continue;

        allocationMap[categoryId] =
            (allocationMap[categoryId] ?? 0) + amount;
      }

      // Jumlahkan seluruh transaksi pengeluaran.
      final expenseMap = <int, int>{};

      for (final transaction in transactionRows) {
        final type = (transaction['type'] ?? '')
            .toString()
            .toLowerCase()
            .trim();

        final isExpense = [
          'expense',
          'pengeluaran',
          'out',
          'keluar',
        ].contains(type);

        if (!isExpense) continue;

        final categoryId =
            _toInt(transaction['category_id']);

        final amount = _toInt(transaction['amount']);

        if (categoryId == 0) continue;

        expenseMap[categoryId] =
            (expenseMap[categoryId] ?? 0) + amount;
      }

      expenses.assignAll(expenseMap);
      
      final totalBudget = allocationMap.values.fold<int>(
        0,
        (sum, amount) => sum + amount,
      );

      // Gabungkan data alokasi dan pengeluaran ke kategori.
      final visibleCategories = categoryRows.where((category) {
        final archived = category['is_archived'] == true;
        final archive = category['is_archive'] == true;

        return !archived && !archive;
      }).map((category) {
        final id = _toInt(category['id']);

        return {
          ...category,
          'allocation': allocationMap[id] ?? 0,
          'spent': expenseMap[id] ?? 0,
          'remaining':
              (allocationMap[id] ?? 0) - (expenseMap[id] ?? 0),
          'percentage': totalBudget > 0
              ? ((allocationMap[id] ?? 0) / totalBudget * 100).round()
              : 0,
        };
      }).toList();

      categories.assignAll(visibleCategories);

      debugPrint('TOTAL KATEGORI: ${categories.length}');
      debugPrint('TOTAL ALOKASI: $totalAllocation');
      debugPrint('TOTAL PENGELUARAN: $totalSpent');
    } catch (e, stack) {
      debugPrint('FETCH CATEGORY ERROR: $e');
      debugPrint('$stack');

      Get.snackbar(
        'Error',
        'Gagal mengambil kategori: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // TAMBAH KATEGORI + ALOKASI
  // ==========================================

  Future<bool> addCategory({
    required String name,
    required String icon,
    required String color,
    required bool isImpulsive,
    int allocation = 0,
  }) async {
    try {
      final categoryName = name.trim();

      if (categoryName.isEmpty) {
        Get.snackbar('Perhatian', 'Nama kategori wajib diisi');
        return false;
      }

      if (allocation < 0) {
        Get.snackbar('Perhatian', 'Alokasi tidak boleh negatif');
        return false;
      }

      final inserted = await supabase
          .from('categories')
          .insert({
            'user_id': userId,
            'name': categoryName,
            'icon': icon,
            'color': color,
            'is_impulsive': isImpulsive,
            'is_default': false,
            'is_archive': false,
            'is_archived': false,
          })
          .select('id')
          .single();

      final categoryId = _toInt(inserted['id']);

      // Simpan budget hanya jika alokasi lebih dari 0.
      if (allocation > 0) {
        await supabase.from('budgets').insert({
          'user_id': userId,
          'category_id': categoryId,
          'amount': allocation,
          'is_impulsive_group': isImpulsive,
          'period_id': null,
        });
      }

      await fetchCategories();

      Get.snackbar(
        'Berhasil',
        'Kategori berhasil ditambahkan',
      );

      return true;
    } on PostgrestException catch (e) {
      debugPrint('ADD CATEGORY ERROR: ${e.message}');

      Get.snackbar(
        'Gagal',
        e.message,
      );

      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  // ==========================================
  // TAMBAH ALOKASI KE KATEGORI YANG SUDAH ADA
  // ==========================================

  Future<bool> addAllocation({
    required int categoryId,
    required int amount,
    required bool isImpulsive,
  }) async {
    try {
      if (amount <= 0) {
        Get.snackbar('Perhatian', 'Masukkan nominal alokasi');
        return false;
      }

      await supabase.from('budgets').insert({
        'user_id': userId,
        'category_id': categoryId,
        'amount': amount,
        'is_impulsive_group': isImpulsive,
        'period_id': null,
      });

      await fetchCategories();

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan alokasi: $e');
      return false;
    }
  }

  // ==========================================
  // HAPUS KATEGORI
  // ==========================================

  Future<void> deleteCategory(Map<String, dynamic> category) async {
    try {
      final categoryId = category['id'];

      if (categoryId == null) {
        throw Exception('Category ID tidak ditemukan');
      }

      isLoading.value = true;

      final result = await supabase
          .from('categories')
          .update({
            'is_archive': true,
            'is_archived': true,
          })
          .eq('id', categoryId)
          .select('id');

      if (result.isEmpty) {
        throw Exception(
          'Kategori tidak terhapus. Periksa RLS Supabase atau kepemilikan kategori.',
        );
      }

      await fetchCategories();

      Get.snackbar(
        'Berhasil',
        'Kategori berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('DELETE CATEGORY ERROR: $e');

      Get.snackbar(
        'Gagal Menghapus',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
