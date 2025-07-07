import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../binding/controllers/binding_controller.dart';
import '../../elderly_management/controllers/elderly_management_controller.dart';

class WebsiteController extends GetxController {
  static WebsiteController get instance => Get.find();
  GlobalKey<FormState> websiteFormKey = GlobalKey<FormState>();
  final websiteController = TextEditingController();

  void loadWebsite() async {
    websiteController.text =
        UserController.instance.user.value.organisationWebsite ?? '';
  }

  void updateWebsite() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      if (!websiteFormKey.currentState!.validate()) {
        return;
      }

      String id = UserController.instance.user.value.id;

      final data = {
        'organisationWebsite': websiteController.text.trim(),
      };

      final userRepository = UserRepository.instance;
      await userRepository.updateOtherUserDetail(id, data);
      UserController.instance.fetchUserRecord();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Congratulations', message: 'Website has been updated!');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
