import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/authentication/authentication_repository.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/data/services/notification/fcm_service.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/constants/image_strings.dart';
import 'package:elderly_community/utils/helpers/network_manager.dart';
import 'package:elderly_community/utils/popups/full_screen_loader.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  /// Variables
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final gender = TextEditingController();
  final password = TextEditingController();
  final confirmedPassword = TextEditingController();
  final dobController = TextEditingController().obs;
  final role = ''.obs;

  /// Field specific for Event Organiser
  GlobalKey<FormState> organiserSignUpFormKey = GlobalKey<FormState>();
  final organisationDescription = TextEditingController();
  final organisationWebsite = TextEditingController();
  var selectedFiles = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    role.value = Get.arguments?['role'] ?? '';
  }

  /// Password Visibility
  RxBool isPasswordHidden = true.obs;
  RxBool isConfirmPasswordHidden = true.obs;

  Future<void> selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      dobController.value.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any, // Allows images and files
    );

    if (result != null) {
      selectedFiles.addAll(result.files.map((file) => File(file.path!)));
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> signUp() async {
    try {
      // Start loading
      ECFullScreenLoader.openLoadingDialog(
          'We are processing your information', ECImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECFullScreenLoader.stopLoading();
        ECLoaders.errorSnackBar(
            title: "Error", message: 'No internet connection');
        return;
      }

      // Form validation
      if (!signUpFormKey.currentState!.validate()) {
        ECFullScreenLoader.stopLoading();
        return;
      }

      // Register user in the Firebase Authentication & Save user data in the Firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim(), phoneNumber.text.trim());

      String? deviceToken = await FcmService.instance.getFCMToken();

      // Save Authenticated user data in the Firebase Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: name.text.trim(),
        email: email.text.trim(),
        role: role.value,
        phoneNumber: phoneNumber.text.trim(),
        gender: gender.text.trim(),
        dob: Timestamp.fromDate(
            DateFormat('yyyy-MM-dd').parse(dobController.value.text.trim())),
        createdAt: Timestamp.now(),
        address: {},
        profilePicture: '',
        deviceToken: deviceToken ?? '',
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // Remove loader
      ECFullScreenLoader.stopLoading();

      // Show success message
      ECLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your account has been created!');
      // Move to homepage
      Get.offNamed('/upload_address');
    } catch (e) {
      ECFullScreenLoader.stopLoading();
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> signupAsEventOrganiser() async {
    try {
      // Start loading
      ECFullScreenLoader.openLoadingDialog(
          'We are processing your information', ECImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECFullScreenLoader.stopLoading();
        ECLoaders.errorSnackBar(
            title: "Error", message: 'No internet connection');
        return;
      }

      // Form validation
      if (!organiserSignUpFormKey.currentState!.validate()) {
        ECFullScreenLoader.stopLoading();
        return;
      }

      if (selectedFiles.isEmpty) {
        ECFullScreenLoader.stopLoading();
        ECLoaders.errorSnackBar(
            title: 'Error',
            message: 'Please upload your business registration certificate.');

        return;
      }

      // Register user in the Firebase Authentication & Save user data in the Firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim(), phoneNumber.text.trim());

      String? deviceToken = await FcmService.instance.getFCMToken();

      final userRepository = Get.put(UserRepository());
      List<String> uploadedFileUrls =
          await userRepository.uploadFile(selectedFiles);

      // Save Authenticated user data in the Firebase Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: name.text.trim(),
        email: email.text.trim(),
        role: role.value,
        phoneNumber: phoneNumber.text.trim(),
        gender: gender.text.trim(),
        dob: Timestamp.fromDate(
            DateFormat('yyyy-MM-dd').parse(dobController.value.text.trim())),
        createdAt: Timestamp.now(),
        address: {},
        profilePicture: '',
        deviceToken: deviceToken ?? '',
        organisationDescription: organisationDescription.text.trim(),
        organisationWebsite: organisationWebsite.text.trim(),
        businessRegistrationFiles: uploadedFileUrls,
        organisationStatus:
            OrganisationAccountStatus.pending.toString().split('.').last,
      );

      await userRepository.saveUserRecord(newUser);

      // Remove loader
      ECFullScreenLoader.stopLoading();

      // Show success message
      ECLoaders.successSnackBar(
          title: 'Congratulations',
          message:
              'Your account has been created! Please complete your profile!');
      // Move to homepage
      Get.offNamed('/upload_address', arguments: true);
    } catch (e) {
      ECFullScreenLoader.stopLoading();
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
