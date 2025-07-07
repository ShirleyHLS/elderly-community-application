import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/enums.dart';

class NotificationModel {
  String? id;
  String userId;
  String title;
  String body;
  Timestamp createdAt;
  NotificationType type;
  bool read;
  Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    required this.read,
    this.data,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      read: map['read'] ?? false,
      type: NotificationType.values.byName(map['type'] ?? 'sosAlert'),
      data: map['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'createdAt': createdAt,
      'type': type.name,
      'data': data ?? {},
      'read': read,
    };
  }
}
