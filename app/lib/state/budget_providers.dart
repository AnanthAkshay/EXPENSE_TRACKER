import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_providers.dart';
import '../services/budget_service.dart';
import '../models/budget.dart';

final budgetServiceProvider = Provider<BudgetService>((ref) {
  final client = ref.watch(apiClientProvider);
  return BudgetService(client);
});

final selectedBudgetMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final budgetOverviewProvider = FutureProvider.autoDispose<BudgetOverviewModel>((ref) async {
  final service = ref.watch(budgetServiceProvider);
  final month = ref.watch(selectedBudgetMonthProvider);
  return service.getBudgetOverview(month);
});
