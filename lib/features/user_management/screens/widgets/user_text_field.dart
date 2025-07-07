import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool isReadOnly;
  final bool isEnabled;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.validator,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      keyboardType: keyboardType,
      readOnly: isReadOnly,
      enabled: isEnabled,
      validator: validator,
      onTap: onTap,
      style: TextStyle(
        color: isEnabled ? Colors.black : Colors.grey.shade700,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
        filled: true,
        fillColor: isEnabled ? Colors.white : Colors.grey.shade200,
        // Light gray for read-only fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ECColors.secondary, width: 1),
        ),
      ),
    );
  }
}
