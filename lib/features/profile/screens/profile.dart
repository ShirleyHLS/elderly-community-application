import 'package:elderly_community/common/curved_edges.dart';
import 'package:elderly_community/data/repositories/authentication/authentication_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/features/profile/screens/widgets/caregiver_profile_tile.dart';
import 'package:elderly_community/features/profile/screens/widgets/elderly_profile_tile.dart';
import 'package:elderly_community/features/profile/screens/widgets/admin_profile_tile.dart';
import 'package:elderly_community/features/profile/screens/widgets/organiser_profile_tile.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/profile_tile_widget.dart';
import '../../../utils/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void logout() {
    AuthenticationRepository.instance.logOut();
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomCurvedEdgeWidget(
            child: Container(
              height: 200,
              width: double.infinity,
              color: ECColors.primary,
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: controller
                              .user.value.profilePicture.isNotEmpty
                          ? NetworkImage(controller.user.value.profilePicture)
                          : null,
                      child: controller.user.value.profilePicture.isNotEmpty
                          ? null
                          : Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    SizedBox(height: ECSizes.spaceBtwItems),
                    Text(
                      controller.user.value.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(controller.user.value.email,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ECSizes.spaceBtwItems),
              child: _getRoleBasedTiles(controller.user.value.role),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getRoleBasedTiles(String role) {
    switch (role) {
      case "elderly":
        return const ElderlyProfileTiles();
      case "caregiver":
        return const CaregiverProfileTiles();
      case "admin":
        return const AdminProfileTiles();
      case "event organiser":
        return const OrganiserProfileTiles();
      default:
        return Center(child: Text("Invalid Role"));
    }
  }
}
