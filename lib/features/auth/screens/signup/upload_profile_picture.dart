import 'package:elderly_community/features/home/screens/elderly_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/curved_app_bar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../controllers/signup/upload_profile_controller.dart';

class UploadProfilePictureScreen extends StatelessWidget {
  const UploadProfilePictureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UploadProfileController controller =
        Get.put(UploadProfileController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text("Complete your profile")),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a profile picture',
                style: Theme.of(context).textTheme.headlineMedium),
            // SizedBox(height: ECSizes.spaceBtwSections),
            Spacer(),

            /// Profile Picture Preview
            Center(
              child: GestureDetector(
                onTap: controller.pickImage,
                child: Obx(
                  () => CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: controller.selectedImage.value != null
                        ? FileImage(controller.selectedImage.value!)
                        : null,
                    child: controller.selectedImage.value == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            Spacer(),

            /// Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.uploadProfilePicture(),
                child: Text(ECTexts.tContinue),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child:
                  OutlinedButton(onPressed: () => controller.skip(), child: Text(ECTexts.skip)),
            ),
            SizedBox(height: ECSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
