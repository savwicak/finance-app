
class CategoryModel {
  final String? id;
  final String userId;
  final String name;
  final String icon;
  final String color;
  final bool isImpulsive;
  final bool isDefault;
  final bool isArchive;
  final int sortOrder;

  CategoryModel({
    this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    this.isImpulsive = false,
    this.isDefault = false,
    this.isArchive = false,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'category',
      color: json['color'] ?? '#B8E600',
      isImpulsive: json['is_impulsive'] ?? false,
      isDefault: json['is_default'] ?? false,
      isArchive: json['is_archive'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_impulsive': isImpulsive,
      'is_default': isDefault,
      'is_archive': isArchive,
      'sort_order': sortOrder,
    };
  }
}
