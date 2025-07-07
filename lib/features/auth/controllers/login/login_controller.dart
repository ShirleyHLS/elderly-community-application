import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/data/services/notification/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class LoginController extends GetxController {
  /// Variables
  final email = TextEditingController();
  final password = TextEditingController();
  final localStorage = GetStorage();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  RxBool isPasswordHidden = true.obs;
  RxBool rememberMe = false.obs;

  @override
  void onInit() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> emailAndPasswordSignIn(GlobalKey<FormState> formKey) async {
    try {
      print('❤️❤️❤️');
      // Start loading
      ECFullScreenLoader.openLoadingDialog(
          'We are processing your information', ECImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECFullScreenLoader.stopLoading();
        ECLoaders.errorSnackBar(title: "Error", message: 'No internet connection');
        return;
      }

      // Form validation
      if (!formKey.currentState!.validate()) {
        ECFullScreenLoader.stopLoading();
        return;
      }

      // Save data if Remember Me selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      // Login user using email & password authentication
      final userCredential = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Remove loader
      ECFullScreenLoader.stopLoading();

      // Show success message
      ECLoaders.successSnackBar(
          title: 'Congratulations', message: 'Login successful!');

      // Screen redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      ECFullScreenLoader.stopLoading();
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
