import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../state/expense_providers.dart';
import '../../state/dashboard_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/add_expense_bottom_sheet.dart';
import '../../core/constants/app_constants.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseModel expense;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catColor = CategoryChip.parseColor(expense.categoryColorHex ?? '#6366F1');
    final iconData = CategoryChip.getIconData(expense.categoryIconKey ?? 'tag');

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(expense.expenseDate);
    } catch (_) {}
    final formattedDate = parsedDate != null ? DateFormat('EEEE, MMMM dd, yyyy').format(parsedDate) : expense.expenseDate;
    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddExpenseBottomSheet(initialExpense: expense),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense?'),
                  content: const Text('Are you sure you want to delete this expense?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );

              if (confirm == true && expense.id != null) {
                final service = ref.read(expenseServiceProvider);
                await service.deleteExpense(expense.id!);
                ref.invalidate(expensesListProvider);
                ref.invalidate(dashboardDataProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: catColor, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              currencyFormatter.format(expense.amount),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              expense.note ?? expense.categoryName ?? 'Expense',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            _buildDetailTile(context, 'Category', expense.categoryName ?? 'Uncategorized', Icons.category_outlined, catColor),
            _buildDetailTile(context, 'Date', formattedDate, Icons.calendar_today_outlined, null),
            if (expense.paymentMethodName != null)
              _buildDetailTile(context, 'Payment Method', expense.paymentMethodName!, Icons.payment_outlined, null),
            if (expense.note != null && expense.note!.isNotEmpty)
              _buildDetailTile(context, 'Note', expense.note!, Icons.notes_outlined, null),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, String label, String value, IconData icon, Color? accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: accentColor ?? Theme.of(context).textTheme.bodySmall?.color, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
