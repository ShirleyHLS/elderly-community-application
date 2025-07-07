import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendBindingRequestModal extends StatelessWidget {
  SendBindingRequestModal({
    super.key,
  });

  final controller = BindingController.instance;

  @override
  Widget build(BuildContext context) {
    controller.phoneController.clear();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Enter Elderly's Phone Number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Phone Number",
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          SizedBox(height: 50),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.sendBindingRequest(),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator()
                      : Text("Send Request"),
                ),
              )),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
