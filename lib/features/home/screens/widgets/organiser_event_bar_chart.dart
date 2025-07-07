import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../events/models/event_bar_data_model.dart';

class OrganiserEventBarChart extends StatelessWidget {
  final List<EventData> events;
  final String title;

  const OrganiserEventBarChart({
    super.key,
    required this.events,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
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
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ECSizes.md),

          /// Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align items at the end
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.blue, "Max Participants"),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.green, "Actual Participants"),
                ],
              ),
            ],
          ),
          SizedBox(height: ECSizes.xl),

          /// Bar Chart
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: _buildBarGroups(),
                // Generate bars dynamically
                titlesData: _buildTitles(),
                // Customize labels
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barTouchData: BarTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate bars for each event
  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(events.length, (index) {
      final event = events[index];
      return BarChartGroupData(x: index, barRods: [
        // Max Participants
        BarChartRodData(
          toY: event.maxParticipants.toDouble(),
          color: Colors.blue,
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
        // Actual Participants
        BarChartRodData(
          toY: event.actualParticipants.toDouble(),
          color: Colors.green,
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
      ]);
    });
  }

  // Custom labels for X-axis
  FlTitlesData _buildTitles() {
    return FlTitlesData(
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
            if (value.toInt() >= events.length) return Container();
            return SideTitleWidget(
              meta: meta,
              child: Text(events[value.toInt()].eventName,
                  style: const TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
