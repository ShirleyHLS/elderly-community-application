import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  String? id;
  String eventId;
  String userId;
  String organisationId;
  String feedback; // Suggestions for improvement
  int rating; // Rate your overall satisfaction with the event
  Timestamp createdAt;

  FeedbackModel({
    this.id,
    required this.eventId,
    required this.userId,
    required this.organisationId,
    required this.feedback,
    required this.rating,
    required this.createdAt,
  });

  static FeedbackModel empty() => FeedbackModel(
        id: '',
        eventId: '',
        userId: '',
        organisationId: '',
        feedback: '',
        rating: 0,
        createdAt: Timestamp.fromDate(DateTime(1900, 1, 1)),
      );

  Map<String, dynamic> toJson() => {
        "eventId": eventId,
        "userId": userId,
        "organisationId": organisationId,
        "feedback": feedback,
        "rating": rating,
        "createdAt": createdAt,
      };

  factory FeedbackModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return FeedbackModel(
        id: document.id,
        eventId: data["eventId"] ?? '',
        userId: data["userId"] ?? '',
        organisationId: data["organisationId"] ?? '',
        feedback: data["feedback"] ?? '',
        rating: data["rating"] ?? 0,
        createdAt: data["createdAt"] ?? '',
      );
    }
    return empty();
  }
}
