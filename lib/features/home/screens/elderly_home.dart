import 'package:elderly_community/features/home/screens/widgets/clock_widget.dart';
import 'package:elderly_community/common/curved_edges.dart';
import 'package:elderly_community/common/quick_button.dart';
import 'package:elderly_community/common/task_tile_widget.dart';
import 'package:elderly_community/features/home/controllers/elderly_home_controller.dart';
import 'package:elderly_community/features/home/screens/widgets/notification_widget.dart';
import 'package:elderly_community/features/reminders/controllers/reminder_controller.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../reminders/screens/widgets/reminder_details_modal.dart';

class ElderlyHomeScreen extends StatelessWidget {
  const ElderlyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ElderlyHomeController controller = Get.put(ElderlyHomeController());
    final ReminderController reminderController = Get.put(ReminderController());
    final notificationController = Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          NotificationWidget(notificationController: notificationController),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomCurvedEdgeWidget(
              child: Container(
                color: ECColors.primary,
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 25),
                child: Column(
                  children: [
                    /// Time Display
                    ClockWidget(),
                    SizedBox(height: ECSizes.spaceBtwItems),

                    Text(
                      "Today's Reminders",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: ECSizes.spaceBtwItems),

                    /// Today's Reminders
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ECSizes.spaceBtwItems),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Scrollable Task List
                            Expanded(
                              child: SingleChildScrollView(
                                child: Obx(() {
                                  if (controller.reminderList.isEmpty) {
                                    return Center(
                                        child: Text("No reminders found."));
                                  }
                                  return Column(
                                    children:
                                        controller.reminderList.map<Widget>(
                                      (reminder) {
                                        DateTime reminderDateTime =
                                            reminder.reminderTime.toDate();
                                        String formattedTime = reminder
                                                .isRecurring
                                            ? "Daily ${DateFormat.jm().format(reminderDateTime)}"
                                            : DateFormat('yyyy-MM-dd hh:mm a')
                                                .format(reminderDateTime);
                                        bool isCompletedToday = reminder
                                                    .lastCompletedDate !=
                                                null &&
                                            ECHelperFunctions
                                                .compareDateWithTodayDate(
                                                    reminder.lastCompletedDate!
                                                        .toDate());
                                        return GestureDetector(
                                          onTap: () => showReminderModal(
                                              context,
                                              reminder,
                                              Reminder.today,
                                              isCompletedToday),
                                          child: TaskTileWidget(
                                            title: reminder.title,
                                            time: formattedTime,
                                            isDone: isCompletedToday,
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ECSizes.spaceBtwItems),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: ECSizes.sm,
                mainAxisSpacing: ECSizes.sm,
                children: [
                  QuickButton(
                    label: "Contact",
                    icon: Icons.quick_contacts_dialer,
                    color: ECColors.buttonContact,
                    onPressed: () => Get.toNamed('/contact'),
                  ),
                  QuickButton(
                    label: "Event",
                    icon: Icons.event,
                    color: ECColors.buttonEvent,
                    onPressed: () => Get.toNamed('/event_list'),
                  ),
                  QuickButton(
                    label: "Reminder",
                    icon: Icons.alarm,
                    color: ECColors.buttonHealth,
                    onPressed: () => Get.toNamed('/reminder'),
                  ),
                  QuickButton(
                    label: "SOS",
                    icon: Icons.warning,
                    color: ECColors.buttonSos,
                    onPressed: () => Get.toNamed('/sos_screen'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
