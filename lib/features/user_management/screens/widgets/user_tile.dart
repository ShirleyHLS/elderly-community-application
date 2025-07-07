import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/constants/colors.dart';

class UserTile extends StatelessWidget {
  final String profileUrl;
  final String name;
  final String role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onApprove;
  final bool? isPending;
  final bool? isRejected;

  const UserTile({
    super.key,
    required this.profileUrl,
    required this.name,
    required this.role,
    required this.onEdit,
    required this.onDelete,
    this.onApprove,
    this.isPending,
    this.isRejected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 15.0, right: 5.0),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: profileUrl.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profileUrl,
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
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(role),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending == true)
              IconButton(
                onPressed: onApprove,
                icon: Icon(
                  Icons.pending,
                  color: Colors.orange,
                ),
              ),
            if (isRejected == true)
              IconButton(
                onPressed: onApprove,
                icon: Icon(
                  Icons.cancel,
                  color: Colors.orange,
                ),
              ),
            if (isPending != true && isRejected != true) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: ECColors.buttonPrimary),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete Confirmation",
                    middleText: "Are you sure you want to delete this user?",
                    textConfirm: "Yes",
                    textCancel: "No",
                    confirmTextColor: Colors.white,
                    cancelTextColor: Colors.black,
                    buttonColor: ECColors.error,
                    onConfirm: onDelete,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
