
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/history_general_controller.dart';
import '../widgets/history_filter.dart';
import '../widgets/history_month_selector.dart';
import '../widgets/history_transaction_card.dart';

class HistoryGeneralScreen extends StatelessWidget {
  HistoryGeneralScreen({super.key});

  final HistoryGeneralController controller =
      Get.put(HistoryGeneralController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF292525),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildMonthSelector(),
            const SizedBox(height: 25),
            Expanded(
              child: _buildHistoryContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: controller.exportCsv,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 19,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 9),
                      Icon(
                        Icons.download,
                        size: 19,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Obx(
            () => Align(
              alignment: Alignment.centerLeft,
              child: HistoryFilter(
                methods: controller.methods,
                dates: controller.dateOptions,
                selectedMethod: controller.selectedMethod.value,
                selectedDate: controller.selectedDate.value,
                onMethodChanged: controller.changeMethod,
                onDateChanged: controller.changeDate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(
        () => HistoryMonthSelector(
          monthTitle: controller.monthTitle,
          onPrevious: () => controller.changeMonth(-1),
          onNext: () => controller.changeMonth(1),
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFEFE),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(48),
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFC4E600),
            ),
          );
        }

        final groups = controller.groupedTransactions;
        final dates = groups.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        if (dates.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: const Color(0xFFC4E600),
          onRefresh: controller.fetchTransactions,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 27, 24, 35),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final items = groups[date]!;

              return _buildDateGroup(date, items);
            },
          ),
        );
      }),
    );
  }

  Widget _buildDateGroup(date, items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 14,
            top: 4,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: controller.formatGroupDate(date).split(' ').first,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: controller.formatGroupDate(date).substring(
                        controller.formatGroupDate(date).indexOf(' ') + 1,
                      ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...items.map(
          (transaction) => HistoryTransactionCard(
            transaction: transaction,
          ),
        ),
        const SizedBox(height: 13),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 65,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 15),
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your transactions will appear here.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
