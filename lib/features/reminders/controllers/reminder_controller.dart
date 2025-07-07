import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/reminder/reminder_repository.dart';
import 'package:elderly_community/features/elderly_management/controllers/elderly_management_controller.dart';
import 'package:elderly_community/features/home/controllers/elderly_home_controller.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';

import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/services/notification/fcm_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../../notification/models/notification_model.dart';

class ReminderController extends GetxController {
  static ReminderController get instance => Get.find();

  /// Add new reminder
  final title = TextEditingController();
  final description = TextEditingController();
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();
  final RxBool isRecurring = false.obs;
  GlobalKey<FormState> addReminderFormKey = GlobalKey<FormState>();

  /// Validation Messages
  final RxBool dateTimeError = false.obs;

  final isLoading = false.obs;
  final RxList<ReminderModel> reminderList = <ReminderModel>[].obs;
  final reminderRepository = Get.put(ReminderRepository());

  @override
  void onInit() {
    super.onInit();
    if (UserController.instance.user.value.role == "elderly") {
      fetchReminders();
    }
  }

  // void fetchReminderBasedOnRole({String? elderlyId}) {
  //   if (UserController.instance.user.value.role == "elderly") {
  //     fetchReminders();
  //   } else {
  //     fetchReminders(userId: elderlyId);
  //   }
  // }

