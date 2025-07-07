import 'package:flutter/material.dart';

import '../utils/constants/sizes.dart';

class QuickButton extends StatelessWidget {
  const QuickButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ECSizes.cardRadiusLg)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
