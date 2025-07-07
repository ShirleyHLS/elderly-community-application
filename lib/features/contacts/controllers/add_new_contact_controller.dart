import 'package:elderly_community/data/repositories/contact/contact_repository.dart';
import 'package:elderly_community/features/contacts/controllers/contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../auth/models/user_model.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';

class AddNewContactController extends GetxController {
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> addNewContactFormKey = GlobalKey<FormState>();
  final contactController = ContactController.instance;

  Future<void> addContact() async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        return;
      }

      // Form validation
      if (!addNewContactFormKey.currentState!.validate()) {
        return;
      }

      // Search for user in Firestore
      UserModel? user = await ContactRepository.instance
          .searchUserByPhoneNumber(phoneNumber.text);

      if (user == null) {
        ECLoaders.errorSnackBar(
            title: "Error", message: "User with this phone number not found");
        return;
      }

      // Store the contact in the current user's Contacts collection
      await ContactRepository.instance.storeContact(user.id!, name.text.trim());

      contactController.fetchContacts(forceRefresh: true);
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Contact added successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
