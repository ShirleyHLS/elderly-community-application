import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/reminders/controllers/reminder_controller.dart';
import 'package:elderly_community/features/reminders/screens/widgets/reminder_card.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../models/reminder_model.dart';

class CaregiverReminderListScreen extends StatelessWidget {
  const CaregiverReminderListScreen({
    super.key,
    required this.bindingIndex,
  });

  final int bindingIndex;

  @override
  Widget build(BuildContext context) {
    final bindingController = BindingController.instance;
    final reminderController = Get.put(ReminderController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final elderlyId = bindingController.bindingList[bindingIndex].elderlyId;
      reminderController.fetchReminders(userId: elderlyId);
    });

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Obx(() => Text(
              '${bindingController.bindingList[bindingIndex].elderlyName!}\'s Reminder')),
        ),
      ),
      body: Obx(() {
        if (reminderController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (reminderController.reminderList.isEmpty) {
          return Center(child: Text("No reminders found"));
        }

        List<ReminderModel> upcomingReminders =
            reminderController.getFilteredReminders(Reminder.upcoming);
        List<ReminderModel> todayReminders =
            reminderController.getFilteredReminders(Reminder.today);
        List<ReminderModel> dailyReminders =
            reminderController.getFilteredReminders(Reminder.daily);

        if (dailyReminders.isEmpty &&
            todayReminders.isEmpty &&
            upcomingReminders.isEmpty) {
          return Center(child: Text("No reminders found."));
        }

        return ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            if (todayReminders.isNotEmpty) ...[
              Text("Today Reminders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: ECSizes.sm),
              Column(
                children: todayReminders
                    .map((reminder) => ReminderCard(
                          reminder: reminder,
                          selectedSegment: Reminder.upcoming,
                        ))
                    .toList(),
              ),
              SizedBox(height: ECSizes.md),
            ],
            if (upcomingReminders.isNotEmpty) ...[
              Text("Upcoming Reminders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: ECSizes.sm),
              Column(
                children: upcomingReminders
                    .map((reminder) => ReminderCard(
                          reminder: reminder,
                          selectedSegment: Reminder.upcoming,
                        ))
                    .toList(),
              ),
              SizedBox(height: ECSizes.md),
            ],
            if (dailyReminders.isNotEmpty) ...[
              Text("Daily Reminders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: ECSizes.sm),
              Column(
                children: dailyReminders
                    .map((reminder) => ReminderCard(
                          reminder: reminder,
                          selectedSegment: Reminder.daily,
                        ))
                    .toList(),
              ),
            ],
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed('/reminder_form'),
        backgroundColor: ECColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
