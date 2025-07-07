import 'package:elderly_community/features/event_management/screens/event_management.dart';
import 'package:elderly_community/features/profile/screens/profile.dart';
import 'package:elderly_community/features/user_management/screens/user_list.dart';
import 'package:get/get.dart';

import '../../broadcast/screens/admin_broadcast_list.dart';
import '../../home/screens/admin_home.dart';

class AdminNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    AdminHomeScreen(),
    UserListScreen(),
    EventManagementScreen(),
    AdminBroadcastListScreen(),
    ProfileScreen(),
  ];
}
