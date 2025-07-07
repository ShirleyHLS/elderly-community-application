import 'package:elderly_community/data/services/location/location_service.dart';
import 'package:elderly_community/data/services/notification/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'bindings/general_bindings.dart';
import 'data/repositories/authentication/authentication_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  /// Widgets binding
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  /// Initialise local storage
  await GetStorage.init();

  /// Await native splash until other items load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Initialize firebase & authentication
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then(
    (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );

  // /// Initialise notification
  await FcmService.instance.initialiseFCM();

  /// Initialise location
  // await LocationService.getCurrentLocation();

  await getDatabasesPath();

  await dotenv.load(fileName: ".env");

  runApp(const App());

  // Handle terminated/background notification clicks after UI is ready
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final authRepo = AuthenticationRepository.instance;
    await authRepo.screenRedirect(); // Set the initial home screen first

    await LocationService.initialiseLocation();

    // Check for terminated state (app opened from notification)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("📲 Handling terminated state notification: ${initialMessage.data}");
      FcmService.instance.handleNotificationClick(initialMessage);
    }
  });
}
