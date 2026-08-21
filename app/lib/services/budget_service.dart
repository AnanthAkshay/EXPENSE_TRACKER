import '../core/network/api_client.dart';
import '../models/budget.dart';

class BudgetService {
  final ApiClient _apiClient;

  BudgetService(this._apiClient);

  Future<BudgetOverviewModel> getBudgetOverview(String month) async {
    final data = await _apiClient.get('/budgets', queryParameters: {'month': month});
    return BudgetOverviewModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> upsertBudget({int? categoryId, required String monthYear, required double amount}) async {
    await _apiClient.put('/budgets', data: {
      if (categoryId != null) 'categoryId': categoryId,
      'monthYear': monthYear,
      'amount': amount,
    });
  }
}
