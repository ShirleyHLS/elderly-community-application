import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ECBottomNavigationBarTheme {
  ECBottomNavigationBarTheme._();

  static NavigationBarThemeData lightBottomNavigationBarTheme = NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: Colors.transparent,
    height: 80,
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: ECColors.buttonPrimary);
        }
        return TextStyle(color: Colors.black);
      },
    ),
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: ECColors.buttonPrimary);
        }
        return IconThemeData(color: Colors.black);
      },
    ),
  );
}