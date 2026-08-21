import 'package:flutter/material.dart';

class CalendarHeatmap extends StatelessWidget {
  final List<dynamic> calendarData; // list of {date: "YYYY-MM-DD", amount: double, count: int}
  final Function(String date, double amount)? onDaySelected;

  const CalendarHeatmap({
    super.key,
    required this.calendarData,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (calendarData.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No calendar data available')),
      );
    }

    double maxVal = 0;
    Map<int, double> daySpendMap = {};
    for (var item in calendarData) {
      final dateStr = item['date'] as String;
      final amt = (item['amount'] as num).toDouble();
      final day = int.tryParse(dateStr.split('-').last) ?? 1;
      daySpendMap[day] = amt;
      if (amt > maxVal) maxVal = amt;
    }

    // Assume 31 days grid layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: calendarData.length,
      itemBuilder: (context, index) {
        final item = calendarData[index];
        final dateStr = item['date'] as String;
        final dayNum = dateStr.split('-').last;
        final amt = (item['amount'] as num).toDouble();

        double intensity = maxVal > 0 ? (amt / maxVal) : 0.0;
        Color tileColor;
        if (amt == 0) {
          tileColor = Theme.of(context).cardColor;
        } else if (intensity < 0.3) {
          tileColor = const Color(0xFF06B6D4).withOpacity(0.4);
        } else if (intensity < 0.7) {
          tileColor = const Color(0xFF6366F1).withOpacity(0.7);
        } else {
          tileColor = const Color(0xFFF59E0B);
        }

        return InkWell(
          onTap: () {
            if (onDaySelected != null) {
              onDaySelected!(dateStr, amt);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: amt > 0 ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  if (amt > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '₹${amt >= 1000 ? '${(amt / 1000).toStringAsFixed(1)}k' : amt.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
