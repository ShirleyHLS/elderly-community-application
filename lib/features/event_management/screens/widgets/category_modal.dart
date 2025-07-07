import 'package:elderly_community/features/events/models/event_category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_category_management_controller.dart';

void showCategoryModal(BuildContext context, {EventCategoryModel? category}) {
  final controller = EventCategoryManagementController.instance;

  if (category != null) {
    controller.setCategory(category);
  } else {
    controller.clearFields();
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(category != null ? "Edit Category" : "Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            TextField(
              controller: controller.categoryName,
              decoration: const InputDecoration(
                labelText: "Category Name",
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Status"),
                SizedBox(width: 5),
                Obx(
                  () => Switch(
                    value: controller.status.value,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      controller.status.value = !controller.status.value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (category != null) {
                controller.editCategory(category.id.toString());
              } else {
                controller.addCategory();
              }
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}
