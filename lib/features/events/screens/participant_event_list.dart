import 'package:elderly_community/features/events/controllers/participant_event_controller.dart';
import 'package:elderly_community/features/events/screens/widgets/category_filter_dialog.dart';
import 'package:elderly_community/features/events/screens/widgets/event_card.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/search_filter_bar.dart';
import '../../../utils/constants/colors.dart';

class ParticipantEventListScreen extends StatefulWidget {
  const ParticipantEventListScreen({super.key});

  @override
  State<ParticipantEventListScreen> createState() => _ParticipantEventListScreenState();
}

class _ParticipantEventListScreenState extends State<ParticipantEventListScreen> {
  ElderlyEventStatus selectedSegment = ElderlyEventStatus.upcoming;
  final controller = Get.put(ParticipantEventController());

  @override
  void initState() {
    super.initState();
    // controller.fetchEvents(selectedSegment); // Fetch initial events
    // controller.fetchCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEvents(selectedSegment); // Fetch initial events
      controller.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Event"),
          actions: [
            IconButton(
                onPressed: () => Get.toNamed('participant_event_favourite_list'),
                icon: Icon(Icons.favorite))
          ],
        ),
      ),
      body: Column(
        children: [
          /// Segmented Button
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: CupertinoSlidingSegmentedControl<ElderlyEventStatus>(
                groupValue: selectedSegment,
                backgroundColor: Colors.grey[200] ?? Colors.grey,
                thumbColor: ECColors.buttonPrimary,
                padding: const EdgeInsets.all(4),
                onValueChanged: (ElderlyEventStatus? value) {
                  if (value != null) {
                    setState(() {
                      selectedSegment = value;
                    });
                    controller.fetchEvents(value);
                  }
                },
                children: <ElderlyEventStatus, Widget>{
                  ElderlyEventStatus.upcoming: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Upcoming",
                      style: selectedSegment == ElderlyEventStatus.upcoming
                          ? TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)
                          : TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElderlyEventStatus.myticket: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "My Tickets",
                      style: selectedSegment == ElderlyEventStatus.myticket
                          ? TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)
                          : TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                },
              ),
            ),
          ),

          /// Search & Filter (Only for Upcoming Events)
          if (selectedSegment == ElderlyEventStatus.upcoming)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SearchFilterBar(
                onSearchChanged: (value) {
                  controller.updateSearch(value);
                  // setState(() {
                  //   // searcQuery = value.toLowerCase();
                  // });
                },
                onFilterPressed: () {
                  showFilterDialog(context);
                },
              ),
            ),

          // Display Event List Based on Selected Segment
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final eventList = selectedSegment == ElderlyEventStatus.upcoming
                    ? controller.filteredEvents
                    : controller.myTicketEventList;

                if (eventList.isEmpty) {
                  return Center(child: Text("No events available"));
                }

                return EventCard(events: eventList);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Show filter modal
  void showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CategoryFilterDialog(controller: controller);
      },
    );
  }
}
