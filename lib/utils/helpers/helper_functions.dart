import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ECHelperFunctions {
  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(String title, String message) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static TimeOfDay roundToNearestFiveMinutes(TimeOfDay time) {
    int roundedMinute = (time.minute / 5).round() * 5;
    return time.replacing(minute: roundedMinute);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(
          i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(children: rowChildren));
    }
    return wrappedList;
  }

  static bool compareDateWithTodayDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return date != null &&
        DateTime(date.year, date.month, date.day).isAtSameMomentAs(today);
  }

  static String formatEventDate(DateTime start, DateTime end) {
    String formattedStartDate =
        ECHelperFunctions.getFormattedDate(start, format: "EEE, dd MMM yyyy");
    String formattedStartTime =
        ECHelperFunctions.getFormattedDate(start, format: "hh:mm a");
    String formattedEndDate =
        ECHelperFunctions.getFormattedDate(end, format: "EEE, dd MMM yyyy");
    String formattedEndTime =
        ECHelperFunctions.getFormattedDate(end, format: "hh:mm a");

    // Check if start date and end date are the same
    if (formattedStartDate == formattedEndDate) {
      return "$formattedStartDate $formattedStartTime - $formattedEndTime";
    } else {
      return "$formattedStartDate $formattedStartTime - $formattedEndDate $formattedEndTime";
    }
  }
}
