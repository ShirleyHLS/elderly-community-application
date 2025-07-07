import 'package:elderly_community/features/events/controllers/organiser_event_controller.dart';
import 'package:elderly_community/features/events/screens/widgets/event_card.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';

class OrganiserEventListScreen extends StatefulWidget {
  const OrganiserEventListScreen({super.key});

  @override
  State<OrganiserEventListScreen> createState() =>
      _OrganiserEventListScreenState();
}

class _OrganiserEventListScreenState extends State<OrganiserEventListScreen> {
  OrganiserEventStatus selectedSegment = OrganiserEventStatus.upcoming;
  final controller = Get.put(OrganiserEventController());

  @override
  void initState() {
    super.initState();
    controller.fetchEvents(selectedSegment); // Fetch initial events
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Event"),
        ),
      ),
      body: Column(
        children: [
          /// Segmented Button
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: CupertinoSlidingSegmentedControl<OrganiserEventStatus>(
                groupValue: selectedSegment,
                backgroundColor: Colors.grey[200] ?? Colors.grey,
                thumbColor: ECColors.buttonPrimary,
                padding: const EdgeInsets.all(4),
                onValueChanged: (OrganiserEventStatus? value) {
                  if (value != null) {
                    setState(() {
                      selectedSegment = value;
                    });
                    controller.fetchEvents(value);
                  }
                },
                children: <OrganiserEventStatus, Widget>{
                  OrganiserEventStatus.upcoming: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Upcoming",
                      style: selectedSegment == OrganiserEventStatus.upcoming
                          ? TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)
                          : TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  OrganiserEventStatus.pending: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Pending",
                      style: selectedSegment == OrganiserEventStatus.pending
                          ? TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)
                          : TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  OrganiserEventStatus.past: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Past",
                      style: selectedSegment == OrganiserEventStatus.past
                          ? TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)
                          : TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  OrganiserEventStatus.rejected: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Rejected",
                      style: selectedSegment == OrganiserEventStatus.rejected
                          ? TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)
                          : TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                },
              ),
            ),
          ),

          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   child: CupertinoSlidingSegmentedControl<Event>(
          //     groupValue: selectedSegment,
          //     backgroundColor: Colors.grey[200] ?? Colors.grey,
          //     thumbColor: ECColors.buttonPrimary,
          //     padding: const EdgeInsets.all(4),
          //     onValueChanged: (Event? value) {
          //       if (value != null) {
          //         setState(() {
          //           selectedSegment = value;
          //         });
          //         controller.fetchEvents(value);
          //       }
          //     },
          //     children: <Event, Widget>{
          //       Event.upcoming: Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         child: Text(
          //           "Upcoming",
          //           style: selectedSegment == Event.upcoming
          //               ? TextStyle(
          //                   fontWeight: FontWeight.bold, color: Colors.white)
          //               : TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //       Event.pending: Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         child: Text(
          //           "Pending",
          //           style: selectedSegment == Event.pending
          //               ? TextStyle(
          //                   fontWeight: FontWeight.bold, color: Colors.white)
          //               : TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //       Event.past: Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         child: Text(
          //           "Past",
          //           style: selectedSegment == Event.past
          //               ? TextStyle(
          //                   fontWeight: FontWeight.bold, color: Colors.white)
          //               : TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //       Event.rejected: Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         child: Text(
          //           "Rejected",
          //           style: selectedSegment == Event.rejected
          //               ? TextStyle(
          //                   fontWeight: FontWeight.bold, color: Colors.white)
          //               : TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //     },
          //   ),
          // ),

          // Display Event List Based on Selected Segment
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.eventList.isEmpty) {
                  return Center(child: Text("No events available"));
                }

                return EventCard(events: controller.eventList);
              },
            ),
          ),
        ],
      ),

      // Floating Action Button for Adding Events
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: ECColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          if (UserController.instance.user.value.organisationStatus != null &&
              UserController.instance.user.value.organisationStatus == OrganisationAccountStatus.approved.name) {
            Get.toNamed('/event_form');
          } else {
            ECLoaders.errorSnackBar(
                title: 'Error',
                message:
                    'Your account will need to be approved before start publishing events.');
          }
        },
      ),
    );
  }
}
