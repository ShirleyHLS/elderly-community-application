import 'package:elderly_community/features/profile/controllers/name_controller.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../controllers/website_controller.dart';

class WebsiteFormScreen extends StatelessWidget {
  const WebsiteFormScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final websiteController = Get.put(WebsiteController());
    websiteController.loadWebsite();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('Edit Website'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: websiteController.websiteFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Website Field
                    TextFormField(
                      controller: websiteController.websiteController,
                      validator: (value) => ECValidator.validateWebsite(value),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.web),
                        labelText: "Organisation Website",
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
                onPressed: () => websiteController.updateWebsite(),
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
