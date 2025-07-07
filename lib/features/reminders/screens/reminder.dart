import 'package:elderly_community/features/reminders/controllers/reminder_controller.dart';
import 'package:elderly_community/features/reminders/screens/widgets/reminder_card.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../models/reminder_model.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  ReminderController controller = ReminderController.instance;
  Reminder selectedSegment = Reminder.today;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Reminder"),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CupertinoSlidingSegmentedControl<Reminder>(
              groupValue: selectedSegment,
              backgroundColor: Colors.grey[200] ?? Colors.grey,
              thumbColor: ECColors.buttonPrimary,
              padding: const EdgeInsets.all(4),
              onValueChanged: (Reminder? value) {
                if (value != null) {
                  setState(() {
                    selectedSegment = value;
                  });
                }
              },
              children: <Reminder, Widget>{
                Reminder.today: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Today",
                    style: selectedSegment == Reminder.today
                        ? TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)
                        : TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Reminder.daily: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Daily",
                    style: selectedSegment == Reminder.daily
                        ? TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)
                        : TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Reminder.upcoming: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Upcoming",
                    style: selectedSegment == Reminder.upcoming
                        ? TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)
                        : TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              List<ReminderModel> filteredReminders = controller.getFilteredReminders(selectedSegment);

              // Filter reminders based on the selected segment
              // DateTime now = DateTime.now();
              // List<ReminderModel> filteredReminders =
              //     controller.reminderList.where((reminder) {
              //   DateTime reminderDate = reminder.reminderDateTime;
              //   bool isRecurring = reminder.isRecurring;
              //   if (selectedSegment == Reminder.today) {
              //     return isRecurring ||
              //         (reminderDate.year == now.year &&
              //             reminderDate.month == now.month &&
              //             reminderDate.day == now.day);
              //   } else {
              //     return isRecurring || (reminderDate.isAfter(now));
              //   }
              // }).toList();
              //
              // // Sort reminders: Incomplete at the top, completed at the bottom
              // filteredReminders.sort((a, b) {
              //   bool aCompleted = a.lastCompletedDate != null &&
              //       ECHelperFunctions.compareDateWithTodayDate(
              //           a.lastCompletedDate!.toDate());
              //   bool bCompleted = b.lastCompletedDate != null &&
              //       ECHelperFunctions.compareDateWithTodayDate(
              //           b.lastCompletedDate!.toDate());
              //
              //   return aCompleted
              //       ? 1
              //       : bCompleted
              //           ? -1
              //           : 0;
              // });

              if (filteredReminders.isEmpty) {
                return Center(child: Text("No reminders found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredReminders.length,
                itemBuilder: (context, index) {
                  final reminder = filteredReminders[index];
                  return ReminderCard(
                    reminder: reminder,
                    selectedSegment: selectedSegment,
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed('/reminder_form'),
        backgroundColor: ECColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
