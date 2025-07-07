import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/reminder/reminder_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';
import '../../reminders/models/reminder_model.dart';

class ElderlyHomeController extends GetxController {
  static ElderlyHomeController get instance => Get.find();
  final reminderRepository = Get.put(ReminderRepository());
  final RxList<ReminderModel> reminderList = <ReminderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodayReminders();
  }

  void fetchTodayReminders() async {
    print("Fetching today reminders");
    try {
      // isLoading(true);
      final reminders = await reminderRepository.fetchTodayReminder();
      if (reminders != null) {
        // Sort reminders: isCompleted false at the top
        reminders.sort((a, b) {
          bool aIsCompleted = a.lastCompletedDate != null &&
              ECHelperFunctions.compareDateWithTodayDate(
                  a.lastCompletedDate!.toDate());
          bool bIsCompleted = b.lastCompletedDate != null &&
              ECHelperFunctions.compareDateWithTodayDate(
                  b.lastCompletedDate!.toDate());
          // Extract only time for sorting
          TimeOfDay aTime = TimeOfDay.fromDateTime(a.reminderDateTime);
          TimeOfDay bTime = TimeOfDay.fromDateTime(b.reminderDateTime);

          // Completed reminders go to the bottom
          if (aIsCompleted) return 1;
          if (bIsCompleted) return -1;

          // Sort by hour and minute
          return (aTime.hour * 60 + aTime.minute)
              .compareTo(bTime.hour * 60 + bTime.minute);
        });
        reminderList.assignAll(reminders);
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching reminders: $e');
    } finally {
      // isLoading(false);
    }
  }
}
