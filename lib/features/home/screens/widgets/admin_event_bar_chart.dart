import 'package:elderly_community/utils/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/sizes.dart';

class AdminEventBarChart extends StatelessWidget {
  final Map<String, int> eventCounts;
  final String title;

  const AdminEventBarChart({
    super.key,
    required this.eventCounts,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // List<BarChartGroupData> barGroups = eventCounts.entries.map((entry) {
    //   String dateKey = entry.key; // Example: "2025-3-19"
    //
    //   // Split the date string safely
    //   List<String> parts = dateKey.split('-');
    //
    //   int year = int.parse(parts[0]);  // Year part (e.g., "2025")
    //   int month = parts.length > 1 ? int.parse(parts[1]) : 1;  // Month (default to 1)
    //   int day = parts.length > 2 ? int.parse(parts[2]) : 1;  // Day (default to 1)
    //
    //   DateTime parsedDate = DateTime(year, month, day); // Create DateTime object
    //
    //   return BarChartGroupData(
    //     x: parsedDate.millisecondsSinceEpoch,
    //     barRods: [
    //       BarChartRodData(toY: entry.value.toDouble(), color: Colors.blue),
    //     ],
    //   );
    // }).toList();

    // Convert date keys to a list to maintain order
    List<String> dateKeys = eventCounts.keys.toList();

    List<BarChartGroupData> barGroups = dateKeys.asMap().entries.map((entry) {
      int index = entry.key; // Use index as X-axis value
      String dateKey = entry.value; // Example: "2025-3-19"

      return BarChartGroupData(
        x: index, // Use index instead of timestamp
        barRods: [
          BarChartRodData(
              toY: eventCounts[dateKey]!.toDouble(), color: ECColors.secondary),
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: ECSizes.md),

          /// Bar Chart
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dateKeys.length) {
                          return Text(
                              dateKeys[index]); // Show original date label
                        }
                        return Text('');
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.white,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
