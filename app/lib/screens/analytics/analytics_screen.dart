import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/analytics_providers.dart';
import '../../widgets/bar_chart.dart';
import '../../widgets/calendar_heatmap.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/empty_state.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedTrendPeriodProvider);
    final trendsAsync = ref.watch(trendsDataProvider);
    final calendarAsync = ref.watch(calendarHeatmapProvider);
    final insightsAsync = ref.watch(insightsListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics & Patterns'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Trends'),
              Tab(text: 'Calendar'),
              Tab(text: 'Insights'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Trends
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Spending Trends', style: Theme.of(context).textTheme.titleLarge),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Month'),
                            selected: period == 'month',
                            onSelected: (_) => ref.read(selectedTrendPeriodProvider.notifier).state = 'month',
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('Week'),
                            selected: period == 'week',
                            onSelected: (_) => ref.read(selectedTrendPeriodProvider.notifier).state = 'week',
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('Quarter'),
                            selected: period == 'quarter',
                            onSelected: (_) => ref.read(selectedTrendPeriodProvider.notifier).state = 'quarter',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: trendsAsync.when(
                      data: (data) => SpendingBarChart(data: data),
                      loading: () => const LoadingShimmer(height: 200, borderRadius: 20),
                      error: (err, _) => ErrorBanner(message: 'Failed to load trends: $err'),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: Calendar Heatmap
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Calendar Heatmap', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Tile color intensity reflects daily spend relative to monthly peak.', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  calendarAsync.when(
                    data: (calendarData) => CalendarHeatmap(
                      calendarData: calendarData,
                      onDaySelected: (date, amount) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Spent on $date'),
                            content: Text('Total spend: ₹${amount.toStringAsFixed(2)}'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                    ),
                    loading: () => const LoadingShimmer(height: 220, borderRadius: 20),
                    error: (err, _) => ErrorBanner(message: 'Failed to load calendar: $err'),
                  ),
                ],
              ),
            ),

            // Tab 3: Insights
            insightsAsync.when(
              data: (insights) {
                if (insights.isEmpty) {
                  return const EmptyState(
                    title: 'No Insights Yet',
                    message: 'Log more expenses to generate pattern insights.',
                    icon: Icons.lightbulb_outline,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: insights.length,
                  itemBuilder: (context, index) {
                    final insight = insights[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.auto_graph, color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    insight.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    insight.message,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorBanner(message: 'Failed to load insights: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
