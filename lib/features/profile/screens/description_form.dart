import 'package:elderly_community/features/profile/controllers/description_controller.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';

class DescriptionFormScreen extends StatelessWidget {
  const DescriptionFormScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final descriptionController = Get.put(DescriptionController());
    descriptionController.loadDescription();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('Edit Description'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: descriptionController.descriptionFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Description Field
                    TextFormField(
                      maxLines: 5,
                      controller: descriptionController.descriptionController,
                      validator: (value) =>
                          ECValidator.validateEmptyText('Description', value),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description),
                        labelText: "Organisation Description",
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
                onPressed: () => descriptionController.updateDescription(),
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
