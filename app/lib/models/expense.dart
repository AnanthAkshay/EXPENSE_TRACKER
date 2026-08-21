class ExpenseModel {
  final int? id;
  final int userId;
  final int categoryId;
  final int? paymentMethodId;
  final double amount;
  final String expenseDate;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  // Presentation fields
  final String? categoryName;
  final String? categoryIconKey;
  final String? categoryColorHex;
  final String? paymentMethodName;
  final bool isPendingSync;

  ExpenseModel({
    this.id,
    required this.userId,
    required this.categoryId,
    this.paymentMethodId,
    required this.amount,
    required this.expenseDate,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryIconKey,
    this.categoryColorHex,
    this.paymentMethodName,
    this.isPendingSync = false,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      categoryId: (json['categoryId'] as num).toInt(),
      paymentMethodId: (json['paymentMethodId'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      expenseDate: json['expenseDate'] as String,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryIconKey: json['categoryIconKey'] as String?,
      categoryColorHex: json['categoryColorHex'] as String?,
      paymentMethodName: json['paymentMethodName'] as String?,
      isPendingSync: json['isPendingSync'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'categoryId': categoryId,
      if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      'amount': amount,
      'expenseDate': expenseDate,
      if (note != null) 'note': note,
    };
  }
}
