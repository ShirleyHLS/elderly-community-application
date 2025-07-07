import 'dart:io';

import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../binding/controllers/binding_controller.dart';
import '../../../elderly_management/controllers/elderly_management_controller.dart';
import '../../../profile/controllers/user_controller.dart';

class UploadProfileController extends GetxController {
  var selectedImage = Rx<File?>(null); // Observable for selected image
  var pickedFile;

  Future<void> pickImage() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> uploadProfilePicture() async {
    if (selectedImage.value == null) {
      ECLoaders.errorSnackBar(title: 'Error', message: 'No image selected');
      return;
    }

    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection.');
        return;
      }

      final userRepository = Get.put(UserRepository());
      String imageUrl = await userRepository.uploadImage(
          "Users/profile_picture/", pickedFile);

      Map<String, dynamic> profileData = {'profilePicture': imageUrl};
      await userRepository.updateSingleField(profileData);

      ECLoaders.successSnackBar(
          title: "Success", message: "Profile picture uploaded!");

      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void skip() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection.');
      return;
    }
    AuthenticationRepository.instance.screenRedirect();
  }

  Future<void> updateProfilePicture(bool ownProfile) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection');
        return;
      }

      if (selectedImage.value == null) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No image selected');
        return;
      }

      String id = ownProfile
          ? UserController.instance.user.value.id
          : ElderlyManagementController.instance.elderlyDetail.value.id;

      final userRepository = UserRepository.instance;
      String imageUrl = await userRepository.uploadImage(
          "Users/profile_picture/", pickedFile);

      if (imageUrl.isNotEmpty) {
        Map<String, dynamic> profileData = {'profilePicture': imageUrl};
        await userRepository.updateOtherUserDetail(id, profileData);

        if (ownProfile) {
          UserController.instance.fetchUserRecord();
        } else {
          ElderlyManagementController.instance.fetchElderlyDetail(id);
          BindingController.instance.fetchBingdings();
        }
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Congratulations',
            message: 'Profile picture has been updated!');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
