import 'dart:io';

import 'package:direct_call_plus/direct_call_plus.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/contact/contact_service.dart';

class ContactController extends GetxController {
  static ContactController get instance => Get.find();
  var contacts = <Contact>[].obs;
  var isLoading = false.obs;
  var permissionDenied = false.obs;

  final firstNameController = TextEditingController();

  // final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final contactFormKey = GlobalKey<FormState>();

  var selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    fetchContacts();
    super.onInit();
  }

  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;
      permissionDenied.value = false;

      bool permissionGranted = await FlutterContacts.requestPermission();

      if (!permissionGranted) {
        permissionDenied.value = true;
        contacts.clear();
      } else {
        contacts.value = await ContactService.getAllContacts();
      }
    } catch (e) {
      print('❌ Error fetching contacts: $e');
      permissionDenied.value = true;
      contacts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void clearField() {
    firstNameController.text = '';
    // lastNameController.text = '';
    phoneController.text = '';
  }

  Future<void> saveContact(Contact? contact) async {
    if (contactFormKey.currentState!.validate()) {
      if (contact == null) {
        // Add new contact
        await ContactService.addNewContact(
          firstNameController.text,
          phoneController.text,
          selectedImage.value,
        );
      } else {
        // Update existing contact
        print(contact.id);
        await ContactService.updateContact(
          contact.id,
          firstNameController.text,
          phoneController.text,
          selectedImage.value,
        );
      }
      await fetchContacts();
      Get.back(result: true); // Go back to the contact list
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await ContactService.deleteContact(contactId);
      await fetchContacts(); // Refresh the contact list
      Get.back();
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to delete contact: $e');
    }
  }

  callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    //   if (await canLaunchUrl(phoneUri)) {
    //     await launchUrl(phoneUri);
    //   } else {
    //     ECLoaders.errorSnackBar(title: "Error", message: "Unable to make call");
    //   }
      await DirectCallPlus.makeCall(number);
  }

  Future<void> pickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void openWhatsapp(String phoneNumber) async {
    // final whatsappUrl = "whatsapp://send?phone=+6$phoneNumber&text=Hello";
    if (!phoneNumber.startsWith('+6')) {
      phoneNumber = '6$phoneNumber';
    }
    final whatsappUrl = "https://wa.me/${phoneNumber}";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      ECLoaders.errorSnackBar(
          title: "Error", message: "WhatsApp is not installed");
    }
  }
}
