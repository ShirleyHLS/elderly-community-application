import 'package:flutter/material.dart';

class ProfileFieldWidget extends StatelessWidget {
  const ProfileFieldWidget({
    super.key,
    required this.label,
    this.value,
    this.isEditable = true,
    this.onTap,
  });

  final String label;
  final String? value;
  final bool isEditable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title on the left
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 10),

            // Subtitle in the middle
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            // Trailing icon on the right
            if (isEditable)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
