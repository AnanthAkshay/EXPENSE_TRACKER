import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_providers.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AnalyticsService(client);
});

final dashboardDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getDashboardData();
});
