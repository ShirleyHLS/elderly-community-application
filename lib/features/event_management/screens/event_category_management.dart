import 'package:elderly_community/features/event_management/controllers/event_category_management_controller.dart';
import 'package:elderly_community/features/event_management/screens/widgets/category_modal.dart';
import 'package:elderly_community/features/event_management/screens/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/shimmer_loading.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class EventCategoryManagementScreen extends StatelessWidget {
  const EventCategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventCategoryManagementController());

    controller.fetchEventCatogories();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Category Management"),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: ECSizes.sm),
            itemCount: 6, // Display 6 shimmer items
            itemBuilder: (context, index) => const ShimmerLoading(),
          );
        }
        if (controller.eventCategoryList.isEmpty) {
          return const Center(child: Text('No categories available'));
        }

        return ListView.builder(
          itemCount: controller.eventCategoryList.length,
          itemBuilder: (context, index) {
            final category = controller.eventCategoryList[index];

            return CategoryTile(
              name: category.categoryName,
              status: category.status,
              onEdit: () => showCategoryModal(context, category: category),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: ECColors.primary,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        onPressed: () => showCategoryModal(context),
      ),
    );
  }
}
