import 'package:elderly_community/features/user_management/controllers/user_management_controller.dart';
import 'package:elderly_community/features/user_management/screens/widgets/user_tile.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserManagementController controller =
        Get.put(UserManagementController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text("User Management"),
          actions: [
            IconButton(
                onPressed: () => Get.toNamed('admin_pending_user_list'),
                icon: Icon(Icons.pending))
          ],
        ),
      ),
      body: Column(
        children: [
          /// Search Bar with Filter Icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    focusNode: controller.searchFocusNode,
                    onChanged: (query) => controller.searchUsers(query),
                    onSubmitted: (query) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (role) {
                    FocusScope.of(context).unfocus();
                    controller.filterByRole(role);
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem(controller, '', "All Roles"),
                    _buildMenuItem(controller, 'Admin', "Admin"),
                    _buildMenuItem(controller, 'Caregiver', "Caregiver"),
                    _buildMenuItem(controller, 'Elderly', "Elderly"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// User List
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.filteredUserList.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUserList[index];

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
                    isRejected: user.role == "event organiser"
                        ? user.organisationStatus ==
                            OrganisationAccountStatus.rejected.name
                        : null,
                    onApprove: () {
                      if (user.role == "event organiser") {
                        Get.toNamed('/organiser_approval', arguments: user);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),

      /// Floating Action Button for Adding Users
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _showRoleSelectionDialog(context),
        backgroundColor: ECColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      UserManagementController controller, String role, String label) {
    return PopupMenuItem(
      value: role,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (controller.selectedRole.value == role)
            const Icon(Icons.check, color: ECColors.secondary),
        ],
      ),
    );
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Role"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.elderly),
                title: Text("Elderly"),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/user_form', arguments: {'role': 'elderly'});
                },
              ),
              ListTile(
                leading: Icon(Icons.handshake),
                title: Text("Caregiver"),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/user_form', arguments: {'role': 'caregiver'});
                },
              ),
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text("Admin"),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/user_form', arguments: {'role': 'admin'});
                },
              ),
              ListTile(
                leading: Icon(Icons.business),
                title: Text("Event Organiser"),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/organiser_form');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
