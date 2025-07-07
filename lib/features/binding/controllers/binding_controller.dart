import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/binding/binding_repository.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/data/services/notification/fcm_service.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:elderly_community/features/binding/models/binding_model.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/repositories/notification/notification_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../notification/models/notification_model.dart';

class BindingController extends GetxController {
  static BindingController get instance => Get.find();

  final TextEditingController phoneController = TextEditingController();
  var isLoading = false.obs;
  final bindingRepository = Get.put(BindingRepository());
  final role = UserController.instance.user.value.role;

  final RxList<BindingModel> bindingList = <BindingModel>[].obs;

  // Rx<UserModel> elderlyDetail = UserModel.empty().obs;

  @override
  void onInit() {
    super.onInit();
    fetchBingdings();
  }

  Future<void> fetchBingdings() async {
    // print("Fetching reminders");
    try {
      isLoading(true);
      final bindings = await bindingRepository.fetchBindings(role);
      if (bindings != null) {
        bindingList.assignAll(bindings);
        print(bindingList.length);
      } else {
        bindingList.clear();
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching binding list: $e');
    } finally {
      isLoading(false);
    }
  }

  // Future<UserModel?> fetchElderlyDetail(String elderlyId) async {
  //   try {
  //     final elderlyDetail =
  //         await UserRepository.instance.fetchUserDetails(userId: elderlyId);
  //     this.elderlyDetail(elderlyDetail);
  //     return elderlyDetail;
  //   } catch (e) {
  //     ECLoaders.errorSnackBar(
  //         title: 'Error', message: 'Error fetching elderly detail: $e');
  //   }
  // }

  // Check if there are any pending requests
  bool checkPendingRequests() {
    return bindingList.value.any(
      (binding) =>
          binding.status == BindingStatus.pending.toString().split('.').last,
    );
  }

  Future<void> sendBindingRequest() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Please enter a phone number');
      return;
    }
    isLoading.value = true;

    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        isLoading.value = false;
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      if (phone == UserController.instance.user.value.phoneNumber) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: "You cannot bind with your own account!");
        isLoading.value = false;
        return;
      }

      // Check if elderly exists
      UserModel? elderly =
          await UserRepository.instance.checkIfElderlyExist(phone);

      if (elderly == null) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: "Elderly user not found");
        isLoading.value = false;
        return;
      }

      // Check if binding record exists
      final existingBindings = await bindingRepository.getExistingBinding(
        caregiverId: UserController.instance.user.value.id,
        elderlyId: elderly.id,
      );

      if (existingBindings != null) {
        String status = existingBindings.status.toLowerCase();

        if (status == BindingStatus.approved.toString().split('.').last) {
          ECLoaders.errorSnackBar(
              title: 'Error', message: "You are already bound with this user.");
          isLoading.value = false;
          return;
        } else if (status == BindingStatus.pending.toString().split('.').last) {
          ECLoaders.errorSnackBar(
              title: 'Info', message: "Please wait for request approval.");
          isLoading.value = false;
          return;
        } else if (status ==
                BindingStatus.rejected.toString().split('.').last ||
            status == BindingStatus.removed.toString().split('.').last) {
          // Update existing request to "pending"
          final data = {
            'status': BindingStatus.pending.toString().split('.').last,
          };

          await bindingRepository.updateSingleField(existingBindings.id!, data);
          fetchBingdings();
          isLoading.value = false;
          Get.back();

          Future.microtask(() {
            ECLoaders.successSnackBar(
                title: "Congratulations",
                message: "Request sent successfully!");
          });
          return;
        }
      }

      BindingModel newRequest = BindingModel(
        caregiverId: UserController.instance.user.value.id,
        elderlyId: elderly.id,
        status: BindingStatus.pending.toString().split('.').last,
        createdAt: Timestamp.now(),
      );
      String id = await bindingRepository.saveBindingRequest(newRequest);

      NotificationModel reminderNotification = NotificationModel(
        userId: elderly.id,
        title: "New Binding Request",
        body: "A caregiver wants to connect with you. Tap to approve.",
        createdAt: Timestamp.now(),
        type: NotificationType.bindingRequest,
        data: {
          'id': id,
          'caregiver_id': UserController.instance.user.value.id,
          'caregiver_name': UserController.instance.user.value.name,
          'elderly_id': elderly.id,
        },
        read: false,
      );

      final notificationRepo = NotificationRepository.instance;

      await notificationRepo.saveNotification(reminderNotification);
      await FcmService.sendNotification(
        token: elderly.deviceToken,
        title: "New Binding Request",
        body: "A caregiver wants to connect with you. Tap to approve.",
        data: {
          'type': 'bindingRequest',
          'id': id,
          'caregiver_id': UserController.instance.user.value.id,
          'caregiver_name': UserController.instance.user.value.name,
          'elderly_id': elderly.id,
        },
      );

      fetchBingdings();
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Congratulations", message: "Request sent successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void acceptRequest(String id) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      final data = {
        'status': BindingStatus.approved.toString().split('.').last,
      };

      await bindingRepository.updateSingleField(id, data);

      fetchBingdings();
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Congratulations",
            message: "You have approved the binding request!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void rejectRequest(String id) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      final data = {
        'status': BindingStatus.rejected.toString().split('.').last,
      };

      await bindingRepository.updateSingleField(id, data);

      fetchBingdings();
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Congratulations",
            message: "You have rejected the binding request!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void deleteBinding(String binding_id) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet connection.');
        return;
      }

      final data = {
        'status': BindingStatus.removed.toString().split('.').last,
      };

      await bindingRepository.updateSingleField(binding_id, data);
      fetchBingdings();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Binding deleted successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
