import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:get/get.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: contact.photo != null
              ? ClipOval(
                  child: Image.memory(
                    contact.photo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white),
                ),
        ),
        title: Text(
          contact.displayName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => Get.toNamed('/contact_details', arguments: contact),
      ),
    );
  }
}
