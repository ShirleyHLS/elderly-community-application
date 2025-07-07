import 'package:elderly_community/data/repositories/event/event_repository.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:get/get.dart';

class AdminHomeController extends GetxController {
  static AdminHomeController get instance => Get.find();

  var statistics = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var hasEventError = false.obs;
  final userRepo = Get.put(UserRepository());
  final eventRepo = Get.put(EventRepository());

  var eventCountByMonth = <String, int>{}.obs;
  var eventCountByYear = <String, int>{}.obs;
  var todayEventList = <EventModel>[].obs;
  var isChartLoading = true.obs;

  Future<void> fetchStatistics() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      statistics.value = await userRepo.fetchUserStatistics();
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventStatistics() async {
    try {
      isChartLoading.value = true;
      hasEventError.value = false;
      // Fetch all event counts in a single query
      var stats = await eventRepo.fetchEventCounts();

      eventCountByMonth.value = stats["monthlyCounts"];
      eventCountByYear.value = stats["yearlyCounts"];
      todayEventList.assignAll(stats["todayEvents"]);
    } catch (e) {
      hasEventError.value = true;
      print("Error fetching event statistics: $e");
    } finally {
      hasEventError.value = false;
      isChartLoading.value = false;
    }
  }
}
