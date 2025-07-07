import 'package:elderly_community/features/home/screens/widgets/admin_event_bar_chart.dart';
import 'package:elderly_community/features/home/screens/widgets/greeting_text_widget.dart';
import 'package:elderly_community/features/home/screens/widgets/notification_widget.dart';
import 'package:elderly_community/features/home/screens/widgets/statistics_card_shimmer.dart';
import 'package:elderly_community/features/home/screens/widgets/statistics_card_widget.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../notification/controllers/notification_controller.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final homeController = Get.put(AdminHomeController());
    final notificationController = Get.put(NotificationController());

    homeController.fetchStatistics();
    homeController.fetchEventStatistics();

    Future<void> refreshData() async {
      await Future.wait([
        homeController.fetchStatistics(),
        homeController.fetchEventStatistics(),
      ]);
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: GreetingTextWidget(controller: controller),
          // actions: [
          //   NotificationWidget(notificationController: notificationController),
          // ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
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
                    children: List.generate(
                        4, (index) => const StatisticsCardShimmer()),
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
                      icon: Icons.elderly,
                      title: "Elderly Users",
                      value: "${stats['totalElderly']}",
                      bgColor: Colors.red[50]!,
                      iconColor: Colors.red[300]!,
                    ),
                    StatisticsCardWidget(
                      icon: Icons.handshake_rounded,
                      title: "Caregivers",
                      value: "${stats['totalCaregivers']}",
                      bgColor: Colors.green[50]!,
                      iconColor: Colors.green[300]!,
                    ),
                    StatisticsCardWidget(
                      icon: Icons.event,
                      title: "Event Organisers",
                      value: "${stats['totalOrganisers']}",
                      bgColor: Colors.yellow[50]!,
                      iconColor: Colors.orange[200]!,
                    ),
                    StatisticsCardWidget(
                      icon: Icons.admin_panel_settings,
                      title: "Admins",
                      value: "${stats['totalAdmins']}",
                      bgColor: Colors.purple[50]!,
                      iconColor: Colors.purple[200]!,
                    ),
                  ],
                );
              }),
              const SizedBox(height: ECSizes.spaceBtwSections),

              /// Today Event
              Obx(() {
                if (homeController.isChartLoading.value) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }

                if (homeController.todayEventList.isEmpty) {
                  return const Center(child: Text("No events today."));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Events",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      itemCount: homeController.todayEventList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final event = homeController.todayEventList[index];

                        return Card(
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(Icons.event, color: ECColors.primary),
                            title: Text(event.title),
                            subtitle: Text(ECHelperFunctions.getFormattedDate(
                                event.startDateTime.toDate(),
                                format: "dd MMM yyyy hh:mm a")),
                            onTap: () => Get.toNamed(
                                'admin_approved_event_detail',
                                arguments: event),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: ECSizes.spaceBtwSections),

              /// Chart
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
                // if (homeController.eventCountByDay.isEmpty) {
                //   return const Center(child: Text("No upcoming events found."));
                // }
                return Column(
                  children: [
                    AdminEventBarChart(
                      eventCounts: homeController.eventCountByMonth,
                      title: "Monthly Event Statistics",
                    ),
                    SizedBox(height: 20),
                    AdminEventBarChart(
                      eventCounts: homeController.eventCountByYear,
                      title: "Yearly Event Statistics",
                    ),
                  ],
                );
              }),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
