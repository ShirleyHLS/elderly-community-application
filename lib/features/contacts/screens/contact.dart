import 'package:elderly_community/features/contacts/controllers/contact_controller.dart';
import 'package:elderly_community/features/contacts/screens/widgets/contact_item.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/curved_app_bar.dart';
import 'widgets/shimmer_loading_item.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactController controller = Get.put(ContactController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Contact"),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: ECSizes.sm),
            itemCount: 6, // Display 6 shimmer items
            itemBuilder: (context, index) => const ShimmerLoadingItem(),
          );
        }
        if (controller.contactList.isEmpty) {
          return Center(child: Text("No contacts found"));
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: ECSizes.sm),
          itemCount: controller.contactList.length,
          itemBuilder: (context, index) {
            final contact = controller.contactList[index];
            return ContactItem(contact: contact);
          },
        );
      }),

      /// Add contact button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed('/add_new_contact'),
        backgroundColor: ECColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
