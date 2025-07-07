import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';

import 'location_model.dart';

class EventModel {
  String? id;
  String title;
  String description;
  Timestamp startDateTime;
  Timestamp endDateTime;
  String organizationId;
  LocationModel location;
  int maxParticipants;
  String status; // pending, approved, rejected
  List<String> images;
  Timestamp createdAt;
  List<String> registrations;
  List<String> categoryIds;
  String? organizationName;
  double? distance;
  bool? feedbackCollected;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.organizationId,
    required this.location,
    required this.maxParticipants,
    required this.registrations,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.categoryIds,
    this.feedbackCollected,
  });

  static EventModel empty() => EventModel(
        id: '',
        title: '',
        description: '',
        startDateTime: Timestamp.fromDate(DateTime(1900, 1, 1)),
        endDateTime: Timestamp.fromDate(DateTime(1900, 1, 1)),
        organizationId: '',
        categoryIds: [],
        location: LocationModel.empty(),
        maxParticipants: 0,
        registrations: [],
        status: '',
        images: [],
        createdAt: Timestamp.fromDate(DateTime(1900, 1, 1)),
        feedbackCollected: false,
      );

  /// Convert Firestore JSON to Event Object
  factory EventModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return EventModel(
        id: document.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        startDateTime: data['startDateTime'],
        endDateTime: data['endDateTime'],
        organizationId: data['organizationId'] ?? '',
        categoryIds: List<String>.from(data['categoryIds'] ?? []),
        location: LocationModel.fromMap(data['location']),
        maxParticipants: data['maxParticipants'] ?? 0,
        registrations: List<String>.from(data['registrations'] ?? []),
        status: data['status'] ?? '',
        images: List<String>.from(data['images'] ?? []),
        createdAt: data['createdAt'] ?? '',
        feedbackCollected: data['feedbackCollected'] ?? false,
      );
    }
    return empty();
  }

  /// Convert Event to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "startDateTime": startDateTime,
      "endDateTime": endDateTime,
      "organizationId": organizationId,
      "categoryIds": categoryIds,
      "location": location.toJson(),
      "maxParticipants": maxParticipants,
      "registrations": registrations,
      "status": status,
      "images": images,
      "createdAt": createdAt,
      "feedbackCollected": feedbackCollected ?? false,
    };
  }
}
