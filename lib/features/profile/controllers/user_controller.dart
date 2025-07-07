import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    super.onInit();
    // fetchUserRecord();
  }

  Future<UserModel?> fetchUserRecord() async {
    try {
      print('👀 Fetching user record...');
      final user = await userRepository.fetchUserDetails();
      if (user.name.isNotEmpty) {
        this.user(user); // Ensure the observable updates
        return user;
      } else {
        print('⚠️ User name is empty!');
      }
    } catch (e) {
      print('❌ Error fetching user: $e');
      user(UserModel.empty());
    }
  }


}
