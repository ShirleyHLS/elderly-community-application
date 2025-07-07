import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/event/event_repository.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/notification/notification_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../elderly_management/controllers/elderly_management_controller.dart';
import '../../notification/models/notification_model.dart';
import '../models/event_model.dart';

class ActivityLogController extends GetxController {
  static ActivityLogController get instance => Get.find();

  final isLoading = false.obs;
  final RxList activityLogs = [].obs;
  final eventRepository = EventRepository.instance;
  final notificationRepository = NotificationRepository.instance;

  @override
  void onInit() {
    super.onInit();
    fetchActivityLogs(
        ElderlyManagementController.instance.elderlyDetail.value.id);
  }

  void fetchActivityLogs(String elderlyId) async {
    try {
      isLoading(true);

      // fetch event logs
      final eventLogs =
          await eventRepository.fetchMyTickets(elderlyId: elderlyId);

      final notificationLogs = await notificationRepository
          .fetchNotificationsRelatedToElderly(elderlyId);

      final combinedLogs = [
        if (eventLogs != null) ...eventLogs,
        if (notificationLogs != null) ...notificationLogs,
      ];
      // Sort the list based on timestamps
      combinedLogs.sort((a, b) {
        Timestamp timeA = (a is EventModel)
            ? a.startDateTime
            : (a as NotificationModel).createdAt;
        Timestamp timeB = (b is EventModel)
            ? b.startDateTime
            : (b as NotificationModel).createdAt;
        return timeB.compareTo(timeA); // Descending order (newest first)
      });

      if (combinedLogs != null) {
        activityLogs.assignAll(combinedLogs);
      } else {
        activityLogs.clear();
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching activity logs: $e');
    } finally {
      isLoading(false);
    }
  }
}
