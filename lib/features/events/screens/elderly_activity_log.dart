import 'package:elderly_community/features/events/controllers/activity_log_controller.dart';
import 'package:elderly_community/features/notification/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../binding/controllers/binding_controller.dart';
import '../../notification/models/notification_model.dart';
import '../models/event_model.dart';

class ElderlyActivityLogScreen extends StatelessWidget {
  const ElderlyActivityLogScreen({
    super.key,
    required this.bindingIndex,
  });

  final int bindingIndex;

  @override
  Widget build(BuildContext context) {
    final bindingController = BindingController.instance;
    final controller = Get.put(ActivityLogController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
            title: Text(
                '${bindingController.bindingList[bindingIndex].elderlyName!}\'s Activity Log')),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.activityLogs.isEmpty) {
          return Center(child: Text('No activity logs available.'));
        }

        return ListView.builder(
          itemCount: controller.activityLogs.length,
          itemBuilder: (context, index) {
            final log = controller.activityLogs[index];

            // Check if it's an Event or Notification and display accordingly
            if (log is EventModel) {
              return _buildEventCard(context, log);
            } else if (log is NotificationModel) {
              return _buildNotificationCard(context, log);
            } else {
              return SizedBox.shrink();
            }
          },
        );
      }),
    );
  }
}

Widget _buildEventCard(BuildContext context, EventModel event) {
  return Card(
    color: Colors.grey[50],
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: ListTile(
      onTap: () =>
          Get.toNamed('participant_event_details', arguments: event.id),
      leading: Icon(
        Icons.event,
        color: ECColors.secondary,
      ),
      title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Event Date: ${ECHelperFunctions.getFormattedDate(event.startDateTime.toDate(), format: "dd MMM yyyy hh:mm a")}",
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}

Widget _buildNotificationCard(
    BuildContext context, NotificationModel notification) {
  return Card(
    color: Colors.grey[50],
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: ListTile(
      onTap: () => NotificationController.instance.handleClick(notification),
      leading: Icon(Icons.notifications, color: ECColors.error),
      title: Text(notification.title,
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            ECHelperFunctions.getFormattedDate(notification.createdAt.toDate(),
                format: "dd MMM yyyy hh:mm a"),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}
