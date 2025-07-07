import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:get/get.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../auth/models/user_model.dart';

class ElderlyManagementController extends GetxController {
  static ElderlyManagementController get instance => Get.find();

  Rx<UserModel> elderlyDetail = UserModel.empty().obs;
  final isLoading = false.obs();
  final int? bindingIndex;

  ElderlyManagementController({this.bindingIndex});

  @override
  void onInit() {
    super.onInit();
    if (bindingIndex != null) {
      fetchElderlyDetail(
          BindingController.instance.bindingList[bindingIndex!].elderlyId);
    }
  }

  Future<UserModel?> fetchElderlyDetail(String elderlyId) async {
    try {
      final elderlyDetail =
          await UserRepository.instance.fetchUserDetails(userId: elderlyId);
      this.elderlyDetail(elderlyDetail);
      return elderlyDetail;
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching elderly detail: $e');
    }
  }
}
