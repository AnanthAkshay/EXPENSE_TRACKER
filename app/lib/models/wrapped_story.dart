class WrappedStoryModel {
  final String monthYear;
  final bool sufficientData;
  final bool isCurrentMonth;
  final int totalTransactions;
  final double totalSpend;
  
  final String? topCategoryName;
  final double? topCategoryAmount;
  final double topCategoryPercentage;
  
  final double weekendVsWeekdayDeltaPct;
  final bool weekendSpentMore;
  
  final String? peakDate;
  final double? peakAmount;
  final int peakTransactionCount;
  
  final String? mostFrequentExpenseName;
  final int mostFrequentCount;
  
  final double? momDeltaAmount;
  final bool spentLessMoM;
  
  final double? projectedNextMonthSpend;
  
  final String personalityTag;
  final String personalityDescription;

  WrappedStoryModel({
    required this.monthYear,
    required this.sufficientData,
    required this.isCurrentMonth,
    required this.totalTransactions,
    required this.totalSpend,
    this.topCategoryName,
    this.topCategoryAmount,
    required this.topCategoryPercentage,
    required this.weekendVsWeekdayDeltaPct,
    required this.weekendSpentMore,
    this.peakDate,
    this.peakAmount,
    required this.peakTransactionCount,
    this.mostFrequentExpenseName,
    required this.mostFrequentCount,
    this.momDeltaAmount,
    required this.spentLessMoM,
    this.projectedNextMonthSpend,
    required this.personalityTag,
    required this.personalityDescription,
  });

  factory WrappedStoryModel.fromJson(Map<String, dynamic> json) {
    return WrappedStoryModel(
      monthYear: json['monthYear'] as String? ?? '',
      sufficientData: json['sufficientData'] == true,
      isCurrentMonth: json['isCurrentMonth'] == true,
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      totalSpend: (json['totalSpend'] as num?)?.toDouble() ?? 0.0,
      topCategoryName: json['topCategoryName'] as String?,
      topCategoryAmount: (json['topCategoryAmount'] as num?)?.toDouble(),
      topCategoryPercentage: (json['topCategoryPercentage'] as num?)?.toDouble() ?? 0.0,
      weekendVsWeekdayDeltaPct: (json['weekendVsWeekdayDeltaPct'] as num?)?.toDouble() ?? 0.0,
      weekendSpentMore: json['weekendSpentMore'] == true,
      peakDate: json['peakDate'] as String?,
      peakAmount: (json['peakAmount'] as num?)?.toDouble(),
      peakTransactionCount: (json['peakTransactionCount'] as num?)?.toInt() ?? 0,
      mostFrequentExpenseName: json['mostFrequentExpenseName'] as String?,
      mostFrequentCount: (json['mostFrequentCount'] as num?)?.toInt() ?? 0,
      momDeltaAmount: (json['momDeltaAmount'] as num?)?.toDouble(),
      spentLessMoM: json['spentLessMoM'] == true,
      projectedNextMonthSpend: (json['projectedNextMonthSpend'] as num?)?.toDouble(),
      personalityTag: json['personalityTag'] as String? ?? 'The Steady Tracker',
      personalityDescription: json['personalityDescription'] as String? ?? 'Consistent and mindful tracking habits.',
    );
  }
}
