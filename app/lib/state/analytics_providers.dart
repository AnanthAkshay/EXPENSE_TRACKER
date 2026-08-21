import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_provider.dart';
import '../models/insight.dart';

final selectedTrendPeriodProvider = StateProvider<String>((ref) => 'month');
final selectedCalendarMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final trendsDataProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final period = ref.watch(selectedTrendPeriodProvider);
  return service.getTrends(period);
});

final calendarHeatmapProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final month = ref.watch(selectedCalendarMonthProvider);
  return service.getCalendarHeatmap(month);
});

final insightsListProvider = FutureProvider.autoDispose<List<InsightModel>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final month = ref.watch(selectedCalendarMonthProvider);
  return service.getInsights(month);
});
