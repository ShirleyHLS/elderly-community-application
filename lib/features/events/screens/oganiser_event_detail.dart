import 'package:elderly_community/features/events/controllers/organiser_event_controller.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/event_detail_widget.dart';
import '../../profile/controllers/user_controller.dart';

class OrganiserEventDetailScreen extends StatelessWidget {
  const OrganiserEventDetailScreen({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final role = UserController.instance.user.value.role;
    final controller = OrganiserEventController.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text(event.title),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'View Participants') {
                  Get.toNamed('/organiser_event_participants_list',
                      arguments: event);
                } else if (value == 'Collect Feedback') {
                  controller.collectFeedback(event);
                } else if (value == 'View Feedback') {
                  Get.toNamed('/organiser_feedback_list', arguments: event.id);
                }
              },
              itemBuilder: (context) => [
                if (event.registrations.isNotEmpty)
                  PopupMenuItem(
                    value: 'View Participants',
                    child: Text('View Participants'),
                  ),
                if (!event.feedbackCollected!)
                  PopupMenuItem(
                    value: 'Collect Feedback',
                    child: Text('Collect Feedback'),
                  ),
                if (event.feedbackCollected!)
                  PopupMenuItem(
                    value: 'View Feedback',
                    child: Text('View Feedback'),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: EventDetailWidget(event: event),
              ),
            ),
            // SizedBox(height: 16),
            // event.registrations.isNotEmpty
            //     ? SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           onPressed: () {
            //             Get.toNamed('/organiser_event_participants_list',
            //                 arguments: event);
            //           },
            //           child: Text("View Participants"),
            //         ),
            //       )
            //     : SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           onPressed: null,
            //           child: Text("No participant yet"),
            //           style:
            //               Theme.of(context).elevatedButtonTheme.style?.copyWith(
            //                     side: WidgetStatePropertyAll(BorderSide(
            //                       color: ECColors.buttonDisabled,
            //                     )),
            //                   ),
            //         ),
            //       ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () => Get.toNamed('/feedback_form', arguments: event),
            //   child: Text("Feedback"),
            // ),
          ],
        ),
      ),
    );
  }
}
