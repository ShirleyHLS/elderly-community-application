import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/profile_tile_widget.dart';

class AdminProfileTiles extends StatelessWidget {
  const AdminProfileTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ProfileTileWidget(
            icon: Icons.edit,
            title: 'Profile',
            onTap: () => Get.toNamed('profile_detail')),
      ],
    );
  }
}
