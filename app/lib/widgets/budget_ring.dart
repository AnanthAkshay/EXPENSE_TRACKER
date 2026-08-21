import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class BudgetProgressRing extends StatelessWidget {
  final OverallBudgetModel overall;

  const BudgetProgressRing({
    super.key,
    required this.overall,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (overall.pctUsed / 100).clamp(0.0, 1.0);

    Color statusColor;
    if (overall.pctUsed >= 100) {
      statusColor = AppTheme.dangerColor;
    } else if (overall.pctUsed >= 80) {
      statusColor = AppTheme.warningColor;
    } else {
      statusColor = AppTheme.primaryColor;
    }

    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Monthly Budget',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${overall.daysLeft} days left',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 12,
                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${overall.pctUsed.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Used',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(context, 'Spent', currencyFormatter.format(overall.spent), statusColor),
              _buildMetric(context, 'Budget', currencyFormatter.format(overall.amount), Theme.of(context).textTheme.titleMedium?.color ?? Colors.white),
              _buildMetric(context, 'Remaining', currencyFormatter.format(overall.remaining), overall.remaining < 0 ? AppTheme.dangerColor : AppTheme.successColor),
            ],
          ),
          if (overall.projected > 0) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 16, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  'Projected month-end spend: ${currencyFormatter.format(overall.projected)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
