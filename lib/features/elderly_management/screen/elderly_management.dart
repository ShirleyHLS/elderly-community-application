import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/elderly_management/controllers/elderly_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/profile_tile_widget.dart';
import '../../../utils/constants/sizes.dart';

class ElderlyManagementScreen extends StatelessWidget {
  const ElderlyManagementScreen({
    super.key,
    required this.bindingIndex,
  });

  final int bindingIndex;

  @override
  Widget build(BuildContext context) {
    final bindingController = BindingController.instance;
    final controller = Get.put(ElderlyManagementController(bindingIndex: bindingIndex));

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Obx(() => Text(
                bindingController.bindingList[bindingIndex].elderlyName!,
              )),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Profile
            Obx(
              () => Center(
                child: (bindingController
                                .bindingList[bindingIndex].elderlyProfile !=
                            null &&
                        bindingController.bindingList[bindingIndex]
                            .elderlyProfile!.isNotEmpty)
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: bindingController
                              .bindingList[bindingIndex].elderlyProfile!,
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
                            radius: 50,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 50),
                          ),
                        ),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 50,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 50),
                      ),
              ),
            ),
            const SizedBox(height: ECSizes.spaceBtwItems),

            Obx(
              () => Text(
                  bindingController.bindingList[bindingIndex].elderlyName!,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: ECSizes.xs),
            Text(
                'ID: ${bindingController.bindingList[bindingIndex].elderlyId!}',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: ECSizes.spaceBtwSections),
            Divider(),
            const SizedBox(height: ECSizes.spaceBtwItems),

            Expanded(
              child: ListView(
                children: [
                  ProfileTileWidget(
                      icon: Icons.person,
                      title: 'Personal Info',
                      onTap: () => Get.toNamed('profile_detail',
                          arguments: bindingController
                              .bindingList[bindingIndex].elderlyId)),
                  ProfileTileWidget(
                      icon: Icons.medical_services,
                      title: 'Medical Record',
                      onTap: () => Get.toNamed('medical_record_list')),
                  ProfileTileWidget(
                      icon: Icons.alarm,
                      title: 'Reminder',
                      onTap: () => Get.toNamed('caregiver_reminder_list',
                          arguments: bindingIndex)),
                  ProfileTileWidget(
                      icon: Icons.history,
                      title: 'Activity Logs',
                      onTap: () => Get.toNamed('elderly_activity_log',
                          arguments: bindingIndex)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
