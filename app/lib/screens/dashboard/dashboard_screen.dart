import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../state/dashboard_provider.dart';
import '../../models/expense.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/donut_chart.dart';
import '../../widgets/bar_chart.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/add_expense_bottom_sheet.dart';
import '../../core/constants/app_constants.dart';
import '../wrapped/wrapped_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int index)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              DateFormat('EEEE, MMMM dd').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
            tooltip: 'Spending Wrapped',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WrappedScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
        },
        child: dashboardAsync.when(
          data: (data) => _buildDashboardBody(context, ref, data),
          loading: () => _buildLoadingState(context),
          error: (err, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ErrorBanner(
              message: 'Failed to load dashboard data: $err',
              onRetry: () => ref.invalidate(dashboardDataProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardBody(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 2);

    final double todayTotal = (data['todayTotal'] as num?)?.toDouble() ?? 0.0;
    final double monthTotal = (data['monthTotal'] as num?)?.toDouble() ?? 0.0;
    final double avgDailySpend = (data['avgDailySpend'] as num?)?.toDouble() ?? 0.0;
    final double monthDeltaPct = (data['monthDeltaPct'] as num?)?.toDouble() ?? 0.0;

    final categoryBreakdown = data['categoryBreakdown'] as List<dynamic>? ?? [];
    final timeline7Days = data['timeline7Days'] as List<dynamic>? ?? [];
    final recentTransactionsRaw = data['recentTransactions'] as List<dynamic>? ?? [];
    final recentTransactions = recentTransactionsRaw.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();

    final highestDayMap = data['highestSpendingDay'] as Map<String, dynamic>?;
    String highestDayText = 'None';
    if (highestDayMap != null && highestDayMap['date'] != null) {
      final amt = (highestDayMap['amount'] as num).toDouble();
      highestDayText = '${highestDayMap['date']}\n(${currencyFormatter.format(amt)})';
    }

    final topInsightMap = data['topInsight'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrapped Banner Card
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WrappedScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF9D4EDD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Spending Wrapped',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Discover your monthly spending story & personality',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Top Insight Chip (if present)
          if (topInsightMap != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topInsightMap['title'] as String? ?? 'Intelligent Insight',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topInsightMap['message'] as String? ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 4 Stat Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              StatCard(
                label: "Today's Spend",
                value: currencyFormatter.format(todayTotal),
                icon: Icons.today,
                accentColor: const Color(0xFF06B6D4),
              ),
              StatCard(
                label: 'This Month',
                value: currencyFormatter.format(monthTotal),
                subtitle: monthDeltaPct != 0 ? '${monthDeltaPct > 0 ? '+' : ''}${monthDeltaPct.toStringAsFixed(1)}% MoM' : null,
                icon: Icons.calendar_month,
                accentColor: const Color(0xFF6366F1),
              ),
              StatCard(
                label: 'Avg Daily Spend',
                value: currencyFormatter.format(avgDailySpend),
                icon: Icons.show_chart,
                accentColor: const Color(0xFF10B981),
              ),
              StatCard(
                label: 'Peak Spend Day',
                value: highestDayText,
                icon: Icons.stacked_line_chart,
                accentColor: const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7-Day Timeline Chart
          Text('7-Day Spending Trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SpendingBarChart(data: timeline7Days),
          ),
          const SizedBox(height: 24),

          // Category Breakdown Donut Chart
          Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CategoryDonutChart(
              categoryBreakdown: categoryBreakdown,
              totalSpend: monthTotal,
            ),
          ),
          const SizedBox(height: 24),

          // Recent Transactions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Expenses', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  if (onNavigateTab != null) onNavigateTab!(1);
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (recentTransactions.isEmpty)
            EmptyState(
              title: 'No Expenses Logged',
              message: 'Tap the button below to add your first expense for this month!',
              actionLabel: 'Add Expense',
              onAction: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddExpenseBottomSheet(),
                );
              },
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final expense = recentTransactions[index];
                return ExpenseCard(expense: expense);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          LoadingShimmer(height: 80, borderRadius: 20),
          SizedBox(height: 20),
          LoadingShimmer(height: 160, borderRadius: 20),
          SizedBox(height: 20),
          LoadingShimmer(height: 200, borderRadius: 20),
        ],
      ),
    );
  }
}
