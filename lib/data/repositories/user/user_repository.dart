import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/authentication/authentication_repository.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/exceptions/firebase_exceptions.dart';
import 'package:elderly_community/utils/exceptions/format_exceptions.dart';
import 'package:elderly_community/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data to Firebase
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to fetch user details based on uid
  Future<UserModel> fetchUserDetails({String? userId}) async {
    try {
      final String uid =
          userId ?? AuthenticationRepository.instance.authUser?.uid ?? '';

      final documentSnapshot = await _db.collection("Users").doc(uid).get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update user data in Firestore
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection("Users")
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update any field in specific user collection in Firestore
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to remove user data from Firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload image to Firestore
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<String>> uploadFile(List<File> files) async {
    try {
      List<String> uploadedFileUrls = [];

      for (var file in files) {
        String fileName = file.path.split('/').last;
        final ref = FirebaseStorage.instance
            .ref("Business Certificates")
            .child(fileName);
        await ref.putFile(file);
        uploadedFileUrls.add(await ref.getDownloadURL());
      }

      return uploadedFileUrls;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to fetch user details based on uid
  Future<List<UserModel>> fetchUserList() async {
    try {
      final snapshot = await _db.collection("Users").orderBy('name').get();
      return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<UserModel>> fetchPendingUserList() async {
    try {
      final snapshot = await _db
          .collection("Users")
          .where('organisationStatus',
              isEqualTo: OrganisationAccountStatus.pending.name)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> updateOtherUserDetail(
      String user_id, Map<String, dynamic> json) async {
    try {
      await _db.collection("Users").doc(user_id).update(json);
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<String?> getOrganizationName(String organizationId) async {
    try {
      final userDoc = await _db
          .collection("Users")
          .where("id", isEqualTo: organizationId)
          .where("role", isEqualTo: "event organiser")
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()["name"];
      }
      return null;
    } catch (e) {
      return null; // Return null if not found
    }
  }

  Future<String?> getUserName(String id) async {
    try {
      final userDoc = await _db
          .collection("Users")
          .where("id", isEqualTo: id)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()["name"];
      }
      return null;
    } catch (e) {
      return null; // Return null if not found
    }
  }

  Future<String?> getUserDeviceToken(String id) async {
    try {
      final userDoc = await _db
          .collection("Users")
          .where("id", isEqualTo: id)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()["deviceToken"];
      }
      return null;
    } catch (e) {
      return null; // Return null if not found
    }
  }

  Future<UserModel?> checkIfElderlyExist(String phone) async {
    try {
      final userDoc = await _db
          .collection("Users")
          .where("phoneNumber", isEqualTo: phone)
          .where("role", isEqualTo: "elderly")
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return UserModel.fromSnapshot(userDoc.docs.first);
      }
      return null;
    } catch (e) {
      return null; // Return null if not found
    }
  }

  Future<bool> checkIfPhoneNumberExist(String phone) async {
    try {
      final userDoc = await _db
          .collection("Users")
          .where("phoneNumber", isEqualTo: phone)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchUserStatistics() async {
    try {
      final userSnapshot = await _db.collection('Users').get();

      int totalElderly = 0;
      int totalCaregivers = 0;
      int totalOrganisers = 0;
      int totalAdmins = 0;

      for (var doc in userSnapshot.docs) {
        String role = doc.data()['role'] ?? '';

        switch (role) {
          case 'elderly':
            totalElderly++;
            break;
          case 'caregiver':
            totalCaregivers++;
            break;
          case 'event organiser':
            totalOrganisers++;
            break;
          case 'admin':
            totalAdmins++;
            break;
          default:
            break;
        }
      }

      return {
        "totalElderly": totalElderly,
        "totalCaregivers": totalCaregivers,
        "totalOrganisers": totalOrganisers,
        "totalAdmins": totalAdmins,
      };
    } catch (e) {
      throw Exception("Failed to fetch statistics: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserBasedOnRole(
      List<String> roles) async {
    try {
      final userDoc =
          await _db.collection("Users").where("role", whereIn: roles).get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.map((doc) {
          return {
            "id": doc.id, // User ID
            "deviceToken": doc.data()["deviceToken"], // Device Token
          };
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
