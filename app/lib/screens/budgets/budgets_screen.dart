import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../state/budget_providers.dart';
import '../../models/budget.dart';
import '../../widgets/budget_ring.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/category_chip.dart';
import '../../core/constants/app_constants.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref, {int? categoryId, String? categoryName, double? currentAmount}) {
    final amountCtrl = TextEditingController(text: currentAmount != null && currentAmount > 0 ? currentAmount.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(categoryName != null ? 'Set $categoryName Budget' : 'Set Overall Monthly Budget'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '${AppConstants.currencySymbol} ',
            labelText: 'Monthly Limit',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text.trim());
              if (amt != null && amt >= 0) {
                final month = ref.read(selectedBudgetMonthProvider);
                final service = ref.read(budgetServiceProvider);
                await service.upsertBudget(categoryId: categoryId, monthYear: month, amount: amt);
                ref.invalidate(budgetOverviewProvider);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetOverviewProvider);
    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Control'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(budgetOverviewProvider);
        },
        child: budgetAsync.when(
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Budget Card & Ring
                  InkWell(
                    onTap: () => _showSetBudgetDialog(context, ref, currentAmount: data.overall.amount),
                    borderRadius: BorderRadius.circular(24),
                    child: BudgetProgressRing(overall: data.overall),
                  ),
                  const SizedBox(height: 24),

                  // Category Budgets Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Category Budgets', style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () => _showSetBudgetDialog(context, ref, currentAmount: data.overall.amount),
                        child: const Text('Set Overall'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.categories.length,
                    itemBuilder: (context, index) {
                      final catB = data.categories[index];
                      final color = CategoryChip.parseColor(catB.categoryColorHex);
                      final icon = CategoryChip.getIconData(catB.categoryIconKey);
                      final pct = (catB.pctUsed / 100).clamp(0.0, 1.0);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () => _showSetBudgetDialog(
                            context,
                            ref,
                            categoryId: catB.categoryId,
                            categoryName: catB.categoryName,
                            currentAmount: catB.amount,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        catB.categoryName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      catB.amount > 0
                                          ? '${currencyFormatter.format(catB.spent)} / ${currencyFormatter.format(catB.amount)}'
                                          : '${currencyFormatter.format(catB.spent)} spent (No limit)',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                if (catB.amount > 0) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 8,
                                      backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        catB.pctUsed >= 100
                                            ? Colors.red
                                            : catB.pctUsed >= 80
                                                ? Colors.amber
                                                : color,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                LoadingShimmer(height: 240, borderRadius: 24),
                SizedBox(height: 20),
                LoadingShimmer(height: 80, borderRadius: 16),
              ],
            ),
          ),
          error: (err, _) => ErrorBanner(message: 'Failed to load budgets: $err'),
        ),
      ),
    );
  }
}
