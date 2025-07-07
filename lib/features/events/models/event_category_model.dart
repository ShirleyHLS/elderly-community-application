import 'package:cloud_firestore/cloud_firestore.dart';

class EventCategoryModel {
  String? id;
  String categoryName;
  bool status;

  EventCategoryModel({
    this.id,
    required this.categoryName,
    required this.status,
  });

  static EventCategoryModel empty() => EventCategoryModel(
        id: '',
        categoryName: '',
        status: false,
      );

  factory EventCategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return EventCategoryModel(
        id: document.id,
        categoryName: data['categoryName'] ?? '',
        status: data["status"] ?? '',
      );
    }
    return empty();
  }

  Map<String, dynamic> toJson() {
    final data = {
      'categoryName': categoryName,
      'status': status,
    };
    return data;
  }
}
