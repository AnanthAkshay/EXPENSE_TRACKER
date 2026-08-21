import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/category_chip.dart';

class CategoryDonutChart extends StatefulWidget {
  final List<dynamic> categoryBreakdown;
  final double totalSpend;

  const CategoryDonutChart({
    super.key,
    required this.categoryBreakdown,
    required this.totalSpend,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryBreakdown.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data for category breakdown')),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 3,
          centerSpaceRadius: 55,
          sections: List.generate(widget.categoryBreakdown.length, (i) {
            final item = widget.categoryBreakdown[i];
            final amount = (item['amount'] as num).toDouble();
            final name = item['name'] as String? ?? 'Other';
            final hex = item['colorHex'] as String? ?? '#6366F1';
            final color = CategoryChip.parseColor(hex);

            final isTouched = i == touchedIndex;
            final radius = isTouched ? 30.0 : 24.0;
            final pct = widget.totalSpend > 0 ? (amount / widget.totalSpend * 100).toStringAsFixed(1) : '0';

            return PieChartSectionData(
              color: color,
              value: amount,
              title: isTouched ? '$name\n$pct%' : '',
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }
}
