import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/services/notification/fcm_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../../notification/models/notification_model.dart';

class UserManagementController extends GetxController {
  static UserManagementController get instance => Get.find();
  final RxList<UserModel> userList = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = ''.obs;
  final RxList<UserModel> filteredUserList = <UserModel>[].obs;
  final RxList<UserModel> pendingUserList = <UserModel>[].obs;
  final searchController = TextEditingController(); // Text editing controller
  final searchFocusNode = FocusNode(); // Focus node to control keyboard

  final isLoading = false.obs;
  final userRepository = Get.put(UserRepository());

  /// Variables
  final name = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final gender = TextEditingController();
  final role = TextEditingController();
  final password = TextEditingController();
  final Rxn<DateTime> dob = Rxn<DateTime>();
  final TextEditingController dobController = TextEditingController();
  GlobalKey<FormState> userFormKey = GlobalKey<FormState>();

  final organisationDescription = TextEditingController();
  final organisationWebsite = TextEditingController();
  var selectedFiles = <File>[].obs;

  void onInit() {
    super.onInit();
    // if (userList.isEmpty) {
    print("Calling fetchUserList()...");
    fetchUserList();
    // } else {
    //   print("Skipping fetchUserList()");
    // }
  }

  void clearFields() {
    name.clear();
    email.clear();
    phoneNumber.clear();
    gender.clear();
    dob.value = null;
    dobController.clear();
    password.clear();
    role.clear();
    organisationDescription.clear();
    organisationWebsite.clear();
  }

  void setUser(UserModel user) {
    name.text = user.name;
    email.text = user.email;
    phoneNumber.text = user.phoneNumber;
    gender.text = user.gender;
    role.text = user.role;
    dob.value = user.dob.toDate();
    dobController.text =
        dob.value != null ? DateFormat('yyyy-MM-dd').format(dob.value!) : '';
    if (user.role == "event organiser") {
      organisationDescription.text = user.organisationDescription!;
      organisationWebsite.text = user.organisationWebsite!;
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

  void pickDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: Get.context!,
      initialDate: dob.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      dob.value = selectedDate;
      dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      print(dob.value);
    }
  }

  Future<void> fetchUserList() async {
    print('fetching😶‍🌫️😶‍🌫️😶‍🌫️');
    try {
      isLoading.value = true;
      final users = await userRepository.fetchUserList();
      userList.assignAll(users);
      applyFilters();
      print("Fetched user lists: $users");
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching user list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingUsers() async {
    try {
      final users = await userRepository.fetchPendingUserList();
      pendingUserList.assignAll(users);
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching pending users: $e');
    }
  }

  void searchUsers(String query) {
    searchQuery.value = query.toLowerCase();
    applyFilters();
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    applyFilters();
  }

  void applyFilters() {
    filteredUserList.assignAll(userList.where((user) {
      bool matchesSearch = user.name.toLowerCase().contains(searchQuery.value);
      bool matchesRole = selectedRole.value.isEmpty ||
          user.role == selectedRole.value.toLowerCase();
      return matchesSearch && matchesRole;
    }).toList());
  }

  Future<void> addUser() async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: "No internet connection.");
        return;
      }

      // Validate fields
      if (!userFormKey.currentState!.validate()) {
        return;
      }

      final userCredential = await AuthenticationRepository.instance
          .createNewAccount(email.text.trim(), password.text.trim());

      String userId = userCredential.user!.uid;

      UserModel newUser = UserModel(
        id: userId,
        name: name.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        gender: gender.text.trim(),
        dob: Timestamp.fromDate(dob.value!),
        role: role.text.trim(),
        createdAt: Timestamp.now(),
        address: {},
        profilePicture: '',
        deviceToken: '',
      );

