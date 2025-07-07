import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/features/contacts/models/contact_model.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:get/get.dart';

import '../../../data/repositories/contact/contact_repository.dart';
import '../../../data/repositories/user/user_repository.dart';

class ContactController extends GetxController {
  static ContactController get instance => Get.find();

  final isLoading = false.obs;
  final RxList<ContactModel> contactList = <ContactModel>[].obs;

  final contactRepository = Get.put(ContactRepository());

  @override
  void onInit() {
    super.onInit();
    print("✅ ContactController initialized!");
    print("Current contactList length: ${contactList.length}");
    if (contactList.isEmpty) {
      print("Calling fetchContacts()...");
      fetchContacts(); // Fetch only if empty
    }else {
      print("Skipping fetchContacts()");
    }
  }

  Future<void> fetchContacts({bool forceRefresh = false}) async {
    if (!forceRefresh && contactList.isNotEmpty) return; // Skip if cached

    print('fetching😶‍🌫️😶‍🌫️😶‍🌫️');
    try {
      isLoading.value = true;
      final contacts = await contactRepository.fetchContact();
      contactList.assignAll(contacts);
      print("Fetched contacts: $contacts");
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  callNumber(String number) async{
    // await DirectCallPlus.makeCall(number);
  }
}
