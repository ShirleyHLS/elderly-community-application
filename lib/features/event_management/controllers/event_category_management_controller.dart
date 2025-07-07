import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/repositories/event_category/event_category_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../../events/models/event_category_model.dart';

class EventCategoryManagementController extends GetxController {
  static EventCategoryManagementController get instance => Get.find();

  final eventCategoryRepository = Get.put(EventCategoryRepository());
  final RxList<EventCategoryModel> eventCategoryList =
      <EventCategoryModel>[].obs;
  final isLoading = false.obs;

  /// form
  final categoryName = TextEditingController();
  Rx<bool> status = false.obs;

  setCategory(EventCategoryModel category) {
    categoryName.text = category.categoryName;
    status.value = category.status;
  }

  clearFields() {
    categoryName.text = '';
    status.value = false;
  }

  Future<void> fetchEventCatogories() async {
    try {
      isLoading.value = true;
      final categories = await eventCategoryRepository.fetchEventCategory();
      eventCategoryList.assignAll(categories!);
      print(categories);
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching event categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> fetchCategoryName(List<String> categoryIds) async {
    try {
      final categoryRepository = EventCategoryRepository.instance;
      final List<String> categories =
          await categoryRepository.fetchEventCategoryByIds(categoryIds);
      return categories;
    } catch (e) {
      return ["Error loading category"];
    }
  }

  void addCategory() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection.');
        return;
      }

      if (categoryName.text.isEmpty) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'Category name is required.');
        return;
      }

      final newCategory = EventCategoryModel(
        categoryName: categoryName.text.trim(),
        status: status.value,
      );

      await eventCategoryRepository.addCategory(newCategory);
      fetchEventCatogories();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Category added successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void editCategory(String category_id) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection.');
        return;
      }

      if (categoryName.text.isEmpty) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'Category name is required.');
        return;
      }

      final updatedCategory = EventCategoryModel(
        id: category_id,
        categoryName: categoryName.text.trim(),
        status: status.value,
      );

      await eventCategoryRepository.updateCategory(updatedCategory);
      fetchEventCatogories();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Category edited successfully!");
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
