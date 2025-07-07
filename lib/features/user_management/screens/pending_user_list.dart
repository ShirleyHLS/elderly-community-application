import 'package:elderly_community/features/user_management/controllers/user_management_controller.dart';
import 'package:elderly_community/features/user_management/screens/widgets/user_tile.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';

class PendingUserListScreen extends StatelessWidget {
  const PendingUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserManagementController controller =
        UserManagementController.instance;

    controller.fetchPendingUsers();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Pending Users"),
        ),
      ),
      body: Column(
        children: [
          /// User List
          Expanded(
            child: Obx(() {
              if (controller.pendingUserList.isEmpty) {
                return Center(
                  child: Text('No pending users found.'),
                );
              }
              return ListView.builder(
                itemCount: controller.pendingUserList.length,
                itemBuilder: (context, index) {
                  final user = controller.pendingUserList[index];

                  return UserTile(
                    profileUrl: user.profilePicture,
                    name: user.name,
                    role: user.role,
                    onEdit: () {
                      if (user.role != "event organiser") {
                        Get.toNamed('/user_form', arguments: {'user': user});
                      } else {
                        Get.toNamed('/organiser_form', arguments: user);
                      }
                    },
                    onDelete: () {
                      controller.deleteUser(user.id);
                    },
                    isPending: user.role == "event organiser"
                        ? user.organisationStatus ==
                            OrganisationAccountStatus.pending.name
                        : null,
                    onApprove: () {
                      if (user.role == "event organiser") {
                        Get.toNamed('/organiser_approval', arguments: user);
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
