import 'package:elderly_community/features/contacts/controllers/contact_controller.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../binding/controllers/binding_controller.dart';
import '../controllers/elderly_navigation_controller.dart';

class ElderlyNavigationBar extends StatelessWidget {
  const ElderlyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ElderlyNavigationController());
    final bindingController = Get.put(BindingController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            // NavigationDestination(icon: Icon(Icons.article), label: "Feed"),
            NavigationDestination(icon: Icon(Icons.mic), label: "Chat"),
            NavigationDestination(
                icon: Stack(children: [
                  Icon(Icons.person),
                  if (bindingController.checkPendingRequests())
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
                label: "Profile"),
          ],
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
        ),
      ),
    );
  }
}
