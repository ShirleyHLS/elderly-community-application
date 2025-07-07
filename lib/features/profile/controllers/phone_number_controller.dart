import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../binding/controllers/binding_controller.dart';
import '../../elderly_management/controllers/elderly_management_controller.dart';

class PhoneController extends GetxController {
  static PhoneController get instance => Get.find();
  GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();

  void loadUserPhoneNumber(bool ownProfile) async {
    if (ownProfile) {
      phoneNumberController.text =
          UserController.instance.user.value.phoneNumber ?? '';
    } else {
      if (ElderlyManagementController.instance.elderlyDetail.value!.id.isEmpty) {
        await ElderlyManagementController.instance.fetchElderlyDetail(
            ElderlyManagementController.instance.elderlyDetail.value!.id);
      }
      phoneNumberController.text =
          ElderlyManagementController.instance.elderlyDetail.value!.phoneNumber ?? '';
    }
  }

  void updatePhoneNumber(bool ownProfile) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      if (!phoneFormKey.currentState!.validate()) {
        return;
      }

      String id = ownProfile
          ? UserController.instance.user.value.id
          : ElderlyManagementController.instance.elderlyDetail.value!.id;

      final phoneData = {
        'phoneNumber': phoneNumberController.text.trim(),
      };

      final userRepository = UserRepository.instance;
      await userRepository.updateOtherUserDetail(id, phoneData);
      if (ownProfile) {
        UserController.instance.fetchUserRecord();
      } else {
        ElderlyManagementController.instance.fetchElderlyDetail(id);
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Congratulations',
            message: 'Phone number has been updated!');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
