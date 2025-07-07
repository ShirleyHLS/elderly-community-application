import 'package:elderly_community/common/curved_app_bar.dart';
import 'package:elderly_community/features/event_management/controllers/event_management_controller.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/carousel_image_slider.dart';
import '../../../common/event_detail_widget.dart';
import '../../../utils/helpers/helper_functions.dart';

class EventApprovalScreen extends StatelessWidget {
  const EventApprovalScreen({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final controller = EventManagementController.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Pending"),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// Event Details
            Expanded(
              child: SingleChildScrollView(
                child: EventDetailWidget(event: event),
              ),
            ),
            SizedBox(height: 16),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Reject Confirmation",
                        middleText:
                            "Are you sure you want to reject this event?",
                        textConfirm: "Yes",
                        textCancel: "No",
                        confirmTextColor: Colors.white,
                        cancelTextColor: Colors.black,
                        buttonColor: ECColors.error,
                        onConfirm: () {
                          Get.back();
                          controller.updateEventStatus(
                              event.id ?? '',
                              AdminEventStatus.rejected,
                              event.organizationId,
                              event.title);
                        },
                      );
                    },
                    style:
                        Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              backgroundColor:
                                  WidgetStateProperty.all(ECColors.error),
                              side: WidgetStateProperty.all(
                                  BorderSide(color: ECColors.error)),
                            ),
                    child: Text("Reject"),
                  ),
                ),
                SizedBox(width: 10), // Add some space between the buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Approve Confirmation",
                        middleText:
                            "Are you sure you want to approve this event?",
                        textConfirm: "Yes",
                        textCancel: "No",
                        confirmTextColor: Colors.white,
                        cancelTextColor: Colors.black,
                        buttonColor: ECColors.success,
                        onConfirm: () {
                          Get.back();
                          controller.updateEventStatus(
                              event.id ?? '',
                              AdminEventStatus.approved,
                              event.organizationId,
                              event.title);
                        },
                      );
                    },
                    style:
                        Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              backgroundColor:
                                  WidgetStateProperty.all(ECColors.success),
                              side: WidgetStateProperty.all(
                                  BorderSide(color: ECColors.success)),
                            ),
                    child: Text("Approve"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
