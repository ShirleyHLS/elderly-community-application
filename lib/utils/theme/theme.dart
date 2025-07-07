import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/theme/custom_themes/appbar_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/bottom_navigation_bar_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/chip_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/popup_menu_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/text_field_theme.dart';
import 'package:elderly_community/utils/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class ECAppTheme {
  ECAppTheme._(); // private constructor

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: ECColors.primary,
    scaffoldBackgroundColor: Colors.white,
    textTheme: ECTextTheme.lightTextTheme,
    elevatedButtonTheme: ECElevatedButtonTheme.lightElevatedButtonTheme,
    checkboxTheme: ECCheckboxTheme.lightCheckboxTheme,
    popupMenuTheme: ECPopUpMenuTheme.lightPopupMenuThemeData,
    chipTheme: ECChipTheme.lightChipTheme,
    appBarTheme: ECAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: ECBottomSheetTheme.lightBottomSheetTheme,
    outlinedButtonTheme: ECOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: ECTextFormFieldTheme.lightInputDecorationTheme,
    navigationBarTheme: ECBottomNavigationBarTheme.lightBottomNavigationBarTheme,
  );
}
