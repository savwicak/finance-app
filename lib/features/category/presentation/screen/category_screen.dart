import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/category/presentation/widgets/category_card.dart';

import '../../controllers/category_controller.dart';
import 'add_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final CategoryController controller;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = Get.put(CategoryController());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // DELETE CATEGORY
  Future<void> _confirmDeleteCategory(
    BuildContext context,
    Map<String, dynamic> category,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Yakin ingin menghapus "${category['name']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteCategory(category);
    }
  }

  // ADD CATEGORY
  Future<void> _openAddCategory() async {
    final result = await Get.to<bool>(
      () => const AddCategoryScreen(),
    );

    if (!mounted) return;

    if (result == true) {
      await controller.fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // TITLE
            const Center(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SEARCH + ADD
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    onPressed: _openAddCategory,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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

            const SizedBox(height: 24),

            // CATEGORY LIST
            Expanded(
              child: Obx(() {
                final items = controller.filteredCategories;

                if (controller.isLoading.value && items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.isNotEmpty
                          ? 'Kategori tidak ditemukan'
                          : 'Belum ada kategori',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchCategories,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final category = items[index];

                      return CategoryCard(
                        key: ValueKey(category['id']),
                        category: category,
                        onTap: () {
                          // Buka detail kategori jika diperlukan.
                        },
                        onDelete: () {
                          _confirmDeleteCategory(
                            context,
                            category,
                          );
                        },
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