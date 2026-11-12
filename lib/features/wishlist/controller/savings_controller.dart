
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/savings_goal_model.dart';
import '../models/savings_entry_model.dart';

class SavingsController extends GetxController {
  final supabase = Supabase.instance.client;

  final goals = <SavingsGoalModel>[].obs;
  final entries = <SavingsEntryModel>[].obs;

  final isLoading = false.obs;

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    return user.id;
  }

  int get totalSavings {
    return entries.fold(0, (sum, entry) => sum + entry.amount);
  }

  int totalSavedForGoal(int goalId) {
    return entries
        .where((entry) => entry.goalId == goalId)
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  @override
  void onInit() {
    super.onInit();
    fetchGoals();
  }

  // GET ALL GOALS
  Future<void> fetchGoals() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('savings_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      goals.assignAll(
        response.map((e) => SavingsGoalModel.fromMap(e)).toList(),
      );

      await fetchEntries();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data tabungan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // GET ALL ENTRIES
  Future<void> fetchEntries() async {
    try {
      final response = await supabase
          .from('savings_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      entries.assignAll(
        response.map((e) => SavingsEntryModel.fromMap(e)).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil riwayat tabungan: $e');
    }
  }

  // ADD GOAL
  Future<bool> addGoal({
    required String name,
    required int targetAmount,
    DateTime? dueDate,
  }) async {
    try {
      if (name.trim().isEmpty || targetAmount <= 0) {
        Get.snackbar('Error', 'Nama dan target tabungan harus valid');
        return false;
      }

      await supabase.from('savings_goals').insert({
        'user_id': userId,
        'name': name.trim(),
        'target_amount': targetAmount,
        'due_date': dueDate?.toIso8601String().split('T').first,
      });

      await fetchGoals();

      Get.snackbar('Berhasil', 'Target tabungan berhasil ditambahkan');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan target: $e');
      return false;
    }
  }

  // ADD SAVINGS ENTRY
  Future<bool> addEntry({
    required int goalId,
    required int amount,
    int? periodId,
    String? note,
  }) async {
    try {
      if (amount <= 0) {
        Get.snackbar('Error', 'Nominal harus lebih dari 0');
        return false;
      }

      await supabase.from('savings_entries').insert({
        'user_id': userId,
        'goal_id': goalId,
        'period_id': periodId,
        'amount': amount,
        'note': note,
      });

      await fetchEntries();

      Get.snackbar('Berhasil', 'Tabungan berhasil ditambahkan');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan tabungan: $e');
      return false;
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Hapus riwayat tabungan terlebih dahulu
      await supabase
          .from('savings_entries')
          .delete()
          .eq('goal_id', goalId)
          .eq('user_id', userId);

      // Hapus target tabungan
      await supabase
          .from('savings_goals')
          .delete()
          .eq('id', goalId)
          .eq('user_id', userId);

      await fetchGoals();

      Get.snackbar(
        'Berhasil',
        'Target tabungan berhasil dihapus',
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menghapus target: $e',
      );
    }
  }
}
