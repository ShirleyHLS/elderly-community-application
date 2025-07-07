import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:elderly_community/features/reminders/screens/widgets/reminder_details_modal.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/helper_functions.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final Reminder selectedSegment;

  const ReminderCard({
    required this.reminder,
    required this.selectedSegment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateTime reminderDateTime = reminder.reminderDateTime;
    String formattedTime = reminder.isRecurring
        ? "Daily ${DateFormat.jm().format(reminderDateTime)}"
        : DateFormat('yyyy-MM-dd hh:mm a').format(reminderDateTime);
    bool isCompletedToday = selectedSegment != Reminder.upcoming &&
        reminder.lastCompletedDate != null &&
        ECHelperFunctions.compareDateWithTodayDate(
            reminder.lastCompletedDate!.toDate());

    return GestureDetector(
      onTap: () => showReminderModal(
          context, reminder, selectedSegment, isCompletedToday),
      child: Card(
        color: isCompletedToday ? Colors.grey.shade200 : ECColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ListTile(
          title:
              Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 5),
                  Text(formattedTime),
                ],
              ),
            ],
          ),
          trailing: isCompletedToday
              ? const Icon(Icons.check_circle, color: Colors.green, size: 36)
              : null,
        ),
      ),
    );
  }
}
