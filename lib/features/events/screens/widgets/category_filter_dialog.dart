import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../controllers/participant_event_controller.dart';

class CategoryFilterDialog extends StatelessWidget {
  final ParticipantEventController controller;

  const CategoryFilterDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: controller.eventCategories.map((category) {
                    bool isSelected =
                        controller.selectedCategories.contains(category.id);
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          controller.selectedCategories.remove(category.id!);
                        } else {
                          controller.selectedCategories.add(category.id!);
                        }
                        controller.applyFilters();
                      },
                      child: Chip(
                        label: Text(category.categoryName),
                        backgroundColor: isSelected
                            ? ECColors.buttonPrimary
                            : Colors.grey[300],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
          SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.selectedCategories.clear();
                  controller.applyFilters();
                  Navigator.pop(context);
                },
                child: Text("Clear All"),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.applyFilters();
                  Navigator.pop(context);
                },
                child: Text("Apply Filters"),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
