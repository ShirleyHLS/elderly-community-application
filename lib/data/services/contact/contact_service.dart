import 'dart:io';

import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  static Future<List<Contact>> initContact() async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
    }
    return [];
  }

  /// Fetch all contacts with properties and photos.
  static Future<List<Contact>> getAllContacts() async {
    // if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
    // }
    // return [];
  }

  /// Fetch a single contact by ID.
  static Future<Contact?> getContactById(String id) async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContact(id,
          withProperties: true, withPhoto: true, withAccounts: true);
    }
    return null;
  }

  static Future<void> addNewContact(
      String firstName, String phoneNumber, File? imageFile) async {
    final newContact = Contact()
      ..name.first = firstName
      ..phones = [Phone(phoneNumber)];
    if (imageFile != null) {
      newContact.photo = await imageFile.readAsBytes();
    }
    await newContact.insert();
    ECLoaders.customToast(message: 'New contact added successfully!');
  }

  static Future<void> updateContact(
      String id, String newFirstName, String newPhoneNumber, File? imageFile) async {
    final contact = await getContactById(id);
    if (contact != null) {
      contact.name.first = newFirstName;
      contact.phones = [Phone(newPhoneNumber)];
      if (imageFile != null) {
        contact.photo = await imageFile.readAsBytes();
      }
      await contact.update();
      ECLoaders.customToast(message: 'Contact updated successfully!');
    }
  }

  static Future<void> deleteContact(String id) async {
    final contact = await getContactById(id);
    if (contact != null) {
      await contact.delete();
      ECLoaders.customToast(message: 'Contact deleted successfully!');
    }
  }

  static Future<void> openContactInApp(String id) async {
    await FlutterContacts.openExternalView(id);
  }

  static Future<void> editContactInApp(String id) async {
    await FlutterContacts.openExternalEdit(id);
  }

  static void listenToContactChanges() {
    FlutterContacts.addListener(() => print('Contact DB changed'));
  }
}
