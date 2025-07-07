import 'package:elderly_community/features/home/screens/caregiver_home.dart';
import 'package:elderly_community/features/new_contacts/screens/contact_list.dart';
import 'package:elderly_community/features/profile/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/screens/elderly_home.dart';

class CaregiverNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    CaregiverHomeScreen(),
    ContactListScreen(),
    ProfileScreen(),
  ];
}