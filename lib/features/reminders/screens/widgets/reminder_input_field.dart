import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ReminderInputField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final bool isAlignedRight;

  const ReminderInputField({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
    this.isAlignedRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: !isAlignedRight
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: ECColors.buttonPrimary),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ECColors.buttonPrimary,
                        )),
                  ],
                ),
                const SizedBox(height: 5),
                child,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: ECColors.buttonPrimary),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ECColors.buttonPrimary,
                      ),
                    ),
                  ],
                ),

                /// Right-aligned text for Time & Date
                if (isAlignedRight) child
              ],
            ),
    );
  }
}
