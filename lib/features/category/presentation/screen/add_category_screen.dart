
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final CategoryController controller = Get.find<CategoryController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  String selectedIcon = 'restaurant';
  String selectedColor = '#B8E600';

  bool isImpulsive = false;
  bool isSaving = false;

  final Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant,
    'shopping_bag': Icons.shopping_bag,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'movie': Icons.movie,
    'payments': Icons.payments,
    'pets': Icons.pets,
    'sports': Icons.sports,
    'category': Icons.category,
  };

  final List<String> availableColors = [
    '#B8E600',
    '#FF8A65',
    '#64B5F6',
    '#BA68C8',
    '#FFD54F',
    '#4DB6AC',
    '#F06292',
    '#78909C',
  ];

  // CONVERT HEX TO COLOR
  Color getColor(String hex) {
    return Color(
      int.parse('FF${hex.replaceAll('#', '')}', radix: 16),
    );
  }

  // SAVE CATEGORY
  Future<void> saveCategory() async {
    if (isSaving) return;

    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final success = await controller.addCategory(
      name: nameController.text,
      icon: selectedIcon,
      color: selectedColor,
      isImpulsive: isImpulsive,
    );

    if (!mounted) return;

    setState(() => isSaving = false);

    if (success) {
      Get.offNamed('/category');

      Get.snackbar(
        'Success!',
        'Kategori berhasil ditambahkan!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFB8E600),
        colorText: Colors.black,
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(
          Icons.check_circle,
          color: Colors.black,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Add Category',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // CATEGORY NAME
              const Text(
                'Category Name',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Example: Food & Drink',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5ED),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // CHOOSE ICON
              const Text(
                'Choose Icon',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableIcons.entries.map((entry) {
                  final selected = selectedIcon == entry.key;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIcon = entry.key);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected
                            ? getColor(selectedColor)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? Colors.black
                              : const Color(0xFFE5E5ED),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              // CHOOSE COLOR
              const Text(
                'Choose Color',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 13,
                runSpacing: 13,
                children: availableColors.map((color) {
                  final selected = selectedColor == color;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedColor = color);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: getColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.black,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              // IMPULSIVE CATEGORY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E5ED),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Impulsive Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Tandai kategori untuk pengeluaran impulsif',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeTrackColor: const Color(0xFFB8E600),
                  value: isImpulsive,
                  onChanged: (value) {
                    setState(() => isImpulsive = value);
                  },
                ),
              ),

              const SizedBox(height: 35),

              // SAVE BUTTON
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8E600),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFB8E600),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
