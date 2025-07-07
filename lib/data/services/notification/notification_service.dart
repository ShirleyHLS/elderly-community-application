import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialise
  Future<void> initNotification() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request permission for notifications (Android 13+)
    await androidPlatform?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    bool? exactAlarmAllowed =
        await androidPlatform?.requestExactAlarmsPermission();
    print("Exact alarm permission: $exactAlarmAllowed");

    // required for scheduling notifications
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // prepare android initialisation setting
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    // init setting
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // initialise the plugin
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap);
  }

  /// Notification response
  void onNotificationTap(NotificationResponse notificationResponse) {
    print("Notification clicked: ${notificationResponse.id}");
  }

  /// Notification detail
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
      'Elderly Community',
      'Reminder Notification',
      channelDescription: 'Reminder Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
    ));
  }

  /// Show local notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return flutterLocalNotificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  /// Show periodically local notification
  Future<void> showDailyNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      await notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// schedule local notification
  Future<void> showScheduledNotification(ReminderModel reminder) async {
    int notificationId = reminder.id.hashCode;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Convert TimeOfDay to TZDateTime
    // final tz.TZDateTime scheduledDate =
    //     tz.TZDateTime.from(reminder.reminderTime.toDate(), tz.local);
    // print(scheduledDate);
    // Convert the Firestore Timestamp (or DateTime) to a TZDateTime
    final DateTime reminderTime =
        reminder.reminderTime.toDate();
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      reminderTime.year,
      reminderTime.month,
      reminderTime.day,
      reminderTime.hour,
      reminderTime.minute,
      0, // Ensure seconds are always 00
    );
    print(scheduledDate);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        reminder.title,
        reminder.description,
        scheduledDate,
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: reminder.isRecurring
            ? DateTimeComponents.time // Daily recurring
            : null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  // Helper function to convert TimeOfDay to TZDateTime
  tz.TZDateTime _convertTimeOfDayToTZDateTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
  }

  Future<void> cancelNotification(String reminderId) async {
    int notificationId = reminderId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

// Future<void> requestExactAlarmPermission() async {
//   if (await Permission.scheduleExactAlarm.isGranted) {
//     print("😒😒😒");
//     // Permission is already granted
//     return;
//   }
//
//   // Request permission
//   final status = await Permission.scheduleExactAlarm.request();
//   print("😶‍🌫️😶‍🌫️😶‍🌫️");
//   if (status.isGranted) {
//     // Permission granted
//     print("Exact alarm permission granted");
//   } else {
//     // Permission denied
//     print("Exact alarm permission denied");
//   }
// }
}
