class PaymentMethodModel {
  final int id;
  final int userId;
  final String name;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      name: json['name'] as String,
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'isDefault': isDefault,
    };
  }
}
