import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/features/contacts/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({super.key, required this.contact});

  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: contact.profilePicture.isNotEmpty
              ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: contact.profilePicture,
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          )
              : const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Text(
          contact.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => Get.toNamed('/contact_details', arguments: contact),
      ),
    );
  }
}