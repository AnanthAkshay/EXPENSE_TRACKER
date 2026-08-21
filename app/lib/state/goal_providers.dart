import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_providers.dart';
import '../services/goal_service.dart';
import '../models/goal.dart';

final goalServiceProvider = Provider<GoalService>((ref) {
  final client = ref.watch(apiClientProvider);
  return GoalService(client);
});

final goalsListProvider = FutureProvider.autoDispose<List<GoalModel>>((ref) async {
  final service = ref.watch(goalServiceProvider);
  return service.getGoals();
});
