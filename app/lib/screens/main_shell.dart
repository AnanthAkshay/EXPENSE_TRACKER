import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'analytics/analytics_screen.dart';
import 'budgets/budgets_screen.dart';
import 'goals/goals_screen.dart';
import 'settings/settings_screen.dart';
import '../widgets/add_expense_bottom_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: (index) => setState(() => _currentIndex = index)),
      const HistoryScreen(),
      const AnalyticsScreen(),
      const BudgetsScreen(),
      const GoalsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddExpenseBottomSheet(),
          );
        },
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                _currentIndex == 0 ? Icons.space_dashboard : Icons.space_dashboard_outlined,
                color: _currentIndex == 0 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Home',
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(
                _currentIndex == 1 ? Icons.receipt_long : Icons.receipt_long_outlined,
                color: _currentIndex == 1 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'History',
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 32), // Spacer for center FAB
            IconButton(
              icon: Icon(
                _currentIndex == 2 ? Icons.insights : Icons.insights_outlined,
                color: _currentIndex == 2 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Analytics',
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: Icon(
                _currentIndex == 3 ? Icons.pie_chart : Icons.pie_chart_outline,
                color: _currentIndex == 3 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Budgets',
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
