import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../binding/controllers/binding_controller.dart';
import '../../elderly_management/controllers/elderly_management_controller.dart';

class DescriptionController extends GetxController {
  static DescriptionController get instance => Get.find();
  GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();

  void loadDescription() async {
    descriptionController.text =
        UserController.instance.user.value.organisationDescription ?? '';
  }

  void updateDescription() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      if (!descriptionFormKey.currentState!.validate()) {
        return;
      }

      String id = UserController.instance.user.value.id;

      final data = {
        'organisationDescription': descriptionController.text.trim(),
      };

      final userRepository = UserRepository.instance;
      await userRepository.updateOtherUserDetail(id, data);
      UserController.instance.fetchUserRecord();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Congratulations', message: 'Description has been updated!');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
