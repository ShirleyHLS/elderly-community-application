import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/events/models/event_category_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class EventCategoryRepository extends GetxController {
  static EventCategoryRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCategory(EventCategoryModel category) async {
    try {
      await _db.collection("Event Categories").doc().set(category.toJson());
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

  Future<List<EventCategoryModel>?> fetchEventCategory() async {
    try {
      final documentSnapshot = await _db.collection("Event Categories").get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<EventCategoryModel> categories = documentSnapshot.docs
            .map((snapshot) => EventCategoryModel.fromSnapshot(snapshot))
            .toList();
        return categories;
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

  Future<List<EventCategoryModel>?> fetchAvailableEventCategory() async {
    try {
      final documentSnapshot = await _db
          .collection("Event Categories")
          .where('status', isEqualTo: true)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<EventCategoryModel> categories = documentSnapshot.docs
            .map((snapshot) => EventCategoryModel.fromSnapshot(snapshot))
            .toList();
        return categories;
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

  Future<List<String>> fetchEventCategoryByIds(List<String> categoryIds) async {
    try {
      List<String> categories = [];
      for (String id in categoryIds) {
        DocumentSnapshot categorySnapshot =
            await _db.collection("Event Categories").doc(id).get();
        if (categorySnapshot.exists) {
          String categoryName = categorySnapshot["categoryName"];
          categories.add(categoryName);
        } else {
          categories.add("Unknown Category");
        }
      }
      return categories;
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

  Future<void> updateCategory(EventCategoryModel updatedCategory) async {
    try {
      await _db
          .collection("Event Categories")
          .doc(updatedCategory.id)
          .update(updatedCategory.toJson());
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
