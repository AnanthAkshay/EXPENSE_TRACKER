class InsightModel {
  final String key;
  final String title;
  final String message;
  final double surpriseScore;

  InsightModel({
    required this.key,
    required this.title,
    required this.message,
    required this.surpriseScore,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      key: json['key'] as String? ?? 'INSIGHT',
      title: json['title'] as String? ?? 'Insight',
      message: json['message'] as String? ?? '',
      surpriseScore: (json['surpriseScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
