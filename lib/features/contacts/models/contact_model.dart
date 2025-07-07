import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String contactUid; // From Contacts subcollection
  String name; // From Contacts subcollection
  String phoneNumber; // From Users collection
  String profilePicture; // From Users collection

  ContactModel({
    required this.contactUid,
    required this.name,
    this.phoneNumber = '',
    this.profilePicture = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': contactUid,
      'name': name,
    };
  }

  factory ContactModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return ContactModel(
      contactUid: data['uid'] ?? '',
      name: data['name'] ?? '',
    );
  }
}
