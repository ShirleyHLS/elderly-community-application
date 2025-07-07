import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/feedbacks/models/feedback_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../authentication/authentication_repository.dart';

class FeedbackRepository extends GetxController {
  static FeedbackRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveFeedback(FeedbackModel feedback) async {
    try {
      await _db.collection("Feedbacks").doc().set(feedback.toJson());
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

  Future<DocumentSnapshot?> getFeedbackForUser(String eventId) async {
    try {
      final snapshot = await _db
          .collection("Feedbacks")
          .where("eventId", isEqualTo: eventId)
          .where("userId",
              isEqualTo: AuthenticationRepository.instance.authUser?.uid)
          .get();

      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
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

  Future<List<FeedbackModel>> getEventFeedback(String eventId) async {
    try {
      final snapshot = await _db
          .collection("Feedbacks")
          .where("eventId", isEqualTo: eventId)
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception("Error fetching feedback: $e");
    }
  }

  Future<Map<String, dynamic>> fetchFeedbackStatistics(
      String organisationId) async {
    try {
      var feedbackSnapshot = await _db
          .collection('Feedbacks')
          .where('organisationId', isEqualTo: organisationId)
          .get();

      int totalFeedbacks = feedbackSnapshot.docs.length;
      double totalRating = 0.0;

      for (var doc in feedbackSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0.0);
      }

      double averageRating =
          totalFeedbacks > 0 ? totalRating / totalFeedbacks : 0.0;

      return {
        "totalFeedbacks": totalFeedbacks,
        "averageRating": averageRating.toStringAsFixed(2),
      };
    } catch (e) {
      print("Error fetching feedback statistics: $e");
      return {"totalFeedbacks": 0, "averageRating": "0.0"};
    }
  }
}
