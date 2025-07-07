import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/profile_tile_widget.dart';

class CaregiverProfileTiles extends StatelessWidget {
  const CaregiverProfileTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ProfileTileWidget(
            icon: Icons.link,
            title: 'Binding',
            onTap: () => Get.toNamed('binding')),
        ProfileTileWidget(icon: Icons.edit, title: 'Profile', onTap: () => Get.toNamed('profile_detail')),
      ],
    );
  }
}
