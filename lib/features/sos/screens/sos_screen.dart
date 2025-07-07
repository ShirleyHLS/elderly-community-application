import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elderly_community/utils/constants/colors.dart';

import '../../../common/curved_app_bar.dart';
import '../controllers/sos_controller.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SOSController controller = Get.find<SOSController>();

    return Obx(
      () => Scaffold(
        backgroundColor:
            controller.isActivated.value ? Colors.red.shade100 : Colors.white,
        appBar: CustomCurvedAppBar(
          child: AppBar(
            title: const Text("Emergency"),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTapDown: (_) => controller.startPressTimer(),
                onTapUp: (_) => controller.cancelPressTimer(),
                onTapCancel: controller.cancelPressTimer,
                child: Obx(() => Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isActivated.value
                            ? Colors.grey[100]
                            : ECColors.error,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade300,
                            blurRadius: 50,
                            spreadRadius: 20,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          controller.isActivated.value ? "I'm Safe" : "SOS",
                          style: TextStyle(
                            color: controller.isActivated.value ? ECColors.error : Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  !controller.isActivated.value
                      ? "Press and hold for 5 seconds to activate the SOS feature. Once activated, your current location will be shared with your emergency contact."
                      : "Press and hold for 5 seconds to deactivate SOS.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ECColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
