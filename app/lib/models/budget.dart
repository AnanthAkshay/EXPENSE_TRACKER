class OverallBudgetModel {
  final double amount;
  final double spent;
  final double remaining;
  final double pctUsed;
  final int daysLeft;
  final double projected;

  OverallBudgetModel({
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.pctUsed,
    required this.daysLeft,
    required this.projected,
  });

  factory OverallBudgetModel.fromJson(Map<String, dynamic> json) {
    return OverallBudgetModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      pctUsed: (json['pctUsed'] as num?)?.toDouble() ?? 0.0,
      daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
      projected: (json['projected'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryBudgetModel {
  final int categoryId;
  final String categoryName;
  final String categoryIconKey;
  final String categoryColorHex;
  final double amount;
  final double spent;
  final double remaining;
  final double pctUsed;

  CategoryBudgetModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconKey,
    required this.categoryColorHex,
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.pctUsed,
  });

  factory CategoryBudgetModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetModel(
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      categoryIconKey: json['categoryIconKey'] as String? ?? 'tag',
      categoryColorHex: json['categoryColorHex'] as String? ?? '#4A90E2',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      pctUsed: (json['pctUsed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BudgetOverviewModel {
  final OverallBudgetModel overall;
  final List<CategoryBudgetModel> categories;

  BudgetOverviewModel({
    required this.overall,
    required this.categories,
  });

  factory BudgetOverviewModel.fromJson(Map<String, dynamic> json) {
    return BudgetOverviewModel(
      overall: OverallBudgetModel.fromJson(json['overall'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryBudgetModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
