import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  String name;
  final String email;
  final String role; // elderly, caregiver, event_organiser, admin
  String phoneNumber;
  String gender;
  Timestamp dob;
  final Timestamp createdAt;
  Map<String, dynamic> address;
  String profilePicture;
  // List<Map<String, dynamic>>? contact;
  String deviceToken;

  String? organisationWebsite;
  String? organisationDescription;
  List<String>? businessRegistrationFiles;
  String? organisationStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.gender,
    required this.dob,
    required this.createdAt,
    required this.address,
    required this.profilePicture,
    // this.contact,
    required this.deviceToken,
    // organisation field
    this.organisationWebsite,
    this.organisationDescription,
    this.businessRegistrationFiles,
    this.organisationStatus,
  });

  static UserModel empty() => UserModel(
        id: '',
        name: '',
        email: '',
        role: '',
        phoneNumber: '',
        gender: '',
        dob: Timestamp.fromDate(DateTime(1900, 1, 1)),
        // Default DOB
        createdAt: Timestamp.now(),
        address: {},
        profilePicture: '',
        deviceToken: '',
      );

  /// Convert UserModel to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dob': dob,
      'createdAt': createdAt,
      'address': address,
      'profilePicture': profilePicture,
      'deviceToken': deviceToken,
      if (role == "event organiser") ...{
        'organisationWebsite': organisationWebsite,
        'organisationDescription': organisationDescription,
        'businessRegistrationFiles': businessRegistrationFiles,
        'organisationStatus': organisationStatus,
      }
    };
  }

  /// Factory method to create a UserModel from a Firebase DocumentSnapshot
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        gender: data['gender'] ?? '',
        dob: data['dob'] ?? '',
        createdAt: data['createdAt'] ?? '',
        address: data['address'] ?? {},
        profilePicture: data['profilePicture'] ?? '',
        // contact: List<Map<String, dynamic>>.from(data['contacts'] ?? []),
        deviceToken: data['deviceToken'] ?? '',
        // Organizer fields
        organisationWebsite: data['organisationWebsite'] ?? '',
        organisationDescription: data['organisationDescription'] ?? '',
        organisationStatus: data['organisationStatus'] ?? '',
        businessRegistrationFiles:
            List<String>.from(data['businessRegistrationFiles'] ?? []),
      );
    }
    return empty();
  }
}
