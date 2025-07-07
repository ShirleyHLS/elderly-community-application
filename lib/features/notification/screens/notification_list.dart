import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/notification_controller.dart';

class NotificationListScreen extends StatelessWidget {
  final NotificationController controller = NotificationController.instance;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.markAllAsRead(controller.notificationList);
        }
      },
      child: Scaffold(
        appBar: CustomCurvedAppBar(
          child: AppBar(
            title: Text("Notifications"),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.notificationList.isEmpty) {
            return Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: controller.notificationList.length,
            itemBuilder: (context, index) {
              final notification = controller.notificationList[index];
              final bool isUnread = notification.read == false;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: isUnread ? ECColors.secondary : Colors.transparent,
                    size: 8,
                  ),
                  title: Text(notification.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      Text(
                        ECHelperFunctions.getFormattedDate(
                            notification.createdAt.toDate(),
                            format: "dd MMM yyyy hh:mm a"),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  onTap: () => controller.handleClick(notification),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
