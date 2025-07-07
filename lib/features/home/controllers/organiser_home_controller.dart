import 'package:elderly_community/data/repositories/feedback/feedback_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../../../data/repositories/event/event_repository.dart';
import '../../events/models/event_bar_data_model.dart';

class OrganiserHomeController extends GetxController {
  static OrganiserHomeController get instance => Get.find();
  var statistics = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  final eventRepo = Get.put(EventRepository());
  final feedbackRepo = Get.put(FeedbackRepository());

  var eventChartData = <EventData>[].obs;
  var isChartLoading = true.obs;

  void fetchStatistics(String organizerId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      var eventStats = await eventRepo.fetchEventStatistics(organizerId);
      var feedbackStats =
          await feedbackRepo.fetchFeedbackStatistics(organizerId);

      statistics.value = {
        ...eventStats,
        ...feedbackStats,
      };
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void fetchEventChartData(String organizerId) async {
    try {
      isChartLoading.value = true;
      eventChartData.value =
          await eventRepo.fetchEventChartData(organizerId: organizerId);
    } catch (e) {
      hasError.value = true;
    } finally {
      isChartLoading.value = false;
    }
  }
}
