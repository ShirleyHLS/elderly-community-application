import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../binding/controllers/binding_controller.dart';
import '../../elderly_management/controllers/elderly_management_controller.dart';

class NameController extends GetxController {
  static NameController get instance => Get.find();
  GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  void loadUserName(bool ownProfile) async {
    if (ownProfile) {
      nameController.text = UserController.instance.user.value.name ?? '';
    } else {
      if (ElderlyManagementController
          .instance.elderlyDetail.value!.id.isEmpty) {
        await ElderlyManagementController.instance.fetchElderlyDetail(
            ElderlyManagementController.instance.elderlyDetail.value!.id);
      }
      nameController.text =
          ElderlyManagementController.instance.elderlyDetail.value!.name ?? '';
    }
  }

  void updateUserName(bool ownProfile) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      if (!nameFormKey.currentState!.validate()) {
        return;
      }

      String id = ownProfile
          ? UserController.instance.user.value.id
          : ElderlyManagementController.instance.elderlyDetail.value!.id;

      final nameData = {
        'name': nameController.text.trim(),
      };

      final userRepository = UserRepository.instance;
      await userRepository.updateOtherUserDetail(id, nameData);
      if (ownProfile) {
        UserController.instance.fetchUserRecord();
      } else {
        ElderlyManagementController.instance.fetchElderlyDetail(id);
        BindingController.instance.fetchBingdings();
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Congratulations', message: 'Name has been updated!');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
