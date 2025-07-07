import 'package:elderly_community/features/new_contacts/controller/contact_controller.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class ContactFormScreen extends StatelessWidget {
  const ContactFormScreen({super.key, this.contact});

  final Contact? contact;

  @override
  Widget build(BuildContext context) {
    final controller = ContactController.instance;

    if (contact != null) {
      final updatedContact = controller.contacts
          .firstWhere((c) => c.id == contact!.id, orElse: () => contact!);
      controller.firstNameController.text = updatedContact.displayName;
      controller.phoneController.text =
          contact!.phones.isNotEmpty ? updatedContact.phones.first.number : '';
      controller.selectedImage.value = null;
    } else {
      controller.clearField();
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            /// Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: controller.contactFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Profile Picture
                      GestureDetector(
                        onTap: controller.pickImage,
                        child: Obx(
                          () => CircleAvatar(
                            radius: 50,
                            backgroundImage: controller.selectedImage.value !=
                                    null
                                ? FileImage(controller.selectedImage
                                    .value!) // Show selected image
                                : (contact?.photo != null
                                    ? MemoryImage(
                                        contact!.photo!) // Show contact photo
                                    : null),
                            backgroundColor: Colors.grey,
                            child: controller.selectedImage.value == null &&
                                    contact?.photo == null
                                ? Icon(Icons.camera_alt,
                                    size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections),

                      /// Name Input
                      TextFormField(
                        controller: controller.firstNameController,
                        validator: (value) =>
                            ECValidator.validateEmptyText('Name', value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Name',
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Name Input
                      // TextFormField(
                      //   controller: controller.lastNameController,
                      //   validator: (value) =>
                      //       ECValidator.validateEmptyText('Last Name', value),
                      //   decoration: InputDecoration(
                      //     prefixIcon: const Icon(Icons.person),
                      //     labelText: 'Last Name',
                      //   ),
                      // ),
                      // SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Phone Number Input
                      TextFormField(
                        controller: controller.phoneController,
                        validator: (value) =>
                            ECValidator.validatePhoneNumber(value),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          labelText: ECTexts.phoneNo,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections),
                      // Adjust spacing
                    ],
                  ),
                ),
              ),
            ),

            /// Fixed Save Button at Bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.saveContact(contact),
                child: Text(ECTexts.save),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
