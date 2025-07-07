import 'package:elderly_community/features/home/screens/organiser_home.dart';
import 'package:elderly_community/features/profile/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../events/screens/organiser_event_list.dart';
import '../../home/screens/elderly_home.dart';

class OrganiserNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    OrganiserHomeScreen(),
    OrganiserEventListScreen(),
    ProfileScreen(),
  ];
}
