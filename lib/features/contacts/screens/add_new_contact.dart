import 'package:elderly_community/features/contacts/controllers/add_new_contact_controller.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/sizes.dart';

class AddNewContactScreen extends StatelessWidget {
  const AddNewContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddNewContactController controller =
        Get.put(AddNewContactController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('New Contact'),
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
                  key: controller.addNewContactFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Profile Picture
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections),

                      /// Name Input
                      TextFormField(
                        controller: controller.name,
                        validator: (value) =>
                            ECValidator.validateEmptyText('Name', value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: ECTexts.name,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Phone Number Input
                      TextFormField(
                        controller: controller.phoneNumber,
                        validator: (value) =>
                            ECValidator.validateEmptyText('Phone number', value),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          labelText: ECTexts.phoneNo,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections), // Adjust spacing
                    ],
                  ),
                ),
              ),
            ),

            /// Fixed Save Button at Bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.addContact(),
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
