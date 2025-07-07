import 'package:elderly_community/features/contacts/controllers/contact_controller.dart';
import 'package:elderly_community/utils/helpers/network_manager.dart';
import 'package:get/get.dart';

import '../features/sos/controllers/sos_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(SOSController(), permanent: true);
    // Get.put(ContactController(), permanent: true);
  }
}
