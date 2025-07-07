import 'package:elderly_community/features/reminders/controllers/reminder_controller.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../models/reminder_model.dart';

void showReminderModal(BuildContext context, ReminderModel reminder,
    Reminder selectedSegment, bool isCompleted) {
  final controller = ReminderController.instance;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Title
                  Flexible(
                    child: Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  /// Edit button
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Get.back(); // Close modal
                          Get.toNamed('/reminder_form', arguments: reminder);
                        },
                      ),

                      /// Delete button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Delete Confirmation",
                            middleText: "Are you sure you want to delete this reminder?",
                            textConfirm: "Yes",
                            textCancel: "No",
                            confirmTextColor: Colors.white,
                            cancelTextColor: Colors.black,
                            buttonColor: ECColors.error,
                            onConfirm: () {
                              Get.back(); // Close the dialog
                              controller.deleteReminder(reminder.id!);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: ECSizes.spaceBtwSections),

              /// Reminder Date and Time
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    reminder.isRecurring
                        ? "Daily ${DateFormat.jm().format(reminder.reminderTime.toDate())}" // Only time (hh:mm AM/PM)
                        : DateFormat('yyyy-MM-dd hh:mm a')
                            .format(reminder.reminderTime.toDate()),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              SizedBox(height: ECSizes.spaceBtwSections),

              /// Description
              Text(
                "Description: ${reminder.description}" ??
                    "No description provided.",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: ECSizes.spaceBtwSections),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Back button
                  ElevatedButton(
                    style:
                        Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              backgroundColor:
                                  WidgetStateProperty.all(ECColors.error),
                              side: WidgetStateProperty.all(
                                  BorderSide(color: ECColors.error)),
                            ),
                    onPressed: () {
                      Get.back(); // Close modal
                    },
                    child: Text("Back", style: TextStyle(color: Colors.white)),
                  ),

                  /// Completed button
                  if (selectedSegment == Reminder.today)
                    ElevatedButton(
                      style:
                          Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                backgroundColor: !isCompleted
                                    ? WidgetStateProperty.all(ECColors.success)
                                    : WidgetStateProperty.all(
                                        ECColors.buttonDisabled),
                                side: WidgetStateProperty.all(BorderSide(
                                    color: !isCompleted
                                        ? ECColors.success
                                        : ECColors.buttonDisabled)),
                              ),
                      onPressed: !isCompleted
                          ? () {
                              // Show confirmation dialog before marking as completed
                              Get.defaultDialog(
                                title: "Mark as Completed",
                                middleText:
                                    "Are you sure you want to mark this reminder as completed?",
                                textConfirm: "Yes",
                                textCancel: "No",
                                confirmTextColor: Colors.white,
                                cancelTextColor: Colors.black,
                                buttonColor: ECColors.success,
                                onConfirm: () {
                                  Get.back(); // Close dialog
                                  controller.markReminderAsCompleted(reminder);
                                },
                              );
                            }
                          : null,
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Completed",
                              style: TextStyle(color: Colors.white))),
                    ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
