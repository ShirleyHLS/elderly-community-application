import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../profile/controllers/user_controller.dart';

class GreetingTextWidget extends StatelessWidget {
  const GreetingTextWidget({
    super.key,
    required this.controller,
  });

  final UserController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good day!',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Obx(() => Text(
          controller.user.value.name.isNotEmpty
              ? controller.user.value.name
              : "Loading...",
          style: Theme.of(context).textTheme.headlineSmall,
        )),
      ],
    );
  }
}
