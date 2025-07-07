import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/authentication/authentication_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class ReminderRepository extends GetxController {
  static ReminderRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save reminder to Firebase
  Future<String?> saveReminder(ReminderModel reminder) async {
    try {
      // await _db.collection("Reminders").doc().set(reminder.toJson());
      DocumentReference docRef = _db.collection("Reminders").doc();
      await docRef.set(reminder.toJson());

      // Return the document ID only if the reminder is created by a caregiver
      return UserController.instance.user.value.role == "caregiver"
          ? docRef.id
          : null;
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

  /// Function to fetch all reminders based on user id
  Future<List<ReminderModel>?> fetchReminder({String? userId}) async {
    try {
      final String uid =
          userId ?? AuthenticationRepository.instance.authUser?.uid ?? '';
      final now = DateTime.now();


      final documentSnapshot = await _db
          .collection("Reminders")
          .where("elderly_id", isEqualTo: uid)
          .orderBy("reminder_time", descending: false)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<ReminderModel> reminders = documentSnapshot.docs
            .map((snapshot) => ReminderModel.fromSnapshot(snapshot))
            .toList();
        return reminders;
      } else {
        return null;
      }
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

  /// Function to fetch today's reminders based on user id
  Future<List<ReminderModel>?> fetchTodayReminder() async {
    try {
      // Get the start and end of today
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Convert to Timestamps
      Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
      Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

      // Query for recurring reminders
      final recurringSnapshot = await _db
          .collection("Reminders")
          .where("elderly_id",
              isEqualTo: AuthenticationRepository.instance.authUser?.uid)
          .where("is_recurring", isEqualTo: true)
          .get();

      // Query for today's reminders
      final todaySnapshot = await _db
          .collection("Reminders")
          .where("elderly_id",
              isEqualTo: AuthenticationRepository.instance.authUser?.uid)
          .where("reminder_time", isGreaterThanOrEqualTo: startTimestamp)
          .where("reminder_time", isLessThanOrEqualTo: endTimestamp)
          .get();

      // Merge the results
      final List<QueryDocumentSnapshot> reminders = [
        ...recurringSnapshot.docs,
        ...todaySnapshot.docs
      ];

      // Remove duplicates if any
      final uniqueReminders =
          {for (var doc in reminders) doc.id: doc}.values.toList();

      if (uniqueReminders.isNotEmpty) {
        List<ReminderModel> reminders = uniqueReminders
            .map((snapshot) => ReminderModel.fromSnapshot(snapshot))
            .toList();
        return reminders;
      } else {
        return null;
      }
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

  /// Function to update any field in specific reminders collection in Firestore
  Future<void> updateSingleField(
      String reminderId, Map<String, dynamic> json) async {
    try {
      await _db.collection("Reminders").doc(reminderId).update(json);
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

  /// Function to update reminder data in Firestore
  Future<void> updateReminder(
      String reminderId, ReminderModel updatedUser) async {
    try {
      await _db
          .collection("Reminders")
          .doc(reminderId)
          .update(updatedUser.toJson());
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

  /// Function to remove reminder from Firestore
  Future<void> removeReminder(String reminderId) async {
    try {
      await _db.collection("Reminders").doc(reminderId).delete();
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

  /// Function to remove reminder from Firestore
  Future<ReminderModel> fetchReminderBasedOnReminderId (String reminderId) async {
    try {
      final documentSnapshot = await _db.collection("Reminders").doc(reminderId).get();
      if (documentSnapshot.exists) {
        return ReminderModel.fromSnapshot(documentSnapshot);
      } else {
        return ReminderModel.empty();
      }
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
