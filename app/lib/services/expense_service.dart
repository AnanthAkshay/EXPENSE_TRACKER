import '../core/network/api_client.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';

class ExpenseService {
  final ApiClient _apiClient;

  ExpenseService(this._apiClient);

  Future<Map<String, dynamic>> getExpenses({
    String? from,
    String? to,
    int? categoryId,
    String? search,
    String? sort,
    int page = 1,
    int size = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      if (from != null && from.isNotEmpty) 'from': from,
      if (to != null && to.isNotEmpty) 'to': to,
      if (categoryId != null && categoryId > 0) 'categoryId': categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };

    final data = await _apiClient.get('/expenses', queryParameters: params);
    final itemsRaw = data['items'] as List<dynamic>? ?? [];
    final items = itemsRaw.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
    final total = (data['total'] as num?)?.toInt() ?? 0;

    return {'items': items, 'total': total};
  }

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final res = await _apiClient.post('/expenses', data: expense.toJson());
    return ExpenseModel.fromJson(res as Map<String, dynamic>);
  }

  Future<ExpenseModel> updateExpense(int id, ExpenseModel expense) async {
    final res = await _apiClient.put('/expenses/$id', data: expense.toJson());
    return ExpenseModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteExpense(int id) async {
    await _apiClient.delete('/expenses/$id');
  }

  Future<List<CategoryModel>> getCategories({bool includeArchived = false}) async {
    final res = await _apiClient.get('/categories', queryParameters: {'includeArchived': includeArchived});
    final list = res as List<dynamic>? ?? [];
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory(String name, String iconKey, String colorHex) async {
    final res = await _apiClient.post('/categories', data: {
      'name': name,
      'iconKey': iconKey,
      'colorHex': colorHex,
    });
    return CategoryModel.fromJson(res as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory(int id, String name, String iconKey, String colorHex, bool isArchived) async {
    final res = await _apiClient.put('/categories/$id', data: {
      'name': name,
      'iconKey': iconKey,
      'colorHex': colorHex,
      'isArchived': isArchived,
    });
    return CategoryModel.fromJson(res as Map<String, dynamic>);
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final res = await _apiClient.get('/payment-methods');
    final list = res as List<dynamic>? ?? [];
    return list.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
