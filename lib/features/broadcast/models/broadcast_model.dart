import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastModel {
  String? id;
  String title;
  String body;
  List<String> roles;
  Timestamp createdAt;
  String createdBy;

  BroadcastModel({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.roles,
    required this.createdBy,
  });

  factory BroadcastModel.fromMap(Map<String, dynamic> map, String docId) {
    return BroadcastModel(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
      roles: List<String>.from(map['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'roles': roles,
    };
  }
}
