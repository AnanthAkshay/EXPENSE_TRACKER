import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingBarChart extends StatelessWidget {
  final List<dynamic> data; // list of {date: "YYYY-MM-DD", amount: double}

  const SpendingBarChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No trend data available')),
      );
    }

    double maxVal = 0;
    for (var item in data) {
      final val = (item['amount'] as num).toDouble();
      if (val > maxVal) maxVal = val;
    }
    if (maxVal == 0) maxVal = 100;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dateStr = data[groupIndex]['date'] as String;
                final amt = rod.toY.toStringAsFixed(2);
                return BarTooltipItem(
                  '$dateStr\n₹$amt',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < data.length) {
                    final dateStr = data[idx]['date'] as String;
                    try {
                      final dt = DateTime.parse(dateStr);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          DateFormat('dd/MM').format(dt),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      );
                    } catch (_) {}
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            final amt = (data[i]['amount'] as num).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: amt,
                  color: Theme.of(context).colorScheme.primary,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
