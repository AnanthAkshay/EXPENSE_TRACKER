class CategoryModel {
  final int id;
  final int userId;
  final String name;
  final String iconKey;
  final String colorHex;
  final bool isDefault;
  final bool isArchived;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.isDefault,
    required this.isArchived,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String? ?? 'tag',
      colorHex: json['colorHex'] as String? ?? '#4A90E2',
      isDefault: json['isDefault'] == true,
      isArchived: json['isArchived'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'iconKey': iconKey,
      'colorHex': colorHex,
      'isDefault': isDefault,
      'isArchived': isArchived,
    };
  }
}
