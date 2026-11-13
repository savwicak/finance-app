
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  final categories = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  String get userId => supabase.auth.currentUser!.id;

  // FILTER CATEGORY
  List<Map<String, dynamic>> get filteredCategories {
    final query = searchQuery.value.toLowerCase();

    return categories.where((category) {
      final name = (category['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // FETCH CATEGORIES
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .eq('is_archive', false)
          .order('sort_order', ascending: true);

      categories.assignAll(
        List<Map<String, dynamic>>.from(response),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil kategori: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ADD CATEGORY
  Future<bool> addCategory({
    required String name,
    required String icon,
    required String color,
    required bool isImpulsive,
  }) async {
    try {
      final cleanName = name.trim();

      if (cleanName.isEmpty) {
        Get.snackbar('Error', 'Nama kategori tidak boleh kosong');
        return false;
      }

      // CHECK DUPLICATE
      final existing = await supabase
          .from('categories')
          .select('id')
          .eq('user_id', userId)
          .eq('name', cleanName)
          .eq('is_archive', false)
          .maybeSingle();

      if (existing != null) {
        Get.snackbar(
          'Kategori Sudah Ada',
          'Nama kategori "$cleanName" sudah digunakan.',
        );
        return false;
      }

      // NEXT SORT ORDER
      final nextOrder = categories.isEmpty
          ? 1
          : categories
                  .map((item) => (item['sort_order'] ?? 0) as int)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      // INSERT
      await supabase.from('categories').insert({
        'user_id': userId,
        'name': cleanName,
        'icon': icon,
        'color': color,
        'is_impulsive': isImpulsive,
        'is_default': false,
        'is_archive': false,
        'sort_order': nextOrder,
      });

      await fetchCategories();

      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        Get.snackbar(
          'Kategori Sudah Ada',
          'Kategori dengan nama tersebut sudah tersedia.',
        );
      } else {
        Get.snackbar('Error', 'Gagal menambahkan kategori: ${e.message}');
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan kategori: $e');
      return false;
    }
  }

  // DELETE CATEGORY (SOFT DELETE)
  Future<bool> deleteCategory(Map<String, dynamic> category) async {
    try {
      final id = category['id'];

      if (id == null) {
        Get.snackbar('Error', 'ID kategori tidak ditemukan');
        return false;
      }

      // PREVENT DELETE DEFAULT CATEGORY
      if (category['is_default'] == true) {
        Get.snackbar(
          'Tidak Bisa Dihapus',
          'Kategori default tidak dapat dihapus.',
        );
        return false;
      }

      // UPDATE SUPABASE
      await supabase
          .from('categories')
          .update({
            'is_archive': true,
          })
          .eq('id', id)
          .eq('user_id', userId);

      // REMOVE FROM LOCAL LIST
      categories.removeWhere(
        (item) => item['id'] == id,
      );

      Get.snackbar(
  'Success!',
  'Kategori berhasil dihapus!',
  snackPosition: SnackPosition.TOP,
  backgroundColor: AppTheme.primary,
  colorText: Colors.black,
  margin: const EdgeInsets.all(15),
  borderRadius: 12,
  duration: const Duration(seconds: 2),
  icon: const Icon(
    Icons.check_circle,
    color: Colors.black,
  ),
);

      return true;
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus kategori: ${e.message}',
      );
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
      return false;
    }
  }
}
