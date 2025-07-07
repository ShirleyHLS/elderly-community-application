import 'package:elderly_community/features/navigation_bar/controllers/caregiver_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CaregiverNavigationBar extends StatelessWidget {
  const CaregiverNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CaregiverNavigationController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
            () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            // NavigationDestination(icon: Icon(Icons.article), label: "Feed"),
            NavigationDestination(icon: Icon(Icons.contact_phone), label: "Contact"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
          onDestinationSelected: (index) =>
          controller.selectedIndex.value = index,
        ),
      ),
    );
  }
}


