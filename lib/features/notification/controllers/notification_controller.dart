import 'package:elderly_community/data/repositories/feedback/feedback_repository.dart';
import 'package:elderly_community/data/repositories/notification/notification_repository.dart';
import 'package:elderly_community/data/repositories/reminder/reminder_repository.dart';
import 'package:elderly_community/features/elderly_management/controllers/elderly_management_controller.dart';
import 'package:elderly_community/features/reminders/controllers/reminder_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/event/event_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../events/models/event_model.dart';
import '../../reminders/screens/widgets/reminder_details_modal.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();
  final notificationRepository = Get.put(NotificationRepository());
  var notificationList = <NotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchNotifications();
    super.onInit();
  }

  bool get hasUnreadNotifications =>
      notificationList.any((notification) => !notification.read);

  void fetchNotifications() async {
    try {
      isLoading(true);
      final notifications = await notificationRepository.fetchNotifications();

      if (notifications != null) {
        notificationList.assignAll(notifications);

        // await markAllAsRead(notifications);
      } else {
        notificationList.clear();
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching notifications: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> markAllAsRead(List<NotificationModel> notifications) async {
    try {
      // final unreadNotifications =
      // notifications.where((notification) => !notification.read).toList();
      //
      // for (var notification in unreadNotifications) {
      //   await notificationRepository.markAsRead(notification.id!);
      // }
      await notificationRepository.markAsRead(notifications);
      fetchNotifications();
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to mark all as read');
    }
  }

  Future<void> handleClick(NotificationModel notification) async {
    final type = notification.type;
    switch (type) {
      case NotificationType.sosAlert:
        String? latitude = notification.data?["latitude"];
        String? longitude = notification.data?["longitude"];
        if (latitude != null && longitude != null) {
          String googleMapsUrl =
              "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

          if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
            await launchUrl(Uri.parse(googleMapsUrl),
                mode: LaunchMode.externalApplication);
          } else {
            ECLoaders.customToast(message: 'Could not open Google Maps');
            // throw "Could not open Google Maps";
          }
        } else {
          ECLoaders.customToast(message: notification.body);
        }

      case NotificationType.sosCancel:
        ECLoaders.customToast(message: notification.body);

      case NotificationType.elderlyReminder:
        final reminderId = notification.data?["reminderId"];
        if (reminderId != null) {
          final reminder = await ReminderRepository()
              .fetchReminderBasedOnReminderId(reminderId);
          if (reminder.id!.isNotEmpty) {
            showReminderModal(Get.context!, reminder, Reminder.upcoming, false);
          } else {
            ECLoaders.warningSnackBar(
                title: 'Warning', message: 'The reminder does not exist.');
          }
        } else {
          print("Reminder ID not found in notification data.");
        }

      case NotificationType.missedReminder:
        final reminderId = notification.data?["reminderId"];
        if (reminderId != null) {
          final controller = Get.put(ReminderController());
          final elderly = Get.put(ElderlyManagementController());
          final reminder = await ReminderRepository()
              .fetchReminderBasedOnReminderId(reminderId);
          if (reminder.id!.isNotEmpty) {
            showReminderModal(Get.context!, reminder, Reminder.upcoming, false);
          } else {
            ECLoaders.warningSnackBar(
                title: 'Warning', message: 'The reminder does not exist.');
          }
        } else {
          print("Reminder ID not found in notification data.");
        }

      case NotificationType.bindingRequest:
        Get.toNamed('binding');

      case NotificationType.eventFeedback:
        String eventId = notification.data?["eventId"];
        final feedbackRepo = Get.put(FeedbackRepository());
        final hasGivenFeedback = await feedbackRepo.getFeedbackForUser(eventId);
        if (hasGivenFeedback == null) {
          final eventRepo = Get.put(EventRepository());
          final EventModel? event = await eventRepo.fetchEventById(eventId);
          Get.toNamed('/feedback_form', arguments: event);
        } else {
          ECLoaders.customToast(
              message: "You have already submitted feedback for this event.");
        }

      case NotificationType.eventUpdate:
        String eventId = notification.data?["eventId"];
        final eventRepo = EventRepository.instance;
        final EventModel? event = await eventRepo.fetchEventById(eventId);
        Get.toNamed('/organiser_event_details', arguments: event);

      case NotificationType.broadcast:
      case NotificationType.accountUpdate:
    }
  }
}
