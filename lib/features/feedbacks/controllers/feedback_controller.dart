import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/feedback/feedback_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../../events/controllers/participant_event_controller.dart';
import '../models/feedback_model.dart';

class FeedbackController extends GetxController {
  static FeedbackController get instance => Get.find();

  final feedbackRepository = Get.put(FeedbackRepository());

  final feedbackFormKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  var selectedRating = 3.obs;
  var isSubmitting = false.obs;

  var feedbackList = <FeedbackModel>[].obs;
  var overallRating = 0.0.obs;
  var totalReviews = 0.obs;
  var isLoading = false.obs;

  void submitFeedback(String eventId, String organisationId) async {
    if (!feedbackFormKey.currentState!.validate()) return;

    isSubmitting.value = true;

    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        isSubmitting.value = false;
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      final feedback = FeedbackModel(
        eventId: eventId,
        userId: UserController.instance.user.value.id,
        organisationId: organisationId,
        feedback: commentController.text.trim(),
        rating: selectedRating.value,
        createdAt: Timestamp.now(),
      );

      await feedbackRepository.saveFeedback(feedback);

      final participantController = ParticipantEventController.instance;
      participantController.hasSubmittedFeedback.value = true;

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Feedback submitted successfully!");
      });

      // Clear form
      commentController.clear();
      selectedRating.value = 3;
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: "Failed to submit feedback: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchFeedback(String eventId) async {
    try {
      isLoading.value = true;
      final feedbacks = await feedbackRepository.getEventFeedback(eventId);
      feedbackList.assignAll(feedbacks);

      // Calculate average rating
      if (feedbacks.isNotEmpty) {
        double total = feedbacks.fold(0, (sum, item) => sum + item.rating);
        overallRating.value = total / feedbacks.length;
        totalReviews.value = feedbacks.length;
      }
    } catch (e) {
      print("Error fetching feedback: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
