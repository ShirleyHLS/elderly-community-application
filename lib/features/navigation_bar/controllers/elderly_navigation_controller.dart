import 'package:elderly_community/features/ai_chat/screens/ai_chat.dart';
import 'package:elderly_community/features/profile/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/screens/elderly_home.dart';

class ElderlyNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    ElderlyHomeScreen(),
    AIChatScreen(),
    ProfileScreen(),
  ];
}