import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../binding/controllers/binding_controller.dart';
import '../../../elderly_management/controllers/elderly_management_controller.dart';
import '../../../profile/controllers/user_controller.dart';
import '../../models/user_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> addressEditFormKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final postcodeController = TextEditingController();
  var selectedState = Rxn<MalaysianState>();

  void loadUserAddress(bool ownProfile) async {
    UserModel? user;

    if (ownProfile) {
      // Own profile
      user = UserController.instance.user.value;
    } else {
      // Elderly profile
      if (ElderlyManagementController.instance.elderlyDetail.value.id.isEmpty) {
        await ElderlyManagementController.instance.fetchElderlyDetail(
            ElderlyManagementController.instance.elderlyDetail.value.id);
      }
      user = ElderlyManagementController.instance.elderlyDetail.value;
    }

    if (user != null && user.address != null) {
      streetController.text = user.address['street'] ?? '';
      cityController.text = user.address['city'] ?? '';
      postcodeController.text = user.address['postcode'] ?? '';
      selectedState.value = MalaysianState.values.firstWhereOrNull(
        (state) =>
            state.toString().split('.').last.toLowerCase() ==
            user!.address['state'].toString().toLowerCase(),
      );
    }
  }

  void saveAddress() async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: "Error", message: 'No internet connection');
        return;
      }

      // Form validation
      if (!addressFormKey.currentState!.validate()) {
        return;
      }

      final addressData = {
        'address': {
          'street': streetController.text.trim(),
          'city': cityController.text.trim(),
          'state': selectedState.value?.toString().split(".").last ?? '',
          'postcode': postcodeController.text.trim(),
        }
      };

      final userRepository = UserRepository.instance;
      await userRepository.updateSingleField(addressData);

      // Show success message
      ECLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your address has been saved!');

      // Move to homepage
      Get.offNamed('/upload_profile_picture');
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void updateAddress(bool ownProfile) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      // Form validation
      if (!addressEditFormKey.currentState!.validate()) {
        return;
      }

      String id;
      if (ownProfile) {
        id = UserController.instance.user.value.id;
      } else {
        id = ElderlyManagementController.instance.elderlyDetail.value.id;
      }

      final addressData = {
        'address': {
          'street': streetController.text.trim(),
          'city': cityController.text.trim(),
          'state': selectedState.value?.toString().split(".").last ?? '',
          'postcode': postcodeController.text.trim(),
        }
      };

      final userRepository = UserRepository.instance;
      await userRepository.updateOtherUserDetail(id, addressData);
      if (ownProfile) {
        UserController.instance.fetchUserRecord();
      } else {
        ElderlyManagementController.instance.fetchElderlyDetail(id);
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Congratulations', message: 'Address has been updated!');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  String? getFormattedAddress(Map<String, dynamic> address) {
    final city = address['city'] ?? '';
    final street = address['street'] ?? '';
    final postcode = address['postcode'] ?? '';
    final stateKey =
        address['state']?.toString().toLowerCase().replaceAll(' ', '') ?? '';

    MalaysianState? stateEnum = MalaysianState.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == stateKey,
    );

    final formattedState = stateEnum?.displayName ?? '';

    final data = '$street, $city, $formattedState, $postcode';

    if (street.isEmpty &&
        city.isEmpty &&
        formattedState.isEmpty &&
        postcode.isEmpty) {
      return '';
    }
    return data;
  }
}
