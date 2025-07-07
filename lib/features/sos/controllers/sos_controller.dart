import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/binding/binding_repository.dart';
import 'package:elderly_community/data/repositories/notification/notification_repository.dart';
import 'package:elderly_community/data/services/location/location_service.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import '../../../data/services/notification/fcm_service.dart';
import '../../notification/models/notification_model.dart';

class SOSController extends GetxController {
  RxBool isActivated = false.obs;
  Timer? _pressTimer;
  var caregiverList = [];

  void startPressTimer() {
    _pressTimer = Timer(const Duration(seconds: 3), () async {
      isActivated.value = !isActivated.value;
      // ECLoaders.errorSnackBar(
      //   title: isActivated.value ? "SOS Activated" : "SOS Deactivated",
      //   message: isActivated.value
      //       ? "Your location has been shared with emergency contacts."
      //       : "SOS has been deactivated.",
      // );
      if (isActivated.value) {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
        }
        await sendLocationToCaregiver();
      }
      if (!isActivated.value) {
        Vibration.cancel();
        await sendCancelNotification();
      }
    });
  }

  void cancelPressTimer() {
    _pressTimer?.cancel();
    _pressTimer = null;
  }

  @override
  void onClose() {
    cancelPressTimer();
    Vibration.cancel();
    super.onClose();
  }

  Future<void> sendLocationToCaregiver() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      double? lat, lng;
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      } else {
        ECLoaders.warningSnackBar(
            title: 'Location Disabled', message: 'SOS sent without location.');
      }

      /// Fetch caregiver details
      caregiverList =
          await BindingRepository.instance.fetchBindings('elderly') ?? [];

      if (caregiverList.isEmpty) {
        ECLoaders.errorSnackBar(
          title: "No Caregiver Found",
          message: "No caregiver is linked to your profile.",
        );
        return;
      }

      /// Send notifications to caregivers
      for (var binding in caregiverList) {
        String caregiverId = binding.caregiverId;
        String? caregiverToken = binding.caregiverDeviceToken;
        String status = binding.status;

        if (caregiverToken != null &&
            caregiverToken.isNotEmpty &&
            status == BindingStatus.approved.toString().split('.').last) {
          if (lat != null && lng != null) {
            await sendPushNotification(caregiverId, caregiverToken, lat, lng);
          } else {
            // Optionally notify the caregiver with no location
            await sendPushNotificationWithoutLocation(
                caregiverId, caregiverToken);
          }
        }
      }

      ECLoaders.successSnackBar(
        title: "SOS Activated",
        message: "Your SOS alert has been sent to your caregivers.",
      );
    } catch (e) {
      ECLoaders.errorSnackBar(
        title: "Error Activating SOS",
        message: e.toString(),
      );
    }
  }

  Future<void> sendPushNotification(String caregiverId,
      String caregiverDeviceToken, double lat, double lng) async {
    NotificationModel sosNotification = NotificationModel(
      userId: caregiverId,
      title: "🚨 SOS Alert!",
      body:
          "The elderly person (${UserController.instance.user.value.name}) needs help. Tap to view location.",
      createdAt: Timestamp.now(),
      type: NotificationType.sosAlert,
      data: {
        "latitude": lat.toString(),
        "longitude": lng.toString(),
        "elderlyId": UserController.instance.user.value.id,
      },
      read: false,
    );

    final notificationRepo = Get.put(NotificationRepository());

    await notificationRepo.saveNotification(sosNotification);

    await FcmService.sendNotification(
      token: caregiverDeviceToken,
      title: "🚨 SOS Alert",
      body:
          "The elderly person (${UserController.instance.user.value.name}) needs help. Location: ($lat, $lng)",
      data: {
        'type': NotificationType.sosAlert.name,
        'caregiverId': caregiverId,
        'elderlyId': UserController.instance.user.value.id,
        'latitude': lat.toString(),
        'longitude': lng.toString(),
      },
    );
  }

  Future<void> sendPushNotificationWithoutLocation(
      String caregiverId, String caregiverToken) async {
    NotificationModel sosNotification = NotificationModel(
      userId: caregiverId,
      title: "🚨 SOS Alert!",
      body:
          "The elderly person (${UserController.instance.user.value.name}) needs help. Location unavailable.",
      createdAt: Timestamp.now(),
      type: NotificationType.sosAlert,
      data: {
        "elderlyId": UserController.instance.user.value.id,
      },
      read: false,
    );

    final notificationRepo = Get.put(NotificationRepository());

    await notificationRepo.saveNotification(sosNotification);

    await FcmService.sendNotification(
      token: caregiverToken,
      title: "🚨 SOS Alert",
      body:
          "The elderly person (${UserController.instance.user.value.name}) needs help. Location unavailable.",
      data: {
        'type': NotificationType.sosAlert.name,
        'caregiverId': caregiverId,
        'elderlyId': UserController.instance.user.value.id,
      },
    );
  }

  Future<void> sendCancelNotification() async {
    try {
      if (caregiverList.isEmpty) {
        ECLoaders.errorSnackBar(
          title: "No Caregiver Found",
          message: "No caregiver is linked to your profile.",
        );
        return;
      }

      for (var binding in caregiverList) {
        String caregiverId = binding.caregiverId;
        String? caregiverToken = binding.caregiverDeviceToken;
        String status = binding.status;

        if (caregiverToken != null &&
            caregiverToken.isNotEmpty &&
            status == BindingStatus.approved.toString().split('.').last) {
          NotificationModel cancelNotification = NotificationModel(
            userId: caregiverId,
            title: "🚨 SOS Canceled",
            body:
                "The elderly person (${UserController.instance.user.value.name}) has canceled the SOS alert.",
            createdAt: Timestamp.now(),
            type: NotificationType.sosCancel,
            data: {
              "elderlyId": UserController.instance.user.value.id,
            },
            read: false,
          );

          final notificationRepo = Get.put(NotificationRepository());

          await notificationRepo.saveNotification(cancelNotification);

          await FcmService.sendNotification(
            token: caregiverToken,
            title: "🚨 SOS Canceled",
            body: "The elderly person has canceled the SOS alert.",
            data: {
              'type': 'sosCancel',
              'caregiverId': caregiverId,
              'elderlyId': UserController.instance.user.value.id,
            },
          );
        }
      }
      ECLoaders.successSnackBar(
        title: "SOS Deactivated",
        message: "SOS has been deactivated.",
      );
    } catch (e) {
      ECLoaders.errorSnackBar(
        title: "Error Sending Cancellation",
        message: e.toString(),
      );
    }
  }
}
