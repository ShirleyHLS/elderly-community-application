import 'package:elderly_community/features/new_contacts/controller/contact_controller.dart';
import 'package:elderly_community/features/new_contacts/screens/widgets/contact_item.dart';
import 'package:elderly_community/features/new_contacts/screens/widgets/shimmer_loading_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/curved_app_bar.dart';
import '../../../data/services/contact/contact_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactController());

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
        if (controller.permissionDenied.value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "To use this feature, please go to setting and grant the app access to your contacts.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ECSizes.spaceBtwInputFields),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Open Settings")),
              )
            ],
          );
        }
        if (controller.contacts.isEmpty) {
          return Center(
            child: Text(
              "No contacts found.",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.contacts.length,
          itemBuilder: (context, index) {
            final contact = controller.contacts[index];
            return ContactItem(contact: contact);
          },
        );
      }),
      floatingActionButton: Obx(() {
        if (!controller.permissionDenied.value) {
          return FloatingActionButton(
            backgroundColor: ECColors.primary,
            shape: CircleBorder(),
            child: Icon(Icons.add, color: Colors.black),
            onPressed: () => Get.toNamed('contact_form'),
          );
        }
        return SizedBox.shrink();
      }),
    );
  }
}
