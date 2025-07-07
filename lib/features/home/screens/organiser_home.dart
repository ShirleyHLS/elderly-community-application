import 'package:elderly_community/data/repositories/event/event_repository.dart';
import 'package:elderly_community/features/home/controllers/organiser_home_controller.dart';
import 'package:elderly_community/features/home/screens/widgets/organiser_event_bar_chart.dart';
import 'package:elderly_community/features/home/screens/widgets/greeting_text_widget.dart';
import 'package:elderly_community/features/home/screens/widgets/notification_widget.dart';
import 'package:elderly_community/features/home/screens/widgets/statistics_card_shimmer.dart';
import 'package:elderly_community/features/home/screens/widgets/statistics_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/sizes.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../profile/controllers/user_controller.dart';

class OrganiserHomeScreen extends StatelessWidget {
  const OrganiserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final homeController = Get.put(OrganiserHomeController());
    final notificationController = Get.put(NotificationController());

    // Fetch event statistics and chart data
    homeController.fetchStatistics(controller.user.value.id);
    homeController.fetchEventChartData(controller.user.value.id);

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: GreetingTextWidget(controller: controller),
          actions: [
            NotificationWidget(notificationController: notificationController),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ECSizes.defaultSpace),
        child: Column(
          children: [
            /// Statistics Cards
            Obx(() {
              if (homeController.isLoading.value) {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(4, (index) => const StatisticsCardShimmer()),
                );
              }
              if (homeController.hasError.value) {
                return const Center(child: Text("Failed to load statistics"));
              }
              final stats = homeController.statistics;

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  StatisticsCardWidget(
                    icon: Icons.event,
                    title: "Total Events",
                    value: "${stats['totalEvents']}",
                    bgColor: Colors.red[50]!,
                    iconColor: Colors.red[300]!,
                  ),
                  StatisticsCardWidget(
                    icon: Icons.group,
                    title: "Total Attendees",
                    value: "${stats['totalAttendees']}",
                    bgColor: Colors.green[50]!,
                    iconColor: Colors.green[300]!,
                  ),
                  StatisticsCardWidget(
                    icon: Icons.comment,
                    title: "Total Feedbacks",
                    value: "${stats['totalFeedbacks']}",
                    bgColor: Colors.yellow[50]!,
                    iconColor: Colors.orange[200]!,
                  ),
                  StatisticsCardWidget(
                    icon: Icons.star,
                    title: "Average Ratings",
                    value: "${stats['averageRating']}",
                    bgColor: Colors.purple[50]!,
                    iconColor: Colors.purple[200]!,
                  ),
                ],
              );
            }),
            const SizedBox(height: ECSizes.spaceBtwSections),

            /// Event Chart
            Obx(() {
              if (homeController.isChartLoading.value) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }
              if (homeController.eventChartData.isEmpty) {
                return const Center(child: Text("No upcoming events found."));
              }
              return OrganiserEventBarChart(
                events: homeController.eventChartData,
                title: "Upcoming Event Overview",
              );
            }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