      await UserRepository.instance.saveUserRecord(newUser);
      fetchUserList();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "User added successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> addEventOrganiser() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: "No internet connection.");
        return;
      }

      // Form validation
      if (!userFormKey.currentState!.validate()) {
        return;
      }

      if (selectedFiles.isEmpty) {
        ECLoaders.errorSnackBar(
            title: 'Error',
            message: 'Please upload your business registration certificate.');
        return;
      }

      final userCredential = await AuthenticationRepository.instance
          .createNewAccount(email.text.trim(), password.text.trim());

      String userId = userCredential.user!.uid;

      final userRepository = Get.put(UserRepository());
      List<String> uploadedFileUrls =
          await userRepository.uploadFile(selectedFiles);

      // Save Authenticated user data in the Firebase Firestore
      final newUser = UserModel(
        id: userId,
        name: name.text.trim(),
        email: email.text.trim(),
        role: role.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        gender: gender.text.trim(),
        dob: Timestamp.fromDate(
            DateFormat('yyyy-MM-dd').parse(dobController.value.text.trim())),
        createdAt: Timestamp.now(),
        address: {},
        profilePicture: '',
        deviceToken: '',
        organisationDescription: organisationDescription.text.trim(),
        organisationWebsite: organisationWebsite.text.trim(),
        businessRegistrationFiles: uploadedFileUrls,
        organisationStatus: OrganisationAccountStatus.approved.name,
      );

      await userRepository.saveUserRecord(newUser);
      fetchUserList();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "User added successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void editUser(String user_id, {bool isOrganiser = false}) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: "No internet connection.");
        return;
      }

      // Validate fields
      if (!userFormKey.currentState!.validate()) {
        return;
      }

      final updatedUser;
      if (isOrganiser) {
        updatedUser = {
          'name': name.text.trim(),
          'organisationWebsite': organisationWebsite.text.trim(),
          'organisationDescription': organisationDescription.text.trim(),
          'phoneNumber': phoneNumber.text.trim(),
          'role': role.text.trim(),
        };
      } else {
        updatedUser = {
          'name': name.text.trim(),
          'phoneNumber': phoneNumber.text.trim(),
          'role': role.text.trim(),
        };
      }

      // Store the user
      await userRepository.updateOtherUserDetail(user_id, updatedUser);
      fetchUserList();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "User edited successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void deleteUser(String user_id) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: "No internet connection.");
        return;
      }

      // Store the reminder
      await userRepository.removeUserRecord(user_id);
      fetchUserList();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "User deleted successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void approveOrganiser(String userId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: "No internet connection.");
        return;
      }

      final updatedUser = {
        'organisationStatus': OrganisationAccountStatus.approved.name,
      };

      await userRepository.updateOtherUserDetail(userId, updatedUser);

      String? organiserDeviceToken =
          await userRepository.getUserDeviceToken(userId);
      await sendOrganiserNotification(
        userId,
        organiserDeviceToken ?? '',
        "🎉 Account Approved",
        "Your organiser account has been approved! You can now create and manage events.",
      );

      fetchPendingUsers();
      fetchUserList();
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Organiser Approved!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void rejectOrganiser(String userId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: "No internet connection.");
        return;
      }

      final updatedUser = {
        'organisationStatus': OrganisationAccountStatus.rejected.name,
      };

      await userRepository.updateOtherUserDetail(userId, updatedUser);

      String? organiserDeviceToken =
          await userRepository.getUserDeviceToken(userId);
      await sendOrganiserNotification(
        userId,
        organiserDeviceToken ?? '',
        "❌ Account Rejected",
        "Unfortunately, your organiser account application has been rejected. Please contact support for more details.",
      );

      fetchPendingUsers();
      fetchUserList();
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Rejected", message: "Organiser Rejected!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> sendOrganiserNotification(String userId,
      String organiserDeviceToken, String title, String body) async {
    NotificationModel organiserNotification = NotificationModel(
      userId: userId,
      title: title,
      body: body,
      createdAt: Timestamp.now(),
      type: NotificationType.accountUpdate,
      read: false,
    );

    final notificationRepo = Get.put(NotificationRepository());
    await notificationRepo.saveNotification(organiserNotification);

    if (organiserDeviceToken.isNotEmpty) {
      await FcmService.sendNotification(
        token: organiserDeviceToken,
        title: title,
        body: body,
        data: {
          'type': 'accountUpdate',
          "userId": userId,
        },
      );
    }
  }

  String extractFileName(String fileUrl) {
    Uri uri = Uri.parse(fileUrl);
    String path = uri.pathSegments.last; // Get last part of the URL
    String decodedFileName =
        Uri.decodeFull(path).split('?').first; // Decode it (handle %2F)
    if (decodedFileName.contains("/")) {
      decodedFileName = decodedFileName.split("/").last;
    }
    return decodedFileName;
  }

  bool checkPendingRequests() {
    return userList.any((user) =>
        user.organisationStatus == OrganisationAccountStatus.pending.name);
  }
}
