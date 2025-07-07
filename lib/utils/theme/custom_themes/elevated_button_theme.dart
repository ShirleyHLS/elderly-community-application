import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ECElevatedButtonTheme {
  ECElevatedButtonTheme._();

  static final ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: ECColors.buttonPrimary,
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: ECColors.buttonDisabled,
      side: const BorderSide(color: ECColors.buttonPrimary),
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    )
  );
}