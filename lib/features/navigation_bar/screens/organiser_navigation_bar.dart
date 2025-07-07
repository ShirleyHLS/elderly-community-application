import 'package:elderly_community/features/navigation_bar/controllers/organiser_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrganiserNavigationBar extends StatelessWidget {
  const OrganiserNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrganiserNavigationController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
            () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.event), label: "Event"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
          onDestinationSelected: (index) =>
          controller.selectedIndex.value = index,
        ),
      ),
    );
  }
}


