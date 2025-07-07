import 'package:elderly_community/features/event_management/controllers/event_management_controller.dart';
import 'package:elderly_community/features/navigation_bar/controllers/admin_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../user_management/controllers/user_management_controller.dart';

class AdminNavigationBar extends StatelessWidget {
  const AdminNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminNavigationController());
    final eventController = Get.put(EventManagementController());
    final userController = Get.put(UserManagementController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            // NavigationDestination(icon: Icon(Icons.people), label: "User"),
            NavigationDestination(
                icon: Stack(children: [
                  Icon(Icons.people),
                  if (userController.checkPendingRequests())
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ))
                ]),
                label: "User"),
            NavigationDestination(
                icon: Stack(children: [
                  Icon(Icons.event),
                  if (eventController.checkPendingRequests())
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ))
                ]),
                label: "Event"),
            NavigationDestination(
                icon: Icon(Icons.announcement), label: "Notice"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
        ),
      ),
    );
  }
}
