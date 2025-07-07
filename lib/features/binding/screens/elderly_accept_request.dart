import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptBindingRequestModal extends StatelessWidget {
  const AcceptBindingRequestModal({
    super.key,
    required this.id,
    required this.caregiverId,
    required this.caregiverName,
  });

  final String id;
  final String caregiverId;
  final String caregiverName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BindingController());

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Binding Request"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text("A caregiver wants to connect with you."),
          SizedBox(height: 16),
          Text("Name: $caregiverName",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("ID: $caregiverId"),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => controller.rejectRequest(id),
          child: Text("Reject"),
        ),
        ElevatedButton(
          onPressed: () => controller.acceptRequest(id),
          child: Text("Accept"),
        ),
      ],
    );
  }
}
