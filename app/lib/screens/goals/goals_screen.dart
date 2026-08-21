import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../state/goal_providers.dart';
import '../../models/goal.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_shimmer.dart';
import '../../core/constants/app_constants.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final savedCtrl = TextEditingController();
    DateTime? selectedTargetDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Goal Name (e.g. Vacation)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '${AppConstants.currencySymbol} ',
                    labelText: 'Target Amount',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: savedCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '${AppConstants.currencySymbol} ',
                    labelText: 'Already Saved Amount (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 90)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) {
                      setState(() => selectedTargetDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(selectedTargetDate != null ? DateFormat('yyyy-MM-dd').format(selectedTargetDate!) : 'Select Target Date'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final target = double.tryParse(targetCtrl.text.trim());
                final saved = double.tryParse(savedCtrl.text.trim()) ?? 0.0;
                if (name.isNotEmpty && target != null && target > 0) {
                  final goal = GoalModel(
                    userId: 1,
                    name: name,
                    targetAmount: target,
                    savedAmount: saved,
                    targetDate: selectedTargetDate != null ? DateFormat('yyyy-MM-dd').format(selectedTargetDate!) : null,
                    suggestedMonthlyContribution: 0.0,
                  );
                  final service = ref.read(goalServiceProvider);
                  await service.createGoal(goal);
                  ref.invalidate(goalsListProvider);
                  if (context.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsListProvider);
    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () => _showAddGoalDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(goalsListProvider),
        child: goalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return EmptyState(
                title: 'No Savings Goals Yet',
                message: 'Track progress towards your dream vacation, emergency fund, or gadget!',
                actionLabel: 'Add Goal',
                onAction: () => _showAddGoalDialog(context, ref),
                icon: Icons.savings_outlined,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final pct = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              goal.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                              onPressed: () async {
                                if (goal.id != null) {
                                  final service = ref.read(goalServiceProvider);
                                  await service.deleteGoal(goal.id!);
                                  ref.invalidate(goalsListProvider);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currencyFormatter.format(goal.savedAmount)} of ${currencyFormatter.format(goal.targetAmount)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text('${(pct * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 10,
                            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        if (goal.suggestedMonthlyContribution > 0) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.savings, size: 16, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Suggested saving: ${currencyFormatter.format(goal.suggestedMonthlyContribution)} / month to hit target date!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView.builder(
            itemCount: 3,
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: LoadingShimmer(height: 120, borderRadius: 20),
            ),
          ),
          error: (err, _) => ErrorBanner(message: 'Failed to load goals: $err'),
        ),
      ),
    );
  }
}
