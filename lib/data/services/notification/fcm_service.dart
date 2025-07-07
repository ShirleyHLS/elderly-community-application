import 'dart:convert';

import 'package:elderly_community/app.dart';
import 'package:elderly_community/data/repositories/reminder/reminder_repository.dart';
import 'package:elderly_community/data/services/jwt/jwt_service.dart';
import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../features/events/controllers/organiser_event_controller.dart';
import '../../../features/events/models/event_model.dart';
import '../../../firebase_options.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/text_strings.dart';
import '../../repositories/event/event_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📩 Background Message Received: ${message.notification?.title}");
  await FcmService.instance.setupFlutterNofication();
  await FcmService.instance.showNotification(message);
}

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  static String fcmEndpoint = ECTexts.fcmEndpoint;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> initialiseFCM() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // request notification permission
    await messaging.requestPermission(provisional: true);

    await setupFlutterNofication();

    // Foreground: Listen for messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "FCM Message Received (Foreground): ${message.notification?.title}");

      // Show local notification when the app is in foreground
      showNotification(message);
    });

    // Background: User taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("📲 Background notification opened: ${message.data}");
      // Wait until the navigator is ready
      await _waitForNavigator();
      handleNotificationClick(message);
    });

    // Terminated: Handle notification when app starts from a tap
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((handleNotificationClick));
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) {
    //   if (message != null) {
    //     print(
    //         "🚀 App opened from terminated state by tapping notification: ${message.data}");
    //     handleNotificationClick(context, message.data);
    //   }
    // });
  }

  Future<void> _waitForNavigator() async {
    int retries = 10;
    while (navigatorKey.currentState == null && retries > 0) {
      print("⏳ Waiting for navigator to be ready...");
      await Future.delayed(Duration(milliseconds: 200));
      retries--;
    }
    if (navigatorKey.currentState == null) {
      print("❌ Navigator still not ready after waiting!");
    } else {
      print("✅ Navigator ready!");
    }
  }

  Future<void> setupFlutterNofication() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'Elderly_Community', // id
      'Elderly Community Notifications', // title
      description: 'Notification Channel for Elderly Community', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        handleNotificationClickFromForeground(details);
      },
    );

    isFlutterLocalNotificationsInitialized = true;
  }

  void handleNotificationClickFromForeground(NotificationResponse details) {
    // Convert payload (data) into a usable format
    print(
        '🔔 Notification clicked in foreground with payload: ${details.payload}');
    if (details.payload == null) return;

    final Map<String, dynamic> messageData = jsonDecode(details.payload!);
    print('🔔 Foreground notification clicked with data: $messageData');

    handleNotificationClick(RemoteMessage(data: messageData));
  }

  // Handle Notification Click
  Future<void> handleNotificationClick(RemoteMessage? message) async {
    if (message == null) return;

    final messageData = message.data;
    print(
        '📦📦handle ${messageData["type"] == NotificationType.sosAlert.name}');
    await _waitForNavigator();
    if (navigatorKey.currentState == null) {
      print('⚠️ Navigator not ready, delaying navigation');
      return; // Still not ready, abort
    }

    if (messageData.containsKey("type")) {
      if (messageData["type"] == NotificationType.bindingRequest.name) {
        String id = messageData["id"] ?? "Unknown ID";
        String caregiverId =
            messageData["caregiver_id"] ?? "Unknown Caregiver ID";
        String caregiverName =
            messageData["caregiver_name"] ?? "Unknown Caregiver Name";

        // Navigate to the Binding Requests Screen
        navigatorKey.currentState?.pushNamed(
          '/elderly_accept_request',
          arguments: {
            'id': id,
            'caregiverId': caregiverId,
            'caregiverName': caregiverName,
          },
        );
      } else if (messageData["type"] == NotificationType.elderlyReminder.name) {
        String reminderId = messageData["reminderId"] ?? "Unknown ID";
        final reminderRepo = Get.put(ReminderRepository());
        final ReminderModel reminder =
            await reminderRepo.fetchReminderBasedOnReminderId(reminderId);

        navigatorKey.currentState
            ?.pushNamed('/reminder_details', arguments: reminder);
      } else if (messageData["type"] == NotificationType.missedReminder.name) {
        String reminderId = messageData["reminderId"] ?? "Unknown ID";
        final reminderRepo = Get.put(ReminderRepository());
        final ReminderModel reminder =
            await reminderRepo.fetchReminderBasedOnReminderId(reminderId);

        navigatorKey.currentState
            ?.pushNamed('/reminder_details', arguments: reminder);
      } else if (messageData["type"] == NotificationType.eventFeedback.name) {
        String eventId = messageData["eventId"] ?? "Unknown ID";
        final eventRepo = Get.put(EventRepository());
        final EventModel? event = await eventRepo.fetchEventById(eventId);

        navigatorKey.currentState
            ?.pushNamed('/feedback_form', arguments: event);
      } else if (messageData["type"] == NotificationType.eventUpdate.name) {
        String eventId = messageData["eventId"] ?? "Unknown ID";
        final eventRepo = Get.put(EventRepository());
        Get.put(OrganiserEventController());
        final EventModel? event = await eventRepo.fetchEventById(eventId);

        navigatorKey.currentState
            ?.pushNamed('/organiser_event_details', arguments: event);
      } else if (messageData["type"] == NotificationType.sosAlert.name) {
        navigatorKey.currentState?.pushNamed('/notification_list');
      } else if (messageData["type"] == NotificationType.sosCancel.name) {
        navigatorKey.currentState?.pushNamed('/notification_list');
      }
    }
  }

  Future<void> showNotification(RemoteMessage? message) async {
    if (message == null) return;

    final notification = message.notification;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'Elderly_Community',
      'Elderly Community Notifications',
      channelDescription: 'Notification Channel for Elderly Community',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  Future<String?> getFCMToken() async {
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    return token;
  }

  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      String accessToken = await JWTService.getAccessToken(); // Get OAuth Token

      print(data);
      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": {
            "token": token,
            "notification": {"title": title, "body": body},
            "data": {
              ...data,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification Sent Successfully!");
      } else {
        print("❌ Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}
