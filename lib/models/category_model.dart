class CategoryModel {
  final String id;
  final String storeCategoryId;
  final String name;
  final String icon;
  final String type;

  CategoryModel({
    required this.id,
    required this.storeCategoryId,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    final store = map['category_store'] ?? {};

    return CategoryModel(
      id: map['id'] ?? '',
      storeCategoryId: map['store_category_id'] ?? '',
      name: store['name'] ?? '',
      icon: store['icon'] ?? '',
      type: store['type'] ?? '',
    );
  }
}
