import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ExpenseService(client);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getCategories();
});

final paymentMethodsProvider = FutureProvider<List<PaymentMethodModel>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getPaymentMethods();
});

class ExpenseFilterState {
  final String? from;
  final String? to;
  final int? categoryId;
  final String? search;
  final String sort;
  final int page;

  ExpenseFilterState({
    this.from,
    this.to,
    this.categoryId,
    this.search,
    this.sort = 'date_desc',
    this.page = 1,
  });

  ExpenseFilterState copyWith({
    String? from,
    String? to,
    int? categoryId,
    String? search,
    String? sort,
    int? page,
    bool clearCategory = false,
  }) {
    return ExpenseFilterState(
      from: from ?? this.from,
      to: to ?? this.to,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      search: search ?? this.search,
      sort: sort ?? this.sort,
      page: page ?? this.page,
    );
  }
}

final expenseFilterNotifierProvider = StateNotifierProvider<ExpenseFilterNotifier, ExpenseFilterState>((ref) {
  return ExpenseFilterNotifier();
});

class ExpenseFilterNotifier extends StateNotifier<ExpenseFilterState> {
  ExpenseFilterNotifier() : super(ExpenseFilterState());

  void setSearch(String query) {
    state = state.copyWith(search: query, page: 1);
  }

  void setCategory(int? catId) {
    if (catId == null) {
      state = state.copyWith(clearCategory: true, page: 1);
    } else {
      state = state.copyWith(categoryId: catId, page: 1);
    }
  }

  void setSort(String sortKey) {
    state = state.copyWith(sort: sortKey, page: 1);
  }

  void setDateRange(String? from, String? to) {
    state = state.copyWith(from: from, to: to, page: 1);
  }

  void reset() {
    state = ExpenseFilterState();
  }
}

final expensesListProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  final filter = ref.watch(expenseFilterNotifierProvider);

  return service.getExpenses(
    from: filter.from,
    to: filter.to,
    categoryId: filter.categoryId,
    search: filter.search,
    sort: filter.sort,
    page: filter.page,
    size: 50,
  );
});
