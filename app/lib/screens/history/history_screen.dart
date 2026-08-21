import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/expense_providers.dart';
import '../../state/dashboard_provider.dart';
import '../../models/expense.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/add_expense_bottom_sheet.dart';
import '../expense_detail/expense_detail_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final filterState = ref.watch(expenseFilterNotifierProvider);
    final filterNotifier = ref.read(expenseFilterNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            initialValue: filterState.sort,
            onSelected: (val) => filterNotifier.setSort(val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'date_desc', child: Text('Date: Newest First')),
              PopupMenuItem(value: 'date_asc', child: Text('Date: Oldest First')),
              PopupMenuItem(value: 'amount_desc', child: Text('Amount: High to Low')),
              PopupMenuItem(value: 'amount_asc', child: Text('Amount: Low to High')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => filterNotifier.setSearch(val),
              decoration: InputDecoration(
                hintText: 'Search notes or categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          filterNotifier.setSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category Chips Bar
          categoriesAsync.when(
            data: (categories) {
              return SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      final isSel = filterState.categoryId == null;
                      return ChoiceChip(
                        label: const Text('All'),
                        selected: isSel,
                        onSelected: (_) => filterNotifier.setCategory(null),
                      );
                    }
                    final cat = categories[i - 1];
                    final isSel = cat.id == filterState.categoryId;
                    return CategoryChip(
                      name: cat.name,
                      iconKey: cat.iconKey,
                      colorHex: cat.colorHex,
                      isSelected: isSel,
                      onTap: () => filterNotifier.setCategory(isSel ? null : cat.id),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 44),
            error: (_, __) => const SizedBox(height: 44),
          ),
          const SizedBox(height: 8),

          // List Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(expensesListProvider);
              },
              child: expensesAsync.when(
                data: (data) {
                  final items = data['items'] as List<ExpenseModel>? ?? [];

                  if (items.isEmpty) {
                    return EmptyState(
                      title: 'No Expenses Found',
                      message: filterState.search != null && filterState.search!.isNotEmpty
                          ? 'No transactions matched your search criteria.'
                          : 'You haven\'t logged any expenses yet.',
                      actionLabel: 'Add Expense',
                      onAction: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const AddExpenseBottomSheet(),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final expense = items[index];
                      return Dismissible(
                        key: Key('expense_${expense.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Theme.of(context).colorScheme.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Expense?'),
                              content: const Text('Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) async {
                          if (expense.id != null) {
                            final service = ref.read(expenseServiceProvider);
                            await service.deleteExpense(expense.id!);
                            ref.invalidate(expensesListProvider);
                            ref.invalidate(dashboardDataProvider);
                          }
                        },
                        child: ExpenseCard(
                          expense: expense,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailScreen(expense: expense),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  itemCount: 6,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: LoadingShimmer(height: 72, borderRadius: 16),
                  ),
                ),
                error: (err, _) => ErrorBanner(
                  message: 'Failed to load history: $err',
                  onRetry: () => ref.invalidate(expensesListProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
