import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/elderly_management/controllers/elderly_management_controller.dart';
import 'package:elderly_community/features/home/screens/elderly_home.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/curved_app_bar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../auth/controllers/signup/upload_profile_controller.dart';

class ProfilePictureFormScreen extends StatelessWidget {
  const ProfilePictureFormScreen({
    super.key,
    this.ownProfile = true,
  });

  final bool? ownProfile;

  @override
  Widget build(BuildContext context) {
    final UploadProfileController controller =
        Get.put(UploadProfileController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('Edit Profile Picture'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),

              /// Profile Picture Preview
              Center(
                child: Obx(
                  () {
                    final hasSelectedImage =
                        controller.selectedImage.value != null;
                    final hasProfileImage = ownProfile == true
                        ? UserController
                            .instance.user.value.profilePicture.isNotEmpty
                        : ElderlyManagementController.instance.elderlyDetail.value
                            .profilePicture.isNotEmpty;

                    return CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: hasSelectedImage
                          ? FileImage(controller.selectedImage.value!)
                          : (hasProfileImage
                              ? NetworkImage(ownProfile == true
                                  ? UserController
                                      .instance.user.value.profilePicture
                                  : ElderlyManagementController.instance.elderlyDetail
                                      .value.profilePicture)
                              : null) as ImageProvider?,
                      child: hasSelectedImage || hasProfileImage
                          ? null
                          : Icon(Icons.camera_alt,
                              size: 40, color: Colors.white),
                    );
                  },
                ),
              ),
              Spacer(),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => controller.pickImage(),
                    child: Text('Upload New Photo')),
              ),
              SizedBox(height: ECSizes.spaceBtwItems),
              if (controller.selectedImage.value != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.updateProfilePicture(ownProfile!),
                    child: Text('Save'),
                  ),
                ),
              SizedBox(height: ECSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
