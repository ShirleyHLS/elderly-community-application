import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/contacts/models/contact_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/auth/models/user_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../authentication/authentication_repository.dart';

class ContactRepository extends GetxController {
  static ContactRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to search for a user by phone number
  Future<UserModel?> searchUserByPhoneNumber(String phoneNumber) async {
    try {
      final querySnapshot = await _db
          .collection("Users")
          .where("phoneNumber", isEqualTo: phoneNumber.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No user found
      }

      return UserModel.fromSnapshot(querySnapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to store a contact in the current user's Contacts collection
  Future<void> storeContact(String contactUid, String contactName) async {
    try {
      await _db
          .collection('Users')
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .collection('Contacts')
          .doc(contactUid)
          .set({
        'name': contactName,
        'uid': contactUid,
      });
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to fetch contacts
  Future<List<ContactModel>> fetchContact() async {
    try {
      // Get contact list (Only Name & UID from Contacts subcollection)
      final snapshot = await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .collection("Contacts")
          .get();
      List<ContactModel> contacts = snapshot.docs.map((snapshot)=>ContactModel.fromSnapshot(snapshot)).toList();

      // Fetch additional details (profile pic & phone number) from Users collection
      for (var contact in contacts) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _db.collection("Users").doc(contact.contactUid).get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data()!;
          contact.profilePicture = userData['profilePicture'] ?? '';
          contact.phoneNumber = userData['phoneNumber'] ?? '';
        }
      }

      return contacts;

    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