  void fetchReminders({String? userId}) async {
    try {
      isLoading(true);
      final reminders = await reminderRepository.fetchReminder(userId: userId);
      if (reminders != null) {
        reminderList.assignAll(reminders);
      } else {
        reminderList.clear();
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching reminders: $e');
    } finally {
      isLoading(false);
    }
  }

  List<ReminderModel> getFilteredReminders(Reminder selectedSegment) {
    DateTime now = DateTime.now();
    List<ReminderModel> filteredReminders = reminderList.where((reminder) {
      DateTime reminderDate = reminder.reminderDateTime;
      bool isRecurring = reminder.isRecurring;

      switch (selectedSegment) {
        case Reminder.today:
          return UserController.instance.user.value.role == "elderly"
              ? isRecurring ||
                  (reminderDate.year == now.year &&
                      reminderDate.month == now.month &&
                      reminderDate.day == now.day)
              : (!isRecurring) &&
                  (reminderDate.year == now.year &&
                      reminderDate.month == now.month &&
                      reminderDate.day == now.day);
        case Reminder.daily:
          return isRecurring;
        case Reminder.upcoming:
          DateTime endOfToday =
              DateTime(now.year, now.month, now.day, 23, 59, 59);
          return !isRecurring && reminderDate.isAfter(endOfToday);
      }
    }).toList();

    // Sorting logic only for Today and Daily reminders
    if (selectedSegment == Reminder.today ||
        selectedSegment == Reminder.daily) {
      filteredReminders.sort((a, b) {
        bool aCompleted = a.lastCompletedDate != null &&
            ECHelperFunctions.compareDateWithTodayDate(
                a.lastCompletedDate!.toDate());
        bool bCompleted = b.lastCompletedDate != null &&
            ECHelperFunctions.compareDateWithTodayDate(
                b.lastCompletedDate!.toDate());

        // Extract only time for sorting
        TimeOfDay aTime = TimeOfDay.fromDateTime(a.reminderDateTime);
        TimeOfDay bTime = TimeOfDay.fromDateTime(b.reminderDateTime);

        // Completed reminders go to the bottom
        if (aCompleted) return 1;
        if (bCompleted) return -1;

        // Sort by hour and minute
        return (aTime.hour * 60 + aTime.minute)
            .compareTo(bTime.hour * 60 + bTime.minute);
      });
    }

    return filteredReminders;
  }

  /// Pick Date & Time (Single Field)
  void pickDateTime() async {
    if (isRecurring.value) {
      // Pick Time only

      TimeOfDay? pickedTime = await showIntervalTimePicker(
        context: Get.context!,
        initialTime:
            ECHelperFunctions.roundToNearestFiveMinutes(TimeOfDay.now()),
        interval: 5,
        visibleStep: VisibleStep.fifths,
      );

      if (pickedTime != null) {
        dateTimeError.value = false;
        selectedDateTime.value = DateTime(
          0, 0, 0, // Placeholder date for recurring
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    } else {
      // Pick Date and Time
      DateTime? pickedDate = await showDatePicker(
        context: Get.context!,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        TimeOfDay? pickedTime = await showIntervalTimePicker(
          context: Get.context!,
          initialTime:
              ECHelperFunctions.roundToNearestFiveMinutes(TimeOfDay.now()),
          interval: 5,
          visibleStep: VisibleStep.fifths,
        );

        if (pickedTime != null) {
          dateTimeError.value = false;
          selectedDateTime.value = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
    }
  }

  void clearFields() {
    title.clear();
    description.clear();
    selectedDateTime.value = null;
    isRecurring.value = false;
    dateTimeError.value = false;
  }

  bool validateFields() {
    bool isValid = true;
    if (selectedDateTime.value == null) {
      dateTimeError.value = true;
      isValid = false;
    }
    return isValid;
  }

  Future<void> addReminder() async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      // Validate fields
      bool fieldsValid = validateFields();
      bool formValid = addReminderFormKey.currentState!.validate();
      if (!fieldsValid || !formValid) {
        return;
      }

      String elderlyId;
      if (UserController.instance.user.value.role == "elderly") {
        elderlyId = UserController.instance.user.value.id;
      } else {
        elderlyId = ElderlyManagementController.instance.elderlyDetail.value.id;
      }

      final newReminder = ReminderModel(
        elderlyId: elderlyId,
        title: title.text.trim(),
        description: description.text.trim(),
        reminderTime: isRecurring.value
            ? Timestamp.fromDate(DateTime.now().copyWith(
                hour: selectedDateTime.value!.hour,
                minute: selectedDateTime.value!.minute))
            : Timestamp.fromDate(selectedDateTime.value!),
        isRecurring: isRecurring.value,
      );

      // Store the reminder
      String? reminderId = await reminderRepository.saveReminder(newReminder);
      if (UserController.instance.user.value.role == "elderly") {
        fetchReminders();
        ElderlyHomeController.instance.fetchTodayReminders();
      }

      if (UserController.instance.user.value.role != "elderly") {
        fetchReminders(userId: elderlyId);
        await sendPushNotification(
          elderlyId,
          ElderlyManagementController.instance.elderlyDetail.value.deviceToken,
          title.text.trim(),
          description.text.trim(),
          reminderId!,
          "added",
        );
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Reminder added successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void markReminderAsCompleted(ReminderModel reminder) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      final completedJson = {'last_completed_date': Timestamp.now()};
      await reminderRepository.updateSingleField(
          reminder.id.toString(), completedJson);
      if (UserController.instance.user.value.role == "elderly") {
        fetchReminders();
        ElderlyHomeController.instance.fetchTodayReminders();
      }

      Get.back(); // Close modal
      ECLoaders.successSnackBar(
          title: 'Success', message: 'Reminder marked as completed today!');
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void editReminder(String reminderId) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      // Validate fields
      bool fieldsValid = validateFields();
      bool formValid = addReminderFormKey.currentState!.validate();
      if (!fieldsValid || !formValid) {
        return;
      }

      String elderlyId;
      if (UserController.instance.user.value.role == "elderly") {
        elderlyId = UserController.instance.user.value.id;
      } else {
        elderlyId = ElderlyManagementController.instance.elderlyDetail.value.id;
      }

      final updatedReminder = ReminderModel(
        elderlyId: elderlyId,
        title: title.text.trim(),
        description: description.text.trim(),
        reminderTime: isRecurring.value
            ? Timestamp.fromDate(DateTime.now().copyWith(
                hour: selectedDateTime.value!.hour,
                minute: selectedDateTime.value!.minute))
            : Timestamp.fromDate(selectedDateTime.value!),
        isRecurring: isRecurring.value,
      );

      // Store the reminder
      await reminderRepository.updateReminder(reminderId, updatedReminder);
      if (UserController.instance.user.value.role == "elderly") {
        fetchReminders();
        ElderlyHomeController.instance.fetchTodayReminders();
      }

      if (UserController.instance.user.value.role != "elderly") {
        fetchReminders(userId: elderlyId);
        await sendPushNotification(
          elderlyId,
          ElderlyManagementController.instance.elderlyDetail.value.deviceToken,
          title.text.trim(),
          description.text.trim(),
          reminderId,
          "edited",
        );
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Reminder edited successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void deleteReminder(String reminderId) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      ReminderModel? reminderToDelete = reminderList
          .firstWhereOrNull((reminder) => reminder.id == reminderId);

      // Store the reminder
      await reminderRepository.removeReminder(reminderId);
      if (UserController.instance.user.value.role == "elderly") {
        fetchReminders();
        ElderlyHomeController.instance.fetchTodayReminders();
      }

      if (UserController.instance.user.value.role != "elderly") {
        String elderlyId =
            ElderlyManagementController.instance.elderlyDetail.value.id;
        fetchReminders(userId: elderlyId);
        await sendPushNotification(
          elderlyId,
          ElderlyManagementController.instance.elderlyDetail.value.deviceToken,
          reminderToDelete!.title,
          reminderToDelete.description,
          reminderId,
          "deleted",
        );
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Reminder deleted successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> sendPushNotification(
      String elderlyId,
      String elderlyDeviceToken,
      String title,
      String description,
      String reminderId,
      String action) async {
    NotificationModel reminderNotification = NotificationModel(
      userId: elderlyId,
      title: "🕒 Reminder ($title)",
      body:
          "Your caregiver (${UserController.instance.user.value.name}) has $action a reminder. $description",
      createdAt: Timestamp.now(),
      type: NotificationType.elderlyReminder,
      data: {
        "reminderId": reminderId,
        "elderlyId": elderlyId,
      },
      read: false,
    );

    final notificationRepo = NotificationRepository.instance;

    await notificationRepo.saveNotification(reminderNotification);

    if (elderlyDeviceToken.isNotEmpty) {
      await FcmService.sendNotification(
        token: elderlyDeviceToken,
        title: "🕒 Reminder ($title)",
        body:
            "Your caregiver (${UserController.instance.user.value.name}) has $action a reminder. $description",
        data: {
          'type': 'elderlyReminder',
          "reminderId": reminderId,
          "elderlyId": elderlyId,
        },
      );
    }
  }
}
