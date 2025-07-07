import 'package:elderly_community/common/curved_app_bar.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../../../utils/constants/sizes.dart';
import '../controller/contact_controller.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({
    super.key,
    required this.contact,
  });

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final ContactController controller = ContactController.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Get.defaultDialog(
                  title: "Delete Confirmation",
                  middleText:
                  "Are you sure you want to delete this contact?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  confirmTextColor: Colors.white,
                  cancelTextColor: Colors.black,
                  buttonColor: ECColors.error,
                  onConfirm: () {
                    Get.back();
                    controller.deleteContact(contact!.id);
                  },
                );
              },
              icon:Icon(Icons.delete,),
            ),
            IconButton(
              onPressed: () async {
                final result =
                    await Get.toNamed('/contact_form', arguments: contact);
                if (result == true) {
                  controller.fetchContacts(); // Fetch updated contacts
                }
              },
              icon:Icon(Icons.edit),
            )
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Obx((){
              final updatedContact = controller.contacts
                  .firstWhere((c) => c.id == contact.id, orElse: () => contact);
              if (updatedContact == null){
                return Center(child: Text('Contact not found.'));
              }
              return Column(
                children: [
                  /// Contact details
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: updatedContact.photo != null
                        ? MemoryImage(updatedContact.photo!)
                        : null,
                    backgroundColor:
                        updatedContact.photo != null ? null : Colors.grey,
                    child: updatedContact.photo != null
                        ? null
                        : Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: ECSizes.spaceBtwItems),
                  Text(
                    updatedContact.displayName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ECSizes.sm),
                  Text(
                    updatedContact.phones.first.number.startsWith('+6')
                        ? '${updatedContact.phones.first.number}'
                        : '+6${updatedContact.phones.first.number}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: ECSizes.spaceBtwItems),

                  /// Call & Message Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => controller
                            .callNumber(updatedContact.phones.first.number),
                        style: Theme.of(context)
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
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      const SizedBox(width: ECSizes.spaceBtwItems),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.openWhatsapp(contact.phones.first.number);
                        },
                        style: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.copyWith(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.blue),
                              side: WidgetStatePropertyAll(
                                  BorderSide(color: Colors.blue)),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12)),
                            ),
                        icon: const Icon(Icons.email, color: Colors.white),
                        label: const Text("Message",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),

                  /// Divider
                  SizedBox(height: ECSizes.spaceBtwItems),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
