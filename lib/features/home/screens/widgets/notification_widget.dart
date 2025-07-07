import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../notification/controllers/notification_controller.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    super.key,
    required this.notificationController,
  });

  final NotificationController notificationController;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.notifications, color: Colors.black),
          Positioned(
            right: 0,
            top: 0,
            child: Obx(() {
              final hasUnread =
                  notificationController.hasUnreadNotifications;
              return hasUnread
                  ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
                  : SizedBox.shrink();
            }),
          ),
        ],
      ),
      onPressed: () => Get.toNamed('notification_list'),
    );
  }
}

