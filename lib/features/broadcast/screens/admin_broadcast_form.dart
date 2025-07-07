import 'package:elderly_community/features/broadcast/controllers/admin_broadcast_controller.dart';
import 'package:elderly_community/features/broadcast/models/broadcast_model.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/input_field_widget.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';

class AdminBroadcastFormScreen extends StatelessWidget {
  const AdminBroadcastFormScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = AdminBroadcastController.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clearForm();
    });


    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('New Broadcast Message'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: controller.broadcastFormKey,
                  child: Column(
                    children: [
                      InputFieldWidget(
                        icon: Icons.title,
                        label: 'Notice Title',
                        child: TextFormField(
                          controller: controller.titleController,
                          validator: (value) => ECValidator.validateEmptyText(
                              'Notice Title', value),
                          decoration: InputDecoration(
                            hintText: 'Enter Notice Title',
                          ),
                        ),
                      ),
                      InputFieldWidget(
                        icon: Icons.message,
                        label: 'Message',
                        child: TextFormField(
                          maxLines: 5,
                          controller: controller.messageController,
                          validator: (value) =>
                              ECValidator.validateEmptyText('Message', value),
                          decoration: InputDecoration(
                            hintText: 'Enter Message',
                          ),
                        ),
                      ),
                      InputFieldWidget(
                        icon: Icons.call_received,
                        label: 'Recipients',
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: Role.values.map((role) {
                            return Obx(() => FilterChip(
                                  label: Text(
                                    role.name,
                                  ),
                                  selected: controller.selectedRoles
                                      .contains(role.name),
                                  onSelected: (bool selected) {
                                    selected
                                        ? controller.selectedRoles
                                            .add(role.name)
                                        : controller.selectedRoles
                                            .remove(role.name);
                                  },
                                  checkmarkColor: Colors.black,
                                  selectedColor: ECColors.primary,
                                  backgroundColor: Colors.grey[100],
                                ));
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: controller.sendBroadcast, child: Text("Send")),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
