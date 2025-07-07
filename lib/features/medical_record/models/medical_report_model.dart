import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalReportModel {
  String? id;
  final String elderlyId;
  final List<String> fileUrls;
  final String title;
  final Timestamp createdAt;
  final String recordType;

  MedicalReportModel({
    this.id,
    required this.elderlyId,
    required this.title,
    required this.fileUrls,
    required this.createdAt,
    required this.recordType,
  });

  // Factory method to create an instance from Firestore document
  factory MedicalReportModel.fromSnapshot(DocumentSnapshot document) {
    if (document.data() != null) {
      final data = document.data() as Map<String, dynamic>;
      return MedicalReportModel(
        id: document.id,
        elderlyId: data["elderlyId"],
        fileUrls: List<String>.from(data['fileUrls'] ?? []),
        title: data['title'] ?? '',
        createdAt: data['createdAt'] ?? '',
        recordType: data['recordType'] ?? '',
      );
    }
    return empty();
  }

  // Convert model to Map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'elderlyId': elderlyId,
      'fileUrls': fileUrls,
      'title': title,
      'createdAt': createdAt,
      'recordType': recordType,
    };
  }

  // Empty instance for default values
  static MedicalReportModel empty() {
    return MedicalReportModel(
      id: '',
      elderlyId: '',
      fileUrls: [],
      title: '',
      recordType: '',
      createdAt: Timestamp.fromDate(DateTime(1900, 1, 1)),
    );
  }
}
