import 'package:elderly_community/features/auth/controllers/signup/address_controller.dart';
import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/elderly_management/controllers/elderly_management_controller.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/features/profile/screens/widgets/profile_field.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../auth/models/user_model.dart';

class OrganiserProfileDetailScreen extends StatelessWidget {
  const OrganiserProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    // final bindingController = BindingController.instance;
    ElderlyManagementController? elderlyController;

    userController.fetchUserRecord();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('My Profile'),
        ),
      ),
      body: Obx(() {
        // Get the profile data reactively
        final profile = userController.user.value;

        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Profile Picture
              Center(
                child: GestureDetector(
                  onTap: () =>
                      Get.toNamed('profile_picture_form', arguments: true),
                  child: Stack(
                    children: [
                      (profile.profilePicture != null &&
                              profile.profilePicture.isNotEmpty)
                          ? ClipOval(
                              child: CachedNetworkImage(
                              imageUrl: profile.profilePicture,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ))
                          : const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 50),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: ECColors.buttonPrimary,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Editable Fields
              ProfileFieldWidget(
                label: 'Name',
                value: profile.name,
                onTap: () => Get.toNamed('name_form', arguments: true),
              ),
              ProfileFieldWidget(
                label: 'Website',
                value: profile.organisationWebsite,
                onTap: () => Get.toNamed('website_form'),
              ),
              ProfileFieldWidget(
                label: 'Description',
                value: profile.organisationDescription,
                onTap: () => Get.toNamed('description_form'),
              ),
              ProfileFieldWidget(
                  label: 'ID', value: profile.id, isEditable: false),
              ProfileFieldWidget(
                  label: 'Email', value: profile.email, isEditable: false),
              ProfileFieldWidget(
                label: 'Phone Number',
                value: profile.phoneNumber,
                onTap: () => Get.toNamed('phoneNumber_form', arguments: true),
              ),
              ProfileFieldWidget(
                label: 'Foundation Date',
                value: ECHelperFunctions.getFormattedDate(profile.dob.toDate()),
                isEditable: false,
              ),
              ProfileFieldWidget(
                label: 'Address',
                value: AddressController().getFormattedAddress(profile.address),
                onTap: () => Get.toNamed('address_form', arguments: true),
              ),
            ],
          ),
        );
      }),
    );
  }
}
