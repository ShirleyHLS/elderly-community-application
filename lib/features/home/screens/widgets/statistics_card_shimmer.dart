import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StatisticsCardShimmer extends StatelessWidget {
  const StatisticsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 24, height: 24, color: Colors.white), // Fake icon
            const SizedBox(height: 6),
            Container(width: 100, height: 16, color: Colors.white), // Fake title
            const SizedBox(height: 4),
            Container(width: 60, height: 28, color: Colors.white), // Fake number
          ],
        ),
      ),
    );
  }
}
