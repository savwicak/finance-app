
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../services/financial_insight_service.dart';
import '../services/paypal_checkout_service.dart';

class HomeController extends GetxController {
  HomeController({
    DashboardService? dashboardService,
    FinancialInsightService? insightService,
    PayPalCheckoutService? paypalService,
  })  : _dashboardService = dashboardService ?? DashboardService(),
        _insightService = insightService ?? FinancialInsightService(),
        _paypalService = paypalService ?? PayPalCheckoutService();

  final DashboardService _dashboardService;
  final FinancialInsightService _insightService;
  final PayPalCheckoutService _paypalService;

  final isLoading = true.obs;
  final isDepositing = false.obs;
  final isDeletingGoal = false.obs;
  final errorMessage = ''.obs;
  final insight = 'Menyiapkan insight keuanganmu...'.obs;
  final summary = Rxn<DashboardSummary>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _dashboardService.fetchSummary();

      summary.value = data;
      insight.value =
          await _insightService.getInsight(data.transactions);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> quickDeposit({
    required String goalId,
    required int amount,
  }) async {
    try {
      isDepositing.value = true;

      await _paypalService.createDepositOrder(
        amount: amount,
        goalId: goalId,
      );

      Get.snackbar(
        'PayPal Checkout dibuka',
        'Selesaikan pembayaran di halaman PayPal Sandbox. Setelah kembali, verifikasi dan capture order dari aplikasi.',
      );
    } catch (e) {
      Get.snackbar('Deposit gagal', e.toString());
    } finally {
      isDepositing.value = false;
    }
  }

  // DELETE SAVING GOAL
  Future<void> deleteGoal(String goalId) async {
  if (isDeletingGoal.value) return;

  try {
    isDeletingGoal.value = true;

    await _dashboardService.deleteGoal(goalId: goalId);
    await loadDashboard();

    Get.snackbar(
      'Success!',
      'Saving goal berhasil dihapus!',
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
      'Failed!',
      'Saving goal gagal dihapus!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  } finally {
    isDeletingGoal.value = false;
  }
}}