import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderLogModel {
  String id;
  String elderlyId;
  String reminderId;
  bool completed;
  Timestamp createdAt;
  bool notifiedCaregiver;

  ReminderLogModel({
    required this.id,
    required this.elderlyId,
    required this.reminderId,
    required this.completed,
    required this.createdAt,
    required this.notifiedCaregiver,
  });
}
