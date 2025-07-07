import 'package:elderly_community/features/profile/controllers/phone_number_controller.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';

class PhoneNumberFormScreen extends StatelessWidget {
  const PhoneNumberFormScreen({
    super.key,
    this.ownProfile = true,
  });

  final bool? ownProfile;

  @override
  Widget build(BuildContext context) {
    final phoneController = Get.put((PhoneController()));
    phoneController.loadUserPhoneNumber(ownProfile!);

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('Edit Phone Number'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: phoneController.phoneFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Phone Number
                    TextFormField(
                      controller: phoneController.phoneNumberController,
                      validator: (value) =>
                          ECValidator.validatePhoneNumber(value),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        labelText: ECTexts.phoneNo,
                      ),
                    ),
                    SizedBox(height: ECSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () =>
                      phoneController.updatePhoneNumber(ownProfile!),
                  child: Text(ECTexts.save)),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
