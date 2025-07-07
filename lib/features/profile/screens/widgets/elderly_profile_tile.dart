import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/profile_tile_widget.dart';
import '../../../binding/controllers/binding_controller.dart';

class ElderlyProfileTiles extends StatelessWidget {
  const ElderlyProfileTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final bindingController = BindingController.instance;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Obx(
          () => ProfileTileWidget(
            icon: Icons.link,
            title: 'Binding',
            onTap: () => Get.toNamed('binding'),
            trailing: bindingController.checkPendingRequests()
                ? Icon(Icons.info_outline, color: Colors.red)
                : null, // Default to arrow icon
          ),
        ),
        // ProfileTileWidget(
        //     icon: Icons.sos, title: 'Emergency Contact', onTap: () {}),
        ProfileTileWidget(
            icon: Icons.medical_services,
            title: 'Medical Record',
            onTap: () => Get.toNamed('medical_record_list')),
        ProfileTileWidget(
            icon: Icons.edit,
            title: 'Profile',
            onTap: () => Get.toNamed('profile_detail')),
      ],
    );
  }
}
