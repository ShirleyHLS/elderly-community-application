import 'package:elderly_community/common/event_tile_widget.dart';
import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/home/screens/widgets/elderly_card.dart';
import 'package:elderly_community/features/home/screens/widgets/greeting_text_widget.dart';
import 'package:elderly_community/features/home/screens/widgets/notification_widget.dart';
import 'package:elderly_community/features/home/screens/widgets/shimmer_elderly_card.dart';
import 'package:elderly_community/features/home/screens/widgets/shimmer_event_card.dart';
import 'package:elderly_community/features/notification/controllers/notification_controller.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../common/curved_app_bar.dart';
import '../../events/controllers/participant_event_controller.dart';
import '../../profile/controllers/user_controller.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final bindingController = Get.put(BindingController());
    final eventController = Get.put(ParticipantEventController());
    final notificationController = Get.put(NotificationController());
    eventController.fetchEvents(ElderlyEventStatus.upcoming,
        applyFilter: false);

    Future<void> refreshData() async {
      await Future.wait([
        eventController.fetchEvents(ElderlyEventStatus.upcoming,
            applyFilter: false),
        bindingController.fetchBingdings(),
        // Assuming you have a method to fetch bindings
      ]);
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: GreetingTextWidget(controller: controller),
          actions: [
            NotificationWidget(notificationController: notificationController),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Binded Elderly",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Obx(() {
                      if (bindingController.isLoading.value) {
                        return ShimmerElderlyCard();
                      }
                      if (bindingController.bindingList.isEmpty) {
                        return Center(child: Text("No bindings found"));
                      }

                      final approvedBindings = bindingController.bindingList
                          .where((binding) =>
                              binding.status == BindingStatus.approved.name)
                          .toList();
                      if (approvedBindings.isEmpty) {
                        return Center(
                            child: Text("No approved bindings found"));
                      }

                      return SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: bindingController.bindingList.length,
                          itemBuilder: (context, index) {
                            final binding =
                                bindingController.bindingList[index];
                            if (binding.status ==
                                BindingStatus.approved
                                    .toString()
                                    .split('.')
                                    .last) {
                              return ElderlyCard(
                                elderly: binding,
                                index: index,
                              );
                            } else {
                              return SizedBox
                                  .shrink(); // Return an empty widget if not approved
                            }
                          },
                        ),
                      );
                    }),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Event",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('event_list'),
                          style: ButtonStyle(
                            foregroundColor:
                                WidgetStateProperty.all(ECColors.buttonPrimary),
                            overlayColor:
                                WidgetStateProperty.all(Colors.grey[100]),
                          ),
                          child: Text("See more"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 370,
                      child: Obx(() {
                        if (eventController.isLoading.value) {
                          return ShimmerEventCard();
                        }
                        if (eventController.upcomingEventList.isEmpty) {
                          return Center(child: Text("No events found"));
                        }

                        return PageView.builder(
                          itemCount:
                              eventController.upcomingEventList.length > 5
                                  ? 5
                                  : eventController.upcomingEventList.length,
                          controller: eventController.pageController,
                          // Controls spacing between cards
                          onPageChanged: eventController.updatePageIndicator,
                          itemBuilder: (context, index) {
                            final event =
                                eventController.upcomingEventList[index];
                            return EventTileWidget(
                              event: event,
                              onTap: () => Get.toNamed(
                                  'participant_event_details',
                                  arguments: event.id),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Obx(
                        () => SmoothPageIndicator(
                          controller: eventController.pageController,
                          onDotClicked: eventController.dotNavigationClick,
                          count: eventController.upcomingEventList.length > 5
                              ? 5
                              : eventController.upcomingEventList.length,
                          effect: WormEffect(
                            dotHeight: 7,
                            dotWidth: 7,
                            activeDotColor: ECColors.secondary,
                            dotColor: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
