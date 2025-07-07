import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/reminder_model.dart';

class ReminderDetailsScreen extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderDetailsScreen({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reminder.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
              Get.toNamed('/edit_reminder', arguments: reminder);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  reminder.isRecurring
                      ? DateFormat.jm().format(
                          reminder.reminderTime.toDate()) // Show time only
                      : DateFormat('dd/MM/yyyy h:mm a').format(
                          reminder.reminderTime.toDate()), // Show date & time
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              reminder.description ?? "No description provided.",
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Get.back(); // Go back
                  },
                  child: Text("Back", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    // Mark as completed logic
                  },
                  child:
                      Text("Completed", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
