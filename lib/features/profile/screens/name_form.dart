import 'package:elderly_community/features/profile/controllers/name_controller.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';

class NameFormScreen extends StatelessWidget {
  const NameFormScreen({
    super.key,
    this.ownProfile = true,
  });

  final bool? ownProfile;

  @override
  Widget build(BuildContext context) {
    final nameController = Get.put(NameController());
    nameController.loadUserName(ownProfile!);

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('Edit Name'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: nameController.nameFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name Field
                    TextFormField(
                      controller: nameController.nameController,
                      validator: (value) => ECValidator.validateEmptyText('Name', value),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: ECTexts.name,
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
                onPressed: () => nameController.updateUserName(ownProfile!),
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
