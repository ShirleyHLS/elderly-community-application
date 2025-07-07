import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/broadcast/broadcast_repository.dart';
import 'package:elderly_community/data/repositories/notification/notification_repository.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/broadcast/models/broadcast_model.dart';
import 'package:elderly_community/features/notification/models/notification_model.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/notification/fcm_service.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';

class AdminBroadcastController extends GetxController {
  static AdminBroadcastController get instance => Get.find();

  final RxList<BroadcastModel> broadcastList = <BroadcastModel>[].obs;
  final isLoading = false.obs;
  final notificationRepository = Get.put(NotificationRepository());
  final broadcastRepository = Get.put(BroadcastRepository());

  GlobalKey<FormState> broadcastFormKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final RxList<String> selectedRoles = <String>[].obs;
  RxString creatorName = ''.obs;

  void onInit() {
    super.onInit();
    fetchBroadcastList();
  }

  void clearForm() {
    titleController.clear();
    messageController.clear();
    selectedRoles.clear();
  }

  Future<void> fetchCreatorName(String id) async {
    try {
      String? name = await UserRepository.instance.getUserName(id);
      creatorName.value = name ?? "Unknown";
    } catch (e) {
      creatorName.value = "Error fetching name";
    }
  }

  Future<void> fetchBroadcastList() async {
    print('fetching😶‍🌫️😶‍🌫️😶‍🌫️');
    try {
      isLoading.value = true;
      final broadcasts = await broadcastRepository.fetchBroadcastList();
      if (broadcasts != null) {
        broadcastList.assignAll(broadcasts);
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching broadcast list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendBroadcast() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection.');
        return;
      }

      if (!broadcastFormKey.currentState!.validate()) {
        return;
      }

      if (selectedRoles.isEmpty) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'Please select at least one recipients');
        return;
      }

      ECFullScreenLoader.openLoadingDialog(
          'We are broadcasting your messages', ECImages.docerAnimation);

      List<String> lowerCaseRoles =
          selectedRoles.map((role) => role.toLowerCase()).toList();

      BroadcastModel newBroadcast = BroadcastModel(
        title: titleController.text.trim(),
        body: messageController.text.trim(),
        createdAt: Timestamp.now(),
        roles: lowerCaseRoles,
        createdBy: UserController.instance.user.value.id,
      );

      await broadcastRepository.saveBroadcast(newBroadcast);

      // Fetch users matching selected categories
      List<Map<String, dynamic>> users =
          await UserRepository.instance.fetchUserBasedOnRole(lowerCaseRoles);

      if (users.isNotEmpty) {
        for (var user in users) {
          String id = user['id'];
          String? deviceToken = user['deviceToken'];
          NotificationModel newNotification = NotificationModel(
              userId: id,
              title: titleController.text.trim(),
              body: messageController.text.trim(),
              createdAt: Timestamp.now(),
              type: NotificationType.broadcast,
              read: false);

          await notificationRepository.saveNotification(newNotification);

          if (deviceToken != null && deviceToken.isNotEmpty) {
            await FcmService.sendNotification(
              token: deviceToken,
              title: titleController.text.trim(),
              body: messageController.text.trim(),
              data: {
                'type': 'broadcast',
              },
            );
          }
        }
      } else {
        print("No user found for the given roles.");
      }

      fetchBroadcastList();
      ECFullScreenLoader.stopLoading();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Broadcast sent successfully!");
      });
    } catch (e) {
      ECFullScreenLoader.stopLoading();
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
