import '../core/network/api_client.dart';
import '../models/insight.dart';

class AnalyticsService {
  final ApiClient _apiClient;

  AnalyticsService(this._apiClient);

  Future<Map<String, dynamic>> getDashboardData() async {
    final data = await _apiClient.get('/analytics/dashboard');
    return data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getTrends(String period) async {
    final res = await _apiClient.get('/analytics/trends', queryParameters: {'period': period});
    final list = res as List<dynamic>? ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getCalendarHeatmap(String month) async {
    final res = await _apiClient.get('/analytics/calendar', queryParameters: {'month': month});
    final list = res as List<dynamic>? ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<InsightModel>> getInsights(String month) async {
    final res = await _apiClient.get('/analytics/insights', queryParameters: {'month': month});
    final list = res as List<dynamic>? ?? [];
    return list.map((e) => InsightModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
