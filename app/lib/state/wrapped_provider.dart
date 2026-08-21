import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_providers.dart';
import '../services/wrapped_service.dart';
import '../models/wrapped_story.dart';

final wrappedServiceProvider = Provider<WrappedService>((ref) {
  final client = ref.watch(apiClientProvider);
  return WrappedService(client);
});

final selectedWrappedMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final wrappedStoryProvider = FutureProvider.autoDispose<WrappedStoryModel>((ref) async {
  final service = ref.watch(wrappedServiceProvider);
  final month = ref.watch(selectedWrappedMonthProvider);
  return service.getWrappedStory(month);
});
