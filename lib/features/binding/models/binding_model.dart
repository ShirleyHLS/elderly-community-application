import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/utils/constants/enums.dart';

class BindingModel {
  String? id;
  final String caregiverId;
  final String elderlyId;
  String status; // pending, approved, rejected, removed
  final Timestamp createdAt;
  String? elderlyName;
  String? caregiverName;
  String? elderlyProfile;
  String? caregiverProfile;
  String? caregiverDeviceToken;

  BindingModel({
    this.id,
    required this.caregiverId,
    required this.elderlyId,
    required this.status,
    required this.createdAt,
    this.elderlyName,
    this.caregiverName,
  });

  static BindingModel empty() => BindingModel(
        id: '',
        elderlyId: '',
        caregiverId: '',
        status: '',
        createdAt: Timestamp.fromDate(DateTime(1900, 1, 1)),
      );

  Map<String, dynamic> toJson() {
    final data = {
      "caregiver_id": caregiverId,
      "elderly_id": elderlyId,
      "status": status,
      "created_at": createdAt,
    };

    // if (id != null) data["id"] = id!;
    return data;
  }

  factory BindingModel.fromSnapshot(QueryDocumentSnapshot document) {
    if (document.data() != null) {
      final data = document.data() as Map<String, dynamic>;
      return BindingModel(
        id: document.id,
        caregiverId: data["caregiver_id"],
        elderlyId: data["elderly_id"],
        status: data["status"],
        createdAt: data["created_at"],
      );
    }
    return empty();
  }
}
