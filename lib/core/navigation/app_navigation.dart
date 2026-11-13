
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/app_routes.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';

class AppNavigationController extends GetxController {
  final selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class AppNavigation extends StatelessWidget {
  AppNavigation({super.key});

  final AppNavigationController controller =
      Get.put(AppNavigationController());

  final List<Widget> pages = [
    Routes.pages.firstWhere((page) => page.name == Routes.home).page(),
    Routes.pages.firstWhere((page) => page.name == Routes.historyGeneral).page(),
    Routes.pages.firstWhere((page) => page.name == Routes.category).page(),
    Routes.pages.firstWhere((page) => page.name == Routes.wishlist).page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 85,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                    ),
                    _navItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long_rounded,
                      label: 'History',
                      index: 1,
                    ),
                    const SizedBox(width: 65),
                    _navItem(
                      icon: Icons.category_outlined,
                      activeIcon: Icons.category_rounded,
                      label: 'Category',
                      index: 2,
                    ),
                    _navItem(
                      icon: Icons.favorite_border_rounded,
                      activeIcon: Icons.favorite_rounded,
                      label: 'Wishlist',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Floating Add Button
            Positioned(
              top: -10,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.impulsiveCalculator);
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;

        return InkWell(
          onTap: () => controller.changeTab(index),
          child: SizedBox(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppTheme.primary : Colors.grey,
                  size: 23,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
