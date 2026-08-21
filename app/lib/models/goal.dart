class GoalModel {
  final int? id;
  final int userId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String? targetDate;
  final String? createdAt;
  final double suggestedMonthlyContribution;

  GoalModel({
    this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.targetDate,
    this.createdAt,
    required this.suggestedMonthlyContribution,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] as String?,
      createdAt: json['createdAt'] as String?,
      suggestedMonthlyContribution: (json['suggestedMonthlyContribution'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      if (targetDate != null) 'targetDate': targetDate,
    };
  }
}
