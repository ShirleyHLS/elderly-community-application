import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../features/notification/models/notification_model.dart';
import '../authentication/authentication_repository.dart';

class NotificationRepository extends GetxController {
  static NotificationRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _db.collection("Notifications").doc().set(notification.toMap());
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

  Future<List<NotificationModel>?> fetchNotifications() async {
    try {
      final documentSnapshot = await _db
          .collection("Notifications")
          .where("userId",
              isEqualTo: AuthenticationRepository.instance.authUser?.uid)
          .orderBy('createdAt', descending: true)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<NotificationModel> notifications = documentSnapshot.docs
            .map((snapshot) =>
                NotificationModel.fromMap(snapshot.data(), snapshot.id))
            .toList();
        return notifications;
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

  Future<List<NotificationModel>?> fetchNotificationsRelatedToElderly(
      String elderlyId) async {
    try {
      final documentSnapshot = await _db
          .collection("Notifications")
          .where("userId",
              isEqualTo: AuthenticationRepository.instance.authUser?.uid)
          .where("data.elderlyId", isEqualTo: elderlyId)
          .orderBy('createdAt', descending: true)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<NotificationModel> notifications = documentSnapshot.docs
            .map((snapshot) =>
                NotificationModel.fromMap(snapshot.data(), snapshot.id))
            .toList();
        return notifications;
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

  Future<void> markAsRead(List<NotificationModel> notificationList) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var notification in notificationList) {
        if (!notification.read) {
          var docRef = FirebaseFirestore.instance
              .collection('Notifications')
              .doc(notification.id);
          batch.update(docRef, {'read': true});
        }
      }
      await batch.commit();
      // await _db.collection("Notifications").doc(id).update({'read': true});
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }
}
