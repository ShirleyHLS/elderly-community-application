import 'package:elderly_community/common/curved_app_bar.dart';
import 'package:elderly_community/common/quick_button.dart';
import 'package:elderly_community/features/contacts/controllers/contact_controller.dart';
import 'package:elderly_community/features/contacts/controllers/contact_details_controller.dart';
import 'package:elderly_community/features/contacts/models/contact_model.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import 'widgets/call_log_item.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({
    super.key,
    required this.contact,
  });

  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
    final ContactController controller = ContactController.instance;
    
    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          actions: [
            TextButton(
              onPressed: () {},
              child:
              Text('Edit', style: Theme
                  .of(context)
                  .textTheme
                  .titleSmall),
            )
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Column(
            children: [

              /// Contact details
              CircleAvatar(
                radius: 50,
                backgroundImage: contact.profilePicture.isNotEmpty
                    ? NetworkImage(contact.profilePicture)
                    : null,
                backgroundColor: contact.profilePicture.isNotEmpty
                    ? null : Colors.grey,
                child: contact.profilePicture.isNotEmpty
                    ? null
                    : Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(height: ECSizes.spaceBtwItems),
              Text(
                contact.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineMedium,
              ),
              SizedBox(height: ECSizes.sm),
              Text(
                '+${contact.phoneNumber}',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge,
              ),
              SizedBox(height: ECSizes.spaceBtwItems),

              /// Call & Message Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.callNumber(contact.phoneNumber),
                    style:
                    Theme
                        .of(context)
                        .elevatedButtonTheme
                        .style
                        ?.copyWith(
                      backgroundColor:
                      WidgetStateProperty.all(Colors.green),
                      side: WidgetStatePropertyAll(
                          BorderSide(color: Colors.green)),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12)),
                    ),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("Call",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(width: ECSizes.spaceBtwItems),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Message functionality
                    },
                    style: Theme
                        .of(context)
                        .elevatedButtonTheme
                        .style
                        ?.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      side: WidgetStatePropertyAll(
                          BorderSide(color: Colors.blue)),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12)),
                    ),
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: const Text("Message",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),

              /// Divider
              SizedBox(height: ECSizes.spaceBtwItems),
              Divider(),
              SizedBox(height: ECSizes.spaceBtwItems),

              /// Call logs headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Call logs",
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall),
                  TextButton(
                    onPressed: () {
                      // Navigate to full call log page
                    },
                    child: Text(
                      "See more",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: ECColors.buttonPrimary),
                    ),
                  ),
                ],
              ),

              /// Call log list
              Expanded(
                child: ListView(
                  children: const [
                    CallLogItem(
                      date: "01/12/2024 5:00am",
                      status: "Missed",
                    ),
                    CallLogItem(
                      date: "01/12/2024 5:00am",
                      status: "Answered",
                    ),
                    CallLogItem(
                      date: "01/12/2024 5:00am",
                      status: "Answered",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
