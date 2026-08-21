import '../core/network/api_client.dart';
import '../models/goal.dart';

class GoalService {
  final ApiClient _apiClient;

  GoalService(this._apiClient);

  Future<List<GoalModel>> getGoals() async {
    final res = await _apiClient.get('/goals');
    final list = res as List<dynamic>? ?? [];
    return list.map((e) => GoalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GoalModel> createGoal(GoalModel goal) async {
    final res = await _apiClient.post('/goals', data: goal.toJson());
    return GoalModel.fromJson(res as Map<String, dynamic>);
  }

  Future<GoalModel> updateGoal(int id, GoalModel goal) async {
    final res = await _apiClient.put('/goals/$id', data: goal.toJson());
    return GoalModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteGoal(int id) async {
    await _apiClient.delete('/goals/$id');
  }
}
