import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const InputFieldWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ECColors.buttonPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ECColors.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 24)
      ],
    );
  }
}
