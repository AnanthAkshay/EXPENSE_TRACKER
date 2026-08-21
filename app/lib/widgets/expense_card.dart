import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../widgets/category_chip.dart';
import '../core/constants/app_constants.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryChip.parseColor(expense.categoryColorHex ?? '#6366F1');
    final iconData = CategoryChip.getIconData(expense.categoryIconKey ?? 'tag');

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(expense.expenseDate);
    } catch (_) {}
    final formattedDate = parsedDate != null ? DateFormat('MMM dd, yyyy').format(parsedDate) : expense.expenseDate;
    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: catColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note != null && expense.note!.isNotEmpty
                          ? expense.note!
                          : (expense.categoryName ?? 'Expense'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          expense.categoryName ?? 'Category',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: catColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (expense.paymentMethodName != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              expense.paymentMethodName!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormatter.format(expense.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
