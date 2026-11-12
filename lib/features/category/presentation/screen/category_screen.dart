
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/features/category/presentation/widgets/category_card.dart';
import '../../controllers/category_controller.dart';
import 'add_category_screen.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final CategoryController controller = Get.put(CategoryController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        controller.searchQuery.value = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Find category...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF8F6F7),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5ED),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5ED),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Get.to(
                        () => AddCategoryScreen(),
                      );

                      if (result == true) {
                        controller.fetchCategories();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8E600),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final items = controller.filteredCategories;

                if (items.isEmpty) {
                  return const Center(
                    child: Text('Belum ada kategori'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchCategories,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final category = items[index];

                      return Slidable(
                        key: ValueKey(category['id']),
                        enabled: category['is_default'] != true,
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          extentRatio: 0.28,
                          children: [
                            SlidableAction(
                              onPressed: (_) async {
                                final confirm = await Get.dialog<bool>(
                                  AlertDialog(
                                    title: const Text('Delete Category?'),
                                    content: Text(
                                      'Yakin ingin menghapus "${category['name']}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(result: false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Get.back(result: true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await controller.deleteCategory(category);
                                }
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ],
                        ),
                        child: CategoryCard(category: category),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
