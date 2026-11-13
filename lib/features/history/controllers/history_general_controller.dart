
import 'dart:io';
// import 'package:cross_file/cross_file.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';
import '../repositories/history_general_repository.dart';

class HistoryGeneralController extends GetxController {
  final HistoryGeneralRepository repository = HistoryGeneralRepository();

  final transactions = <TransactionModel>[].obs;
  final isLoading = false.obs;

  final selectedMonth = DateTime.now().obs;
  final selectedMethod = 'All'.obs;
  final selectedDate = 'All'.obs;

  final List<String> dateOptions = [
    'All',
    'Today',
    'Yesterday',
    'This Week',
  ];

  @override
  void onReady() {
    super.onReady();
    fetchTransactions();
  }

  List<String> get methods {
    final values = transactions
        .map((item) => item.method)
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return ['All', ...values];
  }

  String get monthTitle {
    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    final month = selectedMonth.value;

    return '${months[month.month - 1]} ${month.year}';
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;

      final result = await repository.getTransactions(
        month: selectedMonth.value,
      );

      transactions.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(int offset) {
    final current = selectedMonth.value;

    selectedMonth.value = DateTime(
      current.year,
      current.month + offset,
      1,
    );

    fetchTransactions();
  }

  void changeMethod(String? value) {
    if (value != null) {
      selectedMethod.value = value;
    }
  }

  void changeDate(String? value) {
    if (value != null) {
      selectedDate.value = value;
    }
  }

  List<TransactionModel> get filteredTransactions {
    var result = transactions.toList();

    if (selectedMethod.value != 'All') {
      result = result
          .where((item) => item.method == selectedMethod.value)
          .toList();
    }

    final now = DateTime.now();

    if (selectedDate.value == 'Today') {
      result = result.where((item) {
        final date = item.occurredAt;

        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();
    }

    if (selectedDate.value == 'Yesterday') {
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      result = result.where((item) {
        final date = item.occurredAt;

        return date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;
      }).toList();
    }

    if (selectedDate.value == 'This Week') {
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));

      result = result.where((item) {
        return !item.occurredAt.isBefore(start);
      }).toList();
    }

    return result;
  }

  Map<DateTime, List<TransactionModel>> get groupedTransactions {
    final Map<DateTime, List<TransactionModel>> groups = {};

    for (final transaction in filteredTransactions) {
      final date = transaction.occurredAt;

      final key = DateTime(date.year, date.month, date.day);

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(transaction);
    }

    return groups;
  }

  String formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final prefix = date == today
        ? 'Today'
        : date == yesterday
            ? 'Yesterday'
            : DateFormat('EEEE', 'en_US').format(date);

    return '$prefix ${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return months[month - 1];
  }

  String formatAmount(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> exportCsv() async {
    try {
      final data = filteredTransactions;

      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada transaksi untuk diekspor');
        return;
      }

      final rows = <List<String>>[
        ['Date', 'Category', 'Merchant', 'Type', 'Method', 'Source', 'Amount', 'Note'],
      ];

      for (final item in data) {
        rows.add([
          item.occurredAt.toIso8601String(),
          item.categoryName ?? '',
          item.merchant ?? '',
          item.type,
          item.method,
          item.source,
          item.amount.toString(),
          item.note ?? '',
        ]);
      }

      String escapeCsv(String value) {
        return '"${value.replaceAll('"', '""')}"';
      }

      final csv = rows.map(
        (row) => row.map(escapeCsv).join(','),
      ).join('\n');

      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/history_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      await file.writeAsString(csv);

      // await SharePlus.instance.share(
      //   ShareParams(
      //     files: [XFile(file.path)],
      //     text: 'Finance Transaction History',
      //   ),
      // );
    } catch (e) {
      Get.snackbar('Error', 'Gagal export transaksi: $e');
    }
  }
}
