import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  String? id;
  String elderlyId;
  String? eventId;

  // String type;
  String title;
  String description;
  Timestamp reminderTime;
  bool isRecurring;
  Timestamp? lastCompletedDate;

  ReminderModel({
    this.id,
    required this.elderlyId,
    required this.title,
    required this.description,
    required this.reminderTime,
    required this.isRecurring,
    this.eventId,
    this.lastCompletedDate,
  });

  static ReminderModel empty() => ReminderModel(
        id: '',
        elderlyId: '',
        title: '',
        description: '',
        reminderTime: Timestamp.fromDate(DateTime(1900, 1, 1)),
        isRecurring: false,
        eventId: '',
        lastCompletedDate: Timestamp.fromDate(DateTime(1900, 1, 1)),
      );

  /// Convert Reminder to JSON for Firestore
  Map<String, dynamic> toJson() {
    final data = {
      "elderly_id": elderlyId,
      "title": title,
      "description": description,
      "reminder_time": reminderTime,
      "is_recurring": isRecurring,
    };

    // Conditionally add fields if they are not null
    if (id != null) data["id"] = id!;
    if (eventId != null) data["event_id"] = eventId!;
    if (lastCompletedDate != null)
      data["last_completed_date"] = lastCompletedDate!;

    return data;
  }

  /// Convert Firestore JSON to Reminder Object
  factory ReminderModel.fromSnapshot(DocumentSnapshot document) {
    if (document.data() != null) {
      final data = document.data() as Map<String, dynamic>;
      return ReminderModel(
        id: document.id,
        elderlyId: data["elderly_id"],
        eventId: data.containsKey("event_id") ? data["event_id"] : null,
        title: data["title"],
        description: data["description"],
        reminderTime: data["reminder_time"],
        isRecurring: data["is_recurring"],
        lastCompletedDate: data["last_completed_date"] != null
            ? (data["last_completed_date"])
            : null,
      );
    }
    return empty();
  }

  /// Helper method to get reminder time as DateTime (in local time)
  DateTime get reminderDateTime => reminderTime.toDate().toLocal();

  /// Helper method to get last completed date as DateTime (optional)
  DateTime? get lastCompletedDateTime => lastCompletedDate?.toDate().toLocal();
}
