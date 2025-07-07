import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/events/models/event_category_model.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:get/get.dart';

import '../../../data/repositories/event/event_repository.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/services/notification/fcm_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../../notification/models/notification_model.dart';

class EventManagementController extends GetxController {
  static EventManagementController get instance => Get.find();

  final eventRepository = Get.put(EventRepository());
  final RxList<EventModel> eventList = <EventModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvent(AdminEventStatus.pending);
  }

  Future<void> fetchEvent(AdminEventStatus status) async {
    try {
      isLoading.value = true;
      final events = await eventRepository
          .fetchEventsByStatus(status.toString().split('.').last);
      if (events != null) {
        eventList.assignAll(events);
      } else {
        eventList.clear();
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEventStatus(String eventId, AdminEventStatus newStatus,
      String organisationId, String eventTitle) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      String? organiserDeviceToken =
          await UserRepository.instance.getUserDeviceToken(organisationId);

      final data = {
        'status': newStatus.toString().split('.').last,
      };
      await eventRepository.updateSingleField(eventId, data);

      String actionMessage;
      String notificationMessage;
      if (newStatus == AdminEventStatus.approved) {
        actionMessage = "Event approved successfully!";
        notificationMessage =
            "Your event proposal ($eventTitle) has been approved! 🎉";
      } else if (newStatus == AdminEventStatus.rejected) {
        actionMessage = "Event rejected successfully!";
        notificationMessage =
            "Unfortunately, your event proposal ($eventTitle) was rejected. Please review and resubmit.";
      } else {
        actionMessage = "Event status updated successfully!";
        notificationMessage = "Your event status has been updated.";
      }

      await sendPushNotification(organisationId, organiserDeviceToken ?? '',
          notificationMessage, eventId, newStatus);

      fetchEvent(AdminEventStatus.pending);
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(title: "Success", message: actionMessage);
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> sendPushNotification(
      String organisationId,
      String? organiserDeviceToken,
      String message,
      String eventId,
      AdminEventStatus status) async {
    NotificationModel eventNotification = NotificationModel(
      userId: organisationId,
      title: status == AdminEventStatus.approved
          ? "🎉 Event Approved"
          : "❌ Event Rejected",
      body: message,
      createdAt: Timestamp.now(),
      type: NotificationType.eventUpdate,
      data: {
        "organizationId": organisationId,
        "eventId": eventId,
      },
      read: false,
    );
    final notificationRepo = NotificationRepository.instance;
    await notificationRepo.saveNotification(eventNotification);

    if (organiserDeviceToken != null && organiserDeviceToken.isNotEmpty) {
      await FcmService.sendNotification(
        token: organiserDeviceToken,
        title: status == AdminEventStatus.approved
            ? "🎉 Event Approved"
            : "❌ Event Rejected",
        body: message,
        data: {
          'type': 'eventUpdate',
          'organizationId': organisationId,
          "eventId": eventId,
        },
      );
    }
  }

  bool checkPendingRequests() {
    return eventList.any((event) =>
        event.status == AdminEventStatus.pending.toString().split('.').last);
  }
}
